function output = pointCloudCompression(PrincetonShapeFileName)
% init value
disp 'init eye position at [100 100 100]';
eye = [100 100 100];
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

temp = size(ptCloud,1);
disp(['Generating point cloud with ', num2str(temp), ' vertices.' ]);

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
points = [0 0 0];
numOfCells = 5;
xr = floor((maxD-minD)/numOfCells)+1;
zr = floor((maxH-minH)/numOfCells)+1;
yr = floor((maxW-minW)/numOfCells)+1;







% euqal size cells
boundry = [0 0 0 0 0 0];
tminD = minD;
tminH = minH;
tminW = minW;
for h = 1 :numOfCells
    h = h -1;
    tminH = minH + (h * zr);
    for w = 1 :numOfCells
        w = w -1;
        tminW = minW + (w * yr);
        for d = 1 :numOfCells
            d = d - 1;
            tminD = minD + (d * xr);
            tmin = [tminD tminH tminW];
            tmax = [tmin(1)+xr tmin(2)+zr tmin(3)+yr];
            boundry = [boundry; tmin(1) tmin(2) tmin(3) tmax(1) tmax(2) tmax(3)];
        end
    end
end
boundry(1,:) = [];


cellCloud = cell(1,numOfCells*numOfCells*numOfCells);
for p = 1 :size(ptCloud,1)
    x = ptCloud(p,1);
    y = ptCloud(p,2);
    z = ptCloud(p,3);
    for t = 1 :size(boundry,1)
        if (x >= boundry(t,1) && x <= boundry(t,4) && y >= boundry(t,2) && y <= boundry(t,5) && z >= boundry(t,3) && z <= boundry(t,6))
            cellCloud{t} = [cellCloud{t}; ptCloud(p,:)];
            break
        end 
    end
end

validCellBoundry = [0 0 0 0 0 0];
for t = 1 :size(boundry,1)
    if size(cellCloud{t},1) > 10 
        validCellBoundry = [validCellBoundry; boundry(t,:)];
    else
        validCellBoundry = [validCellBoundry; [0 0 0 0 0 0]];
    end
end
validCellBoundry(1,:) = [];

for t = 1 :size(boundry,1)
    tempcell = cellCloud{t};
    if size(tempcell,1) > 8
%         [~,idxMaxx]=max(tempcell(:,1));
%         [~,idxMaxz]=max(tempcell(:,2));
%         [~,idxMaxy]=max(tempcell(:,3));
%         [~,idxMinx]=min(tempcell(:,1));
%         [~,idxMinz]=min(tempcell(:,2));
%         [~,idxMiny]=min(tempcell(:,3));
        Minx=min(tempcell(:,1));
        Minz=min(tempcell(:,2));
        Miny=min(tempcell(:,3));
        Maxx=max(tempcell(:,1));
        Maxz=max(tempcell(:,2));
        Maxy=max(tempcell(:,3));
        temp = [Minx Minz Miny;Maxx Minz Miny;Minx Maxz Miny;Minx Minz Maxy;Maxx Maxz Miny;Maxx Minz Maxy;Minx Maxz Maxy;Maxx Maxz Maxy];
%         points = [points; tempcell(idxMaxx,:); tempcell(idxMaxz,:);tempcell(idxMaxy,:);tempcell(idxMinx,:);tempcell(idxMinz,:);tempcell(idxMiny,:)];
        
        points = [points;temp];
        tempCenterx = floor((max(tempcell(:,1))+ min(tempcell(:,1)))/ 2);
        tempCenterz = floor((max(tempcell(:,2))+ min(tempcell(:,2)))/ 2);
        tempCentery = floor((max(tempcell(:,3))+ min(tempcell(:,3)))/ 2);
%         for t = 1 :size(temp,1)
%             points = [points; floor((temp(t,:)+ [tempCenterx tempCenterz tempCentery])/2)];
%         end

        points = [points; tempCenterx tempCenterz tempCentery];
%     elseif size(tempcell,1) > 0
%         points = [points; tempcell];

    end
end
points(1,:) = [];
% size(cellCloud{1},1)









% not euqal size cells
% points = [0 0 0];
% ptCldArray{1} = CloudPoint(1,"testFile",ptCloud,minD,maxD,minH,maxH,minW,maxW);
% 
% ptCldArray{1}.createGrid(false, false , 1500, 0, 0, 0, 0);
% for i = 1 :size(ptCldArray{1}.cubes,2)
%     cubeArray{i} = ptCldArray{1,1}.cubes(1,i).assignedVertices;
% end
% pos = [1 2 3; 4 2 3; 1 5 3; 1 2 6; 4 5 3; 1 5 6; 4 2 6; 4 5 6];    
% 
% for i = 1 :size(ptCldArray{1}.cubes,2)
%     tempArr = [0 0 0];
%     for c = 1 :size(cubeArray{1,i},2)
%         tempArr = [tempArr; ptCloud(cubeArray{1,i}(c),:)];
%     end
%     tempArr(1,:) = [];
%     cellCloud{i} = tempArr;
%     vertexs = [min(tempArr(:,1)) min(tempArr(:,2)) min(tempArr(:,3)) max(tempArr(:,1)) max(tempArr(:,2)) max(tempArr(:,3))];
%     for i = 1 :8
%         xC = pos(i,1);
%         zC = pos(i,2);
%         yC = pos(i,3);
%         points = [points; [vertexs(xC) vertexs(zC) vertexs(yC)]];
%     end
%     points = [points; floor(vertexs(1)+vertexs(4)/2) floor(vertexs(2)+vertexs(5)/2) floor(vertexs(3)+vertexs(6)/2)];
% end






