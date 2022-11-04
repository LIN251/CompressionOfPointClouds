function [leadColor, derColor, modPts, missingPts] = shiftedPoints(tgtCubeID, srcCloudPoint, destCloudPoint)
%Identify how many points in the cube have moved or changed color
%1. construct a hash table on the W-axis vertex of the sourceFrame
%2. proble the hash table with vertices of the destinationFrame

%Iterate the vertices of the srcframe and obtain their location along a
%dimension
keys=[];
vals=[];

chaosf = 0.001;

hashMapOnLeadFrame = containers.Map('KeyType','char', 'ValueType','any');

leadVL = srcCloudPoint.vertexList;
tgtDimension = 1; % Possible values are 1, 2, 3 for W, H, and D
for i=1:size( srcCloudPoint.cubes(tgtCubeID).assignedVertices, 2 )
    a1 = leadVL( srcCloudPoint.cubes(tgtCubeID).assignedVertices(i) );
    b1 = a1{1};
    % keys(i)=(multiplier1 * round(b1(1),6)) + (multiplier2 * round(b1(2),6)) + (multiplier3 *round(b1(3),6));
    %keys(i)=utilHashFunction(b1);
    %vals(i)=srcCloudPoint.cubes(tgtCubeID).assignedVertices(i);
    hval=utilHashFunction(b1);
    hashMapOnLeadFrame(hval)=srcCloudPoint.cubes(tgtCubeID).assignedVertices(i);
end
%hashMapOnLeadFrame = containers.Map(keys, vals);

%Iterate the vertices of the derived frame and see if their location
%matches
derivedVL = destCloudPoint.vertexList;
colorChangedPoints = 0;
leadColor=[];
derColor=[];
numMovedPoints = 0;
moved = [];
numMovCol = 0;
movCol=[];
modPts=[];
numMissingPts=0;
missingPts=[];
for i=1:size( destCloudPoint.cubes(tgtCubeID).assignedVertices, 2 )
    deriveda1 = derivedVL( destCloudPoint.cubes(tgtCubeID).assignedVertices(i) );
    derivedb1 = deriveda1{1};

    % probeKey = (multiplier1 * round(derivedb1(1),6) ) + (multiplier2 * round(derivedb1(2),6) ) + (multiplier3 * round(derivedb1(3),6) ) ;
    probeKey = utilHashFunction(derivedb1);

    if hashMapOnLeadFrame.isKey(probeKey)
        lV = hashMapOnLeadFrame(probeKey);
        leada1 = leadVL( lV );
        leadb1 = leada1{1};
        leadWidth = leadb1(1);
        leadHeight = leadb1(2);
        leadDepth = leadb1(3);

        %%%if leadWidth == derivedb1(1) && leadHeight == derivedb1(2) && leadDepth == derivedb1(3)
        if abs(leadWidth-derivedb1(1))<chaosf && abs(leadHeight-derivedb1(2))<chaosf && abs(leadDepth-derivedb1(3)) <chaosf
            % Point did not move
            % Check if color changed
            leadRed = leadb1(4);
            leadGreen = leadb1(5);
            leadBlue = leadb1(6);
            leadAlpha = leadb1(7);
            if leadRed == derivedb1(4) && leadGreen == derivedb1(5) && leadBlue == derivedb1(6) && leadAlpha == derivedb1(7)
            else
                colorChangedPoints = colorChangedPoints + 1;
                leadColor(colorChangedPoints)=lV;
                derColor(colorChangedPoints)=destCloudPoint.cubes(tgtCubeID).assignedVertices(i);
            end
            remove(hashMapOnLeadFrame, probeKey); % Delete hashmap entry to find newly inserted points.
        end
    else
        numMissingPts=numMissingPts+1;
        missingPts(numMissingPts)=destCloudPoint.cubes(tgtCubeID).assignedVertices(i);
    end
end
modPts=cell2mat( hashMapOnLeadFrame.values() );
end