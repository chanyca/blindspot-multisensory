%% checkGaze

if dummymode
    [x,y,buttons] = GetMouse(env.screenNumber);
    nowCoords = [x; y];
else % we are actually tracking eyes
    if Eyelink('NewFloatSampleAvailable') > 0   %check if new data available
        evt = Eyelink('NewestFloatSample'); %transmit newest data sample to client, store in evt struct.
%         % eye codes
%         el.LEFT_EYE=0;
%         el.RIGHT_EYE=1;
%         el.BINOCULAR=2;
        
        eye_used = Eyelink('EyeAvailable');

        % if Answer.eye == 'R'
        %     eye_used = 1;
        % elseif Answer.eye == 'L'
        %     eye_used = 0;
        % end

        x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
        y = evt.gy(eye_used+1);
        nowCoords = [x; y];
    end
end

% draw indicator at top left corner
if strcmp(d.ver, 'v4.1')
    targetX = env.xCenter;
    targetY = env.deg.two;
else
    targetX = env.xCenter;
    targetY = env.yCenter;
end

if isGazeInsideCircle(nowCoords, targetX, targetY, stim.fix_deg_allowed)
    Screen('DrawDots', window, [0 0], 30, [0 255 0]'); % green
    fix_success = true;
else
    Screen('DrawDots', window, [0 0], 30, [255 0 0]'); % red
    fix_success = false;
end


if showTrace
    Screen('DrawDots', window, nowCoords, 10, [.5 .5 .5]');  %draw square at the eyetracked location, two squares if two eyes tracked
end