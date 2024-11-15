%% draw blind spot and show where flash(es) are
clear
close
clc
sca
githubDir = extractBefore(pwd, 'rabbit');
baseDir = [extractBefore(pwd, 'blindspot-multisensory'), 'blindspot-multisensory'];
BSdataDir = char(fullfile(baseDir, 'bs_data'));
plotDir = char(fullfile(baseDir, 'plots'));

text_size = 100;
Answer.eye = 'R';
Answer.task = 'AV';
load(fullfile(BSdataDir, 'for_drawing.mat'));
bs_mapping = false;
params;

%% Screen
% close screen and open a one with white background instead
env.screenNumber = 1; % office pc setting
[window, windowRect] = PsychImaging('OpenWindow', env.screenNumber, env.white); % open window
[env.screenXpixels, env.screenYpixels] = Screen('WindowSize', window); % window size
[env.xCenter, env.yCenter] = RectCenter(windowRect); % where is center
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Lines
lineColor = env.black;
lineWidth = 8;
lineExtra = 3;

%% Targets
target_size = 60;

% □: double(char(9633))
% ■: double(char(9632))
L_hollow = double(char(9633));
L_filled = double(char(9632));

% ○: double(char(9675))
% ●: double(char(9679))
R_hollow = double(char(9675));
R_filled = double(char(9679));


%% Start drawing
for eye={'L' 'R'}

% fixation
Screen('DrawLines', window, stim.fix_coords, stim.fix_lw, lineColor, [env.xCenter env.yCenter], 2);

spotY = env.yCenter+deg.five;

% coordinates
L.left = [env.xCenter-deg.fifteen, spotY];
L.right = [L.left(1)+deg.three, spotY];
L.top = [mean([L.left(1), L.right(1)]), spotY-deg.three];
L.bottom = [L.top(1), spotY+deg.three];
L.center = [L.top(1), spotY];

R.left = [env.xCenter+deg.fifteen-deg.three, spotY];
R.right = [R.left(1)+deg.three, spotY];
R.top = [mean([R.left(1), R.right(1)]), spotY-deg.three];
R.bottom = [R.top(1), spotY+deg.three];
R.center = [R.top(1), spotY];

%% draw left spot


Screen('TextSize', window, target_size);

if eye{1} == 'L'
    Screen('FillOval', window, env.grey, ...
        CenterRectOnPointd([0 0 L.right(1)-L.left(1) L.bottom(2)-L.top(2)],L.top(1),L.left(2)));
    DrawFormattedText(window, L_filled, L.center(1)-deg.half, L.center(2)+deg.half, lineColor);
else
    Screen('FrameOval', window, lineColor, ...
        CenterRectOnPointd([0 0 L.right(1)-L.left(1) L.bottom(2)-L.top(2)],L.top(1),L.left(2)), ...
        10);
    DrawFormattedText(window, L_hollow, L.center(1)-deg.half, L.center(2)+deg.half, lineColor);
end

% flashes (crosses) on blind spot
flashes = [[L.left(1)-deg.one, L.left(2)];...
           [L.right(1)+deg.one, L.right(2)]; ...
           [L.bottom(1), L.bottom(2)+deg.one]; ...
           [L.top(1), L.top(2)-deg.one]];

for f=1:length(flashes)
    DrawFormattedText(window, L_hollow, flashes(f,1)-deg.half, flashes(f,2)+deg.half, lineColor);
end

%% draw lines to indicate 0.5 deg

% left border
xLeft = L.left(1)-deg.one;
xRight = L.left(1);
yTop = L.left(2)+deg.half;
yBottom = L.left(2)+deg.one;
draw_line_p5deg(window, deg, text_size, xLeft, xRight,  yTop, yBottom, lineColor, lineExtra, lineWidth, 'left')

% top border
xLeft = L.top(1)+deg.half;
xRight = L.top(1)+deg.one;
yTop = L.top(2)-deg.one;
yBottom = L.top(2);
draw_line_p5deg(window, deg, text_size, xLeft, xRight,  yTop, yBottom, lineColor, lineExtra, lineWidth, 'top')


