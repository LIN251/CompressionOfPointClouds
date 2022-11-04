function output = findCubesInLineSeg(lineArray, pt)
% Iterate the array and identify which line segment contains the point
results = [];
cntr = 1;
for i=1:size(lineArray,2)
    min=lineArray(i).minInclusive;
    max=lineArray(i).maxExclusive;
    if pt >= min && pt < max
        tgtLine=lineArray(i);
        for j=1:size(tgtLine.cubeIds,2)
            results(cntr)=tgtLine.cubeIds(j);
            cntr = cntr + 1;
        end
    end
end
output=results;
end