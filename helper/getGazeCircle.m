function [xGazeCircle, yGazeCircle] =getGazeCircle(xCenter, yCenter, visualAngle) 

    r = visualAngle; %radius
    C = [xCenter, yCenter]; %center
    theta = linspace(0, 2*pi, 100); % angles for generating points
    xGazeCircle = xCenter + r*cos(theta); % x-coordinates of points
    yGazeCircle = yCenter + r*sin(theta); % y-coordinates of points


end