%% draw right spot

Screen('TextSize', window, target_size);

if eye{1} == 'L'
    Screen('FrameOval', window, lineColor, ...
        CenterRectOnPointd([0 0 R.right(1)-R.left(1) R.bottom(2)-R.top(2)],R.top(1),R.left(2)), ...
        10);
    DrawFormattedText(window, R_hollow, R.center(1)-deg.half, R.center(2)+deg.half, lineColor);
else
    Screen('FillOval', window, env.grey, ...
        CenterRectOnPointd([0 0 R.right(1)-R.left(1) R.bottom(2)-R.top(2)],R.top(1),R.left(2)));
    DrawFormattedText(window, R_filled, R.center(1)-deg.half, R.center(2)+deg.half, lineColor);
end

% flashes (crosses) on control spot
flashes = [[R.left(1)-deg.one, R.left(2)];...
           [R.right(1)+deg.one, R.right(2)]; ...
           [R.bottom(1), R.bottom(2)+deg.one]; ...
           [R.top(1), R.top(2)-deg.one]];

for f=1:length(flashes)
    DrawFormattedText(window, R_hollow, flashes(f,1)-deg.half, flashes(f,2)+deg.half, lineColor);
end

% top border
xLeft = R.top(1)+deg.half;
xRight = R.top(1)+deg.one;
yTop = R.top(2)-deg.one;
yBottom = R.top(2);
draw_line_p5deg(window, deg, text_size, xLeft, xRight,  yTop, yBottom, lineColor, lineExtra, lineWidth, 'top')

% right border
xLeft = R.right(1);
xRight = R.right(1)+deg.one;
yTop = R.right(2)+deg.half;
yBottom = R.right(2)+deg.one;
draw_line_p5deg(window, deg, text_size, xLeft, xRight,  yTop, yBottom, lineColor, lineExtra, lineWidth, 'right')


%% screen capture
Screen('Flip', window);
imgArray = Screen('GetImage', window);
imwrite(imgArray, [plotDir filesep 'bs_flash_' eye{1} '.png'],'png');

WaitSecs(2)

end
sca

%% Customized functions
function draw_line_p5deg(window, deg, text_size, xLeft, xRight, yTop, yBottom, lineColor, lineExtra, lineWidth, where)

Screen('TextSize', window, text_size);

if strcmp(where, 'right')
    Screen('DrawLine', window, lineColor, xLeft, yTop, xLeft, yBottom+lineExtra, lineWidth) % left vertical
    Screen('DrawLine', window, lineColor, xRight, yTop, xRight, yBottom+lineExtra, lineWidth) % right vertical
    Screen('DrawLine', window, lineColor, xLeft, yBottom, xRight, yBottom, lineWidth) % horizontal
    DrawFormattedText(window, ['0.5', char(176)], xLeft+deg.one, yBottom+deg.three, lineColor);
elseif strcmp(where, 'left')
    Screen('DrawLine', window, lineColor, xLeft, yTop, xLeft, yBottom+lineExtra, lineWidth) % left vertical
    Screen('DrawLine', window, lineColor, xRight, yTop, xRight, yBottom+lineExtra, lineWidth) % right vertical
    Screen('DrawLine', window, lineColor, xLeft, yBottom, xRight, yBottom, lineWidth) % horizontal
    DrawFormattedText(window, ['0.5', char(176)], xLeft-deg.four, yBottom+deg.three, lineColor);
elseif strcmp(where, 'top')
    Screen('DrawLine', window, lineColor, xLeft, yTop, xRight+lineExtra, yTop, lineWidth) % top horizontal
    Screen('DrawLine', window, lineColor, xLeft, yBottom, xRight+lineExtra, yBottom, lineWidth) % bottom horizontal
    Screen('DrawLine', window, lineColor, xRight, yTop, xRight, yBottom, lineWidth) % vertical
    DrawFormattedText(window, ['0.5', char(176)], xRight+deg.one, yBottom, lineColor);
end

end