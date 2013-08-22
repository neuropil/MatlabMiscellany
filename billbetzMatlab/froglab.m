function varargout = froglab(varargin)
% froglab: a student laboratory exercise for recording, displaying,
% and analyzing synaptic potentials. Written for PC with a
% National Instruments A/D card.
% *******************************************
% Bill Betz
% Department of Physiology & Biophysics
% University of Colorado Medical School
% Aurora, CO 80045 USA
% email: bill.betz@ucdenver.edu

global v vh
if nargin==0;
    close all
    more off
    %%%%%%%%% Matlab code - Make figure
    hfig=openfig(mfilename,'reuse');
    set(hfig,'visible','off','name','NMJ lab','handlevisibility','on',...
        'doublebuffer','on')
    handles=guihandles(hfig); guidata(hfig, handles);
    if nargout>0; varargout{1}=hfig; end
    vh=handles; % creates structure array v, containing all global v vhariables
    vh.hfig=hfig;
    %%%%%%%%%%%%%%%%%%% Initial values

    if isempty(v)
        v.testprogram=0; % for testing - mepps and epps artificially create
        v.sr=5000; % digitizing rate for data acquisition
        v.sr0=v.sr; % copy
        %    set(vh.h1digrate,'string',['Digitizer Vars ' num2str(v.sr)])

        v.hh=sort(findobj('tag','h1radiodisptime')); hhval=str2num(get(v.hh(3),'string'));
        set(v.hh,'value',0); set(v.hh(3),'value',1); v.nradiodisp=3;
        v.disptime=[hhval 1 .05]; % x axis max for chart, mepp, and epp
        v.fun=0; % marker is asterisk at bottom (0) or fun font at trace (1)
        v.funfont={'wingdings'}; % 'webdings' 'wingdings' 'wingdings 2' 'wingdings 3'};
        %{'Milestones Regular' 'Mini Pics Art Jam' 'Mini Pics Lil Critters'...
        %       'Mini Pics Lil Events' 'Mini Pics Lil Vehicles' 'Mini Pics Red Rock' 'WingDings'};
        v.funchar=[char(65:90) char(97:122)]; v.funcharsize=18;
        %vh.hfig=hfig; % handle of figure
        v.source=mfilename; % name of this function
        v.abortdaq=0; % main variable for abort and service
        v.scopezoom=0;
        v.zoompos=[0 -.1 5 .2];
        v.zoomwidth=0.01; % half-width
        v.dscroll=0.1; % fraction of screen to scrool with left & right arrows
        v.hold=0; v.nhold=0;
        v.holdv=0; % # last offset (mV) for held sweeps (scope mode only)
        v.dhold=get(vh.h1sweepoffset,'value'); % offset for each sweep
        v.pause=0; % pause (scope mode only)
        v.chartpaper=1; % chart & mepp display chart(0) or 'scope (1)
        v.linestyle=1; % 0=dotted, 1=solid
        v.mode=1; % scope (1), mepp(2), epp(3), analysis(4)
        v.readzero=0; % temp variable that read zero button pressed
        v.yoffset=0; % Read zero value
        v.offset2=-50; % mV offset to position zero so there is a larger negative range
        v.modestr={'Scope' 'MEPPs' 'EPPs' 'Analyze'}; % Mode callback names
        v.ac=0; % a/c recording
        v.keypress=0; % keypress
        v.keypresscase=''; % keypress callback name
        v.ylimdc=[get(vh.h1ybot,'value') get(vh.h1ytop,'value')]; % DC scope mode yaxis VALUES
        v.ylimac=[-5 10];                                         % AC scope mode yaxis VALUES
        v.pretend=0; % make fake mepp & epp curves (analyze)
        v.holdline=[]; % hold lines in  scope mode

        % MEPP variables
        v.pre=20; v.post=40; % msec pre & post MEPP peak to keep
        v.npre=round(v.sr*v.pre/1000); v.npost=round(v.sr*v.post/1000); % # pts
        v.mepps=zeros(1,v.npre+1+v.npost); % holds captured mepps
        v.nmepp=0; % number of captured mepps
        v.mxmepp=[]; % vector of max values of captured mepps
        v.thresh=get(vh.h2thresh,'value'); % threshold for mepps
        % v.keepit=0; % flag: 0=don't keep; 1=mark but don't keep; 2=keep mepps
        v.editmepps=0; % flag for editing mepps
        %  set(vh.h2nprepost,'string',['Pre/Post ' num2str(v.pre) '/' num2str(v.post)])

        % EPP variables
        v.h3single=0;
        v.nbineppcalc=200; % # bins for calculated EPP fit
        v.nbineppobs=20;   % # bins for observed EPP amplitudes
        v.sptepp=v.sr*v.disptime(3); % # samples per epp
        v.epps=zeros(1,v.sptepp); % holds captured epps
        v.sumepp=zeros(v.sptepp,1); % for average epp display
        v.nepp=0; % # captured epps
        v.mxepp=[]; % vector of max values of captured epps
        % v.keepitepp=0; % flag: 0=don't keep; 1=keep epp
        v.epplen=100; % length of epp record (msec)
        v.editepps=0; % flag for editing epps
        v.lowcut=0.25; % low limit for EPPs (below this: m=0)
        v.showavgepp=0; % plots the average of all kept EPPs
        %  clr=[.61 .61 .88]; if v.showavgepp; clr=[1 0 0]; end
        %  set(vh.h3showavgepp,'backgroundcolor',clr)

        v.eppleft=.01; v.eppleftpt=round(v.eppleft*v.sr);
        v.eppright=.02; v.epprightpt=round(v.eppright*v.sr);
        v.calc3vars=1; % (Analyze mode) =0 if new # bins or mouse click

        % Stimulus trigger
        v.trigsource=0; % Stim Trig internal(0) or external (1)
        v.exttrig=0; % flag that external trigger occurred
        v.stimv=5; % voltage of internal output pulse for triggering stimulator
        v.stimpre=5; % msec pre internal trigger
        v.stimpulsedur=1; % pulse duration (msec)
        v.stimdur=1; % same as v.stimpulsedur
        v.stimpost=1; % msec post internal trigger
        v.stimrpt=1; % repeat the trigger
        v.stimf2=1; v.stimf1=1; % internal stimulus frequencies for scope and epp
        v.trainf=50; % train frequency (Hz)
        v.traindur=2; % train duration (sec)
        % nn=floor(v.trainf*v.traindur);
        % set(findobj('tag','h1train'),'string',['train ' num2str(nn)])
        % set(findobj('tag','h1trainvars'),'string',['Set ' num2str(v.trainf) 'Hz/' num2str(v.traindur) ' s'])
        % v.trainon=0; % train on or off
        v.stimperiod1=1/v.stimf1; % internal stimulus period (s)
        % v.stimon2=0; % flag: epp internal stimulus is off (0) or on (1)
        % v.stimon1=0; % flag: scope internal stimulus is off (0) or on (1)
    end % if ~exist('v')
    v.keepit=0; v.keepitepp=0; v.trainon=0; v.stimon2=0; v.stimon1=0;
    clr=[.61 .61 .88]; if v.showavgepp; clr=[1 0 0]; end
    set(vh.h3showavgepp,'backgroundcolor',clr)
    nn=floor(v.trainf*v.traindur);
    set(findobj('tag','h1train'),'string',['train ' num2str(nn)])
    set(findobj('tag','h1trainvars'),'string',['Set ' num2str(v.trainf) 'Hz/' num2str(v.traindur) ' s'])

    getmarker
    %%%%%%%%%%%%%%%%%%%%%%%% Initialize DAQ
    daqreset % Reset the daq card
    hw=daqhwinfo('nidaq'); v.hw=char(hw.BoardNames); % 'PCI-6035E' or 'PCI-MI0-16E-4';
    % For laptops: 'DAQCard-1200' or 'DAQCard-6024E'
    v.inputrange=[-1 1];
    %%%%%%%%%%%%%%%%%%%%%%%% Initialize graph
    figure(vh.hfig); % pop figure
    set(vh.hfig,'visible','on')
    vh.hax=subplot(1.1,1,1);
    pos=get(vh.hax,'position'); pos(3)=0.85; set(vh.hax,'position',pos); % widen axes
    set(vh.hax,'color',[1 1 .95])
    %   set(gca,'Ylabel',text('String','mV','Color','r'))
    vh.hax2=axes('position',[.77 .68 .2 .22],'visible','on'); % Mepp histogram
    axes(vh.hax)
    ybot=get(vh.h1ybot,'value'); ytop=get(vh.h1ytop,'value');
    set(vh.hax,'xlim',[0 v.disptime(1)],'ylim',[ybot ytop]);
    v.ymarker=0;
    v.abortdaq=6;
    abortdaq
