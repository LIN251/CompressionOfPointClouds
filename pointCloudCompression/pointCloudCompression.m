function output = pointCloudCompression(PrincetonShapeFileName, eye)

% Include top folder for distanceCells
addpath(genpath([fileparts(pwd), filesep, 'util' ]));
addpath(genpath([fileparts(pwd), filesep, 'class' ]));
dimRow=true;
vertexCount = [];
faceCount = [];
edgeCount = [];
rowCount = 1;
vertexList{1} = [];
faceList{1} = [];
faceColorList{1} = [];

fileID=fopen(PrincetonShapeFileName);

multiplier=100;

while (~feof(fileID))
    currLine = textscan(fileID,'%s',1,'Delimiter','\n');
    currRow = char(currLine{1});
    splittedRow = strsplit(currRow,' ');

    if (~strcmp(splittedRow(1),'#') && ~strcmp(splittedRow(1),'OFF'))

        splittedRow = str2double(splittedRow);

        if(dimRow)
            dimRow = false;
            vertexCount = splittedRow(1);
            faceCount = splittedRow(2);
            edgeCount = splittedRow(3);
        else
            if(rowCount <= vertexCount)
                vertexList{rowCount} = [splittedRow(1)*multiplier splittedRow(2)*multiplier splittedRow(3)*multiplier];
            end
            if(vertexCount < rowCount && (rowCount-vertexCount) <= faceCount)
                if(splittedRow(1) == 3)
                    faceList{rowCount-vertexCount} = [splittedRow(2) splittedRow(3) splittedRow(4)];
                    % faceColorList{rowCount-vertexCount} = [splittedRow(5) splittedRow(6) splittedRow(7) splittedRow(8)];
                end
                if(splittedRow(1) == 4)
                    faceList{rowCount-vertexCount} = [splittedRow(2) splittedRow(3) splittedRow(4) splittedRow(5)];
                    % faceColorList{rowCount-vertexCount} = [splittedRow(6) splittedRow(7) splittedRow(8) splittedRow(9)];
                end
            end

            rowCount = rowCount +1;

            % progress
            if(mod(rowCount,10000)==0)
                disp('.');
            end
        end
    end
end

disp 'Structure materialized in memory.';
disp '';

for i=1:size(vertexList,2)
    currV = vertexList{i};
end

xCoo = [];
yCoo = [];
zCoo = [];

if size(faceList,2)> 1
  for j=1:size(faceList,2)
    currF = faceList{j};

    for k=1:size(currF,2)
        xCoo = [xCoo vertexList{currF(k)+1}(1)];
        yCoo = [yCoo vertexList{currF(k)+1}(2)];
        zCoo = [zCoo vertexList{currF(k)+1}(3)];
    end
    xCoo = [xCoo xCoo(1)];
    yCoo = [yCoo yCoo(1)];
    zCoo = [zCoo zCoo(1)];

  end
end

fclose(fileID); %Close the input file

%return;

if size(faceList,2) < 2
    disp 'No triangle mesh to reduce to a point cloud.  Returning';
    return;
end

disp 'Generating point cloud';

% The following code implements illumination using FLSs
downWash = 1000; % size of downWash along a dimension in micrometers
displayDimSize = 1000*1000; %Size of a dimension
eltsPerDim = displayDimSize/downWash; %Number of elts per x, y, and z

%An FLS may occupy a cell of the displayGrid declared below
displayGrid = zeros(eltsPerDim,eltsPerDim,eltsPerDim); %Display Grid

%One corner cell of the grid is reserved for the dispatcher.
%Its coordinates are [1,1,1], [1,1,Max], [1,Max,1], [Max,1,1], [1,Max,Max],
%[Max,Max,1], [Max,1,Max], [Max,Max,Max]
Max=eltsPerDim;
dispatcherLocation=[1,1,1];

disp '>> Sort cells based on their distance from the view.';
%For each face, compute its distance from the dispatcher.  Store in a table.
sz = [ size(faceList,2) 2];
varTypes=["int64","double"];
varNames=["faceid","distance"];
sf = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
for j=1:size(faceList,2)
    currF = faceList{j};
    dist = distTrigFace(dispatcherLocation, vertexList{currF(1)+1}, vertexList{currF(2)+1}, vertexList{currF(3)+1});
    sf(j,:)={j,dist};
end

sortedFaces=sortrows(sf,2,'descend'); %Sort in descending distance

disp 'Process sorted faces';

%For each element of sortedFaces, get the shortest distance from the
%dispatcher to its vertices and compute location of its FLSs.
ptCloud=[];
for rowid=1:height(sortedFaces)
    sfaceid = sortedFaces(rowid,1); %This is the faceid
    sdist = sortedFaces(rowid,2); %distance from the dispatcher

    currFaceID=table2array(sfaceid);
    currF = faceList{currFaceID(1)};

    v1x = vertexList{currF(1)+1};
    v1y = vertexList{currF(2)+1}; 
    v1z= vertexList{currF(3)+1};

    pts = surfaceVs(v1x, v1y, v1z, threshold);
    ptCloud = [ptCloud; pts];
    
%     if(mod(rowid,10)==0)
%         disp('.');
%     end
end


% Eliminate duplicate points
ptCloud=unique(ptCloud,'rows');



