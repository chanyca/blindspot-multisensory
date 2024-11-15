function drawStim(target, window, stim, env, varargin)


while ~isempty(varargin)
    switch varargin{1}
        case 'ori'
            ori = varargin{2};
        case 'centeredRect'
            centeredRect = varargin{2};
           %centeredRect = OffsetRect(centeredRect, centeredRect, 0, 150);

    end
    varargin(1:2) = [];
end
if string(target) == "fixation"
    Screen('DrawLines', window, stim.fix_coords, stim.fix_lw, env.white, [env.xCenter env.yCenter], 2);
elseif string(target) == "fixation_top"
    Screen('DrawLines', window, stim.fix_coords, stim.fix_lw, env.white, stim.fix_loc, 2);
elseif string(target) == "flash"
    centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter, env.yCenter);
    Screen('FillRect', window, env.white, centeredRect);
elseif string(target) == "reference"
    for f=1:length(stim.ref_loc)
        Screen('FillRect', window, env.grey, stim.ref_loc{f});
    end
elseif string(target) == "grating"
    % Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] 
    % [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    Screen('DrawTextures', window, stim.grating, [], centeredRect, ...
        ori+90, [], [], [], [], [], [stim.phase, stim.freqProbe, stim.contrast, 0]');
elseif string(target) == "teardrop"
   
    %Screen('DrawTexture', window, stim.teardrop, stim.ImageSize1, stim.DestRect1', ori);
    Screen('DrawTexture', window, stim.teardrop, stim.ImageSize1, centeredRect, ori);
    
elseif string(target) == "bar"
    centeredRect = CenterRectOnPointd(stim.baseRect_ver, env.xCenter, env.yCenter);
    Screen('FillRect', window, env.white, centeredRect);

else % text prompt
    DrawFormattedText(window, target, 'center', 'center', env.white);
end