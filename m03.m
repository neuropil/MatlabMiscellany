function m03 (varargin) % VARiable ARGuments IN
% varargin contains any information passed into the function
global x hui hline

if nargin == 0 % No info (arguments) passed
    % (m03 called by itself)
    % This is m01
    close all
    figure
    axes('xlim',[0 100],'ylim',[0 100])
    x = 1:100;
    y = x;
    hline=line(x,y);
    
    hui=uicontrol('style','slider',...
        'value',1,...
        'min',1,'max',100,...
        'callback','m03 m02'); % Callback must change
    % from 'm02' to 'm03 m02'
else
    %%%%%%%%%%%%%% This is the old m02
    %function m02 % Omit the first 2 lines of m02
    %global x hslider hline
    div = get(hui,'value');
    set(hline, 'ydata', x/div)
end