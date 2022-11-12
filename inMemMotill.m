function [llArray, hlArray, dlArray, cubes] = inMemMotill(cloudPoint, cubeCapacity, silent)

addpath(genpath([pwd, filesep, 'classes' ]));
addpath(genpath([pwd, filesep, 'util' ]));

maxCardinality=3;
if cubeCapacity < maxCardinality
    outputT= ['Maximum cardinality of a cube must at least ', num2str(maxCardinality), '. ', num2str(cubeCapacity), ' was specified as input.  Change it to 5 or higher.'];
    disp(outputT);
end

vertexCount = [];
faceCount = [];

numVertex=size(cloudPoint.vertexList,2);
maxL = cloudPoint.maxL;
maxH = cloudPoint.maxH;
maxD = cloudPoint.maxD;
minL = cloudPoint.minL;
minH = cloudPoint.minH;
minD = cloudPoint.minD;

if ~silent
    outputT= [' Length = [', num2str(minL), ', ', num2str(maxL), ']' ];
    disp(outputT);
    outputT= [' Height = [', num2str(minH), ', ', num2str(maxH), ']' ];
    disp(outputT);
    outputT= [' Depth = [', num2str(minD), ', ', num2str(maxD), ']' ];
    disp(outputT);
end

cubeID=1;

% Here is the first cube for the entire point set.
o1=oneCube(cubeID,cubeCapacity);

o1.widthLineSegment=[0,maxL+1];
o1.heightLineSegment=[0,maxH+1];
o1.depthLineSegment=[0,maxD+1];

cubes(cubeID) = o1;

% Construct array of line segments for the first cube
llArray=lineSegment(0,maxL+1);
hlArray=lineSegment(0,maxH+1);
dlArray=lineSegment(0,maxD+1);

% Initialize all line segments with cube id 1
llArray(1).addCube(cubeID);
hlArray(1).addCube(cubeID);
dlArray(1).addCube(cubeID);


%Process and 
for i=1:size(cloudPoint.vertexList,2)
    currV = cloudPoint.vertexList{i};
    % Identify the cube that should hold this vertex using set intersection
    tgtCubeID = findCube(llArray, hlArray, dlArray, currV);
    % Check to see if the target cube overflows.  If so then split the cube
    tgtCube = cubes(tgtCubeID);
    if tgtCube.isFull()
        % Construct the new cubeID
        cubeID = cubeID + 1;
        % Dimension to split along
        dimID = mod(cubeID, 3)+1;
        % Split the cube into two to obtain a new object
        twoCube = splitCubeWithChaosFactor(tgtCube, dimID, cloudPoint.vertexList, cubeID, cubeCapacity, llArray, hlArray, dlArray, i, cubes);
        % twoCube = splitCubeIntoTwo(tgtCube, dimID, vertexList, cubeID, cubeCapacity, wlArray, hlArray, dlArray, i, cubes);
        % Repair the cubeArray
        cubes(twoCube(1).identity)=twoCube(1);
        cubes(twoCube(2).identity)=twoCube(2);
        % Fix the line segments
        if dimID == 1
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(llArray, tgtCube.widthLineSegment(1), tgtCube.widthLineSegment(2));
            remlSeg = llArray(remlSegIdx);

            % Remove it from the wlArray if this is the only line segment
            if size(remlSeg.cubeIds,2) == 1
                llArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                llArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            lsOne = lineSegment(twoCube(1).widthLineSegment(1), twoCube(1).widthLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            sz=size(llArray,2);
            llArray(sz+1)=lsOne;

            lsTwo = lineSegment(twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            sz=size(llArray,2);
            llArray(sz+1)=lsTwo;
            % Assign cubes of the line segmented that is divided across the
            % new line segments
            %listOfCubes=remlSeg.getCubes();
            %for j=1:size(listOfCubes,2)
            %    if (listOfCubes(j) ~= tgtCube.identity)
            %        cbidx = listOfCubes(j);
            %        cb = cubes(cbidx);
            %        pt=cb.widthLineSegment(1);
            %        tgtLineSeg=findLineSeg(wlArray, pt);
            %        tgtLineSeg.addCube(cb.identity); % cubes(j).identity;
            %    end
            %end
            % Add the new cube to their corresponding width and height line
            % segments
            tgtLSH = findLineSegIDX(hlArray, twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            hlArray(tgtLSH).addCube(twoCube(2).identity);

            tgtLSD = findLineSegIDX(dlArray, twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            dlArray(tgtLSD).addCube(twoCube(2).identity);
        elseif dimID ==2
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(hlArray, tgtCube.heightLineSegment(1), tgtCube.heightLineSegment(2));
            remlSeg = hlArray(remlSegIdx);

            % Remove it from the hlArray if this is the only line segment
            if size(remlSeg.cubeIds,2) == 1
                hlArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                hlArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            lsOne = lineSegment(twoCube(1).heightLineSegment(1), twoCube(1).heightLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            sz=size(hlArray,2);
            hlArray(sz+1)=lsOne;

            lsTwo = lineSegment(twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            sz=size(hlArray,2);
            hlArray(sz+1)=lsTwo;

            % Add the new cube to their corresponding width and height line
            % segments
            tgtLSW = findLineSegIDX(llArray, twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            llArray(tgtLSW).addCube(twoCube(2).identity);

            tgtLSD = findLineSegIDX(dlArray, twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            dlArray(tgtLSD).addCube(twoCube(2).identity);
        else
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(dlArray, tgtCube.depthLineSegment(1), tgtCube.depthLineSegment(2));
            remlSeg = dlArray(remlSegIdx);

            % Remove it from the dlArray
            if size(remlSeg.cubeIds,2) == 1
                dlArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                dlArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            lsOne = lineSegment(twoCube(1).depthLineSegment(1), twoCube(1).depthLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            sz=size(dlArray,2);
            dlArray(sz+1)=lsOne;

            lsTwo = lineSegment(twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            sz=size(dlArray,2);
            dlArray(sz+1)=lsTwo;

            % Add the new cube to their corresponding width and height line
            % segments
            tgtLSW = findLineSegIDX(llArray, twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            llArray(tgtLSW).addCube(twoCube(2).identity);

            tgtLSH = findLineSegIDX(hlArray, twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            hlArray(tgtLSH).addCube(twoCube(2).identity);
        end
    else
        %tgtCube.assignedVertices = i;
        tgtCube.assignVertex(i, currV(1), currV(2), currV(3), currV(4), currV(5), currV(6), currV(7));
    end
    % Otherwise, insert the vertex into the cube.
end

% Set the neighbor relationship
for p=1:size(cubes,2)-1
    for q=p+1:size(cubes,2)
        output = areTwoCubesNeighbors(cubes(p), cubes(q));
        if output == 1
            cubes(p).assignNeighbor(q);
            cubes(q).assignNeighbor(p);
        end
    end
end

if ~silent
    reportCubeStats(cubes, cubeCapacity);
end
end