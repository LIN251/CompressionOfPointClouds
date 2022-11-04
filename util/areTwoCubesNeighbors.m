function output = areTwoCubesNeighbors(firstCube, secondCube)
output = 0;
% For two cubes to be neighbors, they must overlap along at least two
% dimensions
widthOutput = doLinesOverlap(firstCube.widthLineSegment(1), firstCube.widthLineSegment(2), secondCube.widthLineSegment(1), secondCube.widthLineSegment(2));
heightOutput = doLinesOverlap(firstCube.heightLineSegment(1), firstCube.heightLineSegment(2), secondCube.heightLineSegment(1), secondCube.heightLineSegment(2));
depthOutput = doLinesOverlap(firstCube.depthLineSegment(1), firstCube.depthLineSegment(2), secondCube.depthLineSegment(1), secondCube.depthLineSegment(2));
if widthOutput == 1 && heightOutput == 1
    output = 1;
end
if widthOutput == 1 && depthOutput == 1
    output = 1;
end
if heightOutput == 1 && depthOutput == 1
    output = 1;
end
end