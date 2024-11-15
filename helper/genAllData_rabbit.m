function allData = genAllData_rabbit
% Example usage: allData = genAllData_rabbit


%% Important directories

userID = extractBetween(pwd,['Users',filesep], filesep);
baseDir = [extractBefore(pwd, 'blindspot-multisensory'), 'blindspot-multisensory'];

d.homeDir = baseDir;
d.dataDir = char(fullfile(d.homeDir, 'Data'));
d.BSdataDir = char(fullfile(baseDir, 'bs_data'));

%% Get list of data files
dataList = dir(fullfile(d.dataDir, 'SV*.mat'));

for ind = 1:numel(dataList)
    data = extractData(dataList(ind), d);
    allData(ind) = data;
end

allData = groupData(allData);

% save
save(fullfile(d.dataDir, 'allData.mat'), 'allData');

clear data i dataList

%% Generate table of blind spot measurements

% subject IDs
sids = {allData(cellfun(@(x) contains(x, 'SV'), {allData.SID})).SID};
sids = unique(sids);

% Left eye blind spot
var_names = {'Horizontal distance', 'Vertical distance', 'Width', 'Height', 'Area', ...
             'x_center', 'y_center', 'width_pix', 'height_pix', 'area_pix'};
Left = table(allData(end-2).bs.hor_dist.', allData(end-2).bs.ver_dist.', ...
             allData(end-2).bs.hor_r.'*2, allData(end-2).bs.ver_r.'*2, ...
             allData(end-2).bs.area.', allData(end-2).bs.hor_dist_pix.', ...
             allData(end-2).bs.ver_dist_pix.', allData(end-2).bs.width_pix.'*2, ...
             allData(end-2).bs.height_pix.'*2, allData(end-2).bs.area_pix.', ...
             'VariableNames', var_names);

% Right eye blind spot
Right = table(allData(end-1).bs.hor_dist.', allData(end-1).bs.ver_dist.', ...
              allData(end-1).bs.hor_r.'*2, allData(end-1).bs.ver_r.'*2, ...
              allData(end-1).bs.area.', allData(end-1).bs.hor_dist_pix.', ...
              allData(end-1).bs.ver_dist_pix.', allData(end-1).bs.width_pix.'*2, ...
              allData(end-1).bs.height_pix.'*2, allData(end-1).bs.area_pix.', ...
              'VariableNames', var_names);

% Calculate means and std deviations
% Left
Left_mean = varfun(@mean, Left, 'InputVariables', @isnumeric, 'OutputFormat', 'uniform');
Left_std = varfun(@std, Left, 'InputVariables', @isnumeric, 'OutputFormat', 'uniform');
% append to the end
Left = [Left; num2cell(Left_mean); num2cell(Left_std)];
% Right
Right_mean = varfun(@mean, Right, 'InputVariables', @isnumeric, 'OutputFormat', 'uniform');
Right_std = varfun(@std, Right, 'InputVariables', @isnumeric, 'OutputFormat', 'uniform');
% append to the end
Right = [Right; num2cell(Right_mean); num2cell(Right_std)];

