function [out] = INCUBE(Points, Corner, Lengths)

%this code detrmine a point (points) in or out a cube
% "out" is horizontal vector
%      if point incube --> 0
%      if point outcube -> 1
% "Points": points that we want to determine their location
% "Corner": coordinates of the main corner of a cube
% "Lengths": cube size (length of an edge) 
%
%Ver:   01.02.3
%Date:  7/18/2018
%Autho: Sajjad Nasiri
%Email: s_nasiri_cs@yahoo.com

%% Parameter
[~, n] = size(Points);
out = zeros(1, n);

x = Points(1, :);
y = Points(2, :);
z = Points(3, :);

%% Determine

out(x<Corner(1)) = 1;
out(y<Corner(2)) = 1;
out(z<Corner(3)) = 1;

out(x>Corner(1) + Lengths(1)) = 1;
out(y>Corner(2) + Lengths(2)) = 1;
out(z>Corner(3) + Lengths(3)) = 1;

