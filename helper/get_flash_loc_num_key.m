%% get_flash_loc
% allow user to move mouse to click on flash locations
% press ENTER to submit response
% press BACKSPACe to delete last response

t0 = GetSecs;

% ShowCursor

count = 0;
clicked = []; rt = [];
rects2Draw = prompt_loc{loc_list(n)};
rect_colors = repmat({env.white}, 1, length(rects2Draw));

responded = false;
WaitSecs(0.01);
clear keyCode

playAudio('resp', env);

while KbCheck; end % Wait until all keys are released.

while ~responded

    % prompt
    line1 = 'Press ENTER to submit response\n\n';
    line2 = 'Press number again to erase the last input';
    DrawFormattedText(window, [line1 line2], 'center', '', env.white);

    % fixation
    drawStim("fixation", window, stim, env);
    drawStim("reference", window, stim, env);

    % all flashes
    for f=1:length(rects2Draw)
        Screen('FillRect', window, rect_colors{f}, rects2Draw{f});
        if any(verLoc == loc_list(n))
            DrawFormattedText(window, num2str(f), rects2Draw{f}(1)-deg.half, rects2Draw{f}(4)+deg.two, rect_colors{f});
            % DrawFormattedText(window, num2str(f), rects2Draw{f}(1), rects2Draw{f}(4)+deg.two, rect_colors{f});
        else
            % DrawFormattedText(window, num2str(f), rects2Draw{f}(1)+deg.two, rects2Draw{f}(4)+deg.half, rect_colors{f});
            DrawFormattedText(window, num2str(f), rects2Draw{f}(1)+deg.two, rects2Draw{f}(4), rect_colors{f});
        end
    end

    [responded, endTask, secs, num] = checkKey_flash_loc;

    if num <= 5
        if ismember(num,clicked)
            rect_colors{num} = env.white;
            count = count-1;
            toKeep = clicked~=num;
            clicked = clicked(toKeep);
            rt = rt(toKeep);
        else
            rect_colors{num} = env.green;
            count = count+1;
            clicked(end+1) = num;
            rt(end+1) = secs-t0;
        end
    end

    % flip everything
    Screen('Flip', window);

    % Uncomment to get a screenshot of flash response prompt screen
    % imgArray = Screen('GetImage', window);
    % imwrite(imgArray, 'flashResp.png','png');

    if endTask
        cleanup;
    end
end

respondedALL(1) = responded;

Data.ResponsesF(end+1) = count;
Data.Flash_loc{end+1}  = clicked;
Data.RT_F{end+1}       = rt;

HideCursor
