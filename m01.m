function m01
global x hui hline % GLOBAL variables
% to pass between functions m01 and m02
close all
figure
axes('xlim',[0 100],'ylim',[0 100])
x = 1:100 ;
y = x;
hline = line(x,y);
% Set up slider, give its range (1-100),
% initial value (1), and callback (m02)
hui = uicontrol('style','slider',...
    'value',1,...
    'min',1,'max',100,...
    'callback','m02');