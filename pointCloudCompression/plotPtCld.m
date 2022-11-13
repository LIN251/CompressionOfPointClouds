function output = plotPtCld(filename,eye,direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Plots the point cloud generated as the output %
%               of cnvPrincetonShapeToPtCld.m                 %
% Dependencies: None                                          %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

multiplier = 1;

fileID=fopen(filename);

% Read and discard the first two linesithub
currLine = textscan(fileID,'%s',1,'Delimiter','\n');
currLine = textscan(fileID,'%s',1,'Delimiter','\n');
currRow = char(currLine{1});
splittedRow = strsplit(currRow,' ');
splittedRow = str2double(splittedRow);
numVs = splittedRow(1);
% disp( sprintf("Number of vertices to process is %d",numVs) );
% figure('WindowButtonDownFcn',@(src,evnt)printPos())
axis equal;
hold on;

quiver3(eye(1), eye(2), eye(3), direction(1), direction(2), direction(3), 30);
while (~feof(fileID))
    currLine = textscan(fileID,'%s',1,'Delimiter','\n');
    currRow = char(currLine{1});
    splittedRow = strsplit(currRow,' ');

    splittedRow = str2double(splittedRow);
    plot3(splittedRow(1), splittedRow(2), splittedRow(3), '.b');
end


view(-140,12);


% function printPos
%   clickedPt = get(gca,'CurrentPoint');
%   VMtx = view(gca);
%   point2d = VMtx * [clickedPt(1,:) 1]';
%   disp(point2d(1:3)')
%   pause(3) 
% end


hold off;


end