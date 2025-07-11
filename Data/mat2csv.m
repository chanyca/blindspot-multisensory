%% mat2csv
%
% DESCRIPTION
% Build CSVs for each subject
% Columns: 
%     - Subject ID: subj_id
%     - Eye: eye
%     - Trial Number: trial_no
%     - No of Flashes: n_flash
%     - No of Beeps: n_beep
%     - Direction: horziontal 0, vertical 1
%     - Blind spot: no 0, yes 1
%     - Response
%     - Response type: flash 1, beep 2
%     - loc_1: hit for location 1
%     - loc_2: hit for location 2
%     - loc_3: hit for location 3
%     - loc_4: hit for location 4
%     - loc_5: hit for location 5

[dataDir,~,~] = fileparts(mfilename('fullpath'));

matFiles = dir('mat/SV*.mat');

for i = 1:length(matFiles)
    fileName = fullfile('mat', matFiles(i).name); 
    fprintf('Processing file: %s\n', fileName);    
    load(fileName, 'Data');

    % Extract relevant fields
    subj_id = Data.SubjectID; % Assuming the subject ID is stored in Data.SubjectID
    eye = Data.Eye; % Assuming eye information is stored in Data.Eye
    
    num_trials = size(Data.Conditions, 1);
    trial_no = 1:size(Data.Conditions,1); 

    location_trials = [Data.Conditions(:,1)];

    % Determine the number of flashes and blindspot
    stimLoc.bsF2 = 1:4; stimLoc.bsF3 = 9:12;
    stimLoc.ctrlF2 = 5:8; stimLoc.ctrlF3 = 13:16;
    
    n_flash = zeros(size(location_trials));
    blindspot = zeros(size(location_trials));

    for t = 1:length(location_trials)
        if ismember(location_trials(t), stimLoc.bsF2)
            n_flash(t) = 2;
            blindspot(t) = 1;
        elseif ismember(location_trials(t), stimLoc.bsF3)
            n_flash(t) = 3;
            blindspot(t) = 1;
        elseif ismember(location_trials(t), stimLoc.ctrlF2)
            n_flash(t) = 2;
            blindspot(t) = 0;
        elseif ismember(location_trials(t), stimLoc.ctrlF3)
            n_flash(t) = 3;
            blindspot(t) = 0;
        end
    end

    % Determine direction of flash movement
    verLoc = [1 2 5 6 9 10 13 14];
    direction = ismember(location_trials, verLoc); % Assuming 0 = horizontal, 1 = vertical

    n_beep = [Data.Conditions(:,2)];
    response = [Data.ResponsesF, Data.ResponsesB];
    response_type = [Data.Conditions(:,3)];

    % Get location hits
    flash_loc = Data.Flash_loc;

    loc_1 = zeros(num_trials, 1);
    loc_2 = zeros(num_trials, 1);
    loc_3 = zeros(num_trials, 1);
    loc_4 = zeros(num_trials, 1);
    loc_5 = zeros(num_trials, 1);

    for t = 1:size(flash_loc, 2)
        current_locs = flash_loc{t};
        if isscalar(current_locs)
            % Single location (e.g., 4)
            eval(['loc_' num2str(current_locs) '(t) = 1;']);
        else
            % Multiple locations (e.g., [3,5])
            for loc = current_locs
                eval(['loc_' num2str(loc) '(t) = 1;']);
            end
        end
    end
    
    % Create a table
    T = table(trial_no', n_flash, n_beep, direction, blindspot,  ...
        response', response_type, loc_1, loc_2, loc_3, loc_4, loc_5, ...
        'VariableNames', {'trial_no', 'n_flash', 'n_beep', 'direction', 'blindspot', ...
        'response', 'response_type', 'loc_1', 'loc_2', 'loc_3', 'loc_4', 'loc_5'});
    
    % Add subject ID and eye as additional columns
    T.subj_id = repmat({subj_id}, height(T), 1);
    T.eye = repmat({eye}, height(T), 1);
    
    % Rearrange columns
    T = T(:, {'subj_id', 'eye', 'trial_no', 'n_flash', 'n_beep', 'direction', 'blindspot', ...
        'response', 'response_type', 'loc_1', 'loc_2', 'loc_3', 'loc_4', 'loc_5'});
    
    % Write to a CSV file
    outputFileName = sprintf('%s_%s.csv', subj_id, eye);
    outputDir = fullfile(dataDir, 'csv');
    writetable(T, fullfile(outputDir, outputFileName));
    
    fprintf('CSV file created: %s\n', outputFileName);
end


