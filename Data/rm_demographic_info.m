clear

cd mat\

matFiles = dir('SV*.mat');

for i = 1:length(matFiles)
    fileName = matFiles(i).name; 
    fprintf('Processing file: %s\n', fileName);    
    load(fileName, 'Data');
    
    if isfield(Data, 'Demographic')
        fprintf('Removing field ''Demographic'' from %s\n', fileName);        
        Data = rmfield(Data, 'Demographic');
        save(fileName, 'Data');
    else
        fprintf('Field ''Demographic'' not found in %s\n', fileName);
    end
end

disp('Processing complete.');
