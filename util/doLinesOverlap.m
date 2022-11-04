function output = doLinesOverlap(oneMin, oneMax, twoMin, twoMax)
output = 0;
%Overlap between two lines r1 and r2 means their 
% r1.min is equal to or greater than r2.min 
% and less than r2.max OR 
% r1.max is greater than r2.min and less than r2.max
if (oneMin >= twoMin && oneMin < twoMax) || (oneMax > twoMin && oneMax < twoMax)
    output = 1;
end
end