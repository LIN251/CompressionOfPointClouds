function output = distanceCells(coord1, coord2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  euclidian distance between coord1 and coord2  %
%               in cells.                                     %
% Used by:      distTrigFace.m                                %
% Dependencies: None                                          %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computes the euclidian distance between coord1 and coord2 in the number of
%cells
if size(coord1,2)~=3 && size(coord1,2)~=7
    err=['Error, input coordinate 1 is not a triangle.  Its size is ' num2str(size(coord1,2))];
    disp(err);%disp '>> Error, input coordinate 1 is not a triangle.  Its size is %d',size(coord1,2);
end
if size(coord2,2)~=3 && size(coord2,2)~=7
    err=['Error, input coordinate 2 is not a triangle.  Its size is ' num2str(size(coord2,2)) ];
    disp(err);%disp '>> Error, input coordinate 2 is not a triangle.  Its size is %d',size(coord2,2);
end
diff = coord1 - coord2;
diffsq = diff.^2;
distsq = diffsq(1)+diffsq(2)+diffsq(3);
output = distsq.^0.5;
end