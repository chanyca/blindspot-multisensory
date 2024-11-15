function grad = color_gradients(opt)

red = {'F9C5D1' 'F7ACBF' 'F38AA5' 'E15C7C' 'C23350'};

purple = {'EBDAFF' 'C8B1E4' '9B72CF' '6636A5' '4C2A77'};

green = {'DEEFB7' 'C8DD96' '9BB55F' '728740' '56682C'};

blue = {'A7DEFE' '6BBBE3' '008CCD' '0066A1' '00476B'};

lightblue = {'ECF2FF' 'D9EBFC' 'AECBEB' '83B0E1' '71A5DE'};

brown = {'B2A496' '9D8977' '886E58' '735238' '5E3719'};

yellow = {'FFECAD' 'FFE285' 'FFD95C' 'FFCF33' 'FFC60A'};

brick = {'E18437' 'D86126' 'C04B10' 'A6410E' '8F3C13'};

if strcmp(opt, 'red')
    grad = cellfun(@(x) ['#' x], red, 'UniformOutput', false);
elseif strcmp(opt, 'purple')
    grad = cellfun(@(x) ['#' x], purple, 'UniformOutput', false);
elseif strcmp(opt, 'green')
    grad = cellfun(@(x) ['#' x], green, 'UniformOutput', false);
elseif strcmp(opt, 'blue')
    grad = cellfun(@(x) ['#' x], blue, 'UniformOutput', false);
elseif strcmp(opt, 'lightblue')
    grad = cellfun(@(x) ['#' x], lightblue, 'UniformOutput', false);
elseif strcmp(opt, 'brown')
    grad = cellfun(@(x) ['#' x], brown, 'UniformOutput', false);
elseif strcmp(opt, 'yellow')
    grad = cellfun(@(x) ['#' x], yellow, 'UniformOutput', false);
elseif strcmp(opt, 'brick')
    grad = cellfun(@(x) ['#' x], brick, 'UniformOutput', false);
end