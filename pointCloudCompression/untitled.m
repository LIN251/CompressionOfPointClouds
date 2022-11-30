
figure('WindowButtonMotionFcn',@(src,evnt)printPos())
plot3(rand(5,1),rand(5,1)*20,rand(5,1)*5,'.'), view(3)
function printPos
  clickedPt = get(gca,'CurrentPoint');
  VMtx = view(gca);
  point2d = VMtx * [clickedPt(1,:) 1]';
  disp(point2d(1:3)')
end


% % % plot
% f = figure;
% axis equal;
% plot3(2, 2, 2, '.b');
% figure('WindowButtonDownFcn',@(src,evnt)printPos(src,evnt))
% view(-140,12);
% 
% % on_click function
% function printPos(src,evnt)
%     plot3(3, 3, 3, '.b');
%     plot3(6, 6, 6, '.b');
%     plot3(8, 8, 8, '.b');
%     plot3(9, 10, 4, '.b');
%     clf(src)
% 
% end

% data = peaks(25);
% h = surf(data);
% pause(3);
% % delete one point (in fact delete all 4 patches containing this point
% data(3,3) = NaN;
% set(h, 'zdata', data)

% 
% figobj = figure;
% f1 = @(varargin) disp('Callback 1');
% f2 = @(varargin) disp('Callback 2');
% iptaddcallback(figobj,'WindowButtonMotionFcn',f1);
% iptaddcallback(figobj,'WindowButtonMotionFcn',f2);



% figure;hold on; h1=plot(1,1,'b.'); h2=plot(2,2,'r.'); hold off
% % if you want to hide h2
% set(h2,'visible','off')
% % if you want to delete h2
% delete(h2)


% figure('WindowButtonDownFcn',@(src,evnt)printPos(src,evnt))
% 
% % on_click function
% function printPos(src,evnt)
%     clickedPt = get(gca,'CurrentPoint');
%     VMtx = view(gca);
%     point2d = VMtx * [clickedPt(1,:) 1]';
%     eyepos = point2d(1:3)'
%     % add points
% 
%     plot3(7.9, 7.9, 7.9, '.b');
%     plot3(8, 8, 8, '.b');
% 
% end



% h = plot(peaks);
% plot3(3, 3, 3, '.b');
% set(gca,'ButtonDownFcn', @clicky);
% function clicky(gcbo,eventdata,handles)
%     disp(get(gca,'Currentpoint'))
% end


% ax=gca;
% plot3(2, 2, 2, '.b'); % just plotting something, but totally not required
% hold(ax, 'on'); % just turning on hold because I'll assume that you don't want the axes reset each time you plot another point
% ax.ButtonDownFcn = @(~,~)point(ax)
% 
% function point(ax)
%     plot(ax,ax.CurrentPoint(1,1),ax.CurrentPoint(1,2),'ko');
% end