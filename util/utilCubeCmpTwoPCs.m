function diffTbl = utilCubeCmpTwoPCs(leadPointCloud, derivedPointCloud)
% Construct a hash table on the derivedFrame
% See if points in LeadFrame are found
chaosf = 0.001;

missingPts=0;
leadPts=0;
sz = [ 0 6];
varTypes=["int64","int64","int64","int64","int64","int64"];
varNames=["diffVertices","cubeid","LeadFVertices","DerivedFVertices","LeadMissingPts","DerivedMissingPts"];
diffTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
rowcnt = 0;
for i=1:size( leadPointCloud.cubes, 2 )
    [leadColor, derColor, mLD, mPts] = shiftedPoints(i, leadPointCloud, derivedPointCloud);
    missingPts=missingPts+size(mPts,2);
    leadPts=leadPts+size(mLD,2);
    valdiff = derivedPointCloud.cubes(i).numVertices - leadPointCloud.cubes(i).numVertices;
    if size(mLD,2) > 0 || size(mPts,2)>0
        rowcnt = rowcnt + 1;
        diffTbl(rowcnt,:)={valdiff,i, leadPointCloud.cubes(i).numVertices, derivedPointCloud.cubes(i).numVertices, size(mLD,2), size(mPts,2)};
    end
end

if missingPts > 0
    outputT= sprintf('Derived Point Cloud has %d non-matching points.',missingPts);
    disp(outputT);
end
if leadPts > 0
    outputT= sprintf('Lead Point Cloud has %d non-matching points.', leadPts);
    disp(outputT);
end
if missingPts == 0 && leadPts == 0
    outputT= sprintf('Point clouds match!');
    disp(outputT);
end

diffTbl=sortrows(diffTbl,1,'descend');
end
