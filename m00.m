function m00
close all % close all figures (windows)
figure
axes('ylim',[0 100]) % declare axes and set limit of y axis
x = 1:100;
y = x;
%set(gca,'ylim',[0 100]) % don't need now
hline = line(x,y);
for div = 1:10
    set(hline,'ydata',y/div)
    pause(1)
end