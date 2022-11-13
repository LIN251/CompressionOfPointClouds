classdef CloudPoint < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This is the point cloud class.  A motion      %
%   illumination consists of a sequence of instances of this  %
%   class.                                                    %
%                                                             %
% Used by: inMemoryCP                                         %
% Dependencies: oneCube class                                 %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        identity
        filename
        backupVertexList
        vertexList
        minL
        maxL
        minH
        maxH
        minD
        maxD

        numVertices {mustBeInteger} = 0
        cubeCapacity {mustBeInteger} = 0
        cubes
        llArray
        hlArray
        dlArray
    end
    methods
        function output = areCubesCorrect(obj)
            numPts = 0;
            output = true;
            for i=1:size( obj.cubes, 2 )
                numPts = numPts + size(obj.cubes(i).assignedVertices,2);
            end
            if numPts ~= obj.numVertices
                output = false;
                error('Error, number of points in the cubes ',num2str(numPts),' does not match total number of points ', num2str(numVertices),'.')
            end
            if output
                outputT= ['Yes. Number of vertices in the cubes equals total number of points in the cloud: ', num2str(obj.numVertices)];
                disp(outputT);
            end
        end
        function numDups = remDups(obj,vtList)
            % Iterate the assigned vertices
            numDups = 0;

            hashtbl = containers.Map('KeyType','char', 'ValueType','any');

            obj.numVertices=0;
            obj.vertexList={};

            for i=1:size(vtList)
                coord=vtList(i,:);
                tgtkey =  utilHashFunction(coord);
                %if any(hashset(:) == tgtkey)
                if hashtbl.isKey(tgtkey)
                    % Do nothing
                    numDups = numDups+1;
                else
                    %newVertices(end+1)=pt;
                    %hashset(end+1)=tgtkey;
                    hashtbl(tgtkey)=i;
                    obj.numVertices = obj.numVertices + 1;
                    obj.vertexList{obj.numVertices}=vtList(i,:);
                end
            end
        end
        function obj = CloudPoint(id, filename, vtList, minL, maxL, minH, maxH, minD, maxD)
            obj.identity=id;
            obj.filename=filename;
            obj.minL=minL;
            obj.maxL=maxL;
            obj.minH=minH;
            obj.maxH=maxH;
            obj.minD=minD;
            obj.maxD=maxD;
            %backupVertexList=zeros(size(vL));

            numDups=obj.remDups(vtList); % populates vertexList and removes duplicates
            outputT= sprintf('Removed %d duplicates',numDups);
            disp(outputT);

            for i=1:size(obj.vertexList,2)
                obj.backupVertexList{i}=obj.vertexList{i};
            end
        end
        function obj = replacePoint(obj, tgtCubeID, srcPt, oldC, newC)
            % Update the vertex coordinate
            obj.vertexList(srcPt)=newC;

            % Update the check point
            oldCord=cell2mat( oldC ); %%cell2mat(leadCloudPoint.vertexList(srcPt));
            newCord=cell2mat( newC );
            obj.cubes(tgtCubeID).replaceVertex(srcPt, oldCord(1), oldCord(2), oldCord(3), oldCord(4), oldCord(5), oldCord(6), oldCord(7), newCord(1), newCord(2), newCord(3), newCord(4), newCord(5), newCord(6), newCord(7));
        end
        function obj = addPoint(obj, tgtCubeID, newC)
            % Create the vertex and its id
            ptID=size(obj.vertexList,2)+1;
            obj.vertexList(end+1) = newC;

            % Add the vertex to the tgtCubeID
            % obj.cubes(tgtCubeID).assignedVertices(end+1)=ptID;

            % Adjust the check point for this cube
            newCord=cell2mat( newC );
            obj.cubes(tgtCubeID).sanityAssignVertex(ptID, newCord(1), newCord(2), newCord(3), newCord(4), newCord(5), newCord(6), newCord(7), obj.vertexList, newC);
        end
        function obj = rmPoint(obj, tgtCubeID, ptID)

            oldCord=cell2mat( obj.vertexList( ptID ) );
            obj.cubes(tgtCubeID).rmVertex(ptID, ...
                oldCord(1), oldCord(2), oldCord(3), ...
                oldCord(4), oldCord(5), oldCord(6), oldCord(7) );
        end
        function obj = createGrid(obj,doReset,silent,cubeCapacity,llArray,hlArray,dlArray,inputCubes)
            % doReset is a binary flag.  When set to true, it
            % refreshes the vertexList using its backup copy.
            obj.cubeCapacity=cubeCapacity;
            if doReset
                obj.vertexList={};
                for i=1:size(obj.backupVertexList,2)
                    obj.vertexList{i}=obj.backupVertexList{i};
                end
                obj.numVertices=size(obj.vertexList,2);
            end
            if obj.identity == 1 || all(llArray==0) || all(hlArray==0) || all(dlArray==0)
                [obj.llArray, obj.hlArray, obj.dlArray, obj.cubes] = inMemMotill(obj, cubeCapacity, silent);
            else
                obj.llArray = llArray;
                obj.hlArray = hlArray;
                obj.dlArray = dlArray;

                o1=oneCube(1,intmax);
                fCubes(1)=o1;
                % Initialize the cube structure for the 2nd cube
                for i=1:size(inputCubes,2)
                    o1 = oneCube(inputCubes(i).identity,intmax);
                    o1.widthLineSegment = inputCubes(i).widthLineSegment;
                    o1.heightLineSegment = inputCubes(i).heightLineSegment;
                    o1.depthLineSegment = inputCubes(i).depthLineSegment;
                    o1.numNeighbors = inputCubes(i).numNeighbors;
                    o1.neighbors = inputCubes(i).neighbors;
                    fCubes(i) = o1;
                end

                obj.cubes = fCubes;

                % Populate this object's cubes with its verticies
                for i=1:size(obj.vertexList,2)
                    % Identify the cube that should hold this vertex using set intersection
                    currV = obj.vertexList{i};
                    %tgtCubeID = findCube(llArray, hlArray, dlArray, currV);
                    %tgtCube = obj.cubes(tgtCubeID);
                    %tgtCube.assignedVertices = i;
                    %Optimization of the above
                    tgtCubeID = findCube(llArray, hlArray, dlArray, obj.vertexList{i});
                    %obj.cubes(tgtCubeID).assignedVertices = i;
                    obj.cubes(tgtCubeID).assignVertex(i, currV(1), currV(2), currV(3), currV(4), currV(5), currV(6), currV(7));
                end
            end
        end
        function obj = resetCloudPoint(obj,doReset,silent,cubeCapacity,llArray,hlArray,dlArray,inputCubes)
            %if obj.cubeCapacity ~= cubeCapacity
            % Verify the input cubes have the appropriate capacity
            if inputCubes ~= 0
                if cubeCapacity ~= inputCubes(1).maxVertices
                    error('Error in resetCloudPoint, specified cubeCapacity ',num2str(cubeCapacity) ,' does not match the inputCubes structure with capacity ',num2str(inputCubes(1).maxVertices) , '.')
                end
            end
            %end
            obj.createGrid(true,silent,cubeCapacity,llArray,hlArray,dlArray,inputCubes)
        end
    end
end