% Concatenate Participant, Left and Right into a single table
T = table(Left, Right, 'RowNames', [sids.'; {'Mean'}; {'Standard deviation'}]);

save(fullfile(d.dataDir, 'BS.mat'), 'T', 'Left_mean', 'Left_std', ...
            'Right_mean', 'Right_std');

% Flattening the nested tables
T = splitvars(T, 'Left');
T = splitvars(T, 'Right');
Participant = table([sids.'; {'Mean'}; {'Standard deviation'}]);
T = [Participant, T];

% round to 2 s.f.
numericVars = varfun(@isnumeric, T, 'OutputFormat', 'uniform');  % Find numeric variables
T{:, numericVars} = round(T{:, numericVars}, 2);

% Display the flattened table
disp(T);

% Now you can write the flattened table to a CSV file
writetable(T, fullfile(d.dataDir, 'BS_table.csv'))

return

%% helper function
function data = extractData(dataInfo, d, varargin)

% fields
% SID, eye, bs.left...bottom, ctrl.left...bottom, 

% load data
load(fullfile(dataInfo.folder,dataInfo.name), 'Data');

% extract data
data.SID        = Data.SubjectID;
try
    data.eye        = Data.Eye;
    data.glasses    = Data.glasses;
end

%% find blindspot data

bsList = dir( [d.BSdataDir, filesep, sprintf('%s*%s_BS.mat', data.SID , data.glasses)]);
load(fullfile(d.BSdataDir, bsList.name), 'BS_Data');

if data.eye == 'L'
    eye_prefix = 'BS_L';
    ctrl_prefix = 'BS_R';
else
    eye_prefix = 'BS_R';
    ctrl_prefix = 'BS_L';
end

eye_fields = {'left', 'right', 'top', 'bottom'};
for i = 1:length(eye_fields)
    data.bs.(eye_fields{i}) = BS_Data.(eye_prefix).(eye_fields{i});
    data.ctrl.(eye_fields{i}) = BS_Data.(ctrl_prefix).(eye_fields{i});
end

data.bs.center = [data.bs.top(1), data.bs.left(2)];
data.ctrl.center = [data.ctrl.top(1), data.ctrl.left(2)];

% calculate distance from center (deg)
x_pixels = 3840; y_pixels = 2160;
pix_size = 600/x_pixels;
view_dist = 570*2;

% VA formula: 2 * atand ( size in mm / viewDist*2)
data.bs.hor_dist = 2*atand(abs(data.bs.center(1) - x_pixels/2)*pix_size / view_dist);
data.bs.ver_dist = 2*atand(abs(data.bs.center(2) - y_pixels/2)*pix_size / view_dist); % positive, below horizontal meridian
% area for an eclipse = pi * r1 * r2
data.bs.hor_r = 2*atand( abs(data.bs.left(1) - data.bs.center(1))*pix_size / view_dist);
data.bs.ver_r = 2*atand( abs(data.bs.top(2) - data.bs.center(2))*pix_size / view_dist);
data.bs.area = pi * data.bs.hor_r * data.bs.ver_r;

% in pixel value
data.bs.hor_dist_pix = abs(data.bs.center(1) - x_pixels/2);
data.bs.ver_dist_pix = abs(data.bs.center(2) - y_pixels/2);
data.bs.width_pix = abs(data.bs.left(1) - data.bs.center(1));
data.bs.height_pix = abs(data.bs.top(2) - data.bs.center(2));
data.bs.area_pix = pi * data.bs.width_pix * data.bs.height_pix;


%% flash data

data.acc = struct(); data.avg = struct(); data.percentage = struct();
data.probLoc = struct();

% sort by stimLoc
stimLoc.bsF2 = 1:4;   stimLoc.bsF3 = 9:12;
stimLoc.ctrlF2 = 5:8; stimLoc.ctrlF3 = 13:16;

% easier to keep it in double array for calculations
tempFlashData = [Data.Conditions(Data.Conditions(:,3) == 1,1:2), Data.ResponsesF.'];

where = {'bs' 'ctrl'};
nf = {'' 'F2' 'F3'};
nb = [0 2 3];

for w=where
    for f=2:3
        i=1;
        [data.([w{1} nf{f}]).all, sort_idx] = sortrows(tempFlashData(ismember(tempFlashData(:,1),stimLoc.([w{1} nf{f}])),:));
        % acc, avg
        data.acc(i).([w{1} nf{f}]) = sum(data.([w{1} nf{f}]).all(:,end) - f ==0)/length(data.([w{1} nf{f}]).all);
        data.avg(i).([w{1} nf{f}]) = mean(data.([w{1}  nf{f}]).all(:,end));
        i=i+1;

        % get flash locations, sorted
        loc = Data.Flash_loc(ismember(tempFlashData(:,1),stimLoc.([w{1} nf{f}]))).';
        loc = loc(sort_idx);
        % sort flash locations left to right, top to bottom
        % loc = sortLocations(data.([w{1} nf{f}]).all(:,1), loc);
        % convert double to cell, append last column
        tmp = num2cell(data.([w{1} nf{f}]).all);
        cellArr = countLocations(loc);
        data.([w{1} nf{f}]).all = [tmp, loc, cellArr];
        
        % take first 3 columns from all, convert to double
        tmp_all = cell2mat(data.([w{1} nf{f}]).all(:,1:3));
        for b=nb
            % data.([w{1} nf{f}]).(['B' num2str(b)]) = data.([w{1} nf{f}]).all(data.([w{1} nf{f}]).all(:,2)==b,[1 3]);
            data.([w{1} nf{f}]).(['B' num2str(b)]) = tmp_all(tmp_all(:,2)==b,:);
            % acc, avg
            data.acc(i).([w{1} nf{f}]) = sum(data.([w{1} nf{f}]).(['B' num2str(b)])(:,end) - f ==0)/length(data.([w{1} nf{f}]).(['B' num2str(b)]));
            data.avg(i).([w{1} nf{f}]) = mean(data.([w{1} nf{f}]).(['B' num2str(b)])(:,end));
            i=i+1;

            % percentage of each responses
            for resp=0:4
                data.percentage(resp+1).([w{1} nf{f} 'B' num2str(b)]) = mean(data.([w{1} nf{f}]).(['B' num2str(b)])(:,end) == resp);
            end

            % get flash locations, sorted
            loc_sub = loc(tmp_all(:,2)==b);
            % convert double to cell, append last column
            tmp = num2cell(data.([w{1} nf{f}]).(['B' num2str(b)]));
            cellArr = countLocations(loc_sub);
            data.([w{1} nf{f}]).(['B' num2str(b)]) = [tmp, loc_sub, cellArr];
            clear tmp

            % get resp (col 3) and location hit array (col 5:end)
            tmp = cell2mat(data.([w{1} nf{f}]).(['B' num2str(b)])(:,[3,5:end]));
            for resp=0:4
                idx = tmp(:,1)==resp;
                % get mean
                % data.probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:) = mean(tmp(idx,2:end),1);
                data.probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:) = sum(tmp(idx,2:end),1)/length(tmp); % over 20 trials in one beep condition
                % data.probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:) = fillmissing(data.probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:), 'constant', 0);
            end

            % only keep resp==2 rows
            % count occurrence of each pair [2,3], [2,4], [3,4]
            idx = tmp(:,1)==2;
            two_pairs = cell2mat(loc_sub(idx));  % Convert cell array to a double matrix
            % condN = size(two_pairs, 1);          % Number of pairs
            possible_pairs = nchoosek([1,2,3,4,5],2);
            percentages = zeros(1, size(possible_pairs, 1));
            
            if ~isempty(two_pairs)
                for iii = 1:size(possible_pairs, 1)
                    current_pair = sort(possible_pairs(iii, :));  % Sort the current pair to ignore order
                    % Sort rows of two_pairs and compare with the current pair
                    sorted_two_pairs = sort(two_pairs, 2);  % Sort the rows of two_pairs
                    percentages(iii) = sum(ismember(sorted_two_pairs, current_pair, 'rows')); % / condN;
                end

                data.two_pair.([w{1} nf{f} 'B' num2str(b)]) = percentages;
                % if abs(sum(percentages) - 1) > eps
                %     error('The sum of percentages is not equal to 1.');
                % end

            else % if two_pairs is empty, store zero array
                data.two_pair.([w{1} nf{f} 'B' num2str(b)]) = percentages;
            end
        end
    end
end

%% extra flash localization trials

data.F_extra = [num2cell(Data.ConditionsF_extra).', num2cell(Data.ResponsesF_extra).', Data.Flash_loc_extra.'];

to_include = {'SV009' 'SV012' 'SV026' 'SV027' 'SV028' 'SV029' ...
              'SV030' 'SV031' 'SV032' 'SV033'};
if ismember(data.SID, to_include)
    illusory_dist = []; third_dist = []; inside_bs = [];
    for i=1:length(data.F_extra)
        [illusory_dist(i,:), third_dist(i,:), inside_bs(i,:)] = dist_from_veridical(data.bs, data.ctrl, data.F_extra{i,1}, data.F_extra{i,end});
    end
    data.F_extra = [data.F_extra, num2cell(illusory_dist), num2cell(third_dist), num2cell(inside_bs)];
    data.inBS = mean(inside_bs, 'omitnan');
else
    data.inBS = nan;
end




%% Count occurences of locations
    function cellArr = countLocations(loc)
        cellArr = [];
        for target=1:5
            cellArr = [cellArr, cellfun(@(x) any(ismember(x, target)), loc)];
        end
        cellArr = num2cell(cellArr);
    end
%% beep data
tempBeepData = [Data.Conditions(Data.Conditions(:,3) == 2,1:2), Data.ResponsesB.', Data.RT_B.'];

for w=where
    for f=2:3
        i=1;
        var = [w{1} nf{f} '_b'];
        [data.(var).all, sort_idx] = sortrows(tempBeepData(ismember(tempBeepData(:,1),stimLoc.([w{1} nf{f}])),:));
        % acc, avg
        data.acc(i).(var) = sum(data.(var).all(:,3) - data.(var).all(:,2) ==0)/length(data.(var).all);
        data.avg(i).(var) = mean(data.(var).all(:,end));
        i=i+1;
        
        for b=nb
            data.(var).(['B' num2str(b)]) = data.(var).all(data.(var).all(:,2)==b,:);
            % acc, avg
            data.acc(i).(var) = sum(data.(var).(['B' num2str(b)])(:,3) - b ==0)/length(data.(var).(['B' num2str(b)]));
            data.avg(i).(var) = mean(data.(var).(['B' num2str(b)])(:,3));
            i=i+1;
        end
    end
end

end % end of function extractData

function allData = groupData(allData)
% fields to OMIT
% glasses, bs, ctrl

fields = fieldnames(allData).';

eye = {'L' 'R'};
for e=eye
    for f=fields
        grpS.(f{1}) = [];
    end
    s = allData(cellfun(@(x) strcmp(x, e{1}), {allData.eye}));
    
    grpS.SID     = 'group';
    grpS.eye     = e{1};
    grpS.glasses = '';

    where = {'bs' 'ctrl'};
    nf = {'F2' 'F3'};
    nb = [0 2 3];
    suffix = {'' '_b'};

    % group acc, avg
    fields = {'acc' 'avg'};
    for a=fields
        for n=1:numel(s)
            for i=1:4
                for b=1:2
                    grpS.(a{1})(i).(['bsF2' suffix{b}])(n) = s(n).(a{1})(i).(['bsF2' suffix{b}]);
                    grpS.(a{1})(i).(['bsF3' suffix{b}])(n) = s(n).(a{1})(i).(['bsF3' suffix{b}]);
                    grpS.(a{1})(i).(['ctrlF2' suffix{b}])(n) = s(n).(a{1})(i).(['ctrlF2' suffix{b}]);
                    grpS.(a{1})(i).(['ctrlF3' suffix{b}])(n) = s(n).(a{1})(i).(['ctrlF3' suffix{b}]);
                end
            end
            % group bs
            grpS.bs.hor_dist(n) = s(n).bs.hor_dist;
            grpS.bs.ver_dist(n) = s(n).bs.ver_dist;
            grpS.bs.hor_r(n) = s(n).bs.hor_r;
            grpS.bs.ver_r(n) = s(n).bs.ver_r;
            grpS.bs.area(n) = s(n).bs.area;
            grpS.bs.hor_dist_pix(n) = s(n).bs.hor_dist_pix;
            grpS.bs.ver_dist_pix(n) = s(n).bs.ver_dist_pix;
            grpS.bs.width_pix(n) = s(n).bs.width_pix;
            grpS.bs.height_pix(n) = s(n).bs.height_pix;
            grpS.bs.area_pix(n) = s(n).bs.area_pix;
        end
    end

    % group percentage, probLoc
    for w=where
        for f=1:2
            for b=nb
                for resp=0:4  
                    tmpArr = [];
                    for n=1:numel(s)
                        grpS.percentage(resp+1).([w{1} nf{f} 'B' num2str(b)])(n) = s(n).percentage(resp+1).([w{1} nf{f} 'B' num2str(b)]);
                        % save the trouble, calculate mean
                        tmpArr = [tmpArr; s(n).probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:)];
                    end
                    grpS.probLoc.([w{1} nf{f} 'B' num2str(b)])(resp+1,:) = mean(tmpArr,1, 'omitnan');
                end

                for n=1:numel(s)
                    grpS.two_pair.([w{1} nf{f} 'B' num2str(b)])(n,:) = s(n).two_pair.([w{1} nf{f} 'B' num2str(b)]);
                end
            end
        end
    end

    % group.bsF2, bsF3, ctrlF2, ctrlF3
    % cols: stimLoc, nBeep, Resp, flashLoc
    % all, B0, B2, B3
    conds = {'all' 'B0' 'B2' 'B3'};

    for w=where
        for f=nf
            for c=conds
                grpS.([w{1} f{1}]).(c{1})(:,1:2) = s(1).([w{1} f{1}]).(c{1})(:,1:2);
                resp_array = [];
                flashLoc_cell = {};
                for n=1:numel(s)
                    resp_array(:,end+1) = cell2mat(s(n).([w{1} f{1}]).(c{1})(:,3));
                    flashLoc_cell(:,end+1) = s(n).([w{1} f{1}]).(c{1})(:,4);
                end
                grpS.([w{1} f{1}]).(c{1})(:,3) = num2cell(resp_array,2);
                grpS.([w{1} f{1}]).(c{1})(:,4) = cellfun(@(x) {x}, num2cell(flashLoc_cell, 2));

                locCnt_array = {};
                for col=5:9
                    tmp = [];
                    for n=1:numel(s)
                        tmp(:,end+1) = cell2mat(s(n).([w{1} f{1}]).(c{1})(:,col));
                    end
                    locCnt_array(:,end+1) = num2cell(tmp,2);
                end
                grpS.([w{1} f{1}]).(c{1})(:,5:9) = locCnt_array;
            end
        end
    end
    allData(end+1) = grpS;
end

% combine both eyes
s = allData(cellfun(@(x) strcmp(x, 'group'), {allData.SID}));
fields = fieldnames(allData).';

for f=fields
    grpS.(f{1}) = [];
end

grpS.SID     = 'group';
grpS.eye     = 'both';
grpS.glasses = '';

% group acc, avg
fields = {'acc' 'avg'};
for a=fields
    for i=1:4
        for b=1:2
            grpS.(a{1})(i).(['bsF2' suffix{b}]) = mean([s(1).(a{1})(i).(['bsF2' suffix{b}]); s(2).(a{1})(i).(['bsF2' suffix{b}])],1);
            grpS.(a{1})(i).(['bsF3' suffix{b}]) = mean([s(1).(a{1})(i).(['bsF3' suffix{b}]); s(2).(a{1})(i).(['bsF3' suffix{b}])],1);
            grpS.(a{1})(i).(['ctrlF2' suffix{b}]) = mean([s(1).(a{1})(i).(['ctrlF2' suffix{b}]); s(2).(a{1})(i).(['ctrlF2' suffix{b}])],1);
            grpS.(a{1})(i).(['ctrlF3' suffix{b}]) = mean([s(1).(a{1})(i).(['ctrlF3' suffix{b}]); s(2).(a{1})(i).(['ctrlF3' suffix{b}])],1);
        end
    end
end

% group percentage
for n=1:numel(s)
    for w=where
        for f=1:2
            for b=nb
                for resp=0:4
                    grpS.percentage(resp+1).([w{1} nf{f} 'B' num2str(b)]) = mean([s(1).percentage(resp+1).([w{1} nf{f} 'B' num2str(b)]); s(2).percentage(resp+1).([w{1} nf{f} 'B' num2str(b)])],1);
                    grpS.probLoc.([w{1} nf{f} 'B' num2str(b)])= mean( cat(3, s(1).probLoc.([w{1} nf{f} 'B' num2str(b)]), s(2).probLoc.([w{1} nf{f} 'B' num2str(b)])), 3, 'omitnan');
                end
                grpS.two_pair.([w{1} nf{f} 'B' num2str(b)]) = [s(1).two_pair.([w{1} nf{f} 'B' num2str(b)]); s(2).two_pair.([w{1} nf{f} 'B' num2str(b)])];
            end
        end
    end
end

% append to the end
allData(end+1) = grpS;

end % end of function groupData


    function [illusory_dist, third_dist, inside_bs] = dist_from_veridical(bs, ctrl, loc, resp)

    % normalized distance
    
    % VA formula: 2*atand( size in mm / viewDist)
    pixSize = 600/3840;
    viewDist = 570*2;
    half = (tand(.5)/2*viewDist)/pixSize;
    
    stimLoc =  {{[bs.left(1)-half, bs.left(2)],     bs.center, [bs.right(1)+half, bs.right(2)]};
                {[bs.right(1)+half, bs.right(2)],   bs.center, [bs.left(1)-half, bs.left(2)]};
                {[bs.top(1), bs.top(2)-half],       bs.center, [bs.bottom(1), bs.bottom(2)+half]};
                {[bs.bottom(1), bs.bottom(2)+half], bs.center, [bs.top(1), bs.top(2)-half]};
                {[ctrl.left(1)-half, ctrl.left(2)],     ctrl.center, [ctrl.right(1)+half, ctrl.right(2)]}; 
                {[ctrl.right(1)+half, ctrl.right(2)],   ctrl.center, [ctrl.left(1)-half, ctrl.left(2)]};
                {[ctrl.top(1), ctrl.top(2)-half],       ctrl.center, [ctrl.bottom(1), ctrl.bottom(2)+half]};
                {[ctrl.bottom(1), ctrl.bottom(2)+half], ctrl.center, [ctrl.top(1), ctrl.top(2)-half]}};

    if loc<=8
        flash_loc = stimLoc{loc};
    else
        flash_loc = stimLoc{loc-8};
    end

    % Define bs_loc
    bs_loc = [1:4, 9:12];

    % Initialize inside_bs as NaN if loc is not in bs_loc
    if ~ismember(loc, bs_loc)
        inside_bs = nan;
    else
        inside_bs = false;  % default to false if loc is in bs_loc
    end

    % half_dist = dist_between_pts(flash_loc{1}, flash_loc{2});
    % half_dist = 2*atand( half_dist*pixSize/ viewDist);

    if size(resp,2)==2 % 3 flahses perceived

        % find the flash closer to 1st flash
        % save as illusory flash
        if dist_between_pts(flash_loc{1}, resp(:,1).') < dist_between_pts(flash_loc{1}, resp(:,2).')
            illusory_flash = resp(:,1).';            
            third_flash = resp(:,2).';            
        else
            illusory_flash = resp(:,2).';
            third_flash = resp(:,1).';
        end

        % calculate illusory flash distance
        illusory_dist = dist_between_pts(flash_loc{2}, illusory_flash);

        % if illusory flash is closer to 1st flash than 2nd, negative
        dist_from_1st = dist_between_pts(flash_loc{1}, illusory_flash);
        dist_from_3rd = dist_between_pts(flash_loc{3}, illusory_flash);
        if dist_from_1st < dist_from_3rd
            illusory_dist = -1*illusory_dist;
        end

        % Check if illusory flash is inside the bs ellipse if loc is in bs_loc
        if ismember(loc, bs_loc)
            a = abs(bs.right(1) - bs.left(1)) / 2;  % Semi-major axis
            b = abs(bs.top(2) - bs.bottom(2)) / 2;  % Semi-minor axis
            xc = bs.center(1);
            yc = bs.center(2);
            x = illusory_flash(1);
            y = illusory_flash(2);

            % Check if within ellipse
            if ((x - xc)^2 / a^2 + (y - yc)^2 / b^2) <= 1
                inside_bs = true;
            end
        end

    elseif size(resp,2)==1 % 2 flashes perceived
        illusory_dist = nan;
        third_flash = resp.';
        inside_bs = nan;

    else % invalid response
        illusory_dist = nan;
        third_dist = nan;
        inside_bs = nan;
        return
    end

    % calculate 'third' flash distance
    third_dist = dist_between_pts(flash_loc{3}, third_flash);


    % if third is closer to 1st flash than actual distance between 1st and
    % 3rd flash, negative
    dist_flash_1_3 = dist_between_pts(flash_loc{1}, flash_loc{3});
    third_from_1st = dist_between_pts(flash_loc{1}, third_flash);
    if third_from_1st < dist_flash_1_3
        third_dist = -1*third_dist;
    end

    % normalize distance
    illusory_dist = illusory_dist / dist_flash_1_3;
    third_dist = third_dist / dist_flash_1_3;

    % % convert pixel distance to visual angle
    % illusory_dist = 2*atand( illusory_dist*pixSize/ viewDist);
    % third_dist = 2*atand( third_dist*pixSize/ viewDist);    

end % end of function dist_from_veridical

function dist = dist_between_pts(pt1, pt2)
    % points are double array: [x, y]
    dist = sqrt( (pt1(1) - pt2(1))^2 + (pt1(2) - pt2(2))^2 );
end % end of function dist_between_pts

function isBS, isIN = is_in_BS(pt, bs, loc)
    bs_loc = [1:4, 9:12];

end % end of function is_in_BS

end % end of genAllData_rabbit