%% init_sound


try
    PsychPortAudio('Stop', env.audio_handle, 1);
end

try
    PsychPortAudio('Stop', pahandle1, 1);
    Snd('Close', 1);
end


InitializePsychSound(3);
param.nchannels = 2;
param.startCue = 0;
param.repetitions = 1;
param.waitForDeviceStart = 1; 

env.audio_handle = PsychPortAudio('Open', [], 1, 1, [], param.nchannels, []);
s = PsychPortAudio('GetStatus', env.audio_handle);
env.sampleRate = s.SampleRate;

param.audioDelay = 0.05; %-0.105;

% Entire stimulus is 250 ms long
param.beep_nSamps = int64(env.sampleRate*(stim.duration + abs(param.audioDelay))); % in case of overflow
param.zero_beep_array = zeros(1, param.beep_nSamps);

param.beepDuration = 0.007; %s (7 ms)
param.beepInterval = 0.058; %s (58 ms)

% make beep
param.beep_array = MakeBeep(800, param.beepDuration, env.sampleRate);
[foo, param.beep_samps] = size(param.beep_array);

param.beepOneBalance = 0.5;
param.beepTwoBalance = 0.5;
param.beepThreeBalance = 0.5;

param.beepOneT = param.audioDelay; % onset at T=0
param.beepTwoT = param.beepOneT + param.beepDuration + param.beepInterval;
param.beepThreeT = param.beepTwoT + param.beepDuration + param.beepInterval;

param.beepOneSamps = int64(param.beepOneT * env.sampleRate); % in Hz
param.beepTwoSamps = int64(param.beepTwoT * env.sampleRate); % in Hz
param.beepThreeSamps = int64(param.beepThreeT * env.sampleRate); % in Hz

% start making beep arrays
param.one_beep_array = param.zero_beep_array;
param.one_beep_array(1, param.beepOneSamps:param.beepOneSamps + param.beep_samps - 1) = param.beep_array * 0.5;

% add in last beep
param.two_beep_array = param.one_beep_array;
param.two_beep_array(1, param.beepThreeSamps:param.beepThreeSamps + param.beep_samps - 1) = param.beep_array * 0.5;

% add in middle beep
param.three_beep_array = param.two_beep_array;
param.three_beep_array(1, param.beepTwoSamps:param.beepTwoSamps + param.beep_samps - 1) = param.beep_array * 0.5;