% eye    = [1 1 1];
verbose = 1;
direction = [];
% Grid: dimensions
grid3D.nx = 100;
grid3D.ny = 100;
grid3D.nz = 100;
minD  = min(ptCloud(:,1))-1;
minH = min(ptCloud(:,2))-1;
minW = min(ptCloud(:,3))-1;



maxD = max(ptCloud(:,1))+1;
maxH = max(ptCloud(:,2))+1;
maxW = max(ptCloud(:,3))+1;
grid3D.minBound = [minD,minH,minW]';
grid3D.maxBound = [maxD,maxH,maxW]';


ptCldArray{1} = CloudPoint(1,"testFile",ptCloud,minD,maxD,minH,maxH,minW,maxW);

ptCldArray{1}.createGrid(false, false , 1500, 0, 0, 0, 0);


for i = 1 :size(ptCldArray{1}.cubes,2)
    cubeArray{i} = ptCldArray{1,1}.cubes(1,i).assignedVertices;
end
pos = [1 2 3; 4 2 3; 1 5 3; 1 2 6; 4 5 3; 1 5 6; 4 2 6; 4 5 6];    
boundry = [0 0 0 0 0 0];
points = [0 0 0];
for i = 1 :size(ptCldArray{1}.cubes,2)
    tempArr = [0 0 0];
    for c = 1 :size(cubeArray{1,i},2)
        tempArr = [tempArr; ptCloud(cubeArray{1,i}(c),:)];
    end
    tempArr(1,:) = [];
    cellPoints{i} = tempArr;
    vertexs = [min(tempArr(:,1)) min(tempArr(:,2)) min(tempArr(:,3)) max(tempArr(:,1)) max(tempArr(:,2)) max(tempArr(:,3))];
    boundry = [boundry; vertexs];
    for i = 1 :8
        xC = pos(i,1);
        zC = pos(i,2);
        yC = pos(i,3);
        points = [points; [vertexs(xC) vertexs(zC) vertexs(yC)]];
    end
    points = [points; floor(vertexs(1)+vertexs(4)/2) floor(vertexs(2)+vertexs(5)/2) floor(vertexs(3)+vertexs(6)/2)];
end
points(1,:) = [];
boundry(1,:) = [];



for i=1:size(points,1)
    cur = points(i,:);
    triple = cur - eye;
    d1 = triple(1:1);
    d2 = triple(2:2);
    d3 = triple(3:3);
    magnitude = sqrt(d1*d1 + d2*d2+ d3*d3);
    dir = triple/magnitude;
    temp = floor(dir* 1000)/1000;
    direction = [direction; temp];
end
direction=unique(direction,'rows');
cellList = [];


% re-Run start here
for e=1:size(direction,1)
    curDirection = direction(e,:);
    index = aabbRayTracing(eye, curDirection, grid3D, verbose,boundry);
    if cur == 0
        continue
    else
        if ismember(index, cellList)
            continue
        else
            cellList = [cellList; index];
        end
    end
end


displayCell = [0 0 0];
for cellIndex=1:size(cellList,1)
    i = cellList(cellIndex);
    if i == 0 
        continue
    else
        displayCell = [displayCell; cellPoints{i}];
    end
end
displayCell(1,:) = [];

%cellPoints

center = [floor((minW+maxW)/2) floor((minH+maxH)/2) floor((minD+maxD)/2)];
triple = center - eye;
d1 = triple(1:1);
d2 = triple(2:2);
d3 = triple(3:3);
magnitude = sqrt(d1*d1 + d2*d2+ d3*d3);
centerDir = triple/magnitude;




% plot
multiplier = 1;

% figure('WindowButtonDownFcn',@(src,evnt)printPos(f))

axis equal;
hold on;
quiver3(eye(1), eye(2), eye(3), centerDir(1), centerDir(2), centerDir(3), 30);
for i=1:size(displayCell)
%     currLine = textscan(fileID,'%s',1,'Delimiter','\n');
%     currRow = char(currLine{1});
%     splittedRow = strsplit(currRow,' ');
% 
%     splittedRow = str2double(splittedRow);
    plot3(displayCell(i,1), displayCell(i,3), displayCell(i,2), '.b');
end


view(-140,12);
hold off;
% 
% function printPos(f)
%     clickedPt = get(gca,'CurrentPoint');
%     VMtx = view(gca);
%     point2d = VMtx * [clickedPt(1,:) 1]';
%     eyepos = point2d(1:3)'
%     clf(f)
%     for i=1:size(displayCell)
%     %     currLine = textscan(fileID,'%s',1,'Delimiter','\n');
%     %     currRow = char(currLine{1});
%     %     splittedRow = strsplit(currRow,' ');
%     % 
%     %     splittedRow = str2double(splittedRow);
%         plot3(displayCell(i,1), displayCell(i,2), displayCell(i,3), '.b');
%     end
% 
% 
% 
% end









% % Write the point cloud to a file
% fid = fopen(pointCloudFileName,'w');
% fprintf(fid,'OFF\n');
% fprintf(fid,'%d 0 0 \n',size(displayCell,1));
% for j=1:size(displayCell,1)
%     % The following switch between y and z is intentional
%     % It is to accomodate matlab 3D plot used in plotPtCld.m
%     fprintf(fid,'%d %d %d\n',displayCell(j,1), displayCell(j,3), displayCell(j,2) );
% end
%  
% fclose(fid);

end