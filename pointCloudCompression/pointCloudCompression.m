function output = pointCloudCompression(PrincetonShapeFileName, hits, cells, mode)
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
end


% Eliminate duplicate points.
ptCloud=unique(ptCloud,'rows');
numberOfPoints = size(ptCloud,1);
disp(['Generating point cloud with ', num2str(numberOfPoints), ' vertices.' ]);
verbose = 1;
direction = [];
% Grid: dimensions.
[idx,center]=kmeans(ptCloud,1);
minD  = min(ptCloud(:,1))-1;
minH = min(ptCloud(:,2))-1;
minW = min(ptCloud(:,3))-1;
maxD = max(ptCloud(:,1))+1;
maxH = max(ptCloud(:,2))+1;
maxW = max(ptCloud(:,3))+1;
grid3D.nx = maxD;
grid3D.ny = maxH;
grid3D.nz = maxW;
grid3D.minBound = [minD,minH,minW]';
grid3D.maxBound = [maxD,maxH,maxW]';
numOfCellsX = cells(1);
numOfCellsY = cells(2);
numOfCellsZ = cells(3);
points = [0 0 0];
validCellBoundry = [0 0 0 0 0 0];
xr = ceil((maxD-minD)/numOfCellsX);
zr = ceil((maxH-minH)/numOfCellsZ);
yr = ceil((maxW-minW)/numOfCellsY);




% % 'pcbin' requires Computer Vision Toolbox
col1 = ptCloud(:,1);
col2 = ptCloud(:,2);
col3 = ptCloud(:,3);
ptCloud2 = pointCloud([col1 col3 col2]);
pointscolor=uint8(zeros(ptCloud2.Count,3));
pointscolor(:,1)=255;
pointscolor(:,2)=255;
pointscolor(:,3)=51;
ptCloud2.Color=pointscolor;


% Get block boundry.
boundry = [0 0 0 0 0 0];
tminD = minD;
tminH = minH;
tminW = minW;
for h = 1 :numOfCellsZ
    h = h -1;
    tminH = minH + (h * zr);
    for w = 1 :numOfCellsY
        w = w -1;
        tminW = minW + (w * yr);
        for d = 1 :numOfCellsX
            d = d - 1;
            tminD = minD + (d * xr);
            tmin = [tminD tminH tminW];
            tmax = [tmin(1)+xr tmin(2)+zr tmin(3)+yr];
            boundry = [boundry; tmin(1) tmin(2) tmin(3) tmax(1) tmax(2) tmax(3)];
        end
    end
end
boundry(1,:) = [];


% Map points to the blocks.
cellCloud = cell(1, numOfCellsX * numOfCellsY * numOfCellsZ);
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


% Block represents points.
for t = 1 :size(boundry,1)
    if size(cellCloud{t},1) > 7
        validCellBoundry = [validCellBoundry; boundry(t,:)];
    else
        validCellBoundry = [validCellBoundry; [0 0 0 0 0 0]];
    end
end
for t = 1 :size(boundry,1)
    tempcell = cellCloud{t};
    if size(tempcell,1) > 7
        Minx=min(tempcell(:,1));
        Minz=min(tempcell(:,2));
        Miny=min(tempcell(:,3));
        Maxx=max(tempcell(:,1));
        Maxz=max(tempcell(:,2));
        Maxy=max(tempcell(:,3));
        temp = [Minx Minz Miny;Maxx Minz Miny;Minx Maxz Miny;Minx Minz Maxy;Maxx Maxz Miny;Maxx Minz Maxy;Minx Maxz Maxy;Maxx Maxz Maxy];        
        points = [points;temp];
        rangeCenterx = floor((max(tempcell(:,1))+ min(tempcell(:,1)))/ 2);
        rangeCentery = floor((max(tempcell(:,2))+ min(tempcell(:,2)))/ 2);
        rangeCenterz = floor((max(tempcell(:,3))+ min(tempcell(:,3)))/ 2);
        range_center = [rangeCenterx rangeCentery rangeCenterz];
        [idk, weight_center]=kmeans(tempcell,1);
        points = [points; range_center];
        points = [points; weight_center];
    elseif size(tempcell,1) > 0
        points = [points; tempcell];
    end