elseif ischar(varargin{1}) % Matlab code    INVOKE NAMED SUBFUNCTION OR CALLBACK
    %try;
    if (nargout); [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else; feval(varargin{:}); end % FEVAL switchyard
    %atch;
    %   s=lasterror; errordlg(['FEVAL switchyard error ' lasterr]); %disp(lasterr); keyboard
    % keyboard
    % end
end % nargin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------------------
function Scope(varargin)
global v vh
axes(vh.hax)
set(vh.hfig,'keypressfcn',[v.source ' keypress'])
v.trig=0;
v.disptime(1)=max(0.1,v.disptime(1)); % Don't display less than about 100 msec
set(vh.hax,'xlim',[0 v.disptime(1)]);
ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
set(vh.hax,'ylim',ylimit)
%v.holdv=v.ac*(0.95*ylimit(1)+0.05*ylimit(2)+v.dhold);
v.holdv=v.ac*(ylimit(1)+0.05*(ylimit(2)-ylimit(1)));
v.stimon1=0; set(vh.h1stim,'value',0)
set(vh.h1stim,'backgroundcolor',[.88 .62 .62])
v.Y=zeros(v.sr*v.disptime(1),1); v.T=[1:v.sr*v.disptime(1)]'/v.sr; lenT=length(v.T);
vline=line('tag','voltage','xdata',v.T,'ydata',v.Y(:,1),'color','red');
v.maxholdline=floor(0.9*(ylimit(2)-ylimit(1)*v.ac-v.Y(1)*~v.ac)/(v.dhold+.001));
hfun=text('tag','hfun','fontsize',48,'position',[.1 0]);

set(vh.hVmtxt,'visible','on')
i=1; lenvY=length(v.Y); yleft=lenvY; widow=[];
tt=v.disptime(1);
v.ymarker=ylimit(1);
%set(vh.hax,'buttondownfcn',[v.source ' mousebutton00']) % zoom
set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton00']) % zoom
hmarker=text('tag','hmarker','position',[tt v.ymarker],...
    'fontsize',v.funcharsize,'FontName',v.funfontnow,'string',v.funcharnow);
sampacq0=0;
start(v.ai)
while v.ai.SamplesAcquired<v.sr; end % take one second of data
while v.abortdaq==0;
    while (v.ai.SamplesAcquired-sampacq0==0); end
    sampacq=v.ai.SamplesAcquired;
    try; v.y=peekdata(v.ai,min(lenvY,sampacq-sampacq0)); catch; end
    v.y=v.y.*100+v.offset2; % convert to mV, make 0 be -50mV to give bigger range on negative side of zero
    sampacq0=sampacq;
    try; avgy=mean(v.y); catch; avgy=0; end
    if length(widow); v.y=[widow;v.y]; widow=[]; end
    lenvy=length(v.y);
    if yleft<lenvy; % Make new widow
        widow=v.y(yleft+1:end);
        if length(widow)>lenvY; disp(['discard ' num2str(length(widow)-lenvY) ' pts']); widow=widow(1:lenvY); end
        v.y=v.y(1:yleft); lenvy=length(v.y);
    end
    if v.readzero; v.readzero=0; v.yoffset=avgy; end
    if v.chartpaper; % oscilloscope display (put v.y in trace)
        xind=lenvY-yleft+1;
        v.Y(xind:xind+lenvy-1)=v.y;
        % set(hmarker,'position',[xind/v.sr v.ymarker])
        xmark=xind/v.sr;
        ymark=xind+lenvy-1;
    else; % chartpaper display
        v.Y=[v.Y(lenvy+1:end);v.y];
        %  set(hmarker,'position',[tt v.ymarker])
        xmark=tt-lenvy/v.sr;
        ymark=yleft;
    end

    if v.ac; yy=v.Y-avgy; else yy=v.Y-v.yoffset; end
    if ~v.fun; ymark=v.ymarker; else ymark=yy(ymark); end
    set(vh.hVmtxt,'string',[num2str(round((avgy-v.yoffset))) ' mV'])
    if ~v.pause
        set(hmarker,'position',[xmark ymark])
        set(vline,'ydata',yy)
    end
    tt=tt-lenvy/v.sr;
    if v.trainon & ~strcmp(v.ao.running,'On');
        v.trainon=0; set(vh.h1train,'backgroundcolor',[.88 .62 .63]);
        if v.stimon1;
            set(v.ao,'repeatoutput',inf)
            putdata(v.ao,v.aodata);
            start(v.ao)
        end
    end

    yleft=yleft-lenvy;
    if yleft<1; yleft=lenvY; tt=v.disptime(1);
        if v.hold & ~v.pause;

            v.maxholdline=min(40,v.maxholdline);
            if v.nhold>=v.maxholdline
                % hh=findobj('tag','holdline') %sort(hh)
                delete(v.holdline(v.maxholdline))
                v.holdline=v.holdline(1:end-1);
                for j=1:v.maxholdline-1
                    yline=get(v.holdline(j),'ydata'); yline=yline-v.dhold; set(v.holdline(j),'ydata',yline);
                end
                drawnow
            else
                v.holdv=v.holdv+v.dhold;
                v.nhold=v.nhold+1;
            end
            hh=line('xdata',v.T,'ydata',yy+(v.hold<2)*v.holdv,'tag','holdline','color',[0 0 0]);
            v.holdline=[hh; v.holdline];
            a=sort(get(gca,'children')); set(gca,'children',a); % pop vline (which has lowest # handle

            v.Y=v.Y.*0+mean(v.y);
            if v.hold>1 %  | v.nhold>50 ;
                v.hold=0; set(vh.h0erase,'backgroundcolor',[.88 .88 0]); end% turn off if >1 (single stim)
        end % if v.hold & ~v.pause
        %getmarker
    end % v.abortdaq==0
    if v.pause==2; yleft=lenvY; tt=v.disptime(1); v.pause=0; end % pause just turned off
    drawnow
    if sampacq>0.95*v.spt; v.abortdaq=6; end % restart v.ai
end % sample acquisition
stop([v.ai v.ao])
delete(v.ao); clear v.ao
delete(v.ai); clear v.ai
if v.abortdaq>100 % blowing up
    v.abortdaq=6;
end
if v.abortdaq ~= 9.1 % not print
    try;
        delete(findobj('tag','holdline')); %v.holdv=v.ac*(0.95*ylimit(1)+0.05*ylimit(2)-v.dhold);
        v.holdv=v.ac*(ylimit(1)+0.05*(ylimit(2)-ylimit(1)));
        drawnow;
    catch; end
    delete(vline)
end
delete(hmarker)
eval([v.source ' abortdaq'])
%------------------------------------------------------------------
function MEPPs(varargin)
global v vh
axes(vh.hax)
set(vh.hVmtxt,'visible','on')
ylimit=[-3 8];
%set(vh.hax,'buttondownfcn',[v.source ' mousebutton02']) % threshold
set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton02']) % threshold
set(vh.hax,'ylim',[get(vh.h2ybot,'value') get(vh.h2ytop,'value')])
set(vh.hax,'xlim',[0 v.disptime(2)]);
v.y=zeros(v.sr*v.disptime(2),1);
v.time=[1:v.sr*v.disptime(2)]';
v.time=v.time./v.sr;
vline=line('tag','voltage','xdata',v.time,'ydata',v.y,'color','green');
xlimit=get(vh.hax,'xlim');
hthreshline=line('xdata',[0 v.disptime(2)],'ydata',[v.thresh v.thresh],'color','red','tag','meppthreshold');
v.peakmepp=v.disptime(2)*v.sr;
mky=zeros(v.npre+v.npost+1,1); mkx=mky;
axes(vh.hax2)
v.spt=get(v.ai,'samplespertrigger');
while v.abortdaq==0 ;
    stop(v.ai)
    start(v.ai)
    while v.ai.SamplesAcquired<v.spt; end
    try; v.y=peekdata(v.ai,v.peakmepp); catch; disp('error peeking'); end
    % stop(v.ai)
    v.y=v.y.*100+v.offset2;
    avg=mean(v.y);
    v.y=v.y-avg;

    if v.testprogram
        v.y=rand(size(v.y,1),size(v.y,2)); vy2=2*rand(size(v.y,1),size(v.y,2));%%%%%%%%%%%
        ind=(v.y>0.998);
        ind2=ind.*vy2;
        v.y(ind)=ind2(ind); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    try; delete(findobj('tag','meppmarker')); catch; end
    if v.hold
        axes(vh.hax)
        line('xdata',v.time,'ydata',v.y,'tag','holdline','color',[0 0 0])
        axes(vh.hax2)
    else
        set(vline,'ydata',v.y); drawnow
    end
    set(vh.hVmtxt,'string',[num2str(round(avg)) ' mV'])
    drawnow;
    nmepp0=v.nmepp;
    if v.keepit
        vv=v.y;
        while max(vv(:))>=v.thresh;
            mx=max(vv(:));
            xx=find(vv==mx); xx=xx(1);
            x1=max(1,xx-v.npre); x2=min(length(vv),xx+v.npost);
            if v.keepit==2;
                v.nmepp=v.nmepp+1;
                try; v.mepps(v.nmepp,1:(x2-x1+1))=vv(x1:x2); catch; disp([x1 x2]); v.nmepp=v.nmepp-1; end
                v.mxmepp(v.nmepp,1)=mx;
            end
            vv(x1:x2)=vv(x1:x2)-max(vv(x1:x2));
            axes(vh.hax)
            text('tag','meppmarker','position',[v.time(xx),mx],'fontsize',24,...
                'horizontalalignment','center','color','red','string','*');

            drawnow
        end
        if v.nmepp;
            try; str=[num2str(mx) ' (N=' num2str(v.nmepp) '; Avg=' num2str(mean(v.mxmepp(:))) '; SD=' num2str(STD(v.mxmepp(:))) ')'];
                set(vh.h2text,'string',str); catch; end
        end
    end
    if v.nmepp>nmepp0; try; nmepp0=v.nmepp;
            axes(vh.hax2);
            hist(v.mxmepp); drawnow; catch; end; end
end % sample acquisition
stop([v.ai v.ao])
axes(vh.hax)
try; delete(v.ao); clear v.ao; catch; end
if v.abortdaq~=9.1 % not print
    try; delete(findobj('tag','holdline')); catch; end
    delete(hthreshline)
    delete(vline)
end
delete(v.ai); clear v.ai
try; delete(findobj('tag','meppmarker')); catch; end
eval([v.source ' abortdaq'])
% --------------------------------------------------------------------
function EPPs(varargin)
global v vh
v.h3single=0;
axes(vh.hax)
%set(vh.hax,'buttondownfcn',[v.source ' mousebutton03']) % threshold
set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton03']) % threshold
set(vh.hVmtxt,'visible','on')
ylimit=[get(vh.h3ybot,'value') get(vh.h3ytop,'value')];
v.stimperiod2=1/v.stimf2;
set(vh.hax,'ylim',ylimit)
set(vh.hax,'xlim',[0 v.disptime(3)]);
havgeppline=line('xdata',0,'ydata',0,'tag','avgepp','color',[1 .5 .5]);

heppleft=line('tag','eppleft','xdata',[v.eppleft v.eppleft],'ydata',ylimit,'color','red');
heppright=line('tag','eppright','xdata',[v.eppright v.eppright],'ydata',ylimit,'color','red');
v.eppleftpt=round(v.eppleft*v.sr); v.epprightpt=round(v.eppright*v.sr);
if ~isfield(v,'time');
    v.y=zeros(v.sr*v.disptime(3),1); v.time=[1:v.sr*v.disptime(3)]';
    v.time=v.time./v.sr; end
vline=line('tag','voltage','xdata',v.time,'ydata',v.y,'color','blue');
v.sptepp=v.sr*v.disptime(3);
mx=0;
v.nepp0=v.nepp;
tic;
tt=v.stimperiod2; if tt==0.1; tt=0; end
str='on'; if v.trigsource; str='off'; end
set([vh.h3stim vh.h3freqtxt vh.h3stimfrequency],'visible',str)
while v.abortdaq==0
    if ~v.trigsource % internal trigger, manual by 'trigger' command
        if v.stimon2;
            v.stimon2=2; % if =1, just turned on, so don't keep sweep if keepitepp=1;
            putdata(v.ao,v.aodata); aa=[v.ai v.ao];
        else
            aa=[v.ai];
        end
        % toc
        if v.h3single
            start(aa); trigger(aa); getepp;
            v.abortdaq=8.5; v.h3single=0; v.stimon2=0; aa=[v.ai];
        else
            if tt; while toc<tt; end; end % This is where the waiting occurs
            start(aa)
            trigger(aa)
            set(vh.h3freqtxt,'string',['freq=' num2str(1/toc)])
            tic
            getepp
        end
    else % external trigger - calls 'exttrig', which just sets exttrig=1
        start(v.ai)
        tic;
        while ~v.exttrig & ~v.abortdaq; % This does not update Vm while waiting
            if toc>0.2
                if v.ai.SamplesAvailable; vm=getsample(v.ai);
                    vmtxt=num2str(round(vm*100+v.offset2));
                else vmtxt='Waiting...';
                    set(vh.hVmtxt,'string',vmtxt); % num2str(vm))
                    tic
                end
            end
            drawnow; % Required or program hangs here
        end % wait here
        if v.exttrig; v.exttrig=0; getepp; end
    end
    if v.nepp>v.nepp0; try; v.nepp0=v.nepp;
            axes(vh.hax2);
            hist(v.mxepp); drawnow; catch; end; end
end
stop(v.ai); delete(v.ai); clear v.ai
try; stop(v.ao); delete(v.ao); clear v.ao; catch; end
%set(vh.hax,'buttondownfcn','')
set(vh.hfig,'windowbuttondownfcn','')
if v.abortdaq~=9.1 % not print
    try; delete(findobj('tag','holdline')); drawnow; catch; end
    delete(vline); delete(heppleft); delete(heppright)
    delete(findobj('tag','avgepp'))
end
eval([v.source ' abortdaq'])
% -------------------------------------------------------------------
function Analyze % curve fitting
global v vh
if ~v.nepp | ~v.nmepp
    v.mxmepp=[.5 .4 .5 .3 .6 .5 .4 .8 .6 .7,...
        .6 .5 .5 .4 .2 .4 .5 .8 .6 .5,...
        .7 .7 .3 .5 .4 .6 .5 .4 .5 .3]';
    v.mxepp=[0 .9 0 1.4 .4 0 1 .5 1.8 0,...
        1.2 .8 1.5 .6 .4 1 2.6 .5 0 1.1,...
        .9 .7 .3 0 1.8 0 .9 2 .5 0,...
        1.1 .6 .4 1.2 0 .5 .7 .4 0 1.5,...
        .8 1 1.2 .5 .6 .23 0 1 .4 1.8]';
    v.nepp=50; v.nmepp=30; v.pretend=1;
end
set(vh.h4nbineppobstxt,'string',[num2str(v.nbineppobs) ' Bins'])
nbinmeppobs=10; nbinmeppcalc=100;
axes(vh.hax2);
set(vh.hax2,'xlimmode','auto')
[v.nx,v.bincenter]=hist(v.mxmepp,nbinmeppobs);
hist(v.mxmepp,nbinmeppobs); % MEPP histogram
bwmeppobs=v.bincenter(2)-v.bincenter(1);
set(findobj(gca,'type','patch'),'facecolor',[.61 .87 .6])
drawnow
set(vh.hax2,'xlimmode','manual');
xlimmepp=get(vh.hax2,'xlim');
ylimit=get(vh.hax2,'ylim'); ylimit(2)=ylimit(2)*1.05; set(vh.hax2,'ylim',ylimit) % MEPP graph
hmeppfitline=line('xdata',[0 0.00001],'ydata',[0 0.00001],'color','red','tag','meppfit');
drawnow

axes(vh.hax); set(vh.hax,'visible','on','xlimmode','auto')
mm0=v.mxepp;
mm=mm0;
mm(mm<v.lowcut)=0;

[v.nx2,v.bincenter2]=hist(mm,v.nbineppobs);
hist(mm,v.nbineppobs); % EPP histogram
bweppobs=v.bincenter2(2)-v.bincenter2(1);
ylimit=get(vh.hax,'ylim'); ylimit(2)=1.05*ylimit(2); set(vh.hax,'ylim',ylimit); % EPP graph
set(findobj(gca,'type','patch'),'facecolor',[.61 .61 .88])
drawnow
set(vh.hax,'xlimmode','manual')
xlimepp=get(vh.hax,'xlim'); %ylimit=get(vh.hax,'ylim');
xlimepp(1)=0; %%%%%%%%%%%%%%%%%%%%%%%%
set(vh.hax,'xlim',[0 xlimepp(2)]) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

heppfitline=line('xdata',[0 0],'ydata',[0 0],'color','red');
hlowcutline=line('tag','lowcut','xdata',[v.lowcut v.lowcut],'ydata',ylimit,'color','red');
%set(vh.hax,'buttondownfcn',[v.source ' mousebutton04'])
set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton04'])
drawnow
htxtcalc=text('tag','epptxt','position',[0 0],'string','-CALC','fontsize',12,'color','red');
htxtobs=text('tag','epptxt','position',[0 0],'string','-OBS','fontsize',12,'color','blue');
htxtavgepp=text('tag','epptxt','position',[0 0],'string','-Avg','fontsize',12,'color','red','rotation',90);

axes(vh.hax2)
bwmeppcalc=(xlimmepp(2)-xlimmepp(1))/nbinmeppcalc;
bweppcalc=(xlimepp(2)-xlimepp(1))/v.nbineppcalc;

if v.calc3vars
    v.avgmepp=mean(v.mxmepp(:)); v.sdmepp=std(v.mxmepp(:));
    v.avgmepp0=v.avgmepp; v.sdmepp0=v.sdmepp;
    v.avgepp=mean(mm); v.avgepp0=v.avgepp;
    v.minavgmepp=0.001; v.minsdmepp=0.1*v.sdmepp; v.minavgepp=0.001;

    vv=get(vh.h4avgmeppslider,'max');
    set(vh.h4avgmeppslider,'max',max(vv,v.avgmepp),'value',v.avgmepp)
    %set(vh.h4avgmepptxt,'string',['Avg MEPP ' num2str(v.avgmepp)])
    set(vh.h4avgmepp,'string',num2str(v.avgmepp))

    vv=get(vh.h4sdmeppslider,'max'); mn=get(vh.h4sdmeppslider,'min');
    set(vh.h4sdmeppslider,'min',min(mn,v.sdmepp),...
        'max',max(vv,v.sdmepp),'value',v.sdmepp)
    %set(vh.h4sdmepptxt,'string',['SD MEPP ' num2str(v.sdmepp)])
    set(vh.h4sdmepp,'string',num2str(v.sdmepp))

    vv=get(vh.h4avgeppslider,'max');
    set(vh.h4avgeppslider,'max',max(vv,v.avgepp),'value',v.avgepp)
    set(vh.h4avgepp,'string',num2str(v.avgepp))
    drawnow
end
while v.abortdaq==0
    % MEPPS %%%%%%%%%%%%%%%%%%
    xmin=xlimmepp(1); xmax=xlimmepp(2); % v.avgmepp+3*v.sdmepp;
    xx=linspace(xmin,xmax,nbinmeppcalc);
    meppcalc=exp(-((xx-v.avgmepp)/v.sdmepp).*((xx-v.avgmepp)/v.sdmepp)/2)/(sqrt(2*pi)*v.sdmepp);
    meppareaobs=bwmeppobs*v.nmepp;
    meppareacalc=sum(meppcalc)*bwmeppcalc;
    yfac=meppareaobs/meppareacalc;
    meppcalc2=meppcalc.*yfac;
    set(hmeppfitline,'xdata',xx,'ydata',meppcalc2);
    set(vh.hax2,'xlimmode','manual')
    drawnow
    pause(0.01)
    % EPPS%%%%%%%%%%%%%%%%%%%%%
    m=v.avgepp/v.avgmepp;
    set(vh.h4avgepptxt1,'string',['avgEPP=' num2str(v.avgepp)])
    set(vh.h4avgmepptxt1,'string',['avgMEPP=' num2str(v.avgmepp)])
    set(vh.h4mtxt,'string',['m = ' num2str(m)])

    xlimit=get(vh.hax,'xlim'); ylimit=get(vh.hax,'ylim');
    xmin=xlimit(1); xmax=xlimit(2);
    mmax=ceil(xlimepp(2)/v.avgmepp); %ceil(3*m);
    if mmax<5; mmax=5; end;
    vmin=0; % vmax=         % v.avgmepp*mmax; %max(v.mxepp); % 0.1;
    cv=v.sdmepp/v.avgmepp;
    v.varmepp=v.sdmepp^2;
    v.xepp=linspace(xmin,xmax,v.nbineppcalc);
    y=zeros(mmax,v.nbineppcalc);
    for xx=1:mmax
        nx=v.nepp*m^xx.*exp(-m)/factorial(xx); % poisson
        var=xx*v.varmepp;
        mean1=v.avgmepp*xx;
        y(xx,:)=(nx/v.nepp)*exp((-(v.xepp-mean1).*(v.xepp-mean1))/(2*var))/(sqrt(2+pi*var));
    end
    yall=sum(y);
    %set(hlowcutline,'xdata',[v.lowcut v.lowcut],'ydata',ylimit)
    nn=sum((v.bincenter2+bweppobs/2)<v.lowcut)+1;
    failobs=sum(v.mxepp<v.lowcut); %        round(sum(v.nx2(1:nn-1)));
    failcalc=round(v.nepp*exp(-m));
    set(htxtcalc,'position',[0 failcalc]);
    set(htxtobs,'position',[0 failobs])
    set(htxtavgepp,'position',[v.avgepp 0])
    set(vh.h4failobstxt,'string',['Obs: ' num2str(failobs)])
    set(vh.h4failcalctxt,'string',['Calc: ' num2str(failcalc)])
    eppareaobs=bweppobs*sum(mm>0); % sum(v.nx2(nn:end));
    eppareacalc=sum(yall)*bweppcalc;
    yfacepp=eppareaobs/eppareacalc;
    v.yall2=yall.*yfacepp;
    set(vh.hax,'ylimmode','auto')
    try; set(heppfitline,'xdata',v.xepp,'ydata',v.yall2); catch; keyboard; end
    set(vh.hax,'xlimmode','manual'); ylimit=get(vh.hax,'ylim');
    set(hlowcutline,'xdata',[v.lowcut v.lowcut],'ydata',ylimit)
    drawnow
    % chi squared
    if 1>0
        set(vh.h4chi2txt,'visible','on')
        chitable=[3.84 5.99 7.81 9.49 11.07 12.53 14.07 15.51 16.92 18.31,...
            19.68 21.03 22.36 23.68 25 26.3 27.59 28.87 30.14 31.41,...
            32.67 33.92 35.17 36.42 37.65 38.89 40.11 41.34 42.56 43.77];
        chi2=0; df=0;
        if failcalc; df=df+1; chi2=(failobs-failcalc)^2/failcalc; end % failures contribution
        jj=1;
        for j=2:size(v.nx2,2)
            yobs=v.nx2(j);
            findx=v.bincenter2(j);
            while v.xepp(jj)<findx; jj=jj+1; end
            yexp=v.yall2(jj);
            try; if yexp; df=df+1; chi2=chi2+((yobs-yexp)^2/yexp); end
            catch; keyboard; end
        end
        % df=size(v.nx2,2)-1; % -nn+1-1;
        str=['=' num2str(chi2) '. DF=' num2str(df)];
        if df<31;
            if chi2<=chitable(df); %str=[str '. p>0.05 (i.e., they are not significantly different)'];
                str=[str '. Because chi squared is less than ' num2str(chitable(df)),...
                    ', p>0.05. That is, the Poisson fit to the observed EPP ',...
                    'distribution is satisfactory'];
                str2='J'; % smiley face  C=thumbs up
            else  % str=[str '. p<0.05 (i.e., they are significantly different)']; end
                str=[str '. Because chi squared is greater than ' num2str(chitable(df)),...
                    ', p<0.05. That is, the Poisson fit is rejected.'];
                str2='L'; % frowny face   D=thumbs down
            end
        end
        set(vh.h4chi2txt,'string',str)
        axes(vh.hax); vv=get(vh.hax); xx=0.9*vv.XLim(2); yy=0.5*vv.YLim(2);
        htxt=findobj('tag','smileyfrowny');
        if isempty(htxt)
            htxt=text('position',[xx yy],'tag','smileyfrowny',...
                'Fontsize',48,'FontName','Wingdings','string','');
        end
        set(htxt,'position',[xx yy],'string',str2)
        axes(vh.hax2)
    end
    while v.abortdaq==0
        drawnow
        pause(0.2)
    end
    if v.abortdaq<1; v.abortdaq=0; end
end
if v.abortdaq~=9.1 % not print
    axes(vh.hax2)
    delete(findobj('type','patch')) % histograms
    delete(hmeppfitline)
    delete(hlowcutline)
    set(vh.hax2,'visible','off')
    axes(vh.hax)
    delete(findobj('type','patch')) % histograms
    delete(findobj('tag','epptxt'))
    delete(heppfitline)
    try; delete(htxt);catch; end
end
if v.pretend; v.pretend=0; v.nepp=0; v.nmepp=0; v.mxepp=0; v.mxmepp=0; end
eval([v.source ' abortdaq'])
% --------------------------------------------------------------------
function hmode
global v vh
% set(vh.hfig,'keypressfcn','')
set(vh.hfig,'windowbuttondownfcn','')
name=get(gco,'string');
v.mode=find(strcmp(name,v.modestr)); if isempty(v.mode); v.mode=1; end
v.calc3vars=1; % Analyze mode (calculate mean MEPP & EPP and Std Dev of MEPPs)
v.abortdaq=6;
% ----------------------------------------------------
function h0
global v vh
str=get(gco,'tag');
if v.keypress; v.keypress=0; str=v.keypresscase; end
switch str
    case 'h0print'
        v.abortdaq=9.1;
    case 'h0grid'
        if v.mode==2; axes(vh.hax); grid; axes(vh.hax2);
        else grid
        end
    case 'h0quit'
        v.abortdaq=10;
    case 'h0eraseheld'
        try; delete(findobj(vh.hax,'tag','holdline')); drawnow; catch; end
        ylimit=get(vh.hax,'ylim'); %v.holdv=v.ac*(0.95*ylimit(1)+0.05*ylimit(2)-v.dhold);
        v.holdv=v.ac*(ylimit(1)+0.05*(ylimit(2)-ylimit(1)));
        v.maxholdline=floor(0.9*(ylimit(2)-ylimit(1)*v.ac-v.Y(1)*~v.ac)/(v.dhold+.001));
        v.nhold=0; v.holdline=[];
    case 'h0erase'
        v.hold=~v.hold;
        clr=[.88 .88 0]; if v.hold; clr=[1 0 0]; end
        set(vh.h0erase,'backgroundcolor',clr)
    case 'h0disptime'
        v.abortdaq=3;
    case 'h0popup'
        hpop=findobj('tag','h0popup');
        nn=round(get(hpop,'value')); set(hpop,'value',1)
        switch nn
            case 1 % MISC
            case 2 % digitizer rate
                v.abortdaq=2;
            case 3 % line/dot
                v.linestyle=~v.linestyle; vline=findobj('tag','voltage');
                set(vline,'linestyle','-','marker','none')
                if ~v.linestyle; set(vline,'linestyle','none','marker','.','markersize',0.1); end
            case 4 % save/load
                v.abortdaq=9;
            case 5 % chartpaper/oscilloscope
                v.chartpaper=~v.chartpaper;
            case 6 % Edit EPPs
                if ~v.nepp; return; end
                v.editepps=~v.editepps;
                if v.editepps; v.abortdaq=4.1; end
            case 7 % Edit MEPPs
                if ~v.nmepp; return; end
                v.editmepps=~v.editmepps;
                if v.editmepps; v.abortdaq=4; end
            case 8 % MEPP pre/post
                v.abortdaq=3.2;
            case 9 % keyboard
                v.abortdaq=1;
            case 10 % zoom width
                v.abortdaq=8.1;
            case 11 % fun fonts
                v.fun=~v.fun
                getmarker
            case 12 % fraction of screen to scrool
                v.abortdaq=2.02;
        end
end
% ----------------------------------------------------
function h1
global v vh
figure(get(0,'currentfigure')) % somehow focus is lost when some buttons are pushed.
% The result is that keypressfcn doesn't work
str=get(gco,'tag');
if v.keypress; v.keypress=0; str=v.keypresscase; end
vline=findobj('tag','voltage');
switch str
    case 'h1pause'
        v.pause=(v.pause+1)*(v.pause<2); % 0=off; 1=on, turns to 2 to tell Scope to reset
        clr=[.88 .62 .62]; str='on'; if v.pause==1; clr=[1 0 0]; str='off'; end
        set(vh.h1pause,'backgroundcolor',clr); set(vline,'visible',str)
    case 'h1sweepoffset'
        v.dhold=get(vh.h1sweepoffset,'value');
        set(vh.h1sweepoffsettxt,'string',['Hold offset ' num2str(v.dhold)])
    case 'h1ac'
        v.ac=get(vh.h1ac,'value');
        ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
        set(vh.h1ytop,'value',ylimit(2)); set(vh.h1ybot,'value',ylimit(1))
        %  ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
        set(vh.hax,'ylim',ylimit)
        v.ymarker=ylimit(1);
        % v.holdv=v.ac*(0.95*ylimit(1)+0.05*ylimit(2)-v.dhold);
        v.holdv=v.ac*(ylimit(1)+0.05*(ylimit(2)-ylimit(1)));
        v.maxholdline=floor(0.9*(ylimit(2)-ylimit(1)*v.ac-v.Y(1)*~v.ac)/(v.dhold+.001));
        % set(vh.h1ybot,'value',ylimit(1)); set(vh.h1ytop,'value',ylimit(2))
    case 'h1radiofreq'
        if ~get(gco,'value'); return; end % gcbo
        stop(v.ao)
        set(vh.h1radiofreq,'value',0); set(gco,'value',1); % gcbo
        v.stimf1=str2num(get(gco,'string'));   % gcbo
        v.stimperiod1=1/v.stimf1;
        str1=[num2str(v.stimf1) ' Hz'];
        str=['cont ' str1];
        set(vh.h1stim,'string',str); set(vh.h1stimfreq,'value',v.stimf1)
        v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
        if v.stimon1;
            v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
            stop(v.ao); putdata(v.ao,v.aodata); start(v.ao);
        end
    case 'h1radiodisptime'
        if ~get(gco,'value'); return; end % gcbo
        v.hold=0; set(vh.h0erase,'backgroundcolor',[.88 .88 0]) % make sure hold is off
        hh=findobj('tag','holdline'); delete(hh); v.nhold=0; v.holdline=[]; % erase held sweeps
        v.disptime(1)=str2num(get(gco,'string'));   % gcbo
        set(vh.h1radiodisptime,'value',0); set(gco,'value',1) % turn all off/one on gcbo
        v.abortdaq=3.01;
    case 'h1readzero'
        v.readzero=1;
    case 'h1zoom'
        switch v.scopezoom
            case 0
                v.pause=1; v.scopezoom=2;
                set(vh.h1zoom,'backgroundcolor',[1 0 0])
                v.zoompos=getrect;
                set(vh.hax,'xlim',[v.zoompos(1) v.zoompos(1)+v.zoompos(3)],...
                    'ylim',[v.zoompos(2) v.zoompos(2)+v.zoompos(4)])
            case {1,2}
                v.pause=0; v.scopezoom=0;
                set(vh.h1zoom,'backgroundcolor',[.88 .62 .62])
                ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
                set(vh.hax,'xlim',[0 v.disptime(1)],'ylim',ylimit);
        end
    case 'h1stim'
        stop(v.ao)
        v.stimon1=~v.stimon1;
        if v.stimon1; clr=[1 0 0];
            set(v.ao,'repeatoutput',inf)
            putdata(v.ao,v.aodata);
            start(v.ao)
        else clr=[.88 .62 .62];
        end
        set(vh.h1stim,'backgroundcolor',clr)
    case 'h1stimfreq'
        stop(v.ao)
        stimfreq=get(vh.h1stimfreq,'value');
        set(vh.h1radiofreq,'value',0); drawnow % turn off radiobuttons
        if stimfreq==0;
            v.abortdaq=7.05;
        else
            v.stimf1=stimfreq;
            v.stimperiod1=1/v.stimf1;
            set(vh.h1stim,'string',['cont ' num2str(v.stimf1) ' Hz'])
            v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
            if v.stimon1;
                v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
                %stop(v.ao);
                putdata(v.ao,v.aodata); start(v.ao);
            end
        end
    case 'h1single'
        v.hold=v.hold+2*~v.hold; set(vh.h0erase,'backgroundcolor',[1 0 0])
        set(v.ao,'repeatoutput',0)
        putdata(v.ao,[0; 5; 0; 0]);
        start(v.ao)
    case 'h1train'
        v.hold=v.hold+2*~v.hold; set(vh.h0erase,'backgroundcolor',[1 0 0])
        stop(v.ao);
        v.trainon=~v.trainon;
        if v.trainon
            rpt=v.traindur*v.trainf;
            set(v.ao,'repeatoutput',rpt)
            putdata(v.ao,v.aodatatrain);
            start(v.ao)
            set(vh.h1train,'backgroundcolor',[1 0 0])
        else
            set(vh.h1train,'backgroundcolor',[.88 .62 .63])
            if v.stimon1;
                set(v.ao,'repeatoutput',inf)
                putdata(v.ao,v.aodata);
                start(v.ao);
            end
        end
    case 'h1trainvars'
        prompt={'Frequency of stimuli during train? (Hz)' 'Duration of train? (seconds)'};
        title='Train variables'; lineno=1; def={num2str(v.trainf) num2str(v.traindur)};
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        v.trainf=str2num(inp{1}); v.traindur=str2num(inp{2});
        nshocks=max(1,floor(v.trainf*v.traindur)); v.traindur=nshocks/v.trainf;
        set(vh.h1trainvars,'string',['Set ' num2str(v.trainf) 'Hz/' num2str(v.traindur) ' s'])
        set(vh.h1train,'string',['train - ' num2str(nshocks)])
        v.aodatatrain=zeros(round((1/v.trainf)*v.aosr),1); v.aodatatrain(1:round(v.stimdur),1)=v.stimv;
    case {'h1ybot' 'h1ytop'}
        a=get(vh.h1ybot,'value'); b=get(vh.h1ytop,'value');
        if a==b; a=500; b=-500; end
        if a>b; set(vh.h1ybot,'value',b); set(vh.h1ytop,'value',a); end
        ymin=min(a,b); ymax=max(a,b);
        set(vh.hax,'ylim',[ymin ymax])
        if v.ac; v.ylimac=[ymin ymax]; else v.ylimdc=[ymin ymax]; end
        v.ymarker=ymin;
end
getmarker
% ----------------------------------------------------
function h2
global v vh
str=get(gco,'tag');
if v.keypress; v.keypress=0; str=v.keypresscase; end
switch str
    case 'h2radiodisptime'
        if ~get(gco,'value'); return; end%gcbo
        v.disptime(2)=str2num(get(gco,'string'));   %gcbo
        set(vh.h2radiodisptime,'value',0); set(gco,'value',1) % turn all off/one ongcbo
        v.abortdaq=3.01;
    case 'h2reset'
        delete(findobj('type','patch')); set(vh.h2text,'string','')
        v.mepps=zeros(1,v.npre+1+v.npost); v.nmepp=0; v.mxmepp=[];
    case 'h2thresh'
        v.thresh=get(vh.h2thresh,'value'); xlimit=get(vh.hax,'xlim');
        hthreshline=findobj('tag','meppthreshold');
        set(hthreshline,'xdata',xlimit,'ydata',[v.thresh v.thresh])
        drawnow
    case 'h2keepit'
        v.keepit=(v.keepit+1)*(v.keepit<2);
        clr=[.61 .88 .61]; if v.keepit==1; clr=[1 .8 .8]; end; if v.keepit==2; clr=[1 0 0]; end
        set(vh.h2keepit,'string',['Keepit ' num2str(v.keepit)],'backgroundcolor',clr)
    case {'h2ybot' 'h2ytop'}
        a=get(vh.h2ybot,'value'); b=get(vh.h2ytop,'value');
        if a==b; a=500; b=-500; end
        if a>b; set(vh.h2ybot,'value',b); set(vh.h2ytop,'value',a); end
        set(vh.hax,'ylim',[min(a,b) max(a,b)])
end
% ----------------------------------------------------
function h3
global v vh
str=get(gco,'tag');
if v.keypress; v.keypress=0; str=v.keypresscase; end
switch str
    case 'h3single'
        v.h3single=1;
        stop(v.ao)
        v.stimon2=1;
        str1=''; % [num2str(v.stimf2) ' Hz'];
        clr=[.61 .61 .88];
        str=['stim is off - ' str1];
        if v.stimon2;
            str=['stim is ON ' str1];
            clr=[1 0 0]; end
        %  set(vh.h3single,'string',str,'backgroundcolor',clr)
        %v.aodata=zeros(v.aodelay+v.stimdur+2,1);
        %v.aodata(v.aodelay+1:v.aodelay+v.stimdur,1)=v.stimv*v.stimon2;
        v.aodata=[0;5;0;0]; % zeros((v.aosr/1000)*(v.aodelay+v.stimdur+1),1);
        p1=(v.aosr/1000)*v.aodelay+1; p2=p1;
        v.aodata(p1:p2,1)=v.stimv*v.stimon2;

        set(v.ao,'repeatoutput',0)
        putdata(v.ao,[0; 5; 0; 0]);

    case 'h3radiodisptime'
        if ~get(gco,'value'); return; end %gcbo
        v.disptime(3)=str2num(get(gco,'string'));   % gcbo
        set(vh.h3radiodisptime,'value',0); set(gco,'value',1) % turn all off/one on gcbo
        v.abortdaq=3.01;
    case {'h3triginternal' 'h3trigexternal'}
        v.trigsource=~v.trigsource;
        set(vh.h3triginternal,'value',~v.trigsource)
        set(vh.h3trigexternal,'value',v.trigsource)
        drawnow
        v.abortdaq=6;
    case 'h3reset'
        set(vh.h3text,'string','')
        v.epps=zeros(1,v.sptepp); v.nepp=0; v.mxepp=[]; v.nepp0=-1;
        v.sumepp=v.sumepp.*0; set(findobj('tag','avgepp'),'xdata',0,'ydata',0)
    case 'h3window'
        v.abortdaq=7.1;
    case 'h3showavgepp'
        v.showavgepp=~v.showavgepp;
        str='off'; clr=[.61 .61 .88]; if v.showavgepp; str='on'; clr=[1 0 0]; end
        %h=findobj('tag','h3showavgepp');
        set(vh.h3showavgepp,'backgroundcolor',clr)
        %h=findobj('tag','avgepp'); set(h,'visible','str')
    case 'h3keepit'
        v.keepitepp=~v.keepitepp;
        clr=[.61 .61 .88]; if v.keepitepp; clr=[1 0 0]; end
        set(vh.h3keepit,'string',['Keepit ' num2str(v.keepitepp)],'backgroundcolor',clr)
        str='off'; if v.keepitepp & v.showavgepp; str='on'; end
        havgeppline=findobj('tag','avgepp'); % somehow this handle gets lost
        set(havgeppline,'visible',str)
    case 'h3stim' % on/off toggle
        stop(v.ao)
        v.stimon2=~v.stimon2;
        str1=''; % [num2str(v.stimf2) ' Hz'];
        clr=[.61 .61 .88];
        str=['stim is off - ' str1];
        if v.stimon2;
            str=['stim is ON ' str1];
            clr=[1 0 0]; end
        set(vh.h3stim,'string',str,'backgroundcolor',clr)
        %v.aodata=zeros(v.aodelay+v.stimdur+2,1);
        %v.aodata(v.aodelay+1:v.aodelay+v.stimdur,1)=v.stimv*v.stimon2;
        v.aodata=zeros((v.aosr/1000)*(v.aodelay+v.stimdur+1),1);
        p1=(v.aosr/1000)*v.aodelay+1; p2=p1;
        v.aodata(p1:p2,1)=v.stimv*v.stimon2;
    case 'h3freqtxt' % formerly text only, now a pushbutton
        v.abortdaq=7.01;
    case 'h3stimfrequency'
        v.abortdaq=7;
    case {'h3ybot' 'h3ytop'}
        a=get(vh.h3ybot,'value'); b=get(vh.h3ytop,'value');
        if a==b; a=500; b=-500; end
        if a>b; set(vh.h3ybot,'value',b); set(vh.h3ytop,'value',a); end
        set(vh.hax,'ylim',[min(a,b) max(a,b)])
end
% ----------------------------------------------------
function h4
global v vh
str=get(gco,'tag');
if v.keypress; v.keypress=0; str=v.keypresscase; end
switch str
    case 'h4ymax'
        prompt={'Ymax of graph?'}; title='Graph Y axis scale'; lineno=1;
        ylimit=get(vh.hax,'ylim'); def={num2str(ylimit(2))};
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        ylimit(2)=str2num(inp{:}); set(vh.hax,'ylim',ylimit)
        hh=findobj('tag','smileyfrowny'); xx=get(hh,'position');
        xx=xx(1);
        set(hh,'position',[xx ylimit(2)/2])
        axes(vh.hax2)
    case 'h4nbineppobs'
        v.abortdaq=8; v.calc3vars=0;
    case 'h4avgmeppslider'
        v.avgmepp=get(vh.h4avgmeppslider,'value'); mx=get(vh.h4avgmeppslider,'max');
        if v.avgmepp==mx; v.avgmepp=v.avgmepp0; set(vh.h4avgmeppslider,'value',v.avgmepp); end
        set(vh.h4avgmepp,'string',num2str(v.avgmepp))
        v.abortdaq=0.1;
    case 'h4sdmeppslider'
        v.sdmepp=get(vh.h4sdmeppslider,'value'); mx=get(vh.h4sdmeppslider,'max');
        if v.sdmepp==mx; v.sdmepp=v.sdmepp0; set(vh.h4sdmeppslider,'value',v.sdmepp); end
        set(vh.h4sdmepp,'string',num2str(v.sdmepp))
        v.abortdaq=0.1;
    case 'h4avgeppslider'
        v.avgepp=get(vh.h4avgeppslider,'value'); mx=get(vh.h4avgeppslider,'max');
        if v.avgepp==mx; v.avgepp=v.avgepp0; set(vh.h4avgeppslider,'value',v.avgepp); end
        set(vh.h4avgepp,'string',num2str(v.avgepp))
        v.abortdaq=0.1;
end
% ------------------------------------------
function abortdaq(varargin)
global v vh
disp(v.abortdaq) %%%%%%%%%%%%%%%%%%%%%%%%%%
switch v.abortdaq
    case 1 % keyboard
        keyboard

    case 2 % digitizing rate and input range
        %v.inputrange=v.ai.Channel.InputRange;
        ir=v.inputrange(2);
        %v.sr=v.ai.SampleRate;
        prompt={'Digitizing rate? (samples/second)' 'Input range? (+/-volts: 0.05 0.1 0.25 0.5 1.0 2.5 5.0 (10)'};
        def={num2str(v.sr) num2str(ir)}; lineno=1; title='Digitizing rate/Input range';
        inp=inputdlg(prompt, title, lineno, def);
        if isempty(inp); inp={num2str(v.sr) num2str(v.inputrange)};
        else sr=str2num(inp{1}); ok=1;
            if v.nmepp & v.sr ~= sr
                inp=questdlg('OK to erase saved MEPPs?');
                if ~strcmp(inp, 'Yes'); ok=0; end
            end
            if ok v.sr=sr; v.sr0=v.sr; end
            ir=str2num(inp{2}); v.inputrange=[-ir ir];
        end
        v.npre=round(v.sr*v.pre/1000); v.npost=round(v.sr*v.post/1000); % # pts
        v.sptepp=v.sr*v.disptime(3); % # samples per epp
    case 2.02 % fraction of screen to scroll
        prompt={'With zoom turned on: Fraction of screen to scrool left & right?'};
        def={num2str(v.dscroll)}; lineno=1; title='Fraction of screen to scroll left & right';
        inp=inputdlg(prompt,title,lineno,def);
        v.dscroll=str2num(inp{1});
    case 3 % disptime
        disptimenow=v.disptime(v.mode);
        ok=1;
        if v.mode==3 & v.nepp; % erased saved EPP
            inp=questdlg('OK to erase saved EPPs?');
            if ~strcmp(inp, 'Yes'); ok=0;
            else
                set(vh.h3text,'string','')
                v.nepp=0; v.mxepp=[]; v.nepp0=-1;
            end
        end
        if ok
            prompt={'Display window width? (sec)'};
            def={num2str(disptimenow)}; lineno=1; title='Display width';
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); inp=disptimenow; else; v.disptime(v.mode)=str2num(inp{1}); end
            if v.mode==3;
                v.sptepp=v.sr*v.disptime(3); v.sumepp=zeros(v.sptepp,1)
                v.epps=zeros(1,v.sptepp); v.nepp=0; v.mxepp=[]; end
        end
    case 3.01 % disptime radio button
        % dummmy to reset disptime
    case 3.1 % line style solid/dotted
        v.linestyle=~v.linestyle;
    case 3.2 % MEPP pre/post to keep
        ok=1;
        if v.nmepp
            inp=questdlg('OK to erase saved MEPPs?');
            if ~strcmp(inp, 'Yes'); ok=0; end
        end
        if ok
            set(vh.h2text,'string','')
            prompt={'Milliseconds pre-peak?' 'Milliseconds post-peak?'};
            def={num2str(v.pre) num2str(v.post)}; lineno=1; title='Number of msec to keep before and after MEPP peak';
            inp=inputdlg(prompt,title,lineno,def);
            if ~isempty(inp); v.pre=str2num(inp{1}); v.post=str2num(inp{2}); end
            v.npre=round(v.sr*v.pre/1000); v.npost=round(v.sr*v.post/1000); % # pts
            v.mepps=zeros(1,v.npre+1+v.npost);
            v.nmepp=0;
            v.mxmepp=[];
            v.thresh=get(vh.h2thresh,'value');
            v.keepit=0;
            v.editmepps=0;
            %set(vh.h2nprepost,'string',['Pre/Post ' num2str(v.pre) '/' num2str(v.post)])
        end
    case 4 % Edit MEPPs
        %set(vh.hax,'buttondownfcn',[v.source ' mousebutton01'])
        set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton01'])
        mepplen=size(v.mepps,2); dt=mepplen/v.sr;
        v.T=[1:v.sr*dt]'/v.sr; % v.T=v.T./v.sr;
        ymin=min(v.mepps(:)); ymax=max(v.mxmepp(:))
        set(vh.hax,'xlim',[0 dt],'ylim',[ymin ymax]);
        set(vline,'xdata',v.T,'ydata',v.mepps(1,:),'color','green');
        htxt=text('string','Left click to keep; right to delete. Click EditMepps again to quit',...
            'position',[0.1*dt ymax-0.1*(ymax-ymin)],'fontsize',15)
        nn=1; str=''; ndel=0;
        while v.editmepps
            set(vline,'ydata',v.mepps(nn,:))
            set(htxt,'string',[num2str(nn) '/' num2str(v.nmepp) ' (' num2str(ndel) ' deleted)'])
            v.waitforbutton=1; % 1=waiting; 0=keep; -1=delete
            while v.waitforbutton==1 & v.editmepps; pause(0.1); drawnow; end
            if v.waitforbutton<0;
                v.mepps=[v.mepps(1:nn-1,:) ; v.mepps(nn+1:end,:)];
                v.mxmepp=[v.mxmepp(1:nn-1,:) ; v.mxmepp(nn+1:end,:)];
                v.nmepp=v.nmepp-1; ndel=ndel+1;
            else; nn=nn+1; if nn>v.nmepp; nn=1; end;
            end
            if nn>=v.nmepp; v.editmepps=0; end
        end
        delete(htxt)
        %set(vh.hax,'buttondownfcn','')
        set(vh.hfig,'windowbuttondownfcn','')
    case 4.1 % Edit EPPs
        %set(vh.hax,'buttondownfcn',[v.source ' mousebutton01'])
        set(vh.hfig,'windowbuttondownfcn',[v.source ' mousebutton01'])
        epplen=size(v.epps,2); dt=epplen/v.sr;
        v.T=[1:v.sr*dt]'/v.sr;
        ymin=min(v.epps(:)); ymax=max(v.mxepp(:));
        set(vh.hax,'xlim',[0 dt],'ylim',[ymin ymax]);
        set(vline,'xdata',v.T,'ydata',v.epps(1,:),'color','blue');
        htxt=text('string','Left click to keep; right to delete. Click EditEpps again to quit',...
            'position',[0.1*dt ymax-0.1*(ymax-ymin)],'fontsize',15);
        nn=1; str=''; ndel=0;
        while v.editepps
            set(vline,'ydata',v.epps(nn,:))
            set(htxt,'string',[num2str(nn) '/' num2str(v.nepp) ' (' num2str(ndel) ' deleted)'])
            v.waitforbutton=1; % 1=waiting; 0=keep; -1=delete
            while v.waitforbutton==1 & v.editepps; pause(0.1); drawnow; end
            if v.waitforbutton<0;
                v.epps=[v.epps(1:nn-1,:) ; v.epps(nn+1:end,:)];
                v.mxepp=[v.mxepp(1:nn-1,:) ; v.mxepp(nn+1:end,:)];
                v.nepp=v.nepp-1; ndel=ndel+1;
            else; nn=nn+1; if nn>v.nepp; nn=1; end;
            end
            if nn>=v.nepp; v.editepps=0; end
        end
        delete(htxt)
        %set(vh.hax,'buttondownfcn','')
        set(vh.hfig,'windowbuttondownfcn','')
        %case 5 % Y axis limits manual select
        % set(vh.hax,'ylim',[-500 500]);
        % a=getrect(vh.hfig); set(vh.hax,'ylim',[a(2) a(2)+a(4)]);
    case 6 % mode ('scope, mepps, epps, analyze)
        tag0=['h' num2str(v.mode)]; % h1, h2, h3, or h4
        hradiomode=findobj('tag','hmode'); set(hradiomode,'value',0); % all radiobuttons
        h=findobj('string',v.modestr{v.mode}); set(h,'value',1) % current radiobutton
        % Display proper key set
        c=fieldnames(vh); % c is a cell array
        s=[strmatch(tag0,c); strmatch('h0',c)]; % s (double array) contains index numbers into c
        hh=[];
        for j=1:size(s,1);
            htmp=getfield(vh,c{s(j)});
            for k=1:size(htmp,2);
                if strcmp('uicontrol',get(htmp(k),'type')) hh=[hh; htmp(k)]; end;
            end
        end
        if isempty(hh); return; end
        hhh=findobj('type','uicontrol'); set(hhh,'visible','off'); % turn off all uicontrols
        set(findobj('tag','hmode'),'visible','on'); set(hh,'visible','on') % turn on radiobuttons and selected mode
        if v.mode==4; set([vh.h0erase vh.h0disptime vh.h0eraseheld],'visible','off'); end
    case 7 % EPP stim frequency slider
        stimfreq=get(vh.h3stimfrequency,'value');
        if stimfreq==0;
            prompt={'Stimulus frequency? (must be greater than 0)'};
            title='Stimulus Frequency?'; lineno=1; def={num2str(v.stimf2)};
            inp=inputdlg(prompt, title, lineno, def);
            if isempty(inp) | strcmp('0', inp); set(vh.h3stimfrequency,'value',v.stimf2); return; end
            stimfreq=str2num(inp{:}); set(vh.h3stimfrequency,'value',stimfreq)
        end
        v.stimf2=stimfreq;
        v.stimperiod2=1/v.stimf2;
        str1='';% [num2str(v.stimf2) ' Hz'];
        str=['stim off - ' str1];
        if v.stimon2; str=['stim ' str1]; end
        set(vh.h3stim,'string',str)
    case 7.01 % Manual EPP stim frequency
        prompt={'Stimulus frequency? (must be greater than 0)'};
        title='Stimulus Frequency?'; lineno=1; def={num2str(v.stimf2)};
        inp=inputdlg(prompt, title, lineno, def);
        if isempty(inp) | strcmp('0', inp); set(vh.h3stimfrequency,'value',v.stimf2); return; end
        stimfreq=str2num(inp{:}); set(vh.h3stimfrequency,'value',stimfreq)
        v.stimf2=stimfreq;
        v.stimperiod2=1/v.stimf2;
        str1='';% [num2str(v.stimf2) ' Hz'];
        str=['stim off  ' str1];
        if v.stimon2; str=['stim ' str1]; end
        set(vh.h3stim,'string',str)

    case 7.05 % Scope stim frequency manual
        prompt={'Stimulus frequency? (must be greater than 0)'};
        title='Stimulus Frequency?'; lineno=1; def={'1'};
        inp=inputdlg(prompt, title, lineno, def);
        if isempty(inp); set(h,'value',v.stimf1); return; end
        stimfreq=str2num(inp{:});

        v.stimf1=stimfreq; set(vh.h1stimfreq,'value',stimfreq)
        v.stimperiod1=1/v.stimf1;
        set(vh.h1stim,'string',['cont ' num2str(v.stimf1) ' Hz'])
        v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
        if v.stimon1;
            v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
            % makeaoai is called below
        end
    case 7.1 % EPP window
        axes(vh.hax)
        vv=getrect(vh.hfig); if ~vv(3); vv=v.eppwindow; end;
        v.eppwindow=vv;
    case 8 % number of EPP bins (observed)
        v.nbineppobs=round(get(vh.h4nbineppobs,'value'));
    case 8.1 % zoom width
        prompt={'Width of zoom window? (ms)'};
        title='Width of zoom window'; lineno=1; def={num2str(2000*v.zoomwidth)};
        inp=inputdlg(prompt, title, lineno, def);
        if isempty(inp); return; end
        v.zoomwidth=str2num(inp{1})/2000;
    case 8.5 % Lowcut
        % dummy to get analyze to start over
    case 9 % Save/Load
        inp=questdlg('Load or Save?','LOAD OR SAVE','Load','Save','Cancel');
        switch inp
            case 'Cancel'
            case 'Load'
                [fname,pname]=uigetfile('*.mat','Load Preferences');
                if ischar(fname);
                    load ([pname fname]); end
            case 'Save'
                [fname,pname]=uiputfile('*.mat','Save Preferences');
                if ischar(fname); 
                    vdat=v.epps; 
                    save([pname 'epp.' fname],'vdat')
                    vdat=v.mepps;
                    save([pname 'mepp.' fname],'vdat')                    
                end
                % if ischar(fname); save([pname fname],'v');end
        end
        v.abortdaq=6;
        eval([v.source ' abortdaq'])
    case 9.1 % Print
        inp=questdlg('Continue?',...
            'Print','Print','Cancel','Cancel');
        switch inp
            case 'Print'
                set(gcf,'paperpositionmode','auto')
                pos=get(gcf,'paperposition');
                p1=max(0.5, pos(1)); p2=max(0.5,pos(2)); p3=min(9.5,pos(3)); p4=min(7,pos(4));
                prompt={'Left margin (inches)' 'Bottom margin (inches)' 'Width (inches)',...
                    'Height (inches)' 'Print buttons, sliders, etc? (y/n)'}';
                title='Print options'; lineno=1; def={num2str(p1) num2str(p2) num2str(p3) num2str(p4) 'n'};
                inp=inputdlg(prompt,title,lineno,def);
                pos=[str2num(inp{1}) str2num(inp{2}) str2num(inp{3}) str2num(inp{4})];
                set(gcf,'paperposition',pos)
                printuicontrols=strcmp(inp{5}, 'y');
                printdlg('-setup',gcf) % print parameters selection
                delete(findobj('tag','voltage'))
                if printuicontrols; print; else print -noui; end
                questdlg('Wait until printing starts, then click CONTINUE','Wait for download...','CONTINUE','CONTINUE')
            case 'Keyboard'
                keyboard
            case 'Cancel'
        end
        %  delete(findobj('type','line'))
    case 9.9 % EPP timing error
        resetf=1;
        msgbox(['Stimulation rate too high! Reset to ' num2str(resetf) ' Hz'])
        v.stimf2=resetf;
        set(vh.h3stimfrequency,'value',resetf)
        set(vh.h3stim,'string',[num2str(resetf) ' Hz'])
    case 10 % quit
        try; close(vh.hfig); return; catch; end;
    otherwise
end  % interrupt service
if v.abortdaq<10
    v.abortdaq=0; end
makeaoai
eval([v.source ' ' v.modestr{v.mode}])
% -----------------------------------------------------
function makeaoai
global v vh
if v.mode==4; return; end
daqreset
v.ao=analogoutput('nidaq',1); addchannel(v.ao,0)
v.ai=analoginput('nidaq',1); addchannel(v.ai,0)
v.ai.transfermode='interrupts';
v.ai.Channel.InputRange=v.inputrange;
v.inputrange=v.ai.Channel.InputRange;
set(v.ai,'inputtype','differential')
spt=v.disptime(v.mode)*v.sr;
if spt>500000; v.sr=1000; else; v.sr=v.sr0; end
switch v.mode
    case 1 % oscilloscope
        v.aosr=1000; % Sample rate must be <=1000 and >~16
        set(v.ao,'samplerate',v.aosr)
        v.aosr = get(v.ao,'SampleRate'); % ActualRate
        v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(2:1+round(v.stimdur),1)=v.stimv;
        v.aodatatrain=zeros(round((1/v.trainf)*v.aosr),1); v.aodatatrain(1:round(v.stimdur),1)=v.stimv;
        set(v.ao,'TriggerType','Immediate','SampleRate',v.aosr,'RepeatOutput',inf)

        set(v.ai,'TriggerType','Immediate')
        v.spt=1200*v.sr; % 20 minutes
        set(v.ai,'SampleRate',v.sr,'SamplesPerTrigger',v.spt)
    case 2 % mepps
        v.aosr=1000; % Sample rate must be <=1000 and >~16
        set(v.ao,'samplerate',v.aosr)
        v.aosr = get(v.ao,'SampleRate'); % ActualRate
        v.stimf1=2; v.stimon1=1; v.stimperiod1=1/v.stimf1;
        v.aodata=zeros(round(v.stimperiod1*v.aosr),1); v.aodata(1:round(v.stimdur),1)=v.stimv;
        set(v.ao,'TriggerType','Immediate','SampleRate',v.aosr,'RepeatOutput',0) %
        set(v.ai,'TriggerType','Immediate')
        v.spt=2*v.disptime(2)*v.sr;
        set(v.ai,'SampleRate',v.sr,'SamplesPerTrigger',v.spt);
    case 3 % epps
        v.aodelay=5; % msec pulse delay
        v.aosr=1000; if strcmp(v.hw,'PCI-6035E') | strcmp(v.hw,'PCI-MI0-16E-4');
            v.aosr=1000; end % 'PCI-6035E' or 'DAQCard-1200'
        set(v.ao,'samplerate',v.aosr); % Sample rate must be <=1000 and >~16
        v.aosr=get(v.ao,'SampleRate'); % ActualRate
        v.aodata=zeros((v.aosr/1000)*(v.aodelay+v.stimdur+1),1);
        p1=(v.aosr/1000)*v.aodelay+1; p2=p1;
        v.aodata(p1:p2,1)=v.stimv*(v.stimon2>0);

        v.sptepp=v.sr*v.disptime(3);
        set(v.ai,'SampleRate',v.sr,'SamplesPerTrigger',v.sptepp)
        v.sr=get(v.ai,'SampleRate');
        if v.trigsource % external trigger
            set(v.ao,'TriggerType','Manual','SampleRate',v.aosr,'RepeatOutput',0) %
            set(v.ai,'TriggerType','HwDigital','TriggerFcn',[v.source ' exttrig']);
        else % internal trigger
            set(v.ao,'TriggerType','Manual','SampleRate',v.aosr,'RepeatOutput',0) %
            set(v.ai,'TriggerType','Manual','TriggerFcn','');
        end
        get(v.ai,'SampleRate');
end
% --------------------------------------------------------------------
function mousebutton00 % zoom Scope
global v vh
[x y] = bbgetcurpt(gca);
button=get(vh.hfig,'selectiontype');
dx=v.zoomwidth; % ms
if (strcmp(button,'normal')) % zoom on
    switch v.scopezoom
        case 0% turn zoom on
            v.pause=1; v.scopezoom=2;
            set(vh.h1zoom,'backgroundcolor',[1 0 0])
            % v.zoompos=getrect; % x0 y0 wd ht
            %set(vh.hax,'xlim',[v.zoompos(1) v.zoompos(1)+v.zoompos(3)],...
            %'ylim',[v.zoompos(2) v.zoompos(2)+v.zoompos(4)])
            set(vh.hax,'xlim',[x-dx x+dx])
        case 2 % turn zoom off
            v.pause=0; v.scopezoom=0;
            set(vh.h1zoom,'backgroundcolor',[.88 .62 .62])
            ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
            set(vh.hax,'xlim',[0 v.disptime(1)],'ylim',ylimit);
        case 1 % zoom in
            v.zoompos(1)=x-v.zoompos(3)/2; v.zoompos(2)=y-v.zoompos(4)/2;
            v.zoompos(1)=x-dx; v.zoompos(2)=x+dx;
            % set(vh.hax,'xlim',[v.zoompos(1) v.zoompos(1)+v.zoompos(3)]);% ,...
            %'ylim',[v.zoompos(2) v.zoompos(2)+v.zoompos(4)])
            set(vh.hax,'xlim',[v.zoompos(1) v.zoompos(2)])
            v.scopezoom=2;
        case 2.1 % zoom out
            ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
            set(vh.hax,'xlim',[0 v.disptime(1)],'ylim',ylimit);
            v.scopezoom=1;
    end
