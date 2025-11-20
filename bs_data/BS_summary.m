function BS_summary()

%% Screen/env
env.screenXpixels = 3840; 
env.screenYpixels = 2160;
xCenter = env.screenXpixels / 2;
yCenter = env.screenYpixels / 2;
outCsvPath = 'bs_summary.csv';

%% Visual degree calculation
screenWidthMm = 600; % mm
pixSizeMm     = screenWidthMm / env.screenXpixels;   % mm / pixel
viewDistMm    = 570; % mm
degPerPix     = 2 * atand( (pixSizeMm/2) / viewDistMm );  % degrees per pixel


%% load files
files  = dir('SV*BS.mat');
if isempty(files)
    warning('No files found matching SV*BS.mat in %s', d.BSdataDir);
end

%% Start building csv
rows = [];

for i = 1:numel(files)
    fpath = fullfile(files(i).folder, files(i).name);
    S = load(fpath);

    if isfield(S, 'SubjectID') && ~isempty(S.SubjectID)
        subjID = string(S.SubjectID);
    else
        tok = regexp(files(i).name, 'SV\d{3}', 'match', 'once');
        if isempty(tok), tok = erase(files(i).name, '.mat'); end
        subjID = string(tok);
    end

    BS_L = []; BS_R = [];
    if isfield(S, 'BS_Data') && isstruct(S.BS_Data)
        if isfield(S.BS_Data, 'BS_L'), BS_L = S.BS_Data.BS_L; end
        if isfield(S.BS_Data, 'BS_R'), BS_R = S.BS_Data.BS_R; end
    end
    if isempty(BS_L) && isfield(S, 'BS_L'), BS_L = S.BS_L; end
    if isempty(BS_R) && isfield(S, 'BS_R'), BS_R = S.BS_R; end

    for eyeCode = ["L","R"]
        bsSeg = []; 
        if eyeCode=="L" && ~isempty(BS_L), bsSeg = BS_L; end
        if eyeCode=="R" && ~isempty(BS_R), bsSeg = BS_R; end
        if isempty(bsSeg), continue; end

        if ~all(isfield(bsSeg, {'left','top','right','bottom'}))
            continue
        end

        left   = vec2(bsSeg.left);
        top    = vec2(bsSeg.top);
        right  = vec2(bsSeg.right);
        bottom = vec2(bsSeg.bottom);

        center = [top(1), left(2)];            % [cx cy]
        radius_hor_px = center(1) - left(1);   % px
        radius_ver_px = bottom(2) - center(2); % px

        % Convert to degrees
        radius_hor_deg = radius_hor_px * degPerPix;
        radius_ver_deg = radius_ver_px * degPerPix;

        % Distances (absolute/Euclidean) in degrees using xCenter/yCenter
        dx_px = center(1) - xCenter;
        dy_px = center(2) - yCenter;

        dist_from_fixation_deg      = hypot(dx_px*degPerPix, dy_px*degPerPix);
        dist_from_hor_meridian_deg  = abs(dx_px) * degPerPix; % |x - xCenter| in deg
        dist_from_ver_meridian_deg  = abs(dy_px) * degPerPix; % |y - yCenter| in deg

        % Width/height in degrees
        width_in_deg  = abs(right(1)  - left(1))  * degPerPix;
        height_in_deg = abs(bottom(2) - top(2))   * degPerPix;

        % Round everything to 2 decimals
        radius_hor_deg             = round(radius_hor_deg, 2);
        radius_ver_deg             = round(radius_ver_deg, 2);
        dist_from_fixation_deg     = round(dist_from_fixation_deg, 2);
        dist_from_hor_meridian_deg = round(dist_from_hor_meridian_deg, 2);
        dist_from_ver_meridian_deg = round(dist_from_ver_meridian_deg, 2);
        width_in_deg               = round(width_in_deg, 2);
        height_in_deg              = round(height_in_deg, 2);

        % Format coordinate 
        left_x   = left(1);   left_y   = left(2);
        top_x    = top(1);    top_y    = top(2);
        right_x  = right(1);  right_y  = right(2);
        bottom_x = bottom(1); bottom_y = bottom(2);
        center_x = center(1); center_y = center(2);

        % Add row
        rows = [rows; struct( ...
            'subjID',                      subjID, ...
            'eye',                         string(eyeCode), ...
            'left_x',                      left_x, ...
            'left_y',                      left_y, ...
            'top_x',                       top_x, ...
            'top_y',                       top_y, ...
            'right_x',                     right_x, ...
            'right_y',                     right_y, ...
            'bottom_x',                    bottom_x, ...
            'bottom_y',                    bottom_y, ...
            'center_x',                    center_x, ...
            'center_y',                    center_y, ...
            'radius_hor_deg',              radius_hor_deg, ...
            'radius_ver_deg',              radius_ver_deg, ...
            'dist_from_fixation_deg',      dist_from_fixation_deg, ...
            'dist_from_hor_meridian_deg',  dist_from_hor_meridian_deg, ...
            'dist_from_ver_meridian_deg',  dist_from_ver_meridian_deg, ...
            'width_in_deg',                width_in_deg, ...
            'height_in_deg',               height_in_deg, ...
            'source_file',                 string(files(i).name) ...
        )];
    end
end

varNames = {'subjID','eye', ...
            'left_x','left_y','top_x','top_y','right_x','right_y', ...
            'bottom_x','bottom_y','center_x','center_y', ...
            'radius_hor_deg','radius_ver_deg','dist_from_fixation_deg', ...
            'dist_from_hor_meridian_deg','dist_from_ver_meridian_deg', ...
            'width_in_deg','height_in_deg','source_file'};

if isempty(rows)
    T = cell2table(cell(0,numel(varNames)), 'VariableNames', varNames);
else
    T = struct2table(rows, 'AsArray', true);
    T = T(:, varNames);
end

writetable(T, outCsvPath);
fprintf('Wrote %d rows to %s\n', height(T), outCsvPath);

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