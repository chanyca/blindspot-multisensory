%% task_master

loc_list = Data.Conditions(:,1);
beeps_list = Data.Conditions(:,2);
resp_list = Data.Conditions(:,3);

pt1_length = sum(resp_list == 1);
pt2_length = length(resp_list) - pt1_length;

%% Wait for key press to begin experiment
responded = false;
while KbCheck; end % Wait until all keys are released.
while ~responded
    line1 = 'The experiment will begin as soon as you are ready\n\n';
    line2 = 'Press any key to continue.';
    drawStim([line1 line2], window, stim, env);
    Screen('Flip', window);
    [responded, ~, ~, ~] = checkKey;
end


%% start showing stimuli

WaitSecs(1);

% count no of nonempty trials
startTrial = length(Data.ResponsesF) + length(Data.ResponsesB) + 1;
if Answer.sid == 'debug'
    startTrial = 1;
end

% ====== debug ======
% startTrial = size(Data.Conditions,1)+1;
% startTrial = pt1_length+3;
% ===================

for n=startTrial:size(Data.Conditions,1)

    if ~dummymode
        Eyelink('Message', 'TRIALID %d', n);
    end

    respSeq = resp_list(n);
    respondedALL = false;    
    
    while ~respondedALL
        checkGaze;
        if mod(n, 20) == 0 && n ~= 0 && n ~= pt1_length && size(Data.Conditions,1)-n > 20 % break every 20 trials
            % intermission
            line1 = 'Please take a break if needed\n';
            line2 = '\n Press any key to continue';            
            drawStim([line1 line2], window, stim, env);

            % get progress
            if n <= pt1_length
                drawStatusBar(n, pt1_length, env, window);
            else
                drawStatusBar(n-pt1_length, pt2_length, env, window);                
            end
            Screen('Flip', window);         
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                cleanup;
            end
            KbStrokeWait;
        end
    
        loc = stimLoc{loc_list(n)};
        rects2Draw = prompt_loc{loc_list(n)};
        pin = pinLoc{loc2pin{loc_list(n)}};
        num_beeps = beeps_list(n);

        dispStim;

        if ~dummymode
            Eyelink('Message', 'RESP_START');
        end
        if n <= pt1_length
            get_flash_loc_num_key;
        else
            get_input_master;
        end
        if ~dummymode
            Eyelink('Message', 'RESP_END');
        end
    end

    if n == pt1_length
        clear keyCode

        % intermission
        line1 = 'You are now done with PART ONE\n\n';
        line2 = 'For part two, report number of BEEP(s)\n\n';
        line3 = 'Use keys 0-4 on the Number Pad.\n\n';
        line4 = 'Press any key to continue';
        drawStim([line1 line2 line3 line4], window, stim, env);
        Screen('Flip', window);

        playAudio('outro', env);

        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            cleanup;
        end
        KbWait;
    end

    if ~dummymode
        Eyelink('Message', 'TRIAL_END %d', n);
    end

end


%% end + extra trials to map flash locations

line1 = 'You are almost done!!!\n';
line2 = '\n Please ring the bell and notify the experimenter. ';

drawStim([line1 line2], window, stim, env);
Screen('Flip', window);
playAudio('outro', env);
KbStrokeWait;

%% Extra trials

% generate trials
nrep = 2;
bsF2 = [1 4]; bsF3 = [9 12];
ctrlF2 = [5 8]; ctrlF3 = [13 16];
locs = [randi(bsF2,1,4), randi(ctrlF2,1,4)]; % only F2B3 trials
locs = locs(randperm(length(locs))); % shuffle
Data.ConditionsF_extra = locs;

% start
for n=1:length(locs)

    if ~dummymode
        Eyelink('Message', 'TRIALID %d', n);
    end

    respSeq = 1;
    respondedALL = false;    
    
    while ~respondedALL
        checkGaze;

        loc = stimLoc{locs(n)};
        num_beeps = 3;
        rects2Draw = prompt_loc{loc_list(n)};
        dispStim;

        if ~dummymode
            Eyelink('Message', 'RESP_START');
        end

        t0 = GetSecs;
        get_flash_loc_mouse;
        Data.ResponsesF_extra(end+1) = clicks.count;
        Data.Flash_loc_extra{end+1}  = clicks.coords;

        if ~dummymode
            Eyelink('Message', 'RESP_END');
        end
    end
    if ~dummymode
        Eyelink('Message', 'TRIAL_END %d', n);
    end

end

%% READ END

line1 = 'You are now finished with this run.\n';
line2 = '\n\n Thank you for your time! ';

drawStim([line1 line2], window, stim, env);
Screen('Flip', window);
playAudio('outro', env);
KbStrokeWait;


%% helper function(s)
function drawPrompt(mode, window, stim, env)

    switch mode
        case 1 % flash
            drawStim('FLASH(ES)', window, stim, env);
            centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter, env.yCenter+200);
            Screen('FillRect', window, env.white, centeredRect);
        case 2 % beep
            drawStim('BEEP(S)', window, stim, env);
    end
    prompt = 'How many?\n\n0    1    2    3    4';
    DrawFormattedText(window, prompt, 'center', env.yCenter-800, env.white);
    
    Screen('Flip', window);
end





