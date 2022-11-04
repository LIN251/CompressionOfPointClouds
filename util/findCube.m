function output = findCube(wlArray, hlArray, dlArray, vertex)
% Find the Width line segment containing the vertex's width point
%widthLineSeg = findLineSeg(wlArray, vertex(1));

% Find the Height line segment containing the vertex's width point
%heightLineSeg = findLineSeg(hlArray, vertex(2));

% Find the depth line segment containing the vertex's width point
%depthLineSeg = findLineSeg(dlArray, vertex(3));

% Compute the set intersection of the cubes in the 3 line segments
widthCubes = findCubesInLineSeg(wlArray, vertex(1)); %widthLineSeg.getCubes();
heightCubes = findCubesInLineSeg(hlArray, vertex(2)); %heightLineSeg.getCubes();
depthCubes = findCubesInLineSeg(dlArray, vertex(3)); %depthLineSeg.getCubes();

output = intersect(widthCubes,(intersect(heightCubes,depthCubes)));
end