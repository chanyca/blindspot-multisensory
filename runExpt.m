%% Main script to run experiment
% CHECK BEFORE YOU START
% Bose speaker turned on to max
% Computer volume at 50
% Chin rest - distance at 57cm
% param.audioDelay = -0.105 (set on 2022 Dell Computer 60Hz empirically) -
% 6/26/2023

%% prep
close all
clear

sca
tic

% add `helper` to path
addpath(genpath('helper'))
addpath(genpath('dependencies'))

d = Directory;


%% Important variables to CHECK
lowvision = 0;
showTrace  = true;
bs_mapping = false;
makeMovie = false;

%% Ask for subject details
[Answer,Cancelled] = getInfo;
if Cancelled
    return
end

dummymode = Answer.dummy-1;
showDemo = Answer.demo-1;

if strcmp(Answer.sid, 'debug')
    dummymode = true;
    showDemo = false;
end


% returns if subject completed task
fileList = dir( [d.dataDir, filesep, ...
    sprintf('%s*%s_%s_%s.mat', Answer.sid, Answer.eye, Answer.glasses, Answer.task)]);

if ~isempty(fileList) % load file if not empty
    load(fullfile(d.dataDir, fileList.name));
    % check completion
%     if Data.complete % Data exists and is complete
% %         clc
% %         disp("ERROR: Subject completed this already.")
% %         sca
% %         return
%     else % Data exists but is incomplete
        sub = [d.dataDir, filesep];
        fileName = [sub, extractBefore(fileList.name, '.mat')];
%         disp(fileName)
    % end
else % Data does not exist
    % initialize data structure
    Data.SubjectID      = Answer.sid;
    Data.complete       = 0;
    Data.Demographic    = [num2str(Answer.age) Answer.sex];
    Data.Eye            = Answer.eye;
    Data.glasses        = Answer.glasses;
    Data.Conditions     = [];
    Data.ResponsesF     = [];
    Data.Flash_loc      = {}; % Note CELL property
    Data.RT_F           = {}; % Note CELL property
    if contains(Answer.task, 'A')
        Data.ResponsesB = [];
        Data.RT_B       = [];
    end
    if contains(Answer.task, 'T')
        Data.ResponsesT = [];
        Data.RT_T       = [];
    end

    % generate trials
    [trials] = genTrials(Answer);
    Data.Conditions = trials;

    % extra trials to precisely map flash location
    Data.ConditionsF_extra = [];
    Data.ResponsesF_extra  = [];
    Data.Flash_loc_extra   = {};
    date = datetime('now', 'Format','dd-mm-yyyy HH_MM_SS');
    sub = [d.dataDir, filesep];
    fileName = sprintf('%s%s_%s_%s_%s_%s', sub, Answer.sid, date, Answer.eye, Answer.glasses, Answer.task);
end

clear fileList


%% find blind spot data
fileList = dir( [d.BSdataDir, filesep, ...
    sprintf('%s*%s_BS.mat', Answer.sid, Answer.glasses)]);

if ~isempty(fileList) % load file if not empty
    load(fullfile(d.BSdataDir, fileList.name));    
else % Data does not exist
    clc
    disp("ERROR: blind spot data missing.")
    sca
    return    
end

clear fileList

%% initial parameters
params;    

%% initialize Eyelink 1000

% tracker EDF file name (1 to 8 letters or numbers)
EyelinkFilename = [Answer.sid, Answer.eye];

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

if lowvision
    % Make calibration easier for low vision subjects
    el.calibrationtargetsize = 7.5; % default 2.5
end

% apply changes
EyelinkUpdateDefaults(el);

% open file on host computer to receive data
Eyelink('openfile',[EyelinkFilename,'.edf']);

% Calibrate the eye tracker using the standard calibration routines
EyelinkDoTrackerSetup(el);

% Eyelink drift correct
EyelinkDoDriftCorrection(el);

Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);

%start writing data to file:  needed to begin, and to restart after every 
%drift correction
Eyelink('StartRecording'); 

%% Start experiment

init_sound;
     
% for temporal accuracy
topPriorityLevel = MaxPriority(window);

% show demo
if showDemo
    demo_trials;
end

task_master;

%% Save data

Data.complete = 1;
save([fileName, '.mat'], 'Data');
cleanup;


