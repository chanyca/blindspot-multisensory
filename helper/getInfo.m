%% getInfo
function [Answer,Cancelled] = getInfo(varargin)

eye = true; glasses = true; dummy = true; demo = true; task = true;
isi = false; ver = false; gap = false; stim = false; stimdur = false; 
beepInterval = false; npracTrials = false; orientation = false; rep = false;
while ~isempty(varargin)
    switch lower(varargin{1})
        case 'eye'
            eye = varargin{2};
        case 'glasses'
            glasses = varargin{2};
        case 'dummy'
            dummy = varargin{2};
        case 'demo'
            demo = varargin{2};
        case 'task'
            task = varargin{2};
        case 'isi'
            isi = varargin{2};
        case 'ver'
            ver = varargin{2};
        case 'gap'
            gap = varargin{2};
        case 'stim'
            stim = varargin{2};
        case 'stimdur'
            stimdur = varargin{2};
        case 'beepinterval'
            beepInterval = varargin{2};
        case 'npractrials'
            npracTrials = varargin{2};
        case 'orientation'
            orientation = varargin{2};
        case 'rep'
            rep = varargin{2};
    end
    varargin(1:2) = [];
end



Title = '';

Options.Resize = 'on';
Options.Interpreter = 'tex';
Options.CancelButton = 'on';
Options.ApplyButton = 'off';
Options.ButtonNames = {'Continue','Cancel'}; %<- default names, included here just for illustration
Options.AlignControls = 'on';

Prompt = {};
Formats = {};
DefAns = struct([]);


% Subject ID
Prompt(1,:) = {'Subject ID', 'sid', []};
Formats(1,1).type = 'edit';
Formats(1,1).format = 'text';
Formats(1,1).size = 100; % automatically assign the height
DefAns(1).sid = 'SV000';

% Age
Prompt(2,:) = {'Age', 'age', []};
Formats(1,2).type = 'edit';
Formats(1,2).format = 'integer';
Formats(1,2).size = 50; % automatically assign the height
DefAns.age = 99;

% Sex assigned at birth
Prompt(3,:) = {'Sex assigned at birth','sex',[]};
Formats(2,1).type = 'list';
Formats(2,1).format = 'text';
Formats(2,1).style = 'radiobutton';
Formats(2,1).items = {'F' 'M'};
DefAns.sex = 'F';

% Eye being tested
if eye
Prompt(end+1,:) = {'Eye being tested','eye',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'L' 'R'};
DefAns.eye = 'L';
end

% Glasses
if glasses
Prompt(end+1,:) = {'Glasses','glasses',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'with' 'without' 'na'};
DefAns.glasses = 'na';
end

% Demo
if demo
Prompt(end+1,:) = {'Show demo','demo',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'integer';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = [0 1];
DefAns.demo = 2; % index, default show demo
end

% Dummy
if dummy
Prompt(end+1,:) = {'Dummy','dummy',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'integer';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = [0 1];
DefAns.dummy = 1; % index, default non dummy
end

% Task
if task
Prompt(end+1,:) = {'Task','task',[]};
Formats(end+1,1).type = 'list'; 
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'AV' 'TV' 'ATV'};
DefAns.task = 'AV';
end

% ISI
if isi
Prompt(end+1,:) = {'ISI', 'isi', []};
Formats(end+1,1).type = 'edit';
Formats(end,1).format = 'integer';
Formats(end,1).size = 50; % automatically assign the height
DefAns.isi = 4;
end

% Version
if ver
Prompt(end+1,:) = {'Version', 'ver', []};
Formats(end+1,1).type = 'edit';
Formats(end,1).format = 'text';
Formats(end,1).size = 50; % automatically assign the height
DefAns.ver = 'v3.2';
end 

% Gap between double taps
if gap
Prompt(end+1,:) = {'Gap                          ','gap',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'integer';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = [0 1];
DefAns.gap = 1; % index, default no gap
end

% stimulus type
if stim
Prompt(end+1,:) = {'Stimulus','stim',[]};
Formats(end+1,1).type = 'list'; 
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'teardrop' 'bar' 'grating'};
DefAns.stim = 'teardrop';
end

% flash duration
if stimdur
Prompt(end+1,:) = {'Flash duration (frames)','stimdur',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'1' '2' '3'};
DefAns.stimdur = '1'; %ms
end

% beep interval
if beepInterval
Prompt(end+1,:) = {'Beep interval (ms)','beepInterval',[]};
Formats(end+1,1).type = 'list';
Formats(end,1).format = 'text';
Formats(end,1).style = 'radiobutton';
Formats(end,1).items = {'58' '80'};
DefAns.beepInterval = '58'; %ms
end    

% no of practice trials
if npracTrials
Prompt(end+1,:) = {'No. of practice trials', 'npracTrials',[]};
Formats(end+1,1).type = 'edit';
Formats(end,1).format = 'integer';
Formats(end,1).size = 50; % automatically assign the height
DefAns.npracTrials = 10;
end

% no of orientations
if orientation
Prompt(end+1,:) = {'No. of orientations', 'n_orientation',[]};
Formats(end+1,1).type = 'edit';
Formats(end,1).format = 'integer';
Formats(end,1).size = 50; % automatically assign the height
DefAns.n_orientation = 6;
end

% no of reps
if rep
Prompt(end+1,:) = {'No. of reps', 'n_rep',[]};
Formats(end+1,1).type = 'edit';
Formats(end,1).format = 'integer';
Formats(end,1).size = 50; % automatically assign the height
DefAns.n_rep = 100;
end

%% FINAL STEP
[Answer,Cancelled] = inputsdlg(Prompt,Title,Formats,DefAns,Options);

end
