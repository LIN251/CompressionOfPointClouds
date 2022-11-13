clc;  % Clear command window.
clear;  % Delete all variables.
close all;  % Close all figure windows except those created by imtool.
imtool close all;  % Close all figure windows created by imtool.
workspace;  % Make sure the workspace panel is showing.
fontSize = 16;
% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
baseFileName = 'cameraman.tif';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
  % File doesn't exist -- didn't find it there.  Check the search path for it.
  fullFileName = baseFileName; % No path this time.
  if ~exist(fullFileName, 'file')
    % Still didn't find it.  Alert user.
    errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
    uiwait(warndlg(errorMessage));
    return;
  end
end
grayImage = imread(fullFileName);
imshow(grayImage, []);
axis on;
title('Original Grayscale Image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message = sprintf('Left click and hold to begin drawing a freehand path.\nSimply lift the mouse button to finish.\nDRAW FAST!!!');
uiwait(msgbox(message));
% User draws curve on image here.
hFH = imfreehand();
% Get the xy coordinates of where they drew.
xy = hFH.getPosition
% get rid of imfreehand remnant.
delete(hFH);
% Overlay what they drew onto the image.
hold on; % Keep image, and direction of y axis.
xCoordinates = xy(:, 1);
yCoordinates = xy(:, 2);
plot(xCoordinates, yCoordinates, 'ro', 'LineWidth', 2, 'MarkerSize', 10);
caption = sprintf('Original Grayscale Image.\nPoints may not lie on adjacent pixels, depends on your speed of drawing!');
title(caption, 'FontSize', fontSize);
% Ask user if they want to burn the line into the image.
promptMessage = sprintf('Do you want to burn the line into the image?');
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
if strcmpi(button, 'Yes')
  cla;
  hold off;
  for k = 1 : length(xCoordinates)
    row = int32(yCoordinates(k));
    column = int32(xCoordinates(k));
    grayImage(row, column) = 255;
  end
  imshow(grayImage, []);
  axis on;
  caption = sprintf('Grayscale Image with Burned In Curve.\nPoints may not lie on adjacent pixels, depends on your speed of drawing!');
  title(caption, 'FontSize', fontSize);
end
% Ask user if they want to interpolate the line to get the "in-between" points that are missed..
% promptMessage = sprintf('Do you want to interpolate the curve into intervening pixels?');
% titleBarCaption = 'Continue?';
% button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
% if strcmpi(button, 'Cancel')
%   return;
% end
xCoordinates = xy(:, 1);
yCoordinates = xy(:, 2);
numberOfKnots = length(xCoordinates);
% Close gaps that you get when you draw too fast.
% Use splines to interpolate a smoother curve,
% with 10 times as many points,
% that goes exactly through the same data points.
samplingRateIncrease = 10;
newXSamplePoints = linspace(1, numberOfKnots, numberOfKnots * samplingRateIncrease);
% smoothedY = spline(xCoordinates, yCoordinates, newXSamplePoints);
% Make the 2D array where the top row is the x coordinates and the bottom row is the y coordinates,
% but with the exception that the left column and right column is a vector that gives the direction of the slope.
yy = [0, xCoordinates', 0; 1, yCoordinates', 1]
pp = spline(1:numberOfKnots, yy); % Get interpolant
smoothedY = ppval(pp, newXSamplePoints); % Get smoothed y values in the "gaps".
% smoothedY is a 2D array with the x coordinates in the top row and the y coordinates in the bottom row.
smoothedXCoordinates = smoothedY(1, :)
smoothedYCoordinates = smoothedY(2, :)
% Plot smoothedY and show how the line is
% smooth, and has no sharp bends.
hold on; % Don't destroy the first curve we plotted.
hGreenCurve = plot(smoothedXCoordinates, smoothedYCoordinates, '-g');
title('Spline Interpolation Demo', 'FontSize', 20);
% But smoothedXCoordinates and smoothedYCoordinates are not in pixel coordinates, they have fractional values.
% If you want integer pixel values, you have to round.
intSmoothedXCoordinates = int32(smoothedXCoordinates)
intSmoothedYCoordinates = int32(smoothedYCoordinates)
% But now it's possible that some coordinates will be on the same pixel if that's
% how they rounded according to how they were located to the nearest integer pixel location.
% So use diff() to remove elements that have the same x and y values.
diffX = [1, diff(intSmoothedXCoordinates)];
diffY = [1, diff(intSmoothedYCoordinates)];
% Find out where both have zero difference from the prior point.
bothZero = (diffX==0) & (diffY == 0);
% Remove those from the arrays.
finalX = intSmoothedXCoordinates(~bothZero);
finalY = intSmoothedYCoordinates(~bothZero);
% Now remove the green line.
delete(hGreenCurve);
% Plot the final coordinates.
hGreenCurve = plot(finalX, finalY, '-y');