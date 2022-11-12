classdef oneCube < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This is the cube class.  A cube has a fixed   %
%  cardinality defined as the number of points in a cloud.    %                                         
%                                                             %
% Used by: Motill                                             %
%                                                             %
% Author: Shahram Ghandeharizadeh <shahram at usc.edu>        %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        identity {mustBeNumeric} = -1
        widthLineSegment {mustBeNumeric} = []
        heightLineSegment {mustBeNumeric} = []
        depthLineSegment {mustBeNumeric} = []
        assignedVertices {mustBeNumeric} = []
        numVertices {mustBeInteger} = 0
        maxVertices {mustBeInteger} = 0
        numNeighbors {mustBeInteger} = 0
        neighbors {mustBeNumeric} = []
        colorCheckSum {mustBeInteger} = 0
        positionCheckSum {mustBeInteger} = 0
    end
    methods
        function obj = oneCube(id, maxCardinality)
            if nargin == 2
                obj.identity = id;
                obj.maxVertices = maxCardinality;
            end
        end
        function r = getVertex(obj, idx)
            r = obj.assignedVertices(idx);
        end
        function r = getCoordinateOfVertex(obj, idx, dimension, vertexList)
            % dimension must be 1 (width), 2 (height), 3 (depth
            if dimension < 1 && dimension > 3
                error('Error.  Input dimension must be 1, 2, or 3.')
                return
            end
            tgtVertx = obj.assignedVertices(idx);
            currV = vertexList{tgtVertx};
            r=currV(dimension);
        end
        function r = isFull(obj)
            r = 1;
            if obj.numVertices < obj.maxVertices
                r = 0;
            end
        end
        function r = cardinality(obj)
            r = obj.numVertices;
        end
        function numDups = removeDups(obj,vertexList)
            % Iterate the assigned vertices
            numDups = 0;
            hashtbl = containers.Map('KeyType','char', 'ValueType','any');
            newVertices=[];
            hashset=[];
            for i=1:size(obj.assignedVertices,2)
                pt = obj.assignedVertices(i);
                coord=vertexList{pt};
                tgtkey =  utilHashFunction(coord);
                if hashtbl.isKey(tgtkey)
                    % Do nothing
                    error('Error, a cube should not have duplicates.  Dups were removed when loading vertices from files.')


                    i
                    coord

                    val = hashtbl(tgtkey)

                    val
                    vertexList(val)
                    %tgtkey
                    numDups = numDups+1;
                else
                    newVertices(end+1)=pt;
                    hashtbl(tgtkey)=i;
                end
            end
            obj.assignedVertices = newVertices;
            obj.numVertices = size(obj.assignedVertices,2);

            obj.reComputeCheckSums(vertexList);
        end
        %{
        function numDups = removeDups(obj,vertexList)
            % Iterate the assigned vertices
            numDups = 0;
            newVertices=[];
            hashset=[];
            for i=1:size(obj.assignedVertices,2)
                pt = obj.assignedVertices(i);
                coord=vertexList{pt};
                tgtkey =  utilHashFunction(coord);
                if any(hashset(:) == tgtkey)
                    % Do nothing

                    coord
                    tgtkey
                    numDups = numDups+1;
                else
                    newVertices(end+1)=pt;
                    hashset(end+1)=tgtkey;
                end
            end
            obj.assignedVertices = newVertices;
            obj.numVertices = size(obj.assignedVertices,2);

            obj.reComputeCheckSums(vertexList);
        end
        %}
        %function obj = set.neighbors(obj, value)
        %    if (value > 0)
        %        obj.numNeighbors = obj.numNeighbors + 1;
        %        obj.neighbors(obj.numNeighbors)=value;
        %    else
        %        error('The assigned vertex id must be a positive integer and index into the array of vertices.');
        %    end
        %end
        function obj = assignNeighbor(obj, value)
            if (value > 0)
                obj.numNeighbors = obj.numNeighbors + 1;
                obj.neighbors(obj.numNeighbors)=value;
            else
                error('The assigned vertex id must be a positive integer and index into the array of vertices.');
            end
        end
        function obj = assignVertex(obj, value, width, height, depth, red, green, blue, alpha)
            if (value > 0)
                obj.numVertices = obj.numVertices+1;
                if (obj.numVertices > obj.maxVertices)
                    error('Overflow.  The cube is full.')
                    return
                end
                obj.assignedVertices(obj.numVertices)=value;
                obj.positionCheckSum = obj.positionCheckSum + int64(width) + int64(height) + int64(depth);
                obj.colorCheckSum = obj.colorCheckSum + int64(red) + int64(green) + int64(blue) + int64(alpha);
            else
                error('The assigned vertex id must be a positive integer and index into the array of vertices.');
            end
        end
        function obj = sanityAssignVertex(obj, value, width, height, depth, red, green, blue, alpha, vertexList, newV)
            if (value > 0)
                vertexList(value)=newV;
                obj.numVertices = obj.numVertices + 1;
                %if (obj.numVertices > obj.maxVertices)
                %    error('Overflow.  The cube is full.')
                %    return
                %end
                obj.assignedVertices(obj.numVertices)=value;
                obj.positionCheckSum = obj.positionCheckSum + int64(width) + int64(height) + int64(depth);
                obj.colorCheckSum = obj.colorCheckSum + int64(red) + int64(green) + int64(blue) + int64(alpha);
            else
                error('The assigned vertex id must be a positive integer and index into the array of vertices.');
            end
        end
        function obj = rmVertex(obj, value, oldwidth, oldheight, olddepth, oldred, oldgreen, oldblue, oldalpha)
            if (value > 0)
                if intersect(obj.assignedVertices,value) == value
                else
                    error('Error in rmVertex.  The vertex being removed does not exist.');
                end
                obj.assignedVertices(obj.assignedVertices == value) = [];
                obj.numVertices = obj.numVertices - 1;
                % SHAHRAM, We may have to change the vertex
                obj.positionCheckSum = obj.positionCheckSum - int64(oldwidth) - int64(oldheight) - int64(olddepth);
                obj.colorCheckSum = obj.colorCheckSum - int64(oldred) - int64(oldgreen) - int64(oldblue) - int64(oldalpha);
            else
                error('The assigned vertex id must be a positive integer and index into the array of vertices.');
            end
        end
        function obj = reComputeCheckSums(obj,vertexList)
            obj.positionCheckSum = 0;
            obj.colorCheckSum = 0;
            for i=1:size(obj.assignedVertices,2)
                tgtVertx = obj.assignedVertices(i);
                currV = vertexList{tgtVertx};
                obj.positionCheckSum = obj.positionCheckSum + int64(currV(1)) + int64(currV(2)) + int64(currV(3));
                obj.colorCheckSum = obj.colorCheckSum + int64(currV(4)) + int64(currV(5)) + int64(currV(6)) + int64(currV(7));
            end
        end
        function obj = replaceVertex(obj, value, oldwidth, oldheight, olddepth, oldred, oldgreen, oldblue, oldalpha, newwidth, newheight, newdepth, newred, newgreen, newblue, newalpha)
            if (value > 0)
                % The vertex value should be changed by the color due to
                % scoping rules.
                obj.positionCheckSum = obj.positionCheckSum - int64(oldwidth) - int64(oldheight) - int64(olddepth);
                obj.colorCheckSum = obj.colorCheckSum - int64(oldred) - int64(oldgreen) - int64(oldblue) - int64(oldalpha);

                obj.positionCheckSum = obj.positionCheckSum + int64(newwidth) + int64(newheight) + int64(newdepth);
                obj.colorCheckSum = obj.colorCheckSum + int64(newred) + int64(newgreen) + int64(newblue) + int64(newalpha);
            else
                error('The assigned vertex id must be a positive integer and index into the array of vertices.');
            end
        end
        %function obj = set.assignedVertices(obj, value)
        %    if (value > 0)
        %        obj.numVertices = obj.numVertices + 1;
        %        if (obj.numVertices > obj.maxVertices)
        %            error('Overflow.  The cube is full.')
        %            return
        %        end
        %        obj.assignedVertices(obj.numVertices)=value;
        %    else
        %        error('The assigned vertex id must be a positive integer and index into the array of vertices.');
        %    end
        %end
    end
end