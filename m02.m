function m02 
global x hui hline 

div = get(hui,'value'); % get the slider value 
set(hline,'ydata',x/div) % redraw the line 