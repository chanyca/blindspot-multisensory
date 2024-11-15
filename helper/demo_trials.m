%% Demo trials
% Visual flash detection - show ONLY flash
% Double flash - show flash AND beep

HideCursor;
showTrace = true;

%% Draw fixation
while ~KbCheck
    drawStim("fixation", window, stim, env);
    checkGaze;
    Screen('Flip', window);   
end
%% 1. show flash

WaitSecs(0.2); % so it doesn't return true immediately
while ~KbCheck
    line1 = 'For the following experiment,\n';
    line2 = 'you will see flash(es) like this.';
    drawStim([line1 line2], window, stim, env);
    checkGaze;
    Screen('Flip', window);    
end

WaitSecs(0.2);
while ~KbCheck
    drawStim("flash", window, stim, env);
    checkGaze;
    Screen('Flip', window);    
end
%% 2. show beep

drawStim('You will also hear beep(s) like this.', window, stim, env)
Screen('Flip', window);
WaitSecs(1);
KbWait;

PsychPortAudio('FillBuffer', env.audio_handle, [param.left_singleBeep_array; param.right_singleBeep_array]);
[~, StimulusOnsetTimePre, FlipTimestamp, ~, ~] = Screen('Flip', window);

t0 = StimulusOnsetTimePre + env.ifi;
WaitSecs(1);

audiostarttime = PsychPortAudio('Start', env.audio_handle, param.repetitions, t0, param.waitForDeviceStart);
WaitSecs(1);


%% 3. play beep that indicates question prompt

drawStim('The following tone indicates that it is time to respond', window, stim, env);
Screen('Flip', window);
KbWait;
WaitSecs(1);
Screen('Flip', window);
playAudio('resp', env);
WaitSecs(1);

%% 4. Demo trials
%% 3B2F

drawStim('Now point to where you see the flash(es) in the following trial.', window, stim, env);
Screen('Flip', window);
KbWait;

for iframe = 1:stim.fix_nFrames
    drawStim("fixation", window, stim, env);
    checkGaze;
    Screen('Flip', window);
end

PsychPortAudio('FillBuffer', env.audio_handle, [param.left_threeBeep_array; param.right_threeBeep_array]);

drawStim("fixation", window, stim, env)
[~, StimOnsetTimePre, FlipTimestamp, ~, ~] = Screen('Flip', window);

t0 = StimOnsetTimePre + env.ifi;

if contains(Answer.task, 'A')
    PsychPortAudio('Volume', env.audio_handle, 1);
    audiostarttime = PsychPortAudio('Start', env.audio_handle, param.repetitions, t0, param.waitForDeviceStart);
end

for iframe = 1:stim.nFrames % 200 ms / 12 frames
    if iframe == stim.onFrames(1)
        drawStim("fixation", window, stim, env);
        
        % flash
        centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter-deg.three, env.yCenter+deg.three);
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);


    elseif iframe == stim.onFrames(3)
        drawStim("fixation", window, stim, env);
        
        % flash
        centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter+deg.three, env.yCenter+deg.three);
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);

    else
        
        % fixation before flash
        drawStim("fixation", window, stim, env);
        checkGaze;
        Screen('Flip', window);
    end
end


for iframe = 1:stim.fix_nFrames
    drawStim("fixation", window, stim, env);
    checkGaze;
    Screen('Flip', window);
end


%% 2B2F

drawStim('Again, point to where you see the flash(es) in the following trial.', window, stim, env);
Screen('Flip', window);
KbWait;

for iframe = 1:stim.fix_nFrames
    drawStim("fixation", window, stim, env);
    checkGaze;
    Screen('Flip', window);
end

PsychPortAudio('FillBuffer', env.audio_handle, [param.left_twoBeep_array; param.right_twoBeep_array]);

drawStim("fixation", window, stim, env)
[~, StimOnsetTimePre, FlipTimestamp, ~, ~] = Screen('Flip', window);

t0 = StimOnsetTimePre + env.ifi;

if contains(Answer.task, 'A')
    PsychPortAudio('Volume', env.audio_handle, 1);
    audiostarttime = PsychPortAudio('Start', env.audio_handle, param.repetitions, t0, param.waitForDeviceStart);
end

for iframe = 1:stim.nFrames % 200 ms / 12 frames
    if iframe == stim.onFrames(1)
        drawStim("fixation", window, stim, env);
        
        % flash
        centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter-deg.three, env.yCenter+deg.three);
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);

    elseif iframe == stim.onFrames(3)
        drawStim("fixation", window, stim, env);
        
        % flash
        centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter+deg.three, env.yCenter+deg.three);
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);

    else
        
        % fixation before flash
        drawStim("fixation", window, stim, env);
        checkGaze;
        Screen('Flip', window);
    end
end

for iframe = 1:stim.fix_nFrames
    drawStim("fixation", window, stim, env);
    checkGaze;
    Screen('Flip', window);
end
