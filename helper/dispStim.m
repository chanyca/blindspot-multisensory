%% dispStim.m

% ________ for oscilloscope ____________________
% num_beeps = 3;
% centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter, env.yCenter+deg.three);
% COMMENT OUT centeredRect ON LINES 65 AND 71
% ______________________________________________


%% What is done here

HideCursor;
showTrace = false;

%% start showing

%% audio buffer
% entire stimulus is 200ms long
% prep beep here
% Fill buffer
if num_beeps == 0 %0B2F, no sound
    PsychPortAudio('FillBuffer', env.audio_handle, [param.left_emptyBeep_array; param.right_emptyBeep_array]);
elseif num_beeps == 2 %2B2F
    PsychPortAudio('FillBuffer', env.audio_handle, [param.left_twoBeep_array; param.right_twoBeep_array]);
elseif num_beeps == 3 %3B2F
    PsychPortAudio('FillBuffer', env.audio_handle, [param.left_threeBeep_array; param.right_threeBeep_array]);
end

%% fixation - won't start trial till successful fixation

if ~dummymode
    Eyelink('Message', 'FIX_START');
end

fail_count = 0;
flag = false;
while ~flag
    fixated = false(1,stim.fix_nFrames);
    for iframe = 1:stim.fix_nFrames
        drawStim("fixation", window, stim, env);
        drawStim("reference", window, stim, env);
        checkGaze;
        Screen('Flip', window);
        fixated(iframe) = fix_success;
        if makeMovie
            Screen('AddFrameToMovie', window)
        end
    end
    if all(fixated)
        flag = true;
        break
    else
        fail_count = fail_count + 1;
        if fail_count >= 3
            fixation_help;
        end
    end
end

if ~dummymode
    Eyelink('Message', 'FIX_END');
end

%% actual stim

% Pre-flip, t approx -0.0167
drawStim("fixation", window, stim, env);
drawStim("reference", window, stim, env);
[~, StimOnsetTimePre, FlipTimestamp, ~, ~] = Screen('Flip', window);
if makeMovie
    Screen('AddFrameToMovie', window)
end

if ~dummymode
    Eyelink('Message', 'STIM_START');
end

t0 = StimOnsetTimePre + env.ifi;

if contains(Answer.task, 'A')
    PsychPortAudio('Volume', env.audio_handle, 1);
    audiostarttime = PsychPortAudio('Start', env.audio_handle, param.repetitions, t0, param.waitForDeviceStart);
end

motor = 'D5'; % proxy pin
for iframe = 1:stim.nFrames % 200 ms / 12 frames
    if iframe == stim.onFrames(1)
        drawStim("fixation", window, stim, env);
        drawStim("reference", window, stim, env);
        if contains(Answer.task, 'T') && num_beeps > 0
            % motor
            motor = pin{1};
            writeDigitalPin(a, motor, 1);
        end
        % flash
        centeredRect = [loc{1}];
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);
        if makeMovie
            Screen('AddFrameToMovie', window)
        end

    elseif iframe == stim.onFrames(2)
        if contains(Answer.task, 'T') && length(pin) == 3 && num_beeps > 0 %3 VIBRATIONS
            drawStim("fixation", window, stim, env);
            drawStim("reference", window, stim, env);
            % motor
            motor = pin{2};
            writeDigitalPin(a, motor, 1);
        end
        if length(loc) == 3 %3 FLASHES
            drawStim("fixation", window, stim, env);
            drawStim("reference", window, stim, env);
            % flash
            centeredRect = [loc{2}];
            Screen('FillRect', window, env.white, centeredRect);
            checkGaze;
            Screen('Flip', window);
            if makeMovie
                Screen('AddFrameToMovie', window)
            end
        end      

    elseif iframe == stim.onFrames(3)
        drawStim("fixation", window, stim, env);
        drawStim("reference", window, stim, env);
        if contains(Answer.task, 'T') && num_beeps > 0
            % motor
            motor = pin{end};
            writeDigitalPin(a, motor, 1);
        end
        % flash
        centeredRect = [loc{end}];
        Screen('FillRect', window, env.white, centeredRect);
        checkGaze;
        Screen('Flip', window);
        if makeMovie
            Screen('AddFrameToMovie', window)
        end

    else
        if contains(Answer.task, 'T')
            writeDigitalPin(a, motor, 0);
        end
        % fixation before flash
        drawStim("fixation", window, stim, env);
        drawStim("reference", window, stim, env);
        checkGaze;
        Screen('Flip', window);
        if makeMovie
            Screen('AddFrameToMovie', window)
        end
    end
end

if ~dummymode
    Eyelink('Message', 'STIM_END');
end


%% fixation
for iframe = 1:stim.fix_nFrames
    drawStim("fixation", window, stim, env);
    drawStim("reference", window, stim, env);
    checkGaze;
    Screen('Flip', window);
    if makeMovie
        Screen('AddFrameToMovie', window)
    end
end
