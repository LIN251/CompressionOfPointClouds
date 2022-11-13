function ptCldArray = inMemoryCP(directoryName,numFiles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This time consuming function reads the        %
%      specified number of point cloud files (PLY) of the Rose%
%      Clip into an array of CloudPoint instances.  The number%
%      of point clouds is                                     %
%      dictated by numFiles.  The Rose Clip point clouds are  %
%      numbered starting with 1. Each element of the array    %
%      maintains the list of vertices for a point cloud along %
%      with min and max for each dimension:  Length, Height,  %
%      and Depth.                                             %
%                                                             %
% Assumptions:  Point cloud files start with the string token %
%    'Scene' and end with the string token '.ply'             %
%                                                             %
% Used by: workflow                                           %
% Dependencies: readPLYfile                                   %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath([pwd, filesep, 'util' ]));

filenameStart='Scene';
filenameMid='';
filenameEnd='.ply';

ptCldArray={};

for j=1:numFiles
    if j < 10
        filenameMid ='00';
    elseif j < 100
        filenameMid='0';
    else
        filenameMid='';
    end
    filePath = [directoryName, filenameStart, filenameMid, num2str(j), filenameEnd ];
    outputT= ['Processing ', filePath ];
    disp(outputT);
    [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPLYfile(filePath);
    ptCldArray{j} = CloudPoint(j,filePath,vertexList,minW,maxW,minH,maxH,minD,maxD);
end
end