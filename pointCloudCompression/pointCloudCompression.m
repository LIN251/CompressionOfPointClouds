function output = pointCloudCompression(PrincetonShapeFileName, pointCloudFileName, eye)

% Include top folder for distanceCells
addpath(genpath([fileparts(pwd), filesep, 'util' ]));

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
    
    if(mod(rowid,10)==0)
        disp('.');
    end
end


% Eliminate duplicate points
ptCloud=unique(ptCloud,'rows');



% eye    = [1 1 1];
verbose = 1;
displayCell = [0 0 0];
direction = [];
% Grid: dimensions
grid3D.nx = 100;
grid3D.ny = 100;
grid3D.nz = 100;
minx = min(ptCloud(:,1));
miny = min(ptCloud(:,2));
minz = min(ptCloud(:,3));
maxx = max(ptCloud(:,1));
maxy = max(ptCloud(:,2));
maxz = max(ptCloud(:,3));
grid3D.minBound = [minx,miny,minz]';
grid3D.maxBound = [maxx,maxy,maxz]';


for i=1:size(ptCloud,1)
    cur = ptCloud(i,:);
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
neighbor = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];

for e=1:size(direction,1)
    curDirection = direction(e,:);
    cur = aabbRayTracing(eye, curDirection, grid3D, verbose,ptCloud);
    if cur == 0
        continue
    else
        for i=1:size(neighbor,1)
            temp = cur + neighbor(i,:);
            if ismember(temp, ptCloud, "rows")
                if ismember(temp, displayCell, "rows")
                    continue
                else
                    displayCell = [displayCell; temp];
                end
            else
                continue
            end
        end
    end
end

center = [floor((minx+maxx)/2) floor((miny+maxy)/2) floor((minz+maxz)/2)];
triple = center - eye;
d1 = triple(1:1);
d2 = triple(2:2);
d3 = triple(3:3);
magnitude = sqrt(d1*d1 + d2*d2+ d3*d3);
centerDir = triple/magnitude;
disp(centerDir);



% Write the point cloud to a file
fid = fopen(pointCloudFileName,'w');
fprintf(fid,'OFF\n');
fprintf(fid,'%d 0 0 \n',size(displayCell,1));
for j=1:size(displayCell,1)
    % The following switch between y and z is intentional
    % It is to accomodate matlab 3D plot used in plotPtCld.m
    fprintf(fid,'%d %d %d\n',displayCell(j,1), displayCell(j,3), displayCell(j,2) );
end
 
fclose(fid);

end