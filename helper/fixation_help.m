%% fixation_help

if ~dummymode
    Eyelink('Message', 'FIX FAILED');
end

showTrace = true;
recalibrate = false;
failCount = 0;
failAllowed = 10/stim.fix_dur;
% if subject fails to fixate for an additional 10 seconds, enter
% recalibration
while ~flag
    fixated = false(1,stim.fix_nFrames);
    for iframe = 1:stim.fix_nFrames
        if strcmp(d.ver, 'v4.1')
            drawStim("fixation_top", window, stim, env);
        else
            drawStim("fixation", window, stim, env);
        end
        checkGaze;
        if ~fix_success
            Screen('FrameOval', window, [1 0 0], stim.fix_circle, stim.fix_circle_width);
        else
            Screen('FrameOval', window, [0 1 0], stim.fix_circle, stim.fix_circle_width);
        end
        Screen('Flip', window);
        fixated(iframe) = fix_success;
    end

    if all(fixated)
        flag = true;
        if ~dummymode
            Eyelink('Message', 'FIX_SUCCEED');
        end
        break
    else
        failCount = failCount + 1;
%         if failCount >= failAllowed
            
    end
end

showTrace = true;

% show fixation for another 200 ms
% for iframe = 1:stim.nFrames
%     drawStim("fixation", window, stim, env);
%     checkGaze;
%     Screen('Flip', window);
% end



