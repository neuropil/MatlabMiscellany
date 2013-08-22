function m04 (varargin)
global x hui hline

if nargin==0
    close all
    figure
    axes('xlim',[0 100],'ylim',[0 100])
    x = 1:100;
    y = x;
    hline = line(x, y);
    
    % make hui a vector of 2 values, hui(1) and hui(2)
    hui(1) = uicontrol('style','slider',...
        'value',1,...
        'min',1,'max',100,...
        'position',[10 10 80 20],... % x,y,width,height
        'callback','m04 slider1'); % rename
    % New slider sets background color of axes
    hui(2) = uicontrol('style','slider',...
        'value',1,...
        'min',0,'max',1,... % 0=black; 1=white
        'position',[110 10 80 20],... % right of 1st slider
        'callback','m04 slider2');
    
else
    % which slider was moved?
    switch varargin{:} % the answer is in varargin, either
        % 'slider1' or 'slider2'
        case 'slider1'
            div = get(hui(1),'value');
            set(hline,'ydata',x/div)
        case 'slider2'
            val = get(hui(2),'value');
            set(gca,'color',[1 val val])
    end
end