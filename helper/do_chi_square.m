% chi-square

clear
clc

allData = genAllData_rabbit;

two_pair = allData(end).two_pair;
possible_pairs = nchoosek([1,2,3,4,5], 2);
% Set the original significance level (usually 0.05)
alpha = 0.05;
alpha_corrected = alpha / 10;  % Adjusted significance level

% fields to go through
loc = {'bs', 'ctrl'};
nf = {'F2', 'F3'};
nb = {'B3', 'B2', 'B0'};

[loc_grid, nf_grid, nb_grid] = ndgrid(loc, nf, nb);
fields = strcat(loc_grid(:), nf_grid(:), nb_grid(:));

for field = fields.'
    max_chi_square = -Inf;
    most_significant_pair = '';

    chi_raw = two_pair.(field{1});
    total_occurence = sum(chi_raw, "all");  % Total sample size N for each condition
    observed_occurence = sum(chi_raw, 1);
    expected_occurence = ones(1, length(observed_occurence)) * round(total_occurence / 10);    

    % Perform chi-square test for each of the 10 pairs
    chi_square_values = ((observed_occurence - expected_occurence).^2) ./ expected_occurence;
    
    % Degrees of freedom for each pair
    df = 1;
    
    % Calculate p-values for each pair using chi-square cumulative distribution function
    p_values = 1 - chi2cdf(chi_square_values, df);
    
    % Sort chi-square values in descending order and get the indices of the top 3 pairs
    [sorted_chi_square_values, sorted_indices] = sort(chi_square_values, 'descend');
    
    % Get the top 3 most significant pairs
    top_3_chi_square = sorted_chi_square_values(1:3);
    top_3_p_values = p_values(sorted_indices(1:3));
    top_3_indices = sorted_indices(1:3);
    
    % Display the top 3 most significant pairs for this condition
    fprintf('For condition %s, the top 3 most significant pairs are:\n', field{1});
    for i = 1:3
        pair = possible_pairs(top_3_indices(i), :);  % Get the pair corresponding to the index
        % Sample size N for the specific pair
        N = observed_occurence(top_3_indices(i));
        
        % Skip pairs with zero observed occurrences
        if N == 0
            fprintf('  Pair [%d, %d]: Skipped due to N=0 (no occurrences)\n', pair(1), pair(2));
            continue;
        end
        
        % Apply Bonferroni correction
        if top_3_p_values(i) < alpha_corrected
            fprintf('  Pair [%d, %d]: Chi-square = %.2f, df = %d, N = %d, p-value = %.4f (significant after correction)\n', ...
                pair(1), pair(2), top_3_chi_square(i), df, N, top_3_p_values(i));
        else
            fprintf('  Pair [%d, %d]: Chi-square = %.2f, df = %d, N = %d, p-value = %.4f (not significant after correction)\n', ...
                pair(1), pair(2), top_3_chi_square(i), df, N, top_3_p_values(i));
        end
    end
end
