%% fixation_BS

showTrace = true;
recalibrate = false;

drawStim("fixation", window, stim, env);
checkGaze;
if ~fix_success
    Screen('FrameOval', window, [1 0 0], stim.fix_circle, stim.fix_circle_width);
else
    Screen('FrameOval', window, [0 1 0], stim.fix_circle, stim.fix_circle_width);
end

% Screen('Flip', window);


