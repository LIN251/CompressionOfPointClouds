figure('WindowButtonDownFcn',@(src,evnt)printPos(src,evnt))

% on_click function
function printPos(src,evnt)


    plot3(7.9, 7.9, 7.9, '.b');
    hold on
    plot3(7.8, 7.8, 7.8, '.b');
    hold on
    plot3(8, 8, 8, '.b');

end