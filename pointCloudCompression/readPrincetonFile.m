function [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPrincetonFile(filename)

dimRow=true;
vertexCount = [];
faceCount = [];
edgeCount = [];
rowCount = 1;
vertexList{1} = [];
faceList{1} = [];
faceColorList{1} = [];

maxW = 0.0;
maxH = 0.0;
maxD = 0.0;
minW = realmax;
minH = realmax;
minD = realmax;
multiplier=1.0;
rowCount = 1;

vertexCount = [];
faceCount = [];

numFaces = 0;
numVertex=0;

fileID=fopen(filename);

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

                if vertexList{rowCount}(1)*multiplier > maxW
                    maxW = vertexList{rowCount}(1)*multiplier;
                end
                if vertexList{rowCount}(2)*multiplier > maxH
                    maxH = vertexList{rowCount}(2)*multiplier;
                end
                if vertexList{rowCount}(3)*multiplier > maxD
                    maxD = vertexList{rowCount}(3)*multiplier;
                end

                % find the minimum W, H, D coordinates
                if vertexList{rowCount}(1)*multiplier < minW
                    minW = vertexList{rowCount}(1)*multiplier;
                end
                if vertexList{rowCount}(2)*multiplier < minH
                    minH = vertexList{rowCount}(2)*multiplier;
                end
                if vertexList{rowCount}(3)*multiplier < minD
                    minD = vertexList{rowCount}(3)*multiplier;
                end
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

fclose(fileID); %Close the input file
numVertex = rowCount;
end