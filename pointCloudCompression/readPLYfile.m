function [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPLYfile(filename)

vertexCount = [];
faceCount = [];

numFaces = 0;
numVertex=0;

fileID=fopen(filename);

doIterate=true;
% Process the header and obtain the number of vertices
while doIterate
    if ~feof(fileID)
        currLine = textscan(fileID,'%s',1,'Delimiter','\n');
        currRow = char(currLine{1});
        splittedRow = strsplit(currRow,' ');
        if strcmp(splittedRow(1),'element') == 1 && strcmp(splittedRow(2),'vertex') == 1
            vertexCount = splittedRow(3);
            numVertex = str2double(vertexCount);
        end
        if strcmp(splittedRow(1),'element') == 1 && strcmp(splittedRow(2),'face') == 1
            faceCount = splittedRow(3);
            numFaces = str2double(faceCount);
        end
        if strcmp(splittedRow(1),'end_header') == 1
            doIterate=false;
        end
    end
    % Process vertices to construct cubes each with cubeCard elements
end

% Make sure we have vertices to process
if numVertex == 0
    fclose(fileID);
    outputT = ['Number of vertices is zero.  Check the input file and make sure there is a row [element vertex INT] in its header.'];
    disp(outputT);
    return;
end
outputT= ['Finished processing the header. There are ', num2str(numVertex), ' vertices to process.'];
disp(outputT);

vertexCount=numVertex;
doIterate=true;
vertexList{1} = [];
maxW = 0.0;
maxH = 0.0;
maxD = 0.0;
minW = realmax;
minH = realmax;
minD = realmax;
multiplier=1.0;
rowCount = 1;

% Read the vertices in memory and compute maxW, maxH, and maxD
for rowCount=1:vertexCount
    currLine = textscan(fileID,'%s',1,'Delimiter','\n');
    currRow = char(currLine{1});
    splittedRow = strsplit(currRow,' ');
    splittedRow = str2double(splittedRow);

    vertexList{rowCount} = [splittedRow(1)*multiplier splittedRow(2)*multiplier splittedRow(3)*multiplier splittedRow(4) splittedRow(5) splittedRow(6) splittedRow(7)];

    % find the maximum W, H, D coordinates
    if splittedRow(1)*multiplier > maxW
        maxW = splittedRow(1)*multiplier;
    end
    if splittedRow(2)*multiplier > maxH
        maxH = splittedRow(2)*multiplier;
    end
    if splittedRow(3)*multiplier > maxD
        maxD = splittedRow(3)*multiplier;
    end

    % find the minimum W, H, D coordinates
    if splittedRow(1)*multiplier < minW
        minW = splittedRow(1)*multiplier;
    end
    if splittedRow(2)*multiplier < minH
        minH = splittedRow(2)*multiplier;
    end
    if splittedRow(3)*multiplier < minD
        minD = splittedRow(3)*multiplier;
    end
end

%{
while doIterate
    if ~feof(fileID)
        currLine = textscan(fileID,'%s',1,'Delimiter','\n');
        currRow = char(currLine{1});
        splittedRow = strsplit(currRow,' ');
        splittedRow = str2double(splittedRow);

        if(rowCount <= vertexCount)
            vertexList{rowCount} = [splittedRow(1)*multiplier splittedRow(2)*multiplier splittedRow(3)*multiplier splittedRow(4) splittedRow(5) splittedRow(6) splittedRow(7)];
            
            % find the maximum W, H, D coordinates
            if splittedRow(1)*multiplier > maxW
                maxW = splittedRow(1)*multiplier;
            end
            if splittedRow(2)*multiplier > maxH
                maxH = splittedRow(2)*multiplier;
            end
            if splittedRow(3)*multiplier > maxD
                maxD = splittedRow(3)*multiplier;
            end

            % find the minimum W, H, D coordinates
            if splittedRow(1)*multiplier < minW
                minW = splittedRow(1)*multiplier;
            end
            if splittedRow(2)*multiplier < minH
                minH = splittedRow(2)*multiplier;
            end
            if splittedRow(3)*multiplier < minD
                minD = splittedRow(3)*multiplier;
            end
        else
            error('Error in readPLYfile.m:  We exceeded the number of read vertices?');     
        end

        rowCount = rowCount +1;

        % progress
        if(mod(rowCount,10000)==0)
            disp('.');
        end
    else
        doIterate = false;
    end
    if rowCount == vertexCount
        doIterate = false;
    end
end
%}

fclose(fileID); %Close the input file

end