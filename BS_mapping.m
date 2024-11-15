 %% BS_mapping
% flickering stimulus that starts 5 deg from center
% Trial 1: horizontal
% Trial 2: vertical
% Trial 3: horizontal, start at average bs_y obtained from vertical
% Display BS, accept -> save data; not accept -> redo
% Eyetracking, display circle indicator at all times

%% prep
close all;
clear all;
sca;
tic;

% add `helper` to path
addpath(genpath('helper'))

d = Directory();

%% Important variables to CHECK
showTrace  = true;
bs_mapping = true;
hz = 7;

%% Ask for subject details
 
[Answer,Cancelled] = getInfo('demo', false);
% BSdataDir = char(fullfile('C:\Users\',d.userID,'\Box\R01\rabbit\MATLAB\', Answer.ver, 'Data', 'blindspot'));

dummymode = Answer.dummy-1;
eye = Answer.eye;

if Answer.sid == 'debug'
    dummymode = true;
end

if Cancelled
    return
end

% returns if subject completed task
fileList = dir( [d.BSdataDir, filesep, sprintf('%s*%s_BS.mat', Answer.sid, Answer.glasses)]);

if ~isempty(fileList) % load file if not empty, since we want both eyes' BS in same mat file
    load(fullfile(d.BSdataDir, fileList.name));
    fileName = fullfile(d.BSdataDir, fileList.name);
    disp(fileName)

else % Data does not exist
    % initialize data structure
    BS_Data.SubjectID      = Answer.sid;
    BS_Data.Demographic    = [num2str(Answer.age) Answer.sex]; 
    BS_Data.glasses        = Answer.glasses;

    date = datestr(datetime('now'), 'dd-mm-yyyy HH_MM_SS');
    fileName = fullfile(d.BSdataDir, sprintf('%s_%s_%s_BS.mat', Answer.sid, date, Answer.glasses));
    save(fileName, '-struct', 'BS_Data');     
end

clear fileList


%% initial parameters

params;
param.text_size = 80;
Screen('TextSize', window, param.text_size);
Screen('TextStyle', window, 1);
FrPerFlicker = round((1/hz)/env.ifi) ; 

HideCursor;

%% initialize Eyelink 1000

% tracker EDF file name (1 to 8 letters or numbers)
EyelinkFilename = 'expt0';

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        sca
        return;
end

% Calibration
el = EyelinkInitDefaults(window);
el.backgroundcolour = 0; % default 0.5
el.msgfontcolour = 1;
el.imgtitlecolour = 1;
el.calibrationtargetcolour = [1 1 1];
el.msgfontsize = 30;


% apply changes
EyelinkUpdateDefaults(el);

% open file on host computer to receive data
Eyelink('openfile',[EyelinkFilename,'.edf']);

% Calibrate the eye tracker using the standard calibration routines
EyelinkDoTrackerSetup(el);

% Eyelink drift correct
EyelinkDoDriftCorrection(el);
%start writing data to file:  needed to begin, and to restart after every 
%drift correction
Eyelink('StartRecording'); 

% initialize sound again because EyeLink messes up PTB
init_sound;
     
% for temporal accuracy
topPriorityLevel = MaxPriority(window);

%% Start

while KbCheck; end
accepted = false;
while ~accepted
    %% Trial 1 - horizontal

    % When to flip?????
    % draw fixation, target, if user press LEFT or RIGHT, update target
    % coordinates
    % FLIP after all that

    % instruction screen
    responded = false;
    while ~responded
        instStr = instructions(1);
        drawStim(instStr, window, stim, env);
        Screen('Flip', window);
        [responded,~,~] = checkKey_BS(responded, 0, []);
    end

    responded = false;
    if eye == 'R'
        bs_x = env.xCenter + deg.ten;
    elseif eye == 'L'
        bs_x = env.xCenter - deg.ten;
    end

    bs_y = env.yCenter + deg.two;

    x_coords = [];

    while KbCheck; end % Wait until all keys are released
    
    fr = 0; % count frames
    while ~responded
        [bs_x,~,buttons] = GetMouse(env.screenNumber);
        if any(buttons)
            x_coords(end+1) = bs_x;
        end
        [responded, ~, ~] = checkKey_BS(responded, bs_x, x_coords);

        % fixation
        fixation_BS

        % draw target
        if ~mod(fr,FrPerFlicker)
            Screen('FillOval', window, env.white, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        else
            Screen('FillOval', window, env.black, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        end
        fr = fr + 1;
    end

    % k-means clustering to find left and right edges
    [idx, c_x] = kmeans(x_coords.',2);
    left_x = min(c_x);
    right_x = max(c_x);


    %% Trial 2 - vertical

    while KbCheck; end % Wait until all keys are released

    % instruction screen
    responded = false;
    while ~responded
        instStr = instructions(2);
        drawStim(instStr, window, stim, env);
        Screen('Flip', window);
        [responded,~,~] = checkKey_BS(responded, 0, []);
    end
    
    responded = false;

    bs_x = mean(c_x);
    bs_y = env.yCenter - deg.five;

    y_coords = [];

    while KbCheck; end % Wait until all keys are released

    fr = 0; % count frames

    while ~responded
        [~,bs_y,buttons] = GetMouse(env.screenNumber);
        if any(buttons)
            y_coords(end+1) = bs_y;
        end
        [responded, ~, ~] = checkKey_BS(responded, bs_y, y_coords);

        % fixation
        fixation_BS

        % draw target
        if ~mod(fr,FrPerFlicker)
            Screen('FillOval', window, env.white, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        else
            Screen('FillOval', window, env.black, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        end
        fr = fr + 1;
    end

    % k-means clustering to find left and right edges
    [idx, c_y] = kmeans(y_coords.',2);
    top_y = min(c_y);
    bottom_y = max(c_y);



    %% Trial 3 - horizontal, final check

    while KbCheck; end % Wait until all keys are released


    % instruction screen
    responded = false;
    while ~responded
        instStr = instructions(3);
        drawStim(instStr, window, stim, env);
        Screen('Flip', window);
        [responded,~,~] = checkKey_BS(responded, 0, []);
    end
    
    responded = false;
    if eye == 'R'
        bs_x = env.xCenter + deg.ten;
    elseif eye == 'L'
        bs_x = env.xCenter - deg.ten;
    end

    bs_y = mean(c_y);

    x_coords = [];

    while KbCheck; end % Wait until all keys are released
    
    fr = 0; % count frames

    while ~responded
        [bs_x,~,buttons] = GetMouse(env.screenNumber);
        if any(buttons)
            x_coords(end+1) = bs_x;
        end
        [responded, ~, ~] = checkKey_BS(responded, bs_x, x_coords);

        % fixation
        fixation_BS

        % draw target
        if ~mod(fr,FrPerFlicker)
            Screen('FillOval', window, env.white, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        else
            Screen('FillOval', window, env.black, CenterRectOnPointd([0 0 deg.half deg.half], bs_x, bs_y));
            Screen('Flip', window);
        end
        fr = fr + 1;
    end

    % k-means clustering to find left and right edges
    [idx, c_x] = kmeans(x_coords.',2);
    left_x = min(c_x);
    right_x = max(c_x);

    %% Show blind spot and see if we accept

    while KbCheck; end % Wait until all keys are released

    left = [left_x, mean(c_y)];
    right = [right_x, mean(c_y)];
    top = [mean(c_x), top_y];
    bottom = [mean(c_x), bottom_y];
    center = [top(1), left(2)];

    responded = false;
    while ~responded
        clear keyCode
        [keyIsDown, secs, keyCode] = KbCheck;        

        % fixation
        fixation_BS

        % draw blind spot
        Screen('FillOval', window, env.grey, CenterRectOnPointd([0 0 right_x-left_x bottom_y-top_y],top(1),left(2)));

%          % debug
         % DrawFormattedText(window, 'left', left_x, mean(c_y), env.grey);
         % DrawFormattedText(window, 'right', right_x, mean(c_y), env.grey);
         % DrawFormattedText(window, 'top', mean(c_x), top_y, env.grey);
         % DrawFormattedText(window, 'bottom', mean(c_x), bottom_y, env.grey);

        % line1 = 'Do you see a white polygon on screen?\n\n';
        line2 = 'Accept: z       Redo: q ';
        DrawFormattedText(window, line2, 'center', '', env.white);
        Screen('Flip', window)

        if keyCode(KbName('z')) || keyCode(122)
            responded = true;
            accepted = true;
%             BS_Data.BS_{eye} = [left; top; right; bottom];
            BS_Data.(['BS_', eye]).left      = left;
            BS_Data.(['BS_', eye]).right     = right;
            BS_Data.(['BS_', eye]).top       = top;
            BS_Data.(['BS_', eye]).bottom    = bottom;

            while KbCheck; end

            %% cleanup
            PsychPortAudio('Stop', env.audio_handle, 1);
            try
                PsychPortAudio('Stop', pahandle1, 1);
                Snd('Close', 1);
            end
            Eyelink('StopRecording')
            Eyelink('CloseFile');
            status=Eyelink('ReceiveFile', EyelinkFilename, fullfile('Data', 'edf', [fileName, '.edf']));
            disp(status)
            Eyelink('Shutdown')

            %% save data
            save(fileName, '-append', 'BS_Data');
            disp(['Save Complete, fileName is ', fileName])

            %% end everything
            close all;
            sca;
            

        elseif keyCode(KbName('q')) || keyCode(113)
            responded = true;
            while KbCheck; end
        end
    end
end

try
    if ~isempty(BS_Data.BS_L) && ~isempty(BS_Data.BS_R)
    BS_Data.complete = 1;
    end
end


%% Local functions

function instStr = instructions(trial)
if trial == 1
    line1 = 'For the following trial, we will map your blind spot\n\n';
    line2 = 'Use LEFT and RIGHT arrow key to move the target\n\n';    
elseif trial == 2
    line1 = 'Use UP and DOWN arrow key to move the target\n\n';
    line2 = '';
elseif trial == 3
    line1 = 'Use LEFT and RIGHT arrow key to move the target\n\n';
    line2 = '';
end

line3 = 'Press SPACE when the target first disappears, and SPACE when it reappears\n\n';
line4 = 'Repeat this process at least three times\n\n';
line5 = 'Press any key to continue.';

instStr = [line1 line2 line3 line4 line5];
end

function [responded,pt,coords] = checkKey_BS(responded, pt, coords)
    clear keyCode

    [keyIsDown, secs, keyCode] = KbCheck;

    if any(keyCode(KbName('return')))
        responded = true;
    elseif keyCode(KbName('RightArrow'))
        pt = pt + 5; % pixel
    elseif keyCode(KbName('LeftArrow'))
        pt = pt - 5; % pixel
    elseif keyCode(KbName('UpArrow'))
        pt = pt - 5; % pixel
    elseif keyCode(KbName('DownArrow'))
        pt = pt + 5; % pixel
    elseif keyCode(KbName('space'))
        coords(end+1) = pt;
        while KbCheck; end % Wait until all keys are released
    elseif keyCode(KbName('ESCAPE'))
        responded = true;
        sca
    end

end
