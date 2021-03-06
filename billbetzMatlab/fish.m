function fish
global v
prompt={'Total number of trials?' 'Total number of events?'};
title='Poisson calculator'; lineno=1;
def={'100' '100'};
inp=inputdlg(prompt,title,lineno,def);
Ntot=str2num(inp{1});
nn=str2num(inp{2});
m=nn/Ntot; em=exp(-m);
for j=1:9
    x=j-1
    n(j)=round(Ntot*m^x*em/factorial(x));
end
n=n';
str=[num2str(Ntot) ' trials. m= ' num2str(m) char(10) char(10),...
   'failures= ' num2str(n(1)) char(10),...
    'singles= ' num2str(n(2)) char(10),...
    'doubles= ' num2str(n(3)) char(10),...
    'triples= ' num2str(n(4)) char(10),...
    '4s= ' num2str(n(5)) char(10),...
    '5s= ' num2str(n(6)) char(10),...
    '6s= ' num2str(n(7)) char(10)];
msgbox(str)