elseif (strcmp(button,'alt')) % turn off scopezoom
    v.pause=0; v.scopezoom=0;
    set(vh.h1zoom,'backgroundcolor',[.88 .62 .62])
    ylimit=v.ylimdc; if v.ac; ylimit=v.ylimac; end
    set(vh.hax,'xlim',[0 v.disptime(1)],'ylim',ylimit);
end
%----------------------------------------------------------------
function mousebutton01 % edit MEPPs
global v vh
button=get(vh.hfig,'selectiontype');
if (strcmp(button,'normal')) % keep it
    v.waitforbutton=0;
elseif (strcmp(button,'alt')) % delete it
    v.waitforbutton=-1;
end
% --------------------------------------------------------------------
function mousebutton02 % MEPP threshold location
global v vh
[x v.thresh]=bbgetcurpt(vh.hax);
xlimit=get(vh.hax,'xlim');
hthreshline=findobj('tag','meppthreshold'); set(hthreshline,'xdata',xlimit,'ydata',[v.thresh v.thresh])
try; set(vh.h2thresh,'value',v.thresh); catch; end
drawnow
axes(vh.hax2)
% --------------------------------------------------------------------
function mousebutton03(varargin) % EPP left, right window borders
global v vh
[x y] = bbgetcurpt(gca);
button=get(vh.hfig,'selectiontype');
if (strcmp(button,'normal')) % left side
    hh=findobj('tag','eppleft'); if x>=v.eppright; return; end
    v.eppleft=x; v.eppleftpt=round(v.eppleft*v.sr);
