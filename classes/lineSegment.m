classdef lineSegment < handle
   properties
      minInclusive {mustBeNumeric} = -1;
      maxExclusive {mustBeNumeric} = -1;
      cubeIds {mustBeInteger} = [];
      numCubes {mustBeInteger} = 0;
   end
   methods
       function obj = lineSegment(minInclusiveVal, maxExclusiveVal)
        if nargin == 2
            obj.minInclusive = minInclusiveVal;
            obj.maxExclusive = maxExclusiveVal;
        end
       end
       function obj = deleteCubeID(obj,cubeID)
           if any( obj.cubeIds == cubeID )
               obj.cubeIds( obj.cubeIds == cubeID ) = [];
               obj.numCubes = obj.numCubes - 1;
           else
               error('Error, lineSegment.deleteCubeID: Cube id does not exists.');
           end
       end
      function r = getCubes(obj)
         r = obj.cubeIds;
      end
      function r=getCardinality(obj)
          r = obj.numCubes;
      end
      %function obj = set.assignedCubes(obj, value)
      function obj = addCube(obj, value)
          if (value > 0)
              obj.numCubes = obj.numCubes + 1;
              obj.cubeIds(obj.numCubes)=value;
          else
              error('Error, lineSegment.addCube:  The assigned cube id must be a positive integer.');
          end
      end
   end
end