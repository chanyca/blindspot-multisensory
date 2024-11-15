
files = dir('SV*.mat');

% Regular expression to identify the date and time pattern
pattern = '\_\d{2}-\d{2}-\d{4} \d{2}_\d{2}_\d{2}';

for i = 1:length(files)
    oldName = files(i).name;
    newName = regexprep(oldName, pattern, ''); % Remove date and time
    newName = strrep(newName, '__', '_'); % Clean up extra underscores if present
    
    % Rename
    movefile(fullfile(oldName), fullfile(newName));
end

disp('File renaming completed!');
