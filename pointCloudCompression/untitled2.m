x=@(t)(sin(4*t)).^2;
y=@(t)cos(5*t);
z=pi;
figure(1)
for t=0:0.002:z
    plot(x(t),y(t),'.','MarkerSize',4,'color',[0,(t+z)/(2*z),(t+z)/(2*z)])
    axis([0  1    -1  1])
    hold on
    pause(eps)
end