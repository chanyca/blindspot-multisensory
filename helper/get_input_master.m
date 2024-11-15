%% get_input_master
t0 = GetSecs;
% endTask = false;


for r=1:length(respSeq)

    responded = false;
    WaitSecs(0.01);
    clear keyCode

    drawPrompt(respSeq(r), window, stim, env);
    playAudio('resp', env);
    while KbCheck; end % Wait until all keys are released.    
    while ~responded
        drawPrompt(respSeq(r), window, stim, env);
        [responded, endTask, secs, num] = checkKey;
        if endTask
            cleanup;
        end
    end

    switch respSeq(r)
        case 1
            Data.ResponsesF(end+1) = num;
            Data.RT_F(end+1) = secs-t0;
        case 2
            Data.ResponsesB(end+1) = num;
            Data.RT_B(end+1) = secs-t0;
    end
    respondedALL(r) = responded;

    if responded
        break
    end
end



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
    DrawFormattedText(window, prompt, 'center', env.yCenter-500, env.white);
    if IsOSX
        DrawFormattedText(window, prompt, 'center', env.yCenter-300, env.white);
    end
    Screen('Flip', window);
end
