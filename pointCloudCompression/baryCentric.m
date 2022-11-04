function output = baryCentric(v1, v2, v3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Computes the center of a triangle identified  %
%               by three vertices using Barycentric technique.%                            %
% Used by:      surfaceVs.m                                   %
% Dependencies: None                                          %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u=0.33333;
w=0.33334;
v=u;
if (u+v+w ~= 1)
    disp 'Error, barycentric is broken.';
end

output=(v1*u)+(v2*v)+(v3*w);
end
