function [trials] = genTrials(Answer)

%% Trials
% 8 locations (4 in blind spot, 4 in control)
% CONDITIONS:
% 0B2F          0B3F
% 2B2F          2B3F***
% 3B2F***       3B3F
% Column 1: location
% Column 2: nBeeps
% Column 3: Response 1/2/3
% respond codes
% 1 - flash
% 2 - beep/vibration
% 3 - vibration/ tactile

%% Create trials
nLoc = 16; %8;
rep = 5;

% no of flashes indicated in params stimLoc, no need to specify here
nBeep = [0,2,3];

%% part one - mouse click to incidace flash location(s)
tempTrials = []; tr=1; % counter
for i=1:nLoc
    for n=1:rep
        for b=nBeep
            tempTrials(end+1,:) = [i, b, 1]; % location, # beeps, response
        end
    end
end

% shuffle
random = randperm(size(tempTrials,1));
j = 1;
for i=random
    trialspt1(j,:) = tempTrials(i,:);
    j=j+1;
end

%% part two - audio/tactile/both, randomized

if length(Answer.task) == 2 && contains(Answer.task, 'A')    
    respTypes = 2;
elseif length(Answer.task) == 2 && contains(Answer.task, 'T')    
    respTypes = 3;
elseif Answer.task == 'ATV'    
    respTypes = [2 3];
end

tempTrials = []; tr=1; % counter
for i=1:nLoc
    for n=1:rep
        for b=nBeep
            for r=respTypes
                tempTrials(end+1,:) = [i, b, r]; % location, # beeps, response
            end
        end
    end
end

% shuffle
random = randperm(size(tempTrials,1));
j = 1;
for i=random
    trialspt2(j,:) = tempTrials(i,:);
    j=j+1;
end


%% Output
trials = [trialspt1; trialspt2];


