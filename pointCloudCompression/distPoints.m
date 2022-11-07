function output = distPoints(coord1, faceV1, faceV2, faceV3)

% Each faceVi has an x, y, z coordinate.

% Include top folder for distanceCells
% addpath(genpath([fileparts(pwd), filesep, 'util' ]));

dv(1) = distanceCells(coord1, faceV1);
dv(2) = distanceCells(coord1, faceV2);
dv(3) = distanceCells(coord1, faceV3);

output = mean(dv);
end