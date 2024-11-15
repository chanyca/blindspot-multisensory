function isInside = isGazeInsideCircle(nowCoords, x, y, visualAngle)
    distance = sqrt((nowCoords(1) - x)^2 + (nowCoords(2) - y)^2); % distance between gaze point and center
    isInside = (distance <= visualAngle); % check if distance is less than or equal to the radius
end