end
points(1,:) = [];
validCellBoundry(1,:) = [];


% Create a figure for mode1 and mode 2. 
disp 'Process original point cloud.';
collectionArr = [];
figobj = figure;
axis equal;
hold on;
ax = gca;


% Set up call back function.
if mode == "mode1"
    % map points to corresponding small blocks.
    for each = 1 :size(cellCloud,2)
        if size(cellCloud{each},2) == 0
            collectionArr = [collectionArr 0];
        else
            collectionArr = [collectionArr plot3(cellCloud{each}(:,1).', cellCloud{each}(:,3).', cellCloud{each}(:,2).', '.b')];  
        end
    end
    
    count = 0;

    % Process original point cloud.
    for each = 1 :size(collectionArr,2)
        if size(cellCloud{each},2) ~= 0
                set(collectionArr(each),'visible','on')
                count = count + size(collectionArr(each).XData,2);
        end
    end

    % call back function for cursor movtion
    f1 = @(src,evnt)modeOne(src,grid3D,validCellBoundry,points,collectionArr);
    iptaddcallback(figobj,'WindowButtonMotionFcn',f1);

elseif mode == "mode2"
    % create a point cloud for comparing purposes.
    col1 = ptCloud(:,1);
    col2 = ptCloud(:,2);
    col3 = ptCloud(:,3);
    ptCloud2 = pointCloud([col1 col3 col2]);
    pointscolor=uint8(zeros(ptCloud2.Count,3));
    pointscolor(:,1)=255;
    pointscolor(:,2)=255;
    pointscolor(:,3)=51;
    ptCloud2.Color=pointscolor;

    ax = pcshow([0 0 0]);
    dataH = get(gca, 'Children');
    set( dataH(1), 'visible', 'off')
  
    % Process original point cloud.
    for each = 1 :size(cellCloud,2)
        if size(cellCloud{each},2) == 0
            collectionArr = [collectionArr 0];
        else
            collectionArr = [collectionArr plot3(cellCloud{each}(:,1).', cellCloud{each}(:,3).', cellCloud{each}(:,2).', '.b')];  
        end
    end
    
    for each = 1 :size(collectionArr,2)
        if size(cellCloud{each},2) ~= 0
                set(collectionArr(each),'visible','on')
        end
    end

    % call back function for cursor click
    f1 = @(src,evnt)modeTwo(src,grid3D,validCellBoundry,points,collectionArr,ax,center,ptCloud2);
    iptaddcallback(figobj,'WindowButtonDownFcn',f1);
else
    disp 'Mode incorrect, enter mode1 or mode2.';
end


% Prepare a default view position.
% Get the max value of x, y, z of the point cloud, and then ceil the value
% to its closest integer. Ex: 88 -> 100, 210->300.
maxPos = max([maxD,maxH,maxW]);
maxPosChar = char(string(maxPos));
maxPosInt = str2num(maxPosChar(1:1))+1;
value = maxPosInt * 10^(size(maxPosChar,2)-1);
cursor = [value value value];

tempPosition = [cursor(1) cursor(3) cursor(2)];
triple = center - tempPosition;
vector = triple/norm(triple);
campos('manual')
camproj('orthographic')
campos([tempPosition(1) , tempPosition(2) ,  tempPosition(3)])
hold on
direction = [vector(1) vector(2) vector(3)];
if cursor(2) < center(2)
    view([-direction(1) -direction(2) -direction(3)]);
else
    view([direction(1) direction(2) direction(3)]);
end
hold on;



% Mode 1 for Button motion tracking.
function modeOne(src,grid3DNew,validCellBoundryNew,pointsNew,collectionArr)
    cellList = [];
    verbosenew = 1;
    % Get click position
    clickedPt = get(gca,'CurrentPoint');
    VMtx = view(gca);
    point2d = VMtx * [clickedPt(1,:) 1]';
    cursor = point2d(1:3)';
    disp 'Process cursor position:';
    disp([cursor(1) cursor(2) cursor(3)])


    % Re-calculate ray directions.
    directionNew = [];
    for u=1:size(pointsNew,1)
        cur = pointsNew(u,:);
        triple = cur - cursor;
        tem = triple/norm(triple);
        directionNew = [directionNew; tem];
    end
    directionNew=unique(directionNew,'rows');


    % AABB ray tracing.
    for e=1:size(directionNew,1)
        curDirection = directionNew(e,:);
        index = aabbRayTracing(cursor, curDirection, grid3DNew, verbosenew, validCellBoundryNew);
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
   

    % Process blocks
    for each = 1 :size(collectionArr,2)
        if size(cellCloud{each},2) ~= 0
            if ismember(each,cellList)
                set(collectionArr(each),'visible','on')
            else
                set(collectionArr(each),'visible','off')
            end  
        
        end
    
    end
    % pause the figure so the point cloud will not move by the Matlab
    % default behaver.
    pause(eps)
    hold on
end



% Mode 2 for Button click tracking.
function modeTwo(src,grid3DNew,validCellBoundryNew,pointsNew,collectionArr,ax,center,OrgPC)
    disableDefaultInteractivity(ax)
    cellList = [];
    verbosenew = 1;
    % Get click position.
    clickedPt = get(gca,'CurrentPoint');
    VMtx = view(gca);
    point2d = VMtx * [clickedPt(1,:) 1]';
    cursor = point2d(1:3)';
    disp 'Process cursor position:';
    disp([cursor(1) cursor(2) cursor(3)])
    if ((grid3DNew.minBound(1) <= cursor(1)) && (cursor(1)<= grid3DNew.maxBound(1)) ...
            && (grid3DNew.minBound(2) <= cursor(2)) && (cursor(2)<= grid3DNew.maxBound(2)) ...
            && (grid3DNew.minBound(3) <= cursor(3)) && (cursor(3)<= grid3DNew.maxBound(3)))
        disp 'Cursor click position inside the point cloud.';
    
    end
    % Re-calculate ray directions.
    directionNew = [];
    for u=1:size(pointsNew,1)
        cur = pointsNew(u,:);
        triple = cur - cursor;
        tem = triple/norm(triple);
        directionNew = [directionNew; tem];
    end
    directionNew=unique(directionNew,'rows');


     % AABB ray tracing.
    for e=1:size(directionNew,1)
        curDirection = directionNew(e,:);
        % call helper function for ray tracing.
        index = aabbRayTracing(cursor, curDirection, grid3DNew, verbosenew, validCellBoundryNew);
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


    % Process blocks.
    
    newPc = [];
    for each = 1 :size(collectionArr,2)
        if size(cellCloud{each},2) ~= 0
            if ismember(each,cellList)
                set(collectionArr(each),'visible','on')
                tempX = collectionArr(each).XData';
                tempY = collectionArr(each).YData';
                tempZ = collectionArr(each).ZData';
                newPc = [newPc;[tempX tempY tempZ]];
            else
                set(collectionArr(each),'visible','off')
            end
        end
    end
    newPC = pointCloud(newPc);
    ax = pcshowpair(OrgPC,newPC);
    p1 = [cursor(1) cursor(3) cursor(2)];
    ax.CameraPosition = p1;
    ax.CameraTarget = center;
    % Set matlab camera.
%     p1 = [cursor(1) cursor(3) cursor(2)];
%     triple = center - p1;
%     unitVector = triple/norm(triple);
%     campos('manual')
%     
%     campos([p1(1) , p1(2) ,  p1(3)])
%     camtarget(center)
%     hold on
%     tempDirection = [unitVector(1) unitVector(2) unitVector(3)];
%     if cursor(2) < center(2)
%         view([-tempDirection(1) -tempDirection(2) -tempDirection(3)]);
%     else
%         view([tempDirection(1) tempDirection(2) tempDirection(3)]);
%     end

    hold on;
    disp '------------Done------------';
end




% AABB ray tracing.
function index = aabbRayTracing(origin, direction, grid3D, verbose, boxes)
    index = 0;
    % call helper function to get the first hit between ray and the ideal
    % box.
    [flag, tMinHit] = rayBCIntersection(origin, direction, grid3D.minBound, grid3D.maxBound);
    % if no hit then return.
    if (flag==0)
        index = 0;
        return
    else
        if (tMinHit<0)
            tMinHit = 0;
        end;
        start   = origin + tMinHit*direction;
        % strat is the first hit betweent current ray and the ideal box.
        x1 = start(1);
        y2 = start(2);
        z3 = start(3);
        index = []; 
        while ( (x1<=grid3D.nx)&&(x1>=1) && (y2<=grid3D.ny)&&(y2>=1) && (z3<=grid3D.nz)&&(z3>=1) )
            if (verbose)
                for t1=1:size(boxes,1)
                    if (boxes(t1,1) == 0 && boxes(t1,2) == 0 && boxes(t1,3) == 0 &&boxes(t1,4) == 0 &&boxes(t1,5) == 0 &&boxes(t1,6) == 0)
                        continue
                    end
                    % check hit a valable block.
                    if (x1 >= boxes(t1,1) && x1 <= boxes(t1,4) && y2 >= boxes(t1,2) && y2 <= boxes(t1,5) && z3 >= boxes(t1,3) && z3 <= boxes(t1,6) && ~ismember(t1,index))   
                        index = [index; t1];
                        %number of blocks hited before returning.
                        if size(index,1) >= hits
                            return
                        end
                    end
                end
            end
            % extend the ray.
            x1 = x1 + direction(1);
            y2 = y2 + direction(2);
            z3 = z3 + direction(3);
        end;        
     end;
end


%helper function to calculate the first hit between ray and the ideal box.
function [flag ,tMin] = rayBCIntersection(origin, direction, vmin, vmax)
    % Simultaneous equations of Rays and Planes.
    if (direction(1) >= 0) 
    	tMin = (vmin(1) - origin(1)) / direction(1);
    	tMax = (vmax(1) - origin(1)) / direction(1);
    else
    	tMin = (vmax(1) - origin(1)) / direction(1);
    	tMax = (vmin(1) - origin(1)) / direction(1);
    end
  
    if (direction(2) >= 0) 
        tymin = (vmin(2) - origin(2)) / direction(2);
        tymax = (vmax(2) - origin(2)) / direction(2);
    else
    	tymin = (vmax(2) - origin(2)) / direction(2);
    	tymax = (vmin(2) - origin(2)) / direction(2);
    end

    if ( (tMin > tymax) || (tymin > tMax) )
        flag = 0;
        tMin = -1;
    	return;
    end
       
    if (tymin > tMin)
        tMin = tymin;
    end
    
	if (tymax < tMax)
        tMax = tymax;
    end
    
	if (direction(3) >= 0)
       tzmin = (vmin(3) - origin(3)) / direction(3);
       tzmax = (vmax(3) - origin(3)) / direction(3);
    else
       tzmin = (vmax(3) - origin(3)) / direction(3);
       tzmax = (vmin(3) - origin(3)) / direction(3);
    end

    % check whether there is a hit between ray and the ideal box.
    % if not hit then return.
    if ((tMin > tzmax) || (tzmin > tMax))
        flag = 0;
        tMin = -1;
       return;
    end
    
    if (tzmin > tMin)
        tMin = tzmin;
    end
   
    if (tzmax < tMax)
        tMax = tzmax;
    end
      flag = 1;
end



disp '------------Done------------';
end