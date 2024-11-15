%% prep screen 
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); 
env.screens = Screen('Screens'); % Get the screen numbers
env.screenNumber = max(env.screens);
env.white = WhiteIndex(env.screenNumber);
env.black = BlackIndex(env.screenNumber);
env.grey = env.white / 2;
env.green = [0 1 0];

% PsychDebugWindowConfiguration %%%%%% DEBUG ONLY
[window, windowRect] = PsychImaging('OpenWindow', env.screenNumber, env.black); % open window

[env.screenXpixels, env.screenYpixels] = Screen('WindowSize', window); % window size
env.ifi = Screen('GetFlipInterval', window); % frame rate

env.FR = round(1/env.ifi); % 60
[env.xCenter, env.yCenter] = RectCenter(windowRect); % where is center
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% keys
KbName('UnifyKeyNames'); 

%% prep visual stimuli
visual_angle;

% param.distX = 100;
stim.duration = .25; %250 ms, more buffer for audio
stim.nFrames = round(stim.duration / env.ifi);
stim.onFrames = [3, 7, 11];
stim.baseCircle = [0 0 deg.two deg.two];
stim.baseRect_ver = [0 0 deg.p28 deg.OneP2];
stim.baseRect_hor = [0 0 deg.OneP2 deg.p28];

% fixation
stim.fix_size = 50;
stim.fix_lw = 10;
stim.fix_X = [-stim.fix_size  stim.fix_size  0               0];
stim.fix_Y = [0               0              -stim.fix_size  stim.fix_size];
stim.fix_coords = [stim.fix_X; stim.fix_Y];
stim.fix_dur = .5; %1; % in sec
stim.fix_nFrames = round(stim.fix_dur / env.ifi);
stim.fix_deg_allowed = deg.two;
stim.fix_circle = [env.xCenter - stim.fix_deg_allowed; ...
                   env.yCenter- stim.fix_deg_allowed; ...
                   env.xCenter + stim.fix_deg_allowed; ...
                   env.yCenter + stim.fix_deg_allowed];
stim.fix_circle_width = 30;

%% text
param.text_color = env.white; %mod(backgr + 0.5,1);
param.text_size = 120;
Screen('TextSize', window, param.text_size);
Screen('TextStyle', window, 1);

%% prep sound
init_sound;