% re-Run start here
points(1,:) = [];
center = [floor(sum(ptCloud(:,1))/size(ptCloud(:,1),1)) floor(sum(ptCloud(:,2))/size(ptCloud(:,2),1)) floor(sum(ptCloud(:,3))/size(ptCloud(:,3),1))];
% points = [20 77 26]
% points = [23 83 25]
% mid  43
%points = [22 25 80]

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
for e=1:size(direction,1)
    curDirection = direction(e,:);
    index = aabbRayTracing(eye, curDirection, grid3D, verbose,validCellBoundry);
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
cellList = unique(cellList);
displayCell = [0 0 0];
for cellIndex=1:size(cellList,1)
    i = cellList(cellIndex);
    if i == 0 
        continue
    else
        displayCell = [displayCell; cellCloud{i}];
    end 
end
displayCell(1,:) = [];



% quiver3(eye(1), eye(2), eye(3), centerDir(1), centerDir(2), centerDir(3), 30);
% plot
figure('WindowButtonDownFcn',@(src,evnt)printPos(src,grid3D,cellCloud,validCellBoundry,points,center))
disp 'Process eye position:';
disp([eye(1) eye(3) eye(2)])
disp 'Process vertices:';
disp(size(displayCell,1)) 
axis equal;
hold on;
for i=1:size(displayCell)
    plot3(displayCell(i,1), displayCell(i,3), displayCell(i,2), '.b');
end
view(-140,12);
% hold on;
% eye_to_center = [eye(1), eye(3),eye(2); center];
% line(eye_to_center(:,1), eye_to_center(:,2), eye_to_center(:,3))
% plot3(eye_to_center(:,1), eye_to_center(:,2), eye_to_center(:,3))
% hold on
% plot3(eye(1), eye(3), eye(2), 'ko');
hold on
set(gca, 'CameraPosition', [eye(1) eye(3) eye(2)]);
hold on;


% on_click function
function printPos(src,grid3DNew,cellCloudNew,validCellBoundryNew,pointsNew,center)
clickedPt = get(gca,'CurrentPoint');
VMtx = view(gca);
point2d = VMtx * [clickedPt(1,:) 1]';
eye_pos = point2d(1:3)';
disp 'Process eye position:';
disp([eye_pos(1) eye_pos(3) eye_pos(2)])
directionNew = [];
for u=1:size(pointsNew,1)
    cur = pointsNew(u,:);
    triple = cur - eye_pos;
    d1 = triple(1:1);
    d2 = triple(2:2);
    d3 = triple(3:3);
    magnitude = sqrt(d1*d1 + d2*d2+ d3*d3);
    dir = triple/magnitude;
    tem = floor(dir* 1000)/1000;
    directionNew = [directionNew; tem];
end
directionNew=unique(directionNew,'rows');
cellList = [];
verbosenew = 1;
for e=1:size(directionNew,1)
    curDirection = directionNew(e,:);
    index = aabbRayTracing(eye_pos, curDirection, grid3DNew, verbosenew, validCellBoundryNew);
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

cellList = unique(cellList);
newDisplayCell = [0 0 0];
for cellIndex=1:size(cellList,1)
    o = cellList(cellIndex);
    if o == 0 
        continue
    else
        newDisplayCell = [newDisplayCell; cellCloudNew{o}];
    end 
end
newDisplayCell(1,:) = [];
clf(src)

disp 'Process vertices:';
disp(size(newDisplayCell,1)) 
axis equal;
hold on;

% to be remove ~
% eye_to_center = [eye_pos(1), eye_pos(3),eye_pos(2); center];
% line(eye_to_center(:,1), eye_to_center(:,2), eye_to_center(:,3))
% plot3(eye_to_center(:,1), eye_to_center(:,2), eye_to_center(:,3))
% hold on
% plot3(eye_pos(1), eye_pos(3), eye_pos(2), 'ko');
% hold on
% to be remove ~

for c=1:size(newDisplayCell,1)
    plot3(newDisplayCell(c,1), newDisplayCell(c,3), newDisplayCell(c,2), '.b');
    hold on
end
hold on;
set(gca, 'CameraPosition', [eye_pos(1) eye_pos(3) eye_pos(2)]);
hold on
disp '------------Done------------';
end
disp '------------Done------------';
end