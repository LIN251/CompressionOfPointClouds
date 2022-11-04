function output = reportCubeStats(cubes, maxCard)
minVertices = intmax;
maxVertices = 0;
minNeighbors = intmax;
maxNeighbors = 0;
totalVertices = 0;
totalNeighbors = 0;
minCubeID = 0;
maxCubeID = 0;
for i=1:size(cubes,2)
    totalVertices = totalVertices + cubes(i).numVertices;
    totalNeighbors = totalNeighbors + cubes(i).numNeighbors;
    if cubes(i).numVertices < minVertices
        minVertices = cubes(i).numVertices;
    end
    if cubes(i).numVertices > maxVertices
        maxVertices = cubes(i).numVertices;
    end
    if cubes(i).numNeighbors < minNeighbors
        minNeighbors = cubes(i).numNeighbors;
        minCubeID = i;
    end
    if cubes(i).numNeighbors > maxNeighbors
        maxNeighbors = cubes(i).numNeighbors;
        maxCubeID = i;
    end
end
outputT= ['Number of vertices = ', num2str(totalVertices) ];
disp(outputT);
outputT= ['Number of cubes = ', num2str(size(cubes,2)) ];
disp(outputT);
outputT= ['Cube with fewest number of vertices = ', num2str(minVertices) ];
disp(outputT);
outputT= ['Cube with highest number of vertices = ', num2str(maxVertices) ];
disp(outputT);
outputT= ['Average number of vertices per cube = ', num2str(totalVertices/size(cubes,2)) ];
disp(outputT);
outputT= ['Cube utilization = ', num2str(100*totalVertices/(size(cubes,2) * maxCard)), '%' ];
disp(outputT);
outputT= ['Fewest number of neighbors = ', num2str(minNeighbors), ', cube id = ', num2str(minCubeID) ];
disp(outputT);
outputT= ['Heighest number of neighbors = ', num2str(maxNeighbors), ', cube id = ', num2str(maxCubeID) ];
disp(outputT);
outputT= ['Average number of neighbors = ', num2str(totalNeighbors/size(cubes,2)) ];

disp(outputT);
end