elseif (strcmp(button,'alt')) % right side
    hh=findobj('tag','eppright'); if x<=v.eppleft; return; end
    v.eppright=x; v.epprightpt=round(v.eppright*v.sr);
end
try; set(hh,'xdata',[x x]); catch; end
% -------------------------------------------------------------
function mousebutton04 % Analyze: lowcutoff for epps (smaller become failures)
global v vh
[x y]=bbgetcurpt(vh.hax);
if x<2
    set(findobj('tag','lowcut'),'xdata',[x x])
    v.lowcut=x; v.abortdaq=8.5;
end
v.calc3vars=0;
%---------------------------------------------------------------------
function [x,y] = bbgetcurpt(axHandle)
pt = get(axHandle, 'CurrentPoint');
x = pt(1,1); y = pt(1,2);
axUnits = get(axHandle, 'Units'); set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position'); set(axHandle, 'Units', axUnits);
axPixelWidth = axPos(3); axPixelHeight = axPos(4);
axXLim = get(axHandle, 'XLim'); axYLim = get(axHandle, 'YLim');
xExtentPerPixel = abs(diff(axXLim)) / axPixelWidth;
yExtentPerPixel = abs(diff(axYLim)) / axPixelHeight;
x = x + xExtentPerPixel/2; y = y + yExtentPerPixel/2;
%---------------------------------------------------------------------
function exttrig % comes here after external input trigger
global v vh
v.exttrig=1;
%---------------------------------------------------------------------
function manualtrig % used for debugging only
% connect pin 10 to pin 38 on pinout connector for daqCard-1200
global v vh
aodata=[0; 5; 0];
putdata(v.ao,aodata)
start(v.ao)
trigger(v.ao)
%------------------------------------------------------------------
function getepp % reads EPP
global v vh;
mx=0;
%a=toc;
while v.ai.SamplesAcquired<v.sptepp; end
[v.y,v.time]=getdata(v.ai,v.sptepp); stop(v.ao)
v.y=v.y.*100+v.offset2;
baseline=mean(v.y(1:round(v.sr/500)));
v.y=v.y-baseline;