%% blind spot data
if ~bs_mapping
    bs.left = BS_Data.(['BS_', Answer.eye]).left;
    bs.top = BS_Data.(['BS_', Answer.eye]).top;
    bs.right = BS_Data.(['BS_', Answer.eye]).right;
    bs.bottom = BS_Data.(['BS_', Answer.eye]).bottom;
    bs.center = [bs.top(1), bs.left(2)];
    bs.radius_hor = bs.center(1) - bs.left(1);
    bs.radius_ver = bs.bottom(2) - bs.center(2);

    %% control location data
    if Answer.eye == 'L'
        ctrlEye = 'R';
    else
        ctrlEye = 'L';
    end

    ctrl.left = BS_Data.(['BS_', ctrlEye]).left;
    ctrl.top = BS_Data.(['BS_', ctrlEye]).top;
    ctrl.right = BS_Data.(['BS_', ctrlEye]).right;
    ctrl.bottom = BS_Data.(['BS_', ctrlEye]).bottom;
    ctrl.center = [ctrl.top(1), ctrl.left(2)];
    ctrl.radius_hor = ctrl.center(1) - ctrl.left(1);
    ctrl.radius_ver = ctrl.bottom(2) - ctrl.center(2);

    %% stim locations   
    stimLoc = { {CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, bs.left(2)),         CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, bs.right(2))}; ... % BS - left to right, vertical bars
                {CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, bs.right(2)),       CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, bs.left(2))}; ... % BS - right to left, vertical bars
                {CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.half),           CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.half)}; ... % BS - top to bottom, horizontal bars
                {CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.half),     CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.half)}; ... % BS - bottom to top, horizontal bars
        
                {CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, ctrl.left(2)),     CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, ctrl.right(2))};... % Ctrl - left to right, vertical bars
                {CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, ctrl.right(2)),   CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, ctrl.left(2))};... % Ctrl - right to left, vertical bars
                {CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.half),       CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.half)};... % Ctrl - top to bottom, horizontal bars
                {CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.half), CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.half)}; ... % Ctrl - bottom to top, horizontal bars
        
                {CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, bs.left(2)),         CenterRectOnPointd(stim.baseRect_ver, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, bs.right(2))}; ... % BS - left, center, right, vertical bars
                {CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, bs.right(2)),       CenterRectOnPointd(stim.baseRect_ver, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, bs.left(2))}; ... % BS - right, center, left, vertical bars
                {CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.half),           CenterRectOnPointd(stim.baseRect_hor, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.half)}; ... % BS - center, horizontal
                {CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.half),     CenterRectOnPointd(stim.baseRect_hor, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.half)}; ... % BS - center, horizontal
        
                {CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, ctrl.left(2)),     CenterRectOnPointd(stim.baseRect_ver, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, ctrl.right(2))}; ... % ctrl - left, center, right, vertical bars
                {CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, ctrl.right(2)),   CenterRectOnPointd(stim.baseRect_ver, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, ctrl.left(2))}; ... % ctrl - right, center, left, vertical bars
                {CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.half),       CenterRectOnPointd(stim.baseRect_hor, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.half)}; ... % ctrl - center, horizontal
                {CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.half), CenterRectOnPointd(stim.baseRect_hor, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.half)}}; ... % ctrl - center, horizontal
    
    verLoc = [1 2 5 6 9 10 13 14];
    
    % prompt flashes
    bs_hor = {CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.one-bs.radius_hor, bs.left(2)), CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, bs.left(2)), ...
        CenterRectOnPointd(stim.baseRect_ver, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, bs.right(2)), ...
        CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.one+bs.radius_hor, bs.right(2))};

    bs_ver = {CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.one-bs.radius_ver), CenterRectOnPointd(stim.baseRect_hor, bs.top(1), bs.top(2)-deg.half), ...
        CenterRectOnPointd(stim.baseRect_hor, bs.center(1), bs.center(2)), CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.half), ...
        CenterRectOnPointd(stim.baseRect_hor, bs.bottom(1), bs.bottom(2)+deg.one+bs.radius_ver)};

    ctrl_hor = {CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.one-ctrl.radius_hor, ctrl.left(2)), CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, ctrl.left(2)), ...
        CenterRectOnPointd(stim.baseRect_ver, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, ctrl.right(2)), ...
        CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.one+ctrl.radius_hor, ctrl.right(2))};

    ctrl_ver = {CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.one-ctrl.radius_ver), CenterRectOnPointd(stim.baseRect_hor, ctrl.top(1), ctrl.top(2)-deg.half), ...
        CenterRectOnPointd(stim.baseRect_hor, ctrl.center(1), ctrl.center(2)), CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.half), ...
        CenterRectOnPointd(stim.baseRect_hor, ctrl.bottom(1), ctrl.bottom(2)+deg.one+ctrl.radius_ver)};

    prompt_loc = {bs_hor; bs_hor; bs_ver; bs_ver; ctrl_hor; ctrl_hor; ctrl_ver; ctrl_ver;...
                  bs_hor; bs_hor; bs_ver; bs_ver; ctrl_hor; ctrl_hor; ctrl_ver; ctrl_ver;};

    % reference flashes
    pad = 100;
    ref_ver = {CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.one-bs.radius_hor, env.screenYpixels-pad), ... %bottom
               CenterRectOnPointd(stim.baseRect_ver, bs.left(1)-deg.half, env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, bs.center(1), env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.half, env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, bs.right(1)+deg.one+bs.radius_hor, env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.one-ctrl.radius_hor, env.screenYpixels-pad), ... %bottom
               CenterRectOnPointd(stim.baseRect_ver, ctrl.left(1)-deg.half, env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, ctrl.center(1), env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.half, env.screenYpixels-pad), ...
               CenterRectOnPointd(stim.baseRect_ver, ctrl.right(1)+deg.one+ctrl.radius_hor, env.screenYpixels-pad)};

    if Answer.eye == 'L' %blindspot is on the left
        ref_hor = {CenterRectOnPointd(stim.baseRect_hor, pad, bs.top(2)-deg.one-bs.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, bs.top(2)-deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, bs.center(2)), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, bs.bottom(2)+deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, bs.bottom(2)+deg.one+bs.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, ctrl.top(2)-deg.one-ctrl.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, ctrl.top(2)-deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, ctrl.center(2)), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, ctrl.bottom(2)+deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, ctrl.bottom(2)+deg.one+ctrl.radius_ver)};
    else
        ref_hor = {CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, bs.top(2)-deg.one-bs.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, bs.top(2)-deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, bs.center(2)), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, bs.bottom(2)+deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, env.screenXpixels-pad, bs.bottom(2)+deg.one+bs.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, ctrl.top(2)-deg.one-ctrl.radius_ver), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, ctrl.top(2)-deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, ctrl.center(2)), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, ctrl.bottom(2)+deg.half), ...
                   CenterRectOnPointd(stim.baseRect_hor, pad, ctrl.bottom(2)+deg.one+ctrl.radius_ver)};
    end

    stim.ref_loc = [ref_ver, ref_hor];
           

end






