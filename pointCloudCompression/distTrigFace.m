function output = distTrigFace(coord1, faceV1, faceV2, faceV3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Distance from a point to a triangle           %
%               Triangle is identified by 3 points: V1/V2,V3  %
%               Point may correspond to the location of the   %
%               dispatcher.                                   %
% Dependencies: distanceCells from the top directory.                                         %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Each faceVi has an x, y, z coordinate.

% Include top folder for distanceCells
% addpath(genpath([fileparts(pwd), filesep, 'util' ]));

dv(1) = distanceCells(coord1, faceV1);
dv(2) = distanceCells(coord1, faceV2);
dv(3) = distanceCells(coord1, faceV3);

output = mean(dv);
end