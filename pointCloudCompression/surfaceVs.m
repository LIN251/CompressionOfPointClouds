function output = surfaceVs(v1, v2, v3, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Converts a triangle into a collection of      %
%               points.  It is used to generate a point cloud %
%               from a triangle.                              %
% Used by: cnvPrincetonShapeToPtCld                           %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPoints=trigAreaHeron(v1,v2,v3);
%thresholdPts=numPoints*threshold;

vS=[];
vS=[vS; round(v1)];
vS=[vS; round(v2)];
vS=[vS; round(v3)];

trigS{1}=[];

trigS{1,1}=v1;
trigS{1,2}=v2;
trigS{1,3}=v3;
trigS{1,4}=baryCentric(v1,v2,v3);

areaThreshold=0.5;

done= 0;

while done ~= 1
    %centerReg = 0;
    %v1=trigS{1,1}{1,1};
    %v2=trigS{1,2}{1,1};
    %v3=trigS{1,3}{1,1};
    %c=trigS{1,4}{1,1};

    v1=trigS{1,1};
    v2=trigS{1,2};
    v3=trigS{1,3};
    c=trigS{1,4};

    vS=[vS; round(c)];

    % Generate 3 additional triangles only if their area is greater than 1
    % cell
    a1=trigAreaHeron(c,v2,v3);
    a2=trigAreaHeron(v1,c,v3);
    a3=trigAreaHeron(v1,v2,c);



    if a1 > areaThreshold
        idx=size(trigS,1)+1;
        trigS{idx,1}=c;
        trigS{idx,2}=v2;
        trigS{idx,3}=v3;
        trigS{idx,4}=baryCentric(c,v2,v3);
    end

    if a2 > areaThreshold
        idx=size(trigS,1)+1;
        trigS{idx,1}=v1;
        trigS{idx,2}=c;
        trigS{idx,3}=v3;
        trigS{idx,4}=baryCentric(v1,c,v3);
    end

    if a3 > areaThreshold
        idx=size(trigS,1)+1;
        trigS{idx,1}=v1;
        trigS{idx,2}=v2;
        trigS{idx,3}=c;
        trigS{idx,4}=baryCentric(v1,v2,c);
    end

    % Delete the processed row
    trigS([1],:)=[];

    %Terminate if the table of trinagles is empty
    if size(trigS,1)==0
        done=1;
    end
end

output=unique(vS,'rows'); % eliminate duplicates
end