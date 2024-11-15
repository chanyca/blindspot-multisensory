%% get_flash_loc_mouse
% allow user to move mouse to click on flash locations
% press ENTER to submit response
% press BACKSPACE to delete last response

clicks.count = 1;
clicks.x = []; clicks.y = [];
clicks.coords = [];
clicks.rt = [];
rects2Draw = [];

responded = false;
WaitSecs(0.01);
clear keyCode

playAudio('resp', env);
while ~responded    

    % prompt
    line1 = 'Where are the flash(es)?\n\n';
    line2 = 'Press ENTER to submit response\n';
    line3 = 'Press BACKSPACE to erase the last input';
    DrawFormattedText(window, [line1 line2 line3], 'center', '', env.white);

    % fixation
    drawStim("fixation", window, stim, env);

    % draw first flash
    centeredRect = [loc{1}];
    Screen('FillRect', window, env.green, centeredRect);
    
    % trace with super long cross that spans across screen
    [x,y,buttons] = GetMouse(env.screenNumber);
    X_coords = [-env.screenXpixels*3 env.screenXpixels*3 0 0];
    Y_coords = [0 0 -env.screenYpixels*3 env.screenYpixels*3];
    XY_coords = [X_coords; Y_coords];
    Screen('DrawLines', window, XY_coords, stim.fix_lw, env.white, [x y], 2);

    if any(verLoc == locs(n))
        rect_ori = stim.baseRect_ver;
        centeredRect = CenterRectOnPointd(rect_ori, x, y);
    else
        rect_ori = stim.baseRect_hor;
        centeredRect = CenterRectOnPointd(rect_ori, x, y);
    end

    % record click, draw green bar if clicked
    [x, y, buttons] = GetMouse(env.screenNumber);
    if any(buttons)
        clicks.count    = clicks.count + 1;
        clicks.x(end+1) = x;
        clicks.y(end+1) = y;
        clicks.coords(:,end+1) = [x, y];
        rects2Draw(:,end+1) = CenterRectOnPointd(rect_ori, x, y);
    end

    while any(buttons) % wait for mouse release, stop taking x- y- coordinates
        [~, ~, buttons] = GetMouse(env.screenNumber);
    end

    for rect = 1:clicks.count-1
        Screen('FillRect', window, env.green, rects2Draw(:,rect));
    end

    % flip everything
    Screen('Flip', window);
    
    [responded, endTask, secs, num] = checkKey;
    if num == 7 && clicks.count > 0 % backspace is pressed
        clicks.count  = clicks.count - 1;
        clicks.x(end) = [];
        clicks.y(end) = [];
        clicks.coords(:,end) = [];
        rects2Draw(:,end) = [];

        num = 99;
    end

    if endTask
        cleanup;
    end

end

respondedALL(1) = responded;

