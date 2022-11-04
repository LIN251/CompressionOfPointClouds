function output = findLineSegIDX(lineArray, lnMin, lnMax)
% Iterate the array and identify which line segment contains the point
output = 0;
for i=1:size(lineArray,2)
    min=lineArray(i).minInclusive;
    max=lineArray(i).maxExclusive;
    if min == lnMin && max == lnMax
        output=i;
        return;
    end
end
if output == 0
    error('Error, findLineSegIDX:  Specified line not found.');
end
end