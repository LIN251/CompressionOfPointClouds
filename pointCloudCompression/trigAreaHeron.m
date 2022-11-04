function output = trigAreaHeron(v1, v2, v3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Computes the area of a triangle using Heron's %
%               technique.                                    %
% Used by:      surfaceVs.m                                   %
% Dependencies: None                                          %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We use Heron's technique to compute the area of a triangle
a=distanceCells(v1,v2);
b=distanceCells(v2,v3);
c=distanceCells(v1,v3);
s=(a+b+c)/2;
area = s*(s-a)*(s-b)*(s-c);
output = area.^0.5;
end