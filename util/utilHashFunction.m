function hval = utilHashFunction(coord)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  A hash function for the coordinates of a point%
%   The resulting hval is a string.                           %
%                                                             %
% Assumptions:  Point cloud files start with the string token %
%    'Scene' and end with the string token '.ply'             %
%                                                             %
% Used by: CloudPoint Class                                   %
% Dependencies: None                                          %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
multiplier1 = 10000;
multiplier2 = 11000;
multiplier3 = 12000;
hval=(multiplier1 * round(coord(1),6)) + (multiplier2 * round(coord(2),6)) + (multiplier3 *round(coord(3),6));
%}
s1 = num2str( round( coord(1),6) );
s2 = num2str( round( coord(2),6) );
s3 = num2str( round( coord(3),6) );
hval = strcat(s1,s2,s3);
end