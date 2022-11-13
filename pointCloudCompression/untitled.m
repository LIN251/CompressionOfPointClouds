function example
figure('WindowButtonMotionFcn',@(src,evnt)printPos())
plot3(rand(5,1),rand(5,1)*20,rand(5,1)*5,'.'), view(3)
      function printPos
          clickedPt = get(gca,'CurrentPoint');
          VMtx = view(gca);
          point2d = VMtx * [clickedPt(1,:) 1]';
          disp(point2d(1:3)')
      end
end