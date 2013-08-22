function m05 (varargin)
global x hui hline

if nargin==0
    close all
    figure
    axes('xlim',[0 100],'ylim',[0 100],...
        'position',[0.1 0.2 0.8 0.7]) % Lift up axes so slider labels
    x = 1:100; % don't overlap graph
    y = x;
    hline = line(x,y);
    
    hui(1) = uicontrol('style','slider',...
        'value',1,...
        'min',1,'max',100,...
        'position',[10 10 80 20],...
        'callback','m05 slider1');
    
    hui(2) = uicontrol('style','slider',...
        'value',1,...
        'min',0,'max',1,...
        'position',[110 10 80 20],...
        'callback','m05 slider2') ;
    hui(3) = uicontrol('style','text',... % Add labels to sliders
        'string','div=1',... % Text only, so
        'position',[10 35 80 20]); % no callback needed
    hui(4) = uicontrol('style','text',...
        'string','color=1',...
        'position',[110 35 80 20]);
    
else
    switch varargin{:}
        case 'slider1'
            div = get(hui(1),'value');
            set(hline,'ydata',x/div)
            % update label above slider. The label has
            % 2 components: the string 'div=' and the
            % value of div, which is a number and must be
            % converted to a string with num2str
            set(hui(3),'string',['div=' num2str(div)])
        case 'slider2'
            val = get(hui(2),'value');
            set(gca,'color',[1 val val])
            % update label, as above
            set(hui(4),'string',['color=' num2str(val)])
    end
end