if v.testprogram
    v.y=rand(size(v.y,1),size(v.y,2)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v.y(v.y>0.99)=2*(3*rand);
end

if v.hold & (v.stimon2 | v.trigsource)
    axes(vh.hax)
    line('xdata',v.time,'ydata',v.y,'tag','holdline','color',[0 0 0])
    axes(vh.hax2);
else
    set(findobj('tag','voltage'),'xdata',v.time,'ydata',v.y);
end
set(vh.hVmtxt,'string',[num2str(round(baseline)) ' mV'])
drawnow % This is what slows things down, due to ERASING
if v.keepitepp & (v.stimon2>1 | v.trigsource) % keep only if internal stim is on, or ext trig.

    v.nepp=v.nepp+1;
    v.epps(v.nepp,:)=v.y;
    if ~v.h3single
        mx=max(v.y(v.eppleftpt:v.epprightpt,1));
        v.mxepp(v.nepp,1)=mx;
    end
    try; v.sumepp=v.sumepp+v.y; catch; msgbox('error'); keyboard; end
    %if v.h3single; v.h3single=0; v.stimon2=0; v.abortdaq=8.5; end
end
if v.nepp>1; havgeppline=findobj('tag','avgepp');
    if v.showavgepp;
        set(havgeppline,'xdata',v.time,'ydata',v.sumepp/v.nepp,'visible','on'); drawnow
    else set(havgeppline,'visible','off')
    end
end
if v.nepp
    str=[num2str(mx) ' (N=' num2str(v.nepp) '; Avg=' num2str(mean(v.mxepp(:))) '; SD=' num2str(STD(v.mxepp(:))) ')'];
    set(vh.h3text,'string',str); end
drawnow


% ------------------------------------------------------------
function getmarker
global v vh
if v.fun
    v.funfontnow=v.funfont{ceil(rand*size(v.funfont,2))};
    v.funcharnow=v.funchar(ceil(rand*52)); v.funcharsize=32;
else
    v.funfontnow='wingdings'; % 'wingdings 3'; % 'arial';
    v.funcharnow='w'; % H=index finger pointing down; t=diamond; w=small diamond
    v.funcharsize=12;
end
hmarker=findobj('tag','hmarker');
if ~isempty(hmarker);
    set(hmarker,'FontName',v.funfontnow,'string',v.funcharnow,'FontSize',v.funcharsize); end
% ------------------------------------------------------------
function keypress(varargin)
global v vh
k=get(vh.hfig,'currentcharacter');
if isempty(k); k=' '; end % shift, ctrl,alt
dest='h0'; ok=1; currentobj=0; v.keypress=1;
if v.mode==1 & findstr(k,'acdstzACDSTZ')
    switch k
        case {'a' 'A'}
            v.ac=~get(vh.h1ac,'value'); set(vh.h1ac,'value',v.ac); v.keypresscase='h1ac'; dest='h1';
        case {'c' 'C'}
            v.mode==1; v.keypresscase='h1stim'; dest='h1';
        case {'d' 'D'} % radiodisptime
            v.nradiodisp=v.nradiodisp+1-3*(v.nradiodisp==3); % don't go to 600
            set(v.hh,'value',0); set(v.hh(v.nradiodisp),'value',1)
            currentobj=v.hh(v.nradiodisp);
            v.keypresscase='h1radiodisptime'; dest='h1';
        case {'s' 'S'}
            v.keypresscase='h1single'; dest='h1';
        case {'t' 'T'}
            v.keypresscase='h1train'; dest='h1';
        case {'z' 'Z'}
            v.keypresscase='h1zoom'; dest='h1';
    end
else
    switch k
        case {'e' 'E'}
            v.keypresscase='h0eraseheld';
        case {'g' 'G'}
            v.keypresscase='h0grid';
        case {'h' 'H'}
            v.keypresscase='h0erase';
        case {'p' 'P'}
            v.keypresscase='h0print';
        case {'q' 'Q'}
            v.keypresscase='h0quit';
        case ' ' % spacebar

        otherwise
            ok=0;
            nn=double(k);
            switch nn
                case 8 % backspace
                case 13 % ENTER
                case 27 % ESC
                case 28 % left arrow
                    if ~v.scopezoom; return; end
                    xlimit=get(vh.hax,'xlim'); xlimit=xlimit-v.dscroll*(xlimit(2)-xlimit(1));
                    set(vh.hax,'xlim',[xlimit]); drawnow
                case 29 % right arrow
                    if ~v.scopezoom; return; end
                    xlimit=get(vh.hax,'xlim'); xlimit=xlimit+v.dscroll*(xlimit(2)-xlimit(1));
                    set(vh.hax,'xlim',[xlimit]); drawnow
                case 30 % up arrow
                    if ~v.scopezoom; return; end
                    ylimit=get(vh.hax,'ylim'); ylimit=ylimit+v.dscroll*(ylimit(2)-ylimit(1));
                    set(vh.hax,'ylim',[ylimit]); drawnow
                case 31 % down arrow
                    if ~v.scopezoom; return; end
                    ylimit=get(vh.hax,'ylim'); ylimit=ylimit-v.dscroll*(ylimit(2)-ylimit(1));
                    set(vh.hax,'ylim',[ylimit]); drawnow
                otherwise
                    ok=0;
                    % msgbox(['You pressed ' k '=' num2str(nn)])
            end
    end
end
if ok
    if currentobj; set(vh.hfig,'currentobject',currentobj); end % sets gco
    eval([v.source ' ' dest])
end
