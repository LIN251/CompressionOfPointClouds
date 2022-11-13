function output = splitCubeWithChaosFactor(tgtCube, dimID, vertexList, newCubeID, cubeCapacity, wlArray, hlArray, dlArray, newEltIdx, cubeArray)
% dimID is the dimension to split: 1 is width, 2 is height, 3 is depth
% Table with the vertices as one column and the dimID as the second column
sz = [ cubeCapacity+1 2];
varTypes=["int64","double"];
varNames=["vid","position"];

vTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
for j=1:cubeCapacity
    vTbl(j,:)={tgtCube.getVertex(j), tgtCube.getCoordinateOfVertex(j, dimID, vertexList)};
end
currV = vertexList{newEltIdx};
vTbl(j+1,:)={newEltIdx, currV(dimID)};

% Sort the table on the dimID column value
sortedVT=sortrows(vTbl,2,'ascend'); %Sort in descending distance

% Get the mid point. 
midRow = fix( (j+1)/2 ) + 1;  % Plus 1 because end of the range is exclusive

revMin = sortedVT(1,2);
revMax = sortedVT(midRow,2);
newMin = sortedVT(midRow,2);
newMax = sortedVT(j+1,2);

% Convert from table format to number format
revMin = table2array(revMin(1,1));
revMax = table2array(revMax(1,1));
newMin = table2array(newMin(1,1));
newMax = table2array(newMax(1,1));

% Adjust for the chaos factor
chaosFactor=0.001;
revMax = revMax+chaosFactor;
newMin = newMin+chaosFactor;

% Adjust the min and max
if dimID == 1
    if tgtCube.widthLineSegment(1) < revMin
        revMin = tgtCube.widthLineSegment(1);
    end
    if newMax < tgtCube.widthLineSegment(2)
        newMax = tgtCube.widthLineSegment(2);
    end
elseif dimID == 2
    if tgtCube.heightLineSegment(1) < revMin
        revMin = tgtCube.heightLineSegment(1);
    end
    if newMax < tgtCube.heightLineSegment(2)
        newMax = tgtCube.heightLineSegment(2);
    end
else
    if tgtCube.depthLineSegment(1) < revMin
        revMin = tgtCube.depthLineSegment(1);
    end
    if newMax < tgtCube.depthLineSegment(2)
        newMax = tgtCube.depthLineSegment(2);
    end
end

% Declare 2 new cubes and initialize their line segments to the original
% cube
revCube = oneCube(tgtCube.identity, cubeCapacity);
revCube.widthLineSegment = tgtCube.widthLineSegment;
revCube.heightLineSegment = tgtCube.heightLineSegment;
revCube.depthLineSegment = tgtCube.depthLineSegment;

newCube = oneCube(newCubeID,cubeCapacity);
newCube.widthLineSegment = tgtCube.widthLineSegment;
newCube.heightLineSegment = tgtCube.heightLineSegment;
newCube.depthLineSegment = tgtCube.depthLineSegment;

% Adjust the cube's line segments
if dimID == 1
    revCube.widthLineSegment=[revMin, revMax];
    newCube.widthLineSegment=[newMin, newMax];
elseif dimID == 2
    revCube.heightLineSegment=[revMin, revMax];
    newCube.heightLineSegment=[newMin, newMax];
else
    revCube.depthLineSegment=[revMin, revMax];
    newCube.depthLineSegment=[newMin, newMax];
end

% Assign the vertices to the appropriate cube
for k=1:j+1
    vid = sortedVT(k, 1);
    vidInt = table2array( vid );
    currV = vertexList{vidInt};
    tgtv = currV(dimID);
    if tgtv < revMax
        %revCube.assignedVertices = vidInt;
        revCube.assignVertex(vidInt, currV(1), currV(2), currV(3));
    else
        %newCube.assignedVertices = vidInt;
        newCube.assignVertex(vidInt, currV(1), currV(2), currV(3));
    end
    % Sanity check.  Comment out for faster execution.
    if tgtv < revMin || tgtv > newMax
        error('Error in splitCubeWithChaosFactor;  mid points are wrong.')
    end
end

%To do:  Repair the line segments



rescube(1)=revCube;
rescube(2)=newCube;

output = rescube;
end