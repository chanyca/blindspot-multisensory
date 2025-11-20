function BS_mat2csv()
% BS_mat2csv
%
% Build CSVs for each subject from SV*_BS.mat files.
% Columns:
%   subj_id, eye,
%   left_x,  left_y,
%   right_x, right_y,
%   top_x,   top_y,
%   bottom_x,bottom_y,
%   center_x,center_y,
%   source_file
%
% One row per eye (L/R) if available.

%% I/O
[dataDir,~,~] = fileparts(mfilename('fullpath')); %#ok<ASGLU>
inDir  = fullfile('mat');
outDir = fullfile('csv');
if ~exist(outDir, 'dir'), mkdir(outDir); end

matFiles = dir('SV*_BS.mat');
if isempty(matFiles)
    warning('No files found in %s matching SV*_BS.mat', inDir);
    return
end

for i = 1:numel(matFiles)
    fileName = matFiles(i).name;
    fprintf('Processing file: %s\n', fileName);

    S = load(fileName);

    % ---- Subject ID (fallback to filename) ----
    subj_id = '';
    if isfield(S, 'Data') && isstruct(S.Data) && isfield(S.Data, 'SubjectID') && ~isempty(S.Data.SubjectID)
        subj_id = char(string(S.Data.SubjectID));
    elseif isfield(S, 'SubjectID') && ~isempty(S.SubjectID)
        subj_id = char(string(S.SubjectID));
    else
        tok = regexp(matFiles(i).name, 'SV\d{3}', 'match', 'once');
        if isempty(tok), tok = erase(matFiles(i).name, '.mat'); end
        subj_id = tok;
    end

    % ---- Locate BS segments (L/R) in various layouts ----
    BS_L = [];
    BS_R = [];

    if isempty(BS_L) || isempty(BS_R)
        if isfield(S, 'BS_Data') && isstruct(S.BS_Data)
            if isempty(BS_L) && isfield(S.BS_Data, 'BS_L'), BS_L = S.BS_Data.BS_L; end
            if isempty(BS_R) && isfield(S.BS_Data, 'BS_R'), BS_R = S.BS_Data.BS_R; end
        end
    end

    if isempty(BS_L) && isfield(S, 'BS_L'), BS_L = S.BS_L; end
    if isempty(BS_R) && isfield(S, 'BS_R'), BS_R = S.BS_R; end

    % ---- Assemble rows (one per eye if available) ----
    rows = [];

    rows = add_eye_row(rows, subj_id, 'L', BS_L, matFiles(i).name);
    rows = add_eye_row(rows, subj_id, 'R', BS_R, matFiles(i).name);

    if isempty(rows)
        warning('No BS segments found for %s. Skipping.', matFiles(i).name);
        continue
    end

    % ---- Table in required column order ----
    varNames = {'subj_id','eye', ...
        'left_x','left_y','right_x','right_y','top_x','top_y','bottom_x','bottom_y', ...
        'center_x','center_y','source_file'};

    T = struct2table(rows, 'AsArray', true);
    % Round all numeric columns to 2 decimals (already rounded inside add_eye_row, but double-sure)
    numCols = varfun(@isnumeric, T, 'OutputFormat', 'uniform');
    T{:, numCols} = round(T{:, numCols}, 2);
    T = T(:, varNames);

    % ---- Write out per-subject CSV (append if multiple files per subject) ----
    outCsv = fullfile(outDir, sprintf('%s_BS.csv', subj_id));
    if exist(outCsv, 'file')
        % Append without headers
        writetable(T, outCsv, 'WriteMode', 'Append', 'WriteVariableNames', false);
    else
        writetable(T, outCsv);
    end

    fprintf('  Wrote %d row(s) to %s\n', height(T), outCsv);
end

fprintf('Done.\n');

end

%% ----------------- Helpers -----------------

function rows = add_eye_row(rows, subj_id, eyeCode, seg, source_name)
% Add one row for the given eye if segment struct is valid.

if isempty(seg) || ~isstruct(seg), return; end
need = {'left','top','right','bottom'};
if ~all(isfield(seg, need))
    return
end

left   = vec2(seg.left);
top    = vec2(seg.top);
right  = vec2(seg.right);
bottom = vec2(seg.bottom);

% Center from corners: [cx, cy] = [top.x, left.y]
center = [top(1), left(2)];

% Round all to 2 decimals
left    = round(left,   2);
right   = round(right,  2);
top     = round(top,    2);
bottom  = round(bottom, 2);
center  = round(center, 2);

% Build a row struct
rows = [rows; struct( ...
    'subj_id',    string(subj_id), ...
    'eye',        string(eyeCode), ...
    'left_x',     left(1),  'left_y',   left(2), ...
    'right_x',    right(1), 'right_y',  right(2), ...
    'top_x',      top(1),   'top_y',    top(2), ...
    'bottom_x',   bottom(1),'bottom_y', bottom(2), ...
    'center_x',   center(1),'center_y', center(2), ...
    'source_file',string(source_name))];
end

function v = vec2(x)
% Ensure a 1x2 [x y] row vector from common shapes
v = double(x);
if numel(v)==2
    v = reshape(v,1,2);
elseif size(v,1)==2 && size(v,2)>=1
    v = v(1:2,1).';
elseif size(v,2)==2 && size(v,1)>=1
    v = v(1,1:2);
else
    error('Corner not a 2-vector.');
end
end
