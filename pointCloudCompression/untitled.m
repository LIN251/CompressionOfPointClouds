% plot
% f = figure;
% axis equal;
% plot3(2, 2, 2, '.b');
% s = 5
figure('WindowButtonDownFcn',@(src,evnt)printPos(src,evnt))
% view(-140,12);
% hold on;



% on_click function
function printPos(src,evnt)
%     clickedPt = get(gca,'CurrentPoint');
%     VMtx = view(gca);
%     point2d = VMtx * [clickedPt(1,:) 1]';
%     eyepos = point2d(1:3)'
    plot3(3, 3, 3, '.b');
    plot3(6, 6, 6, '.b');
    plot3(8, 8, 8, '.b');
    plot3(9, 10, 4, '.b');
    clf(src)

end