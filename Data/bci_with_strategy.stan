
data {
  int<lower=1> N;                  // Number of trials
  array[N] real xA;                // Auditory sensory observations
  array[N] real xV;                // Visual sensory observations
  array[N] real sA;                // Auditory real stimuli
  array[N] real sV;                // Visual real stimuli
  array[N] real loc;               // Stimulus location: Control, Blind Spot
  int strat;                       // Strategy: 1 = model averaging, 2 = model selection, 3 = probablity matching
  array[N] int<lower=1, upper=4> y_obs;  // Subject-reported flash count
}

parameters {
  real<lower=0> sigmaA;            // Auditory noise standard deviation
  real<lower=0> sigmaV;            // Visual noise standard deviation
  real gammaA;                     // Auditory bias term
  real gammaV;                     // Visual bias term
  real muP;                        // Prior mean for sensory locations
  real<lower=0> sigmaP;            // Prior standard deviation
  real<lower=0, upper=1> p_common; // Prior probability of common cause
}

transformed parameters {
  array[N] real log_p_common;
  array[N] real log_p_independent;
  array[N] real p_common_post;
  array[N] real sV_hat;
  array[N] real sA_hat;
  
  for (n in 1:N) {
    real log_lik_common = normal_lpdf(xA[n] | gammaA + muP, sqrt(sigmaA^2 + sigmaP^2)) 
                        + normal_lpdf(xV[n] | gammaV + muP, sqrt(sigmaV^2 + sigmaP^2));
    
    real log_lik_independent = normal_lpdf(xA[n] | gammaA + muP, sqrt(sigmaA^2 + sigmaP^2)) 
                             + normal_lpdf(xV[n] | gammaV + muP, sqrt(sigmaV^2 + sigmaP^2));
    
    log_p_common[n] = log(p_common) + log_lik_common;
    log_p_independent[n] = log1m(p_common) + log_lik_independent;
    
    p_common_post[n] = exp(log_p_common[n] - log_sum_exp(log_p_common[n], log_p_independent[n]));

    real sA_common = (xA[n]/sigmaA^2 + muP/sigmaP^2) / (1/sigmaA^2 + 1/sigmaP^2);
    real sV_common = (xV[n]/sigmaV^2 + muP/sigmaP^2) / (1/sigmaV^2 + 1/sigmaP^2);

    real sA_independent = (xA[n]/sigmaA^2 + muP/sigmaP^2) / (1/sigmaA^2 + 1/sigmaP^2);
    real sV_independent = (xV[n]/sigmaV^2 + muP/sigmaP^2) / (1/sigmaV^2 + 1/sigmaP^2);

    sA_hat[n] = p_common_post[n] * sA_common + (1 - p_common_post[n]) * sA_independent;
    sV_hat[n] = p_common_post[n] * sV_common + (1 - p_common_post[n]) * sV_independent;
  }
}

model {
  sigmaA ~ normal(0, 5);
  sigmaV ~ normal(0, 5);
  gammaA ~ normal(0, 5);
  gammaV ~ normal(0, 5);
  p_common ~ beta(1, 1); 

  for (n in 1:N) {
    target += log_sum_exp(log_p_common[n], log_p_independent[n]);
  }

  // Behavioral likelihood: compare predicted count to actual reported count
  for (n in 1:N) {
    target += (round(sV_hat[n]) == y_obs[n]) ? 0 : negative_infinity();
  }
}

generated quantities {
  array[N] int common_cause_decision;
  array[N] real p_common_sampled;
  array[N] int y_pred;

  for (n in 1:N) {    
    common_cause_decision[n] = p_common_post[n] > 0.5 ? 1 : 0;
    p_common_sampled[n] = uniform_rng(0, 1);

    y_pred[n] = max(1, min(4, round(sV_hat[n])));
  }
}

