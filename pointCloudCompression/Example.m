close all; clear; clc;

figure; axis([-10 10 -10 10 -10 10]); grid on; hold on
xlabel X; ylabel Y; zlabel Z;
%--------------------------------------------------------------------------
xc=0; yc=0; zc=0;    % coordinated of the corner
L=5;                 % cube size 
alpha=0.2;           % transparency (max=1=opaque)

X0 = [0 0 0 0 0 1; 1 0 1 1 1 1; 1 0 1 1 1 1; 0 0 0 0 0 1];
Y0 = [0 0 0 0 1 0; 0 1 0 0 1 1; 0 1 1 1 1 1; 0 0 1 1 1 0];
Z0 = [0 0 1 0 0 0; 0 0 1 0 0 0; 1 1 1 0 1 1; 1 1 1 0 1 1];
%--------------------------------------------------------------------------
C='red'; % unicolor
X = L*(X0) + xc;
Y = L*(Y0) + yc;
Z = L*(Z0) + zc;
fill3(X,Y,Z,C,'FaceAlpha',alpha); hold on
%--------------------------------------------------------------------------
Points = [0  1  3  3 -1  6  4  6  4    % x
          0 -1  2  2  3  2  4  6  5.1  % y
          0  3  4 -1  2  1  6  6  4    % z
         ];
corner = [xc, yc, zc];
Lengths = [5 5 5];
%--------------------------------------------------------------------------
[out] = INCUBE(Points, corner, Lengths);
%--------------------------------------------------------------------------

for i = 1:9
    if out(i) == 0
        plot3(Points(1,i), Points(2,i), Points(3,i), 'bs');
    else
        plot3(Points(1,i), Points(2,i), Points(3,i), 'g*');
    end
end

