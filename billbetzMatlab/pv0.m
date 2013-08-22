function pv (varargin)
v0=getappdata(0,'v0');
if isempty(v0); setupv0; v0=getappdata(0,'v0'); end
setappdata(0,'abort',0)
switch nargin
  case 0
    more off
    a=findobj('type','figure');
    if isempty(a);
      v0.fignum=0; setappdata(0,'v0',v0);
    end
    %%%%%%%%% Matlab code - Make figure
    h=openfig(mfilename,'new'); vh=guihandles(h);
    a=findobj(h,'type','image'); if ~isempty(a); delete(a); end
    a=findobj(h,'type','line'); if ~isempty(a); delete(a); end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SETUP CODE HERE. Use structures 'v' for variables, 'vh' for objects
    set(gcf,'currentaxes',vh.ax)
    v.play=0; v.framestep=1; v.histo=0; v.thresh=0; v.rgbgain=[1 1 1]; v.scroll=0; 
    v.swing=0; v.figname=''; v.fmt=''; v.square=0; v.maskit=0; v.srf=0; v.xbw=0;
    vplay.swingdir=1; v.normalize=0; v.zsem=[]; v.bw=[]; v.mask=[]; v.newzoom=0; v.dxarrow=0;
    v.srf=0; v.close=0; v.label=0; v.minmaxmode=0; v.histofit=0; v.collafframe=0;
    v.singlepixel=0; v.pausefirst=0; v.pauselast=0; v.msz=3; v.rotate=0.5;
    v.circles=0; v.minarea=90; % for auto ROI
    v.frame=1; v.collapseframe=0;
    vplay.frame=v.frame; v.framestep=1;
    setappdata(vh.fig,'vplay',vplay);
    setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v);
    %setappdata(0,'v0',v0)
    setup
    v0=getappdata(0,'v0');    
    if size(v0.rlist,1) || size(v0.glist,1) || size(v0.blist,1);
      inp=questdlg('Keep R-G-B image lists?');
      if ~strcmp(inp,'Yes');
        v0.fbr=''; v0.fbg=''; v0.fbb='';
      end
    end
    setappdata(0,'v0',v0)
    bbmakelist
    loadmovie
    v=getappdata(vh.fig,'v'); if strcmp(v.imtype,'unknown'); return; end
    configfig
    playmovie
  case 2 % call a subfunction (e.g., bbgetrect)
    eval([varargin{1} ' ' varargin{2}])
  case 3 % callback: crop, align, convert, and 3d(turnoff) come here
    h2=findobj('type','figure','visible','off'); delete(h2)   
    %%%%%%%%% Matlab code - Make figure
    h=openfig(mfilename,'new'); % this makes new fig current fig
    a=findobj(h,'type','image'); if ~isempty(a); delete(a); end
    a=findobj(h,'type','line'); if ~isempty(a); delete(a); end
    vh=guihandles(h);
    set(vh.fig,'currentaxes',vh.ax)
    set(0,'currentfigure',vh.fig)
    v=getappdata(v0.callingfig,'v');
    try
      v.rgbyes=v0.rgbyes2;
    catch
    end %
    v0.rgbyes2=0;
    v.Movi=v.Movi2;
    try; v.mapname=v.mapname2; v.mapname2=''; catch; end
    v.figname=varargin{2};
    switch class(v.Movi)
      case 'uint8'
        v.bitdepth=8;
      case 'uint16'
        v.bitdepth=16;
      otherwise
        disp('Not 8 or 16 bits.')
        v.bitdepth=16;
    end
    if strcmp(v.figname,'graph')
      % Moviegraph
      % moviestep=1; len=size(Movi,4); firstframe=1; lastframe=len;
      % swing=0; pse=[1:len]*0; list=getappdata(hfig,'list2');
      rgbyes=1; v0.rgbyes=1; % setappdata(0,'rgbyes',1); % rgbyes=1;
    else
      if isempty(v.list2); v.list2=v.list; end
      if length(v.list2)~=length(v.list);
        v.pse=1:length(v.list2);
        v.pse=v.pse.*0;
      end
      a=size(v.Movi); a=a(end);
      if size(size(v.Movi))<3; a=1; end
      if size(size(v.Movi),2)==3 && v.rgbyes; a=1; end
      if length(v.list2)~=a; v.list2=v.list(1:a); end
      if ~isempty(v.list2); v.list=v.list2; end
    end
    v.list2=[];
    setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
    configfig
    eval([mfilename ' figsize'])
    set(vh.fig,'visible','on')
    playmovie

  case 1
    try
      v0=getappdata(0,'v0');
      if ~isempty(findobj('type','figure'))
        vh=getappdata(gcf,'vh'); % custom colormap saves as v2 and vh2
        v=getappdata(vh.fig,'v');
      end
    catch
    end

    switch (varargin{:})
      case 'pv' % call bbplot with no image data
        h=openfig('pvplot','new');
        a=findobj(h,'type','image'); if ~isempty(a); delete(a); end
        a=findobj(h,'type','line'); if ~isempty(a); delete(a); end
        vh=guihandles(h); % just to generate handles
        set(vh.fig,'visible','off')
        v.dummy=1; v.zdata=[]; v.z2=v.zdata; v.z2original=v.z2; v.msz=3; v.scroll=0;
        v.xdata=0; v.zavg=[]; v.histo=0; v.play=0; v.normalize=0; v.dxarrow=100;
        v.histofit=0; v.fignum=v0.fignum+1; v.xbw=0; v.xavg=[]; v.circles=0;
        v.getpeak={'1' '10' '10' '5' 'avg'};
        % if isempty(v0.fignum); v0.fignum=1; end;
        v0.fignum=v0.fignum+1;
        setappdata(0,'fignum',v0.fignum)
        set(vh.fig,'KeyPressFcn',[mfilename ' keypress' ' keypress'])
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        setappdata(vh.fig,'vh',vh)
        setup
        v=getappdata(vh.fig,'v');
        v.picdir=v0.homedir;
        v.newname='graph';
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        bbplot
      case 'help'
        str=['KEYPRESS ' char(10),...
          'a=align' char(10),...
          'c=collapse' char(10),...
          'e=erase' char(10),...
          'k kbd' char(10),...
          'l label' char(10),...
          'm mask' char(10),...
          'p crop' char(10),...
          'q toggle figsize/scan' char(10),...
          'r roi' char(10),...
          's smooth' char(10),...
          'v save' char(10),...
          'w toggle wrap/bw lut' char(10),...
          'x close window' char(10),...
          'z zoom' char(10)];
        msgbox(str)
      case 'scrollmode'
        v.scroll=~v.scroll;
        if length(v.list)<2; v.scroll=0; end
        setappdata(vh.fig,'v',v)
      case 'keyboard'
        %  sptool
        currentfig=vh.fig;
        try
          x=v.xdata; y=v.z2;
        catch
          x=[]; y=[];
        end
        clc
        disp('Address x data as "x" and y array as "y"')
        keyboard
        v.xdata=double(x); v.z2=y;
        setappdata(currentfig,'v',v); setappdata(0,'v0',v0)
      case 'colorbarr'
        h2=findobj('tag','colorbar');
        if isempty(h2)
          cbarpos={'north' 'south' 'east' 'west',...
            'northoutside' 'southoutside' 'eastoutside' 'westoutside'};
          prompt={'1-4=north,south,east,west; 5-8=same, outside'};
          title='ColorBar position?'; lineno=1; def={'3'};
          inp=inputdlg(prompt,title,lineno,def);
          cbarstr=cbarpos{str2double(inp{:})}; %getappdata(0,'colorbarposition');
          colorbar(cbarstr,'tag','colorbar'); %'color','white');
          set(get(gca,'XLabel'),'color','white')
        else
          delete(h2)
        end

      case 'abortt'
        setappdata(0,'abort',1)
        set(vh.fig,'pointer','arrow')
        buttonvis     
      case 'pixval'
        % disp('pixval')%%%%%%%%%%%%%%%%%%%%%%%%%
        button=get(vh.fig,'selectiontype');
        if strcmp(button,'alt')
          v.play=0; setappdata(vh.fig,'v',v)
          set(vh.fig,'units','pixels') % required for pixval
          try; delete(vh.impix); catch; end % must delete existing one (???)
          vh.impix=impixelinfo; %display pixel tracking bar
        elseif strcmp(button,'normal') 
          try; delete(vh.impix); catch; end
        end
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
      case 'picname'
        button=get(vh.fig,'selectiontype');
        val=get(vh.fs,'value');
        if strcmp(button,'normal') % step down
          dval=-1;
        elseif strcmp(button,'alt')  
          dval=1;
        end
        try
          val=min(v.lastframe,max(v.firstframe,val+dval));
        catch
          return;
        end
        set(vh.fs,'value',val)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        eval([mfilename ' fs'])
      case 'play'
        str='play';
        playnow=v.play; v.play=1;
        if playnow;
          v.swing=~v.swing;
        end
        if v.swing; str='swing'; end
        set(vh.play,'string',str)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        if ~playnow; playmovie; v.play=0;
        end
      case 'fs' % frame by frame slider
        v.play=0; setappdata(vh.fig,'v',v)
        v.frame=round(get(vh.fs,'value'));
        h2=vh.img;
        b=v.firstframe*(v.frame<v.firstframe)+v.lastframe*(v.frame>v.lastframe);
        v.frame=v.frame*~b+b;
        set(vh.fs,'value',v.frame);
        str=[num2str(v.frame) ': ' v.list{v.frame}];
        set(vh.picname,'string',str);
        if ~v.rgbyes;
          set(h2,'cdata',v.Movi(:,:,v.frame));
          if v.srf; set(h2,'zdata',v.Movi(:,:,v.frame)); end
          if v.minmaxmode % auto scaling
            lohi=get(vh.ax,'clim');
            set(vh.minmaxmode,'string',[num2str(lohi(1)) ': ' num2str(lohi(2))])
          end
        else
          a(:,:,1)=v.rgbgain(1)*v.Movi(:,:,1,v.frame);
          a(:,:,2)=v.rgbgain(2)*v.Movi(:,:,2,v.frame);
          a(:,:,3)=v.rgbgain(3)*v.Movi(:,:,3,v.frame);
          %  if ~isempty(v0.watlo); a(v0.watoutline)=127; end
          set(h2,'cdata',a);
        end
        if v.zoom
    i=get(vh.img,'cdata');
    try
      %disp(v.pos)
      i=i(v.pos(2):v.pos(2)+v.pos(4),v.pos(1):v.pos(1)+v.pos(3));
      i=flipdim(i,1);
      set(v.zoomimg,'cdata',i); catch; end
  end
        drawnow
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'pausefirst'
        v.pausefirst=~v.pausefirst;
        clr=[.92 .91 .85]; if v.pausefirst; clr='red'; end
        set(vh.pausefirst,'backgroundcolor',clr)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'pauselast'
        v.pauselast=~v.pauselast;
        clr=[.92 .91 .85]; if v.pauselast; clr='red'; end
        set(vh.pauselast,'backgroundcolor',clr)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'figsize'
        xadd=20; yadd=120;
        sz=size(v.Movi(:,:,1)); %imx=sz(1); imy=sz(2);
        a=get(vh.figsize); 
        if a.Value>a.Max; a.Value=a.Max; set(vh.figsize,'Value',a.Max); end
        figfac=a.Value; 
        if (figfac<=0.1);
          figfac=1;
          set(vh.figsize,'value',1)
        end % Minimum resets size
        scrnsz=get(0,'screensize'); %scrnx=scrnsz(3); scrny=scrnsz(4);
        set(vh.figsizetxt,'string',['FigSize ' num2str(round(figfac*100)/100)]);
        figpos0=get(vh.fig,'position');
        figpos3=max(500,(sz(2)*figfac+xadd));
        figpos4=sz(1)*figfac+yadd;
        figpos1=min(figpos0(1),(scrnsz(3)-figpos3)/1.5);
        figpos2=min(figpos0(2),(scrnsz(4)-figpos4));
        figpos=round([figpos1 figpos2 figpos3 figpos4]);
        uu=get(vh.fig,'units');
        set(vh.fig,'units','pixels')
        set(vh.fig,'position',figpos)
        set(vh.fig,'units',uu)
        impos=[10 yadd sz(2)*figfac sz(1)*figfac];
        set(vh.ax,'visible','off','units','pixels','position',impos)
        set(vh.ax,'units','normalized')
        drawnow
      case 'pauseallslider'
        v.pse=zeros(1,length(v.list));
        v.pse(:)=get(vh.pauseallslider,'value');
        try
          set(vh.pauseall,'string',['Pause ' num2str(v.pse(2))]);
        catch; v.pse=zeros(1,size(v.list,2)); end
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'pauseall'
        sz=size(v.pse,2);
        title='Pause (seconds)';
        prompt='Type pauses (seconds)';
        lineno=1;
        def={num2str(v.pse)};
        inp=inputdlg(title,prompt,lineno,def);
        try
          pse2=str2double(inp{:});
          if size(pse2,2)==sz; v.pse=pse2; end; catch
        end
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'framestep'
        v.framestep=round(get(vh.framestep,'value'));
        set(vh.framesteptxt,'string',['Framestep ' num2str(v.framestep)]);
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
      case 'ffs'
        v.firstframe=round(get(vh.ffs,'value'));
        n2=round(get(vh.lfs,'value'));
        if (v.firstframe>n2); v.firstframe=n2;
          set(vh.ffs,'value',v.firstframe);end
        set (vh.ffstxt,'string',['First ' num2str(v.firstframe)]);
        disp(['First frame = ' num2str(v.firstframe)])
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
      case 'lfs'
        n1=round(get(vh.ffs,'value'));
        n2=round(get(vh.lfs,'value'));
        if (n1>n2); n2=n1; set(vh.lfs,'value',n2);end
        set (vh.lfstxt,'string',['Last ' num2str(n2)]);
        v.lastframe=n2;
        disp(['Last frame = ' num2str(n2)])
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        setappdata(vh.fig,'vh',vh)
      case 'wrap' % wrap <--> gray LUT (press 'w')
        f='wrap.lut'; p=[v0.homedir 'color\'];
        if strcmp(v.mapname,'wrap'); f='gray.lut'; end
        try; map=load([p f]); v.mapname=[f(1:end-4)];
          catch; return; end
          colormap(map)
          set(vh.color,'string',[v.mapname '.lut'])
          setappdata(vh.fig,'v',v)

      case 'color'
        [f p]=uigetfile([v0.homedir 'color\*.lut'],'Pick a color lut');
        if isempty(f); return; end
        if strcmp(f, 'custom.lut');
          eval([mfilename ' pvcolor0'])
        else
          try; map=load([p f]); v.mapname=[f(1:end-4)];
          catch; return; end
        %  if strcmp(f,'v.lut') % make v.lut
           % zv=round(max(v.Movi(:))/2);
            %a=zeros(2*zv,3); ared=(0:zv-1)'; ablue=(zv:-1:0)';
            %a(zv+1:end,1)=ared; a(1:zv+1,3)=ablue;
          %  zv=127;  
          %  a=zeros(256,3); ared=(0:128)'; ablue=(128:-1:0)';
          %  a(128:end,1)=ared; a(1:129,3)=ablue;
         % a=a/max(a(:));
          % v.mapname2='v';
        %  end
          %f  save([v0.homedir 'color\v.lut'],'a', '-ASCII')
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          colormap(map)
          set(vh.color,'string',[v.mapname '.lut'])
        end
        setappdata(vh.fig,'v',v)
      case 'crop'
        v.play=0;
        set(vh.fig,'userdata','hello');
        bbgetrect % draw rectangle, move it and click to close
        waitfor(vh.fig,'userdata')
        v=getappdata(vh.fig,'v');
        pos=v.pos; %getappdata(0,'pos'); % v.pos;
        lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
        lastrect=v0.lastrect; % getappdata(0,'lastrect');
        a(1)=max(1,pos(1)); a(2)=max(1,pos(2));
        a(3)=min(size(v.Movi,2),a(1)+pos(3)); a(4)=min(size(v.Movi,1),a(2)+pos(4));
        prompt={['X Left? Type 0 to use last rectangle: (' num2str(lastrect) ')'],...
          'Y Top?' 'X Right side?' 'Y Bottom?',...
          'All frames (0) or this one only (1)?',...
          'Replacement color (-1=no replacement)?'};
        title='Crop position?'; lineno=1;
        def={num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4)) '0' '-1'};
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        if strcmp(inp{1},'0'); a=lastrect;
        else
          a(1)=max(1,str2double(inp{1})); a(2)=max(1,str2double(inp{2}));
          a(3)=min(size(v.Movi,2),str2double(inp{3}));
          a(4)=min(size(v.Movi,1),str2double(inp{4}));
        end
        oneonly=str2double(inp{5}); repclr=str2double(inp{6});
        frame=get(vh.fs,'value');
        f1=lo; f2=hi; if oneonly; f1=frame; f2=f1; end
        v0.lastrect=a; % setappdata(0,'lastrect',a)
        if v.rgbyes; v.Movi2=v.Movi(a(2):a(4),a(1):a(3),:,f1:f2);
        else v.Movi2=v.Movi(a(2):a(4),a(1):a(3),f1:f2); end
        if repclr>-1;
          v.Movi(a(2):a(4),a(1):a(3),:)=repclr;
          set(vh.img,'cdata',v.Movi(:,:,frame))
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        end
        v.list2=v.list(lo:hi);
        v.srf=0; v.play=0; v0.rgbyes2=v.rgbyes;
        figname=[' crop_' num2str(v0.fignum)];
        v0.callingfig=vh.fig; % v0.callingfig=vh.fig;
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
        eval ([mfilename figname figname figname]) % to make nargin=3

      case 'collapse'
        if length(v.list)<2; return; end
        v.play=0; setappdata(vh.fig,'v',v);
        Movi=v.Movi;
        szy=size(Movi,1); def2=num2str(v.collapseframe);
        la=num2str(length(v.list));
        prompt={['Keep Brightest pixel (b), Dimmest pixel (d)',...
          'Average (a) all pixel values, or sum (s) all pixels?'],...
          'Number of iterations?'};
        title='Output destination?'; lineno=1;
        def={'b' '1'};
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        collapsemode=inp{1}; niter=round(str2num(inp{2}));
        p1=v.Movi(:,:,1); mn=min(p1(:)); bw=p1==mn;
        jmin=round(get(vh.ffs,'value')); jmax=round(get(vh.lfs,'value'));
        buttonvis('abort')
        ntot=jmax-jmin+1;
        npics=round(max(1,ntot*(niter>1)/niter));
        if v.rgbyes; a0=v.Movi(:,:,:,jmin:jmax);
        else a0=v.Movi(:,:,jmin:jmax); end
        sz=size(a0);
        a0=shiftdim(a0,2+v.rgbyes);
        a0=reshape(a0,sz(3+v.rgbyes),[]); % each row=one images
        atmp=a0(1:ntot/npics,:)*0; nn=0;
        for pic=1:npics
          atmp=atmp*0;
          for rdest=1:size(atmp,1)
            rsource=(rdest-1)*npics+pic;
            a(rdest,:)=a0(rsource,:);
          end
          b=max(a); str='max ';
          if strcmp(collapsemode,'a'); b=mean(a); str='avg '; end
          if strcmp(collapsemode,'d'); b=min(a); str='min '; end
          if strcmp(collapsemode,'s'); str='sum ';
            b=double(a); b=sum(b); end
          nn=nn+1;
          if v.rgbyes; c(:,:,:,nn)=reshape(b,sz(1),sz(2));
          else c(:,:,nn)=reshape(b,sz(1),sz(2)); end
        end % for pic=1:nstep
        c=round(c); mn=min(c(:));
        b=c(find(c>mn)); b=min(b(:)); c(c==mn)=b-1;
        if min(c(:))>=0; c=uint16(c); end
        buttonvis
        
        v.Movi2=c;
        % set(vh.img,'cdata',c);
        v.list2={[str num2str(v.fignum)]};
        v0.callingfig=vh.fig;
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        str=[' collapse_' num2str(v.fignum)];
        eval([mfilename str str str])
        
      case 'zoom'
        v.zoom=~v.zoom;
        setappdata(vh.fig,'v',v)
        switch v.zoom
          case 0
            set(vh.zoom,'BackgroundColor',[.92 .91 .85])
            delete(v.zoomfig)
          case 1
            set(vh.zoom,'BackgroundColor',[1 0 0])            
            bbgetrect
        end
      case 'label'
        v.label=~v.label;
        switch v.label
          case 0
            set(vh.fig,'windowbuttondownfcn','');
            clr=[.92 .91 .85];
          case 1
            set(vh.fig,'windowbuttondownfcn',[mfilename ' label2']);
            clr=[1 0 0];
        end
        set(vh.label,'backgroundcolor',clr)
        setappdata(vh.fig,'v',v)
      case 'label2'
        [x y]=bbgetcurpt(gca);
        x=round(x); y=round(y);
        button=get(vh.fig,'selectiontype');
        if (strcmp(button,'alt')) % right button
        elseif (strcmp(button,'extend')) % both buttons NO JOY!
          beep
        elseif (strcmp(button,'normal')) % left button
          if strcmp(get(gco,'type'),'text'); % clicked on existing label
            a=get(gco); % struct array
            def={a.String,a.FontSize,a.Color,a.Rotation,a.FontName,a.FontAngle,...
              a.FontWeight,a.HorizontalAlignment,a.VerticalAlignment};
            x=a.Position(1); y=a.Position(2);
            for j=2:4; def{j}=num2str(def{j}); end
            delete(gco);
          else
            def={'O', '32', '1 1 1', '0', 'helvetica', 'normal', 'normal', 'center', 'middle'};
          end
          prompt={'Label?', 'size', 'color (0-1 for R,G, and B)', 'rotation', 'font',...
            'angle (normal/italic)', 'weight(normal/bold)',...
            'HorizAlign(left/center/right)', 'VertAlign (top/middle/bottom)'};
          str=inputdlg(prompt,'Label',1,def); % str=cell array
          htxt=text(x,y,str{1},'fontsize',str2double(str{2}),'color',str2num(str{3}),...
            'rotation',str2double(str{4}),'fontname',str{5},'fontangle',str{6},...
            'fontweight',str{7},'horizontalalignment',str{8},...
            'verticalalignment',str{9});
          v.lasttext=get(htxt);
          if strcmp(str{1},''); delete(htxt);end
        end

      case 'erase'
        delete(findobj(vh.fig,'type','line'))
        delete(findobj(vh.fig,'type','rectangle'))
        delete(findobj(vh.fig,'type','text'))
        
      case 'smooth'
        v.play=0; setappdata(vh.fig,'v',v);
        jmin=round(get(vh.ffs,'value')); jmax=round(get(vh.lfs,'value'));
        frame=get(vh.fs,'value');
        if isempty(jmin); jmin=1; jmax=1; end
        prompt={'Moving bin: 3d (0 - slow) or each frame 2d smooth (1 - faster) or imhmax (2)?',...
          'Moving bin: Radius? (odd number) or imhmax threshold?',...
          'Std. deviation? (0=box average; >0=gaussian average)',...
          ['Smooth all frames (0) or only frame #' num2str(frame) '(1)?']};
        title='Smoothing'; lineno=1; %def={'3' '0.65'};
        def=v0.lastsmooth; % getappdata(0,'lastsmooth');
        if isempty(def); def={'1' '3' '0.65' '0'}; end
        inp=inputdlg(prompt,title,lineno,def); if isempty(inp); return; end
        smoothmode=str2double(inp{1});
        vv=str2double(inp{2}); if vv/2==round(vv/2); vv=vv+1; end % odd number
        stdev=str2double(inp{3});
        smoothone=str2num(inp{4});
        if smoothone; jmin=frame; jmax=jmin; end
        v0.lastsmooth=inp; % setappdata(0,'lastsmooth',inp)
        filt='box'; if stdev>0; filt='gaussian'; end
        v.Movi2=v.Movi; szy=size(v.Movi,1);
        htxt=text('position',[5 szy/2], 'color','red', 'fontsize',14);
        switch smoothmode
          case 1 % Moving bin 2D
            buttonvis('abort')
            for jj=jmin:jmax
              if getappdata(0,'abort'); return; end
              set(htxt,'string',[num2str(jj) '/' num2str(jmax)]);
              disp([num2str(jj) '/' num2str(jmax)]); drawnow
              if v.rgbyes
                v0.rgbyes2=1;
                for k=1:3
                  v.Movi2(:,:,k,jj)=smoothn(v.Movi(:,:,k,jj),[vv;vv],filt,stdev);
                end
                if smoothone; set(vh.img,'cdata',v.Movi2(:,:,:,frame)); 
                set(vh.fs,'value',frame); end
              else                
                a=v.Movi2(:,:,jj); mn=min(a(:)); bw=(a==mn);
                b=find(a>mn); c=mean(a(b)); a(a==mn)=c;
                a=smoothn(a,[vv;vv],filt,stdev); a(bw)=mn;
                v.Movi2(:,:,jj)=a; % smoothn(v.Movi(:,:,jj),[vv;vv],filt,stdev);
                if smoothone; set(vh.img,'cdata',v.Movi2(:,:,frame)); 
                set(vh.fs,'value',frame); end
            end
           
            end
          case 0 % Moving bin 3D
            sz=[vv; vv; vv];
            v.Movi2=smoothn(v.Movi,sz,filt,stdev); % changes to double format
          case 2 % imhmax
            for jj=jmin:jmax
              v.Movi2(:,:,jj)=imhmax(v.Movi(:,:,jj),vv);
            end
        end
        delete(htxt)
        buttonvis
        v.list2=v.list(jmin:jmax);

        if smoothone;          
          v.Movi=v.Movi2;
          setappdata(vh.fig,'v',v)
          return
        end
        v0.callingfig=vh.fig;
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        str=[' smooth_' num2str(v.fignum)];
        eval([mfilename str str str])
        
      case 'maskit'
        v.maskit=2;
        setappdata(vh.fig,'v',v')
        eval([mfilename ' roi'])
      case 'maskit2'
        v.maskit=0;
        bw=v.mask;
        vh2=getappdata(v.figfocus,'vh'); v2=getappdata(vh2.fig,'v');
        prompt={'Mask outside(0) or inside (1)?',...
          'Mask current figure (0) or make new figure (1)?',...
          'Mask color?'};
        title='Mask properties'; lineno=1;
        def={'0' '1' '0'};
        if strcmp(class(v.Movi), 'double'); def(3)={num2str(min(v.Movi(:)))}; end
        inp=inputdlg(prompt,title,lineno,def);
        outin=str2num(inp{1}); samenew=str2num(inp{2}); clr=str2num(inp{3});
        if ~outin; bw=~bw; end
        addit=~clr;
        switch class(v.Movi)
            case 'uint8'; addit=uint8(addit);
            case 'uint16'; addit=uint16(addit);
            case 'double'; addit=double(addit);
        end
        jmin=round(get(vh2.ffs,'value'));
        jmax=round(get(vh2.lfs,'value'));
        Movi=v2.Movi;
        for j=jmin:jmax
          if v2.rgbyes
            a=v2.Movi(:,:,:,j-jmin+1);
            a=a+addit;
            for k=1:3;
              b=a(:,:,k); b(bw>0)=clr; a(:,:,k)=b;
            end
            a=a-addit;
            Movi(:,:,:,j-jmin+1)=a;
            v0.rgbyes2=1;
          else
            a=v2.Movi(:,:,j); % j-jmin+1);
            a=a+addit;
            a(bw>0)=clr;
            a=a-addit;
            Movi(:,:,j)=a; % j-jmin+1)=a;
            v0.rgbyes2=0;
          end
        end
        if samenew % make new movie
          v.Movi2=Movi;
          v.list2=v2.list(jmin:jmax);
          %if length(v.list)~=length(v2.list); v.list2=v2.list; end
          setappdata(vh.fig,'v',v)
          v0.callingfig=vh.fig;
          setappdata(0,'v0',v0)
          figname=[' mask_' num2str(v2.fignum)];
          eval([mfilename figname figname figname])
          %  v0=getappdata(0,'v0');
        else % mask existing movie
          figure(v.figfocus); %  vh2.fig)
          %    vh2=getappdata(gcf,'vh'); v2=getappdata(vh.fig,'v');
          v2.Movi=Movi; % (:,:,jmin:jmax)=Movi;
          set(vh2.fs,'value',jmin)
          eval([mfilename ' fs'])
          set(vh2.img,'cdata',v2.Movi(:,:,jmin))
          setappdata(v.figfocus,'v',v2); %setappdata(0,'v0',v0)
          figure(vh.fig)
        end
        % setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

      case 'roi'
        v.play=0;
        v.maskit=v.maskit-1; v.maskit=(v.maskit==1); % if cancelled, v.maskit not set to 0s
        roivars=v0.roivars; % getappdata(0,'roivars');
        if isempty(roivars);
          roivars={'a' 'a' '2'}; % auto, average, 2 pixel radius
          v0.roivars=roivars; % setappdata(0,'roivars', roivars);
        end
        prompt={'DRAW (d) or PICK (p) or AUTO by threshold brightness (a)?',...
          'AVERAGE (a) or SUM (s) or BRIGHTEST (b) pixel',...
          'If PICK, radius of square (pixels)?'};
        title='How to select area, What to calculate'; lineno=1;
        def=roivars;
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); v.maskit=0; return; end
        roimode=inp{1}; v.calcmode=inp{2}; rad1=str2num(inp{3});
        v0.roivars=roivars;
        v.figfocus=vh.fig;
        m=getfig('Which figure for measurements?');
        if isempty(m); return; end
        v.figfocus=m(1,1);
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

        switch roimode
          case 'd' % Draw ROI
            try
              delete(vh.h2); catch end; vh.h2=[];
            try
              lastroi=v0.lastroi; % getappdata(0,'lastroi');
            catch
              lastroi={[]};
            end
            if ~isempty(lastroi) % keep former regions?
              roiedit;
              uiwait;
              v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
              lastroi=v0.lastroi; % getappdata(0,'lastroi');
            end
            jmin=round(get(vh.ffs,'value'));
            jmax=round(get(vh.lfs,'value'));
            try
              zz=v.zz; v.zz=[];
            catch
              zz=[];
            end
            vh2=getappdata(v.figfocus,'vh'); v2=getappdata(vh2.fig,'v');
            Movi=v2.Movi;
            inp='Yes';
            while strcmp(inp, 'Yes')
              set(vh.fig,'userdata','hello');
              bbdraw
              waitfor (vh.fig,'userdata')
              clc
              v=getappdata(vh.fig,'v');
              x=round(v.xdraw);
              y=round(v.ydraw);
              x(end+1)=x(1);y(end+1)= y(1);x3=[]; y3=[];
              for j=2:size(x,2);  % Interpolate - fill in gaps
                [xx, yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
                x3=[x3;xx(1:max(1,end-1))]; y3=[y3;yy(1:max(1,end-1))];
              end
              hold on;
              h2=line('xdata',x3,'ydata',y3,'color','white','linewidth',0.1);
              inp3=questdlg('Keep this?','Keep this area?');
              switch inp3
                case 'Cancel'
                  return
                case 'No'
                  delete(h2)
                case 'Yes'
                  bw=(roipoly(v.Movi(:,:,1),x3,y3));
                  zz=[];
                  npix=sum(bw(:));
                  disp([num2str(npix) ' pixels'])
                  if isempty(lastroi); lastroi={[x3 y3]};
                  else lastroi(end+1)={[x3 y3]}; end
                  row=0;
                  for j=jmin:jmax; % get brightness (z) values
                    row=row+1;
                    m=Movi(:,:,j);
                    z(row,1)=sum(sum(m(bw)));               % SUM
                    if strcmp(v.calcmode,'s'); z(:,2)=npix; end
                    try
                      if strcmp(v.calcmode,'a'); z(row,1)=z(row,1)/npix; end % AVERAGE
                    catch
                      keyboard;
                    end
                    if strcmp(v.calcmode,'b'); z(row,1)=max(m(bw)); end   % MAX
                  end
                  if size(lastroi,2)==1 % size(v.bw,3)==1
                    zz=z;
                  else
                    col=size(zz,2)+1; col2=size(z,2);
                    zz(:,col:col+col2-1)=z;
                  end
                  z=[];
                  v0.lastroi=lastroi; % setappdata(0,'lastroi',lastroi)
                  setappdata(vh.fig,'v',v); 
                  setappdata(0,'v0',v0)
              end % switch inp3 (yes,no,cancel)
              inp=questdlg('Draw another?','Draw another area?');
              if strcmp(inp,'Cancel'); return; end
            end % while inp is yes
            bw=v.Movi(:,:,1)*0;
            for j=1:size(lastroi,2)
              a=lastroi{j};
              x=a(:,1); y=a(:,2);
              bw=roipoly(bw,x,y); % ones outside mask
              if j==1; bw2=bw; else bw2=bw2+bw; end
            end
            v.mask=logical(bw2);
            v0.lastroi=lastroi; % setappdata(0,'lastroi',lastroi)
            % v.bw=[];
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            v.zdata=zz; v.z2=zz; v.zavg=[];

          case 'a' % Auto
            if size(v.mask) ~= size(v.Movi(:,:,1)); v.mask=[]; end
            v.histo=0;
            if ~isempty(v.mask)
              a=get(vh.img,'cdata'); b=a;
              a(v.mask>0)=max(a(:));
              set(vh.img,'cdata',a)
              inp=questdlg('Use this mask?');
              set(vh.img,'cdata',b)
              if strcmp(inp,'No');
                v.mask=[];
              else
                setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
                eval([mfilename ' roiautocalc'])
                return
              end
            end
            jnow=round(get(vh.fs,'value')); % if histo; jmin=jnow; jmax=jnow; end
          %  m=v.Movi(:,:,jnow); 
            m=get(vh.img,'cdata');
            mx=double(max(m(:))); mn=double(min(m(:)));
            if ~v.thresh || v.thresh>mx || v.thresh<mn;
              v.thresh=round(mx-0.8*(mx-mn));
            end
            line('tag','roiautoline','visible','off',...
              'linestyle','none','marker','.','markersize',4,'color','red');
            buttonvis('roiauto')

            set(vh.roithresh,'min',mn+1,'max',mx-1,'value',v.thresh,...
              'sliderstep',[1/(mx-mn) .05])
            set(vh.roithreshtxt,'string',['threshold= ' num2str(v.thresh)])
            setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            set(vh.fig,'userdata','')
            eval([mfilename ' roiautoslider'])
            return

          case 'p' % pick
            v.roirad=round(rad1); % needed in bbgetpts
            setappdata(vh.fig,'v',v)
            set(vh.fig,'userdata','hello');
            bbgetpts
            waitfor(vh.fig,'userdata')
            v=getappdata(vh.fig,'v');
            x=v.x; y=v.y;
            vh2=getappdata(v.figfocus,'vh');
            v2=getappdata(vh2.fig,'v'); % for calcs
            Movi=v2.Movi;
            if v.maskit; v.mask=logical(Movi)*0; end
            jmin=round(get(vh2.ffs,'value'));
            jmax=round(get(vh2.lfs,'value'));
            szx=size(v2.Movi,2); szy=size(v2.Movi,1);
            col=0;
            for spot=1:size(x,2)
              col=col+1;
              x0=x(1,spot); y0=y(1,spot);
              xmin=round(max(1,x0-rad1)); xmax=round(min(szx,x0+rad1));
              ymin=round(max(1,y0-rad1)); ymax=round(min(szy,y0+rad1));
              m0=Movi(ymin:ymax,xmin:xmax,jmin:jmax);
              if v.maskit; 
                v.mask(ymin:ymax,xmin:xmax,jmin:jmax)=1; 
              end
              npix=(ymax-ymin+1)*(xmax-xmin+1);
              row=0;
              for frame=jmin:jmax
                row=row+1;
                mm=m0(:,:,frame);                
                z(row,col)=sum(mm(:));
                if strcmp(v.calcmode,'a'); z(row,col)=z(row,col)/npix; end
                if strcmp(v.calcmode,'b'); z(row,col)=max(mm(:)); end
              end
            end
            z=double(z);
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            v.zdata=z; v.zavg=[]; v.z2=z;
        end % ROI mode (auto, draw, pick, etc)

        v.newname=v.name;
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        if v.maskit; eval([mfilename ' maskit2'])
        else bbplot; end
        % END ROI
      case 'roiminareaman'
        minvals=get(vh.roiminarea);
        minarea=round(minvals.Value);
        inp=inputdlg({'Min Area?'},'Mask minimum area',1,{num2str(minarea)});
        minarea=round(str2num(inp{:}));d
        set(vh.roiminarea,'value',minarea,'Max',minarea*2)
        eval([mfilename ' roiautoslider'])
      case 'roiautosliderman' % manual entry of roiautoslider (thresh for mask)
        v.thresh=round(get(vh.roithresh,'value'));
        inp=inputdlg({'Threshold?'},'Mask threshold',1,{num2str(v.thresh)});
        v.thresh=round(str2num(inp{:}));
        set(vh.roithresh,'value',v.thresh)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        eval([mfilename ' roiautoslider'])
      case 'roiautoslider' % gets both min and thresh values
        v.thresh=round(get(vh.roithresh,'value'));
        minvals=get(vh.roiminarea);
        minarea=round(minvals.Value); % round(get(vh.roiminarea,'value'));
        if minarea==round(minvals.Max);
          set(vh.roiminarea,'Max',round(1.5*minvals.Max));
          setappdata(vh.fig,'vh',vh)
        end
        jnow=round(get(vh.fs,'value'));
        set(vh.roithreshtxt,'string',['thresh=' num2str(v.thresh)])
        set(vh.roiminareatxt,'string',['min=' num2str(minarea)])
        drawnow
        %m=v.Movi(:,:,jnow);
        m=get(vh.img,'cdata');
        bw=(m>=v.thresh);

        numpix=sum(bw(:)); % for John Caldwell 10/25/06
        avg=sum(sum(m(bw)))/numpix;

        [bwL]=bwlabel(bw,4);
        tic
        s=regionprops(bwL,'Area');
        s=[s.Area]';
        [a,ix]=sort(s,'descend');
        nn=1; bw2=(bw>1);
        try
          % tic
          while(s(ix(nn))>=minarea)
            bw2(bwL==ix(nn))=1;
            nn=nn+1;
            elapsed=toc; % disp(elapsed)
           % if elapsed>10; disp(['Drawing only ' num2str(nn-1) ' largest areas']);
            %  nn=size(ix,1)+1; end
          end
        catch
        end
        v.bw=bw2;
        numpix2=sum(bw2(:));
        avg2=sum(sum(m(bw2)))/numpix2;
        disp(['Thresh=' num2str(v.thresh) '. MinArea=' num2str(minarea) '. ' num2str(nn-1) ' areas.'])
      %  disp(['Numpix=' num2str(numpix) '. Avg=' num2str(avg)])
        disp(['Numpix=' num2str(numpix2) '. Avg=' num2str(avg2) '. '])
     %   disp([num2str(nn-1) '/' num2str(size(ix,1)) ' areas'])
        disp('_____________________________________________')
        bw2=bwmorph(bw2,'remove');
        [r,c]=find(bw2);
        hline=findobj('tag','roiautoline');
        set(hline,'visible','on','xdata',c,'ydata',r);
        drawnow
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

      case 'roimodelNN' % model nearest neighbor
        prompt={['This will randomly position n pixels within the mask, ',...
          'and calculate nearest neighbors. It will repeat the cacluation N times, ',...
          'and plot the average results. What is n, the number of pixels to place randomly?'],...
          'What is minimum separation (in nm)?',...
          'How many nm/pixel?',...
          'What is N, the number of iterations?'};
        title='Modeling nearest neighbors'; lineno=1; def={'100' '250' '51' '1'};
        inp=inputdlg(prompt,title,lineno,def);
        npix=str2num(inp{1}); dxminnm=str2num(inp{2}); 
        nmperpix=str2num(inp{3}); niter=str2num(inp{4});
        dxmin=dxminnm/nmperpix;
        if npix==0 | niter==0; return; end
        [x0 y0]=find(v.bw);
        a=rand(size(x0,1),1);
        xy=[x0 y0 a];
        xy=sortrows(xy,3); % all possible positions
        n=1; xx=zeros(npix,1); res=zeros(npix,1);
        yy=xx; xx(1)=xy(1,1); yy(1)=xy(1,2); % place first point
        nrow=0;
        while n<=npix
          disp(n); drawnow
          nrow=nrow+1;
          xtest=xy(nrow,1); ytest=xy(nrow,2);
          dx=xx(1:n,1)-xtest; dy=yy(1:n,1)-ytest;
          dxy=dx.^2+dy.^2;
          dxy=sort(dxy);
          if sqrt(dxy(1))<dxmin % no joy
          else
            n=n+1;
            xx(n)=xtest; yy(n)=ytest;
            res(n)=sqrt(dxy(1));
          end
        end % while
        for j=1:npix
          disp(j); drawnow
          x=xx(j,1); y=yy(j,1);
          dx=xx-x; dy=yy-y;
          dxy=dx.^2+dy.^2;
          dxy=sort(dxy);
          res(j)=sqrt(dxy(2,1));
        end
        res=res(2:end,1);
        v.zdata=res; v.z2=res; v.avg=[];
        setappdata(vh.fig,'v',v)
        bbplot

      case 'roiNN' % distance to edge
        bw=v.bw;
        hline=line;
        [r,c]=find(bw>0); sz=size(r,1);
        bw2=bwmorph(bw,'remove');
        [re,ce]=find(bw2);
        a=v.Movi;
        b=a==0; if sum(b(:)); a=a+1;; end
        a(bw==0)=0;
        res=zeros(sz,4);
        for j=1:sz
          %  disp([num2str(j) ' / ' num2str(sz)])
          % if ~mod(j,1000); disp([num2str(j) ' / ' num2str(sz)]); end

          r2=(re-r(j)); r3=r2.^2; c2=(ce-c(j)); c3=c2.^2;
          d1=sqrt(r3+c3);
          dmin=min(d1);
          res(j,1)=c(j); % x pos
          res(j,2)=r(j); % y pos
          res(j,3)=a(r(j),c(j),1); % F
          res(j,4)=dmin;
          %    d2=[ce re d1];
          %  d3=sortrows(d2,3);
          %  line([c(j) d3(1,1)],[r(j) d3(1,2)]); drawnow
        end
        v.zdata=res; v.z2=res; v.zavg=[];
        v.xdata=[]; v.newname=v.name;
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        bbplot
        hline=findobj('tag','roiautoline');
        set(hline,'visible','on','xdata',ce,'ydata',re);
        drawnow
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

      case 'tempcalc' % NN spots in 2 images cross correlation temp calc
        str=['This routine will use image 1 and image 2 and find the ',...
          'nearest neighbor of each point in one image to the points ',...
          'in the other image, and vice versa. A point is defined as ',...
          'a pixel with max value. In addition, the routine will ',...
          'randomize positions of spots and calculate nearest ',...
          'neighbors for 100 randomized trials. Do you want to continue?'];
        inp=questdlg(str,'Continue?');
        if ~strcmp(inp,'Yes'); return; end
        m1=v.Movi(:,:,1); mx1=max(m1(:));
        m2=v.Movi(:,:,2); mx2=max(m2(:));
        sz1=sum(sum(v.Movi(:,:,1)==mx1)); sz2=sum(sum(v.Movi(:,:,2)==mx2));
        sz=[sz1,sz2]; res=NaN(max(sz),4);
        [x1 y1]=find(m1==mx1); [x2 y2]=find(m2==mx2);
        xy=res; xy(1:size(x1,1),1)=x1; xy(1:size(x2,1),2)=x2;
        xy(1:size(y1,1),3)=y1; xy(1:size(y2,1),4)=y2; % [x1 x2 y1 y2]
        
        val=res(:,1:2); % original values of maxima
        for j=1:sz1; val(j,1)=v.Movi2(x1(j),y1(j),1); end
        for j=1:sz2; val(j,2)=v.Movi2(x2(j),y2(j),2); end
        
        for k=1:2
          npix=sz(k);
          for j=1:npix 
            %disp(j); drawnow
            x=xy(j,k); y=xy(j,k+2);
            dx=xy(:,3-k)-x; dy=xy(:,5-k)-y;
            dxy=dx.^2+dy.^2;
            dxy=sort(dxy);
            res(j,k)=sqrt(dxy(1,1));
           % drawnow
          end
        end
        v.zdata=res; v.z2=res; v.avg=[];
        setappdata(vh.fig,'v',v)
        %    bbplot

        % randomize
        [x0 y0]=find(v.Movi(:,:,1)); % (v.bw); all pixels not masked
        % sz=[sz1 sz2];
        a=rand(size(x0,1),1);
        ntrials=100;
        for trial=1:ntrials
          disp(ntrials-trial)
          xy=[x0 y0 a];
          xy=sortrows(xy,3); % all possible positions
          x1=xy(1:sz1,1); y1=xy(1:sz1,2);
          a=rand(size(x0,1),1); xy=[x0 y0 a]; xy=sortrows(xy,3);
            x2=xy(1:sz2,1); y2=xy(1:sz2,2);
          for k=1:2
            xx=x1; yy=y1; xx2=x2; yy2=y2;
            if k==2; xx=x2; yy=y2; xx2=x1; yy2=y1; end
            npix=size(xx,1);
            for j=1:npix
              % disp(j); drawnow
              x=xx(j,1); y=yy(j,1);
              dx=xx2-x; dy=yy2-y;
              dxy=dx.^2+dy.^2;
              dxy=sort(dxy);
              res(j,k+2)=sqrt(dxy(1,1));
            end
          end
          resnow=sort(res(:,3:4));
          if trial==1
            res0=resnow;
          else
            res0=res0+resnow;
          end
        end % for trial...
        res0=res0/ntrials;
        res(:,3:4)=res0;
        
        res=[val res];
          
       % res2=[res(:,1);res(:,2)]; res3=[res(:,3);res(:,4)];
       % res2(isnan(res2))=[]; res3(isnan(res3))=[];
       % v.zdata=sort([res2 res3]); 
        
        v.zdata=res;
        v.z2=v.zdata; v.avg=[];
        setappdata(vh.fig,'v',v)
        bbplot
        str='C1-2 = intensity values at maxima; C3-4 = observed NN; C5-6 = randomized NN';
        msgbox(str)

      case 'roiautoabort'
        buttonvis('normal')

      case 'roiautocalc'
        v.mask=v.bw; % setappdata(0,'mask',v.bw)
        setappdata(vh.fig,'v',v)
        buttonvis('normal')
        if v.maskit;
          eval([mfilename ' maskit2']); return;
        end
        bw=v.bw;
        vh2=getappdata(v.figfocus,'vh');
        v2=getappdata(vh2.fig,'v'); % for calcs
        Movi=v2.Movi;
        jmin=round(get(vh.ffs,'value'));
        jmax=round(get(vh.lfs,'value'));
        bwl=bwlabel(bw); nspots=max(bwl(:));
        avgall=1;
        if nspots>1
          prompt={[num2str(nspots) ' spots - keep separate (0) or average all (1)?']};
          inp=inputdlg(prompt,'Keep separate or Average spots?',1,{'01'});
          avgall=str2num(inp{1});
        end
        z=[];
        row=0; col=1;        
        for frame=jmin:jmax
          row=row+1;
          m=Movi(:,:,frame);
          m(~bw)=0;
         if ~avgall    
            for j=1:nspots
              m2=bwl==j;
              s=sum(m(m2));
              npix=sum(m2(:));
              z(row,j)=s/npix;
            end
    else
          s=sum(m(:));
          npix=sum(bw(:));
          if strcmp(v.calcmode,'a');
            z(row,col)=s/npix;
          elseif strcmp(v.calcmode,'b') || strcmp(v.calcmode,'s');
            z(row,col)=max(m(:));
          end
         end % if ~avgall
        end % frame loop
        v2.zdata=z; v2.z2=z; v2.zavg=[];
        v2.xdata=(1:size(z,1))';
        figure(vh2.fig)
        v2.newname=v.name;
        v2.mask=v.mask;
        setappdata(vh2.fig,'v',v2); setappdata(0,'v0',v0)
   %     inp=questdlg('Do a single pixel analysis?','Single pixel analysis?'); %No';
    inp='No'; %%%%%%%%%%%%%%%%%%  
   if strcmp(inp,'Cancel'); return; end
        if strcmp(inp,'Yes')
          figure(vh2.fig)
          v0.lastroi=[]; % setappdata(0,'lastroi',[])
          snglpix
        end
        bbplot

      case 'endothresh'
        val=round(get(vh.endothresh,'value'));
        bw=v.Movi(:,:,2)>=val;
        m1=v.frame1; m1(~bw)=0;
        v.Movi(:,:,1)=m1;
        m3=v.frame3; m3(~bw)=0;
        v.Movi(:,:,3)=m3;

        frame=round(get(vh.fs,'value'));
        if frame==3; set(vh.img,'cdata',m3);
        elseif frame==1; set(vh.img,'cdata',m1);
        end
        set(vh.endothreshtxt,'string',['min df=' num2str(val)])
        drawnow

      case 'alignkeypress'
        k=get(vh.fig,'currentcharacter');
        if isempty(k); return; end
        dx=0; dy=0; rotatesgn=0;
        switch k
          case {'[' ']'} % move ~10% of total length
            df=round(0.1*size(v.Movi,3)); if strcmp(k,'['); df=-df; end
            v.frame=v.frame+df; if v.frame>size(v.Movi,3); v.frame=1; end
            if v.frame<1; v.frame=size(v.Movi,3); end
            v.Movi2(:,:,2)=v.Movi(:,:,v.frame);
            v.lastdx=v.dx; v.lastdy=v.dy;
            v.dx=0; v.dy=0;
            set(vh.img,'cdata',v.Movi2); drawnow
          case {'r' 'R'} % repeat last
            dx=v.lastdx; dy=v.lastdy; v.dx=0; v.dy=0;
          case '0' % return to original position
            dx=-v.dx; dy=-v.dy;
          case {'x' 'X'} % quit
            set(vh.fig,'keypressfcn',[mfilename ' keypress' ' keypress'])
            hh=findobj('tag','alignhelp'); if ~isempty(hh); delete(hh); end
            v.rgbyes=0;
            if isa(v.Movi,'uint16'); v.Movi=v.Movi./v.f; v.Movi=v.Movi+v.mn; end
            v.Movi2=v.Movi;
            set(vh.img,'cdata',v.Movi(:,:,1))
            delete(findobj('tag','aligntext'))
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            if v.figfocus~=gcf && sum(v.dxy(:))>0 % align on different figure
              vh2=getappdata(v.figfocus,'vh'); v2=getappdata(vh2.fig,'v');
              figure(vh2.fig)
              v2.Movi2=v2.Movi;
              for j=1:size(v2.Movi,3)
                disp(j)
                if v.dxy(j,1) || v.dxy(j,2)
                  e=bbalign(j,v.dxy,v2.Movi(:,:,:),9999e9,v);
                  v2.Movi2(:,:,j)=uint8(e);
                end
              end
              v0.callingfig=vh2.fig;
              setappdata(vh2.fig,'v',v2); setappdata(0,'v0',v0)
              figname=[' align_' num2str(v2.fignum)];
              eval([mfilename figname figname figname])
            end
            
            
            return
          case {'z' 'Z'} % new base image
            v.Movi2(:,:,1)=v.Movi2(:,:,2);
            set(vh.img,'cdata',v.Movi2)
            drawnow
            disp(['Base image = ' num2str(v.frame)])
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          otherwise
            nn=double(k);
            % disp(nn)
            switch nn
              case 8 % backspace
                v.frame=v.frame-1; if v.frame<1; v.frame=size(v.Movi,3); end
                v.Movi2(:,:,2)=v.Movi(:,:,v.frame);
                v.lastdx=v.dx; v.lastdy=v.dy;
                v.dx=0; v.dy=0;
                set(vh.img,'cdata',v.Movi2);drawnow
              case 13 % ENTER - This is the only key that moves the image for real
                v.Movi(:,:,v.frame)=v.Movi2(:,:,2); % this saves any change to v.Movi
                v.frame=v.frame+1; if v.frame>size(v.Movi,3); v.frame=1; end
                v.Movi2(:,:,2)=v.Movi(:,:,v.frame);
                v.lastdx=v.dx; v.lastdy=v.dy;
                v.dxy(v.frame,1)=v.dx; v.dxy(v.frame,2)=v.dy;
                v.dx=0; v.dy=0;
                set(vh.img,'cdata',v.Movi2); drawnow
              case 27 % ESC
                v.frame=v.frame+1; if v.frame>size(v.Movi,3); v.frame=1; end
                v.Movi2(:,:,2)=v.Movi(:,:,v.frame);
                v.lastdx=v.dx; v.lastdy=v.dy;
                v.dx=0; v.dy=0;
                set(vh.img,'cdata',v.Movi2)
              case 28 % left arrow
                dx=-1;
              case 29 % right arrow
                dx=1;
              case 30 % up arrow
                dy=-1;
              case 31 % down arrow
                dy=1;
              case 60 % < rotate counterclockwise
                rotatesgn=1;
              case 62 % > rotate clockwise
                rotatesgn=-1;
              case 63 % ? set rotation
                inp=inputdlg({'Rotation degrees?'}, 'Rotation degrees', 1,{num2str(v.rotate)});
                v.rotate=str2num(inp{1});
            end % otherwise
        end % switch k
        if rotatesgn
          degrees=v.rotate*rotatesgn;
          [sy,sx,sz]=size(v.Movi2);
          pts=[round(sx/2);round(sy/2)];
          a=v.Movi2(:,:,2);
          b=double(a);
          [b,pts2]=bbrotate_image(degrees,b,pts);
          [sy2,sx2]=size(b);
          dsy=round((sy2-sy)/2); dsx=round((sx2-sx)/2);
          b=b(dsy:dsy+sy-1,dsx:dsx+sx-1);
          v.Movi2(:,:,2)=uint16(b);
          if isa(a,'uint8'); v.Movi2(:,:,2)=uint8(b); end
          v.Movi(:,:,v.frame)=v.Movi2(:,:,2); % this saves any change to v.Movi
        else
          v.dx=v.dx+dx; v.dy=v.dy+dy;
          if dx || dy
            m=v.Movi(:,:,v.frame);
            if v.dx>0 % move right
              m=[m(:,1:v.dx)*0 m(:,1:end-v.dx)];
            elseif v.dx<0 % move left
              m=[m(:,-v.dx+1:end) m(:,1:-v.dx)*0];
            end

            if v.dy>0 % move up
              m= [m(1:v.dy,:)*0; m(1:end-v.dy,:)];
            elseif v.dy<0 % move down
              m=[ m(-v.dy+1:end,:); m(1:-v.dy,:)*0];
            end

            v.Movi2(:,:,2)=m;
          end % if dx | dy
        end
        set(vh.img,'cdata',v.Movi2);
        a=double(v.Movi2(v.y1:v.y2,v.x1:v.x2,1));
        b=double(v.Movi2(v.y1:v.y2,v.x1:v.x2,2));
        if isa(v.Movi,'uint16'); a=a./v.f; b=b./v.f; end
        v.msd=sum(sum(((a-b).^2)))/(size(a,1)*size(a,2));
        set(findobj('tag','aligntext'),...
          'string',[num2str(v.frame) ' / ' num2str(size(v.Movi,3)) ' - ' num2str(round(v.msd))])
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        % disp(['Frame ' num2str(v.frame)])

      case 'align'
        v.play=0; setappdata(vh.fig,'v',v);
        Movi=v.Movi;
        jmin=round(get(vh.ffs,'value'));
        jmax=round(get(vh.lfs,'value'));
        htxt=text('position',[5 size(v.Movi,1)/2], 'color','red', 'fontsize',14);
        prompt=['4 modes to choose from: ' char(10),...
          '1. Auto; Least square fit of selected region' char(10),...
          '2. Manual Pick: Pick same point in every image (rough alignment)' char(10),...
          '3. Manual Slide: Use arrows to move pixel-by-pixel' char(10),...
          '4. Morph: pick many pairs of points in image 1 and 2'];
        title='Align images'; lineno=1;  try; def=v.alignmode; catch; def={'1'}; end
        inp=inputdlg(prompt,title,lineno,def);
        % inp=questdlg(prompt,'Alignment mode','Auto','Pick','Slide','Auto');
        if isempty(inp); return; end
        alignmode=str2num(inp{1});
        switch alignmode
          case 1  % AUTO  
            v.Movi2=v.Movi;
            v.alignfig=jmin;
             buttonvis('abort')
            drawnow
            for j=jmin:jmax
              if getappdata(0,'abort'); return; end
            a=double(v.Movi(:,:,v.alignfig));
            b=double(v.Movi(:,:,j));
            [output Greg]=align_dfr(fft2(a),fft2(b),1);
            v.Movi2(:,:,j)=uint16(abs(ifft2(Greg)));
            set(vh.img,'cdata',v.Movi2(:,:,j))
            disp([num2str(j) ' / ' num2str(jmax) '.  dx=' num2str(output(4)) '  dy=' num2str(output(3))])           
            drawnow
            end
             setappdata(vh.fig,'v',v)
            set(vh.fig,'pointer','arrow')
            buttonvis
            v0.callingfig=vh.fig;
            setappdata(0,'v0',v0)
            figname=[' align_' num2str(v.fignum)];
            eval([mfilename figname figname figname])
            return
          
          case 2 % PICK
            buttonvis('abort') % setup
            jj=jmin; %abort=0;
            while jj<=jmax
              if getappdata(0,'abort'); return; end
              if jj<jmin; jj=jmin; end
              set(htxt,'string',[num2str(jj) '/' num2str(jmax)]);
              set(vh.fig,'pointer','crosshair');
              disp([num2str(jj) '/' num2str(jmax)])
              if v.rgbyes;
                a(:,:,1)=v.rgbgain(1)*v.Movi(:,:,1,jj);
                a(:,:,2)=v.rgbgain(2)*v.Movi(:,:,2,jj);
                a(:,:,3)=v.rgbgain(3)*v.Movi(:,:,3,jj);
                set(vh.img,'cdata',a);
              else set(vh.img,'cdata',Movi(:,:,jj));
              end
              set(vh.fig,'windowbuttondownfcn','uiresume');
              uiwait
              button=get(vh.fig,'selectiontype');
              switch button
                case {'normal' 'extend' 'open'}
                  [x y]=bbgetcurpt(gca);
                  xyalign(jj,1)=round(x); xyalign(jj,2)=round(y);
                case 'alt'
                  jj=jj-2;
              end
              jj=jj+1;
            end % while jj<=jmax
            set(vh.img,'buttondownfcn',[mfilename ' pixval']);
            set(vh.fig,'pointer','arrow');
            %beep
            set(htxt,'string',' Wait...'); drawnow
            disp('Wait...')
            xybar=round(mean(xyalign(jmin:jmax,:)));
            xyalign(:,1)=-(xyalign(:,1)-xybar(1,1));
            xyalign(:,2)=-(xyalign(:,2)-xybar(1,2));
            for jj=jmin:jmax
              if getappdata(0,'abort'); return; end
              if v.rgbyes; e=Movi(:,:,:,jj); else e=Movi(:,:,jj); end
              if xyalign(jj,1) || xyalign(jj,2)
                e=bbalign(jj,xyalign,Movi,9999e9,v);
              end
              if v.rgbyes; Movi(:,:,:,jj)=uint8(e); v0.rgbyes2=1;
              elseif isa(Movi,'uint8'); Movi(:,:,jj)=uint8(e);
              elseif isa(Movi,'uint16'); Movi(:,:,jj)=uint16(e);
              end
            end
            v.Movi2=Movi;
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig;
            setappdata(0,'v0',v0)
            set(vh.fig,'pointer','arrow')
            delete(htxt);
            buttonvis
            figname=[' align_' num2str(v.fignum)];
            eval([mfilename figname figname figname])
          case 3 % align SLIDE
            %    if ~isa(v.Movi,'uint8') | v.rgbyes; msgbox('Please convert to
            %    8 bits','replace'); return; end
            v.figfocus=vh.fig;
            m=getfig('Which figure for measurements?');
            if isempty(m); return; end
            v.figfocus=m(1,1);
            v.dxy=zeros(size(v.Movi,3),2);
            currentfig=gcf;
            hh=msgbox(['NOTE: Only ENTER or ROTATE (< or >) keys save the result!',...
              char(10) 'MOVE GREEN IMAGE OVER RED:',...
              char(10) 'ARROWS: Use 4 arrows to move green image over red.',...
              char(10) '0 = go back to initial position.',...
              char(10) 'r = Repeat movement of previous image.',...
              char(10) '< or >  = ROTATE counterclockwise or clockwise',...
              char(10) '? = set number of degrees to rotate (default=0.5)',...
              char(10) '[ or ] = move L or R ~10% total # frames',...
              char(10),...
              char(10) 'GO TO NEW IMAGE:',...
              char(10) 'ENTER = SAVE and go to next.',...
              char(10) 'ESC = go to next (no save).',...
              char(10) 'BACKSPACE = go to previous (no save).',...
              char(10)  '[ or ] = go back or forward 10% (no save).',...
              char(10) 'z = use current image as base image.',...
              char(10) 'x = quit'],'replace');
            set(hh,'tag','alignhelp','position',[500 388 222 164])
            figure(currentfig)
            v.frame=1;   v.f=255/double(max(v.Movi(:)));
            if isa(v.Movi,'uint16');
              v.mn=min(v.Movi(:));
              v.Movi=v.Movi-v.mn; mx=max(v.Movi(:));
              v.f=double(65536/mx); v.Movi=v.Movi.*v.f;
            end
            v.Movi2=v.Movi(:,:,1); %.*v.f;
            v.Movi2(:,:,2)=v.Movi(:,:,1); % .*v.f;
            v.Movi2(:,:,3)=v.Movi(:,:,1)*0;
            set(vh.fig,'keypressfcn',[mfilename ' alignkeypress'])
            v.rgbyes=1; v.dx=0; v.dy=0;
            sz=size(v.Movi2(:,:,1));
            v.y1=round(sz(1)/2-sz(1)/4); v.y2=round(v.y1+sz(1)/2);
            v.x1=round(sz(2)/2-sz(2)/4); v.x2=round(v.x1+sz(2)/2);
            set(vh.img,'cdata',v.Movi2)
            text('tag','aligntext','string',[num2str(v.frame) '/' num2str(size(v.Movi,3))],...
              'position',[5 15],'fontsize',12,'color','white')
            setappdata(vh.fig,'v',v)

          case 4 % morph
            prompt={['This routine will "morph" an image - reshape it locally - so that it aligns with another. ',...
              'The "base" image in the first image in the stack. The "align" image - the one that gets ',...
              'morphed - is the second image in the stack. You will pick congruent points in each ',...
              'image using the Matlab function "cpselect." The output will be two images - the ',...
              'original base image (first in the stack) and the new, morphed image',...
              char(10) char(10) 'Choose method of morphing: 1=linear conformal; 2=affine;',...
              '3=polynomial; 4=piecewise linear; 5=local weighted mean'],...
              'Fine tune with cpcorr? (0=no; 1=yes)'};
            title='Morph';  lineno=1; def={'4' '0'};
            try;
              if ~isempty(v.morphp1);
                prompt=[prompt {'Erase previous points? (0=no; 1=yes)'}];
                def=[def {'0'}];
              end
            catch;
              v.morphp1=[]; v.morphp2=[];
            end

            inp=inputdlg(prompt,title,lineno,def);
            nn=str2num(inp{1}); finetune=str2num(inp{2});
            modestr0={'linear conformal' 'affine' 'polynomial' 'piecewise linear' 'lwm'};
            modestr=modestr0{nn}; modestr2=strrep(modestr,' ','_');
            try; if str2num(inp{3}); v.morphp1=[]; v.morphp2=[]; end
            catch; end

            a0=v.Movi(:,:,1:2); % first image will be morphed to fit to second image
            fac=1;
            if isa(a0,'uint16');
              mn=min(a0(:)); a0=a0-mn; mx=max(a0(:)); fac=65536/mx; a0=a0.*fac;
            end
            pic1=a0(:,:,1); pic2=a0(:,:,2);

            %try;
            %a=v.morphp1;
            try; p1=v.morphp1; p2=v.morphp2;
              [v.morphp2,v.morphp1] = cpselect(pic2,pic1,p2, p1, 'Wait',true);
            catch;
              [v.morphp2,v.morphp1] = cpselect(pic2,pic1, 'Wait',true);
            end
            setappdata(vh.fig,'v',v)
            if size(v.morphp1)<6; msgbox('Need at least six pairs of points. Try again'); return; end

            if finetune
              [v.morphp2]= cpcorr(v.morphp2, v.morphp1, pic2,pic1); % fine tune
            end

            t_concord = cp2tform(v.morphp2,v.morphp1,modestr);

            pic2_reg = imtransform(pic2, t_concord, 'XData', [1 size(pic1,2)],  'YData',[1 size(pic1,1)]);
            pic1=pic1./fac; pic2_reg=pic2_reg./fac;
            v.Movi2= v.Movi(:,:,1); v.Movi2(:,:,2)= pic2_reg;
            v.list2=[v.list(1) {'morph'}];
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' morph_' modestr2 '_' num2str(v.fignum)];
            setappdata(vh.fig,'v',v)
            eval ([mfilename figname figname figname]);

        end % v.alignmode

      case 'mask'
        v.play=0; setappdata(vh.fig,'v',v)
        bw=roipoly;
        prompt={'Fill color value? (clear line to cancel)',...
          'Fill this image only (0) or all displayed images (1)',...
          'Put mask on current movie (0) or make new movie(1)?'};
        mn=get(vh.minslider,'value');
        def={num2str(mn) '1' '0'};
        aa=inputdlg(prompt,'Mask',1,def);
        if isempty(aa{1}); return; end
        clr=str2double(aa{1}); img=str2double(aa{2}); newmovie=str2double(aa{3});

        frame=round(get(vh.fs,'value'));
        jmin=round(get(vh.ffs,'value')); jmax=round(get(vh.lfs,'value'));
        if img==1; % all frames
          if ~v.rgbyes
            for j=jmin:jmax
              m=v.Movi(:,:,j);
              m(bw)=clr;
              v.Movi2(:,:,j)=m;
            end
          else
            %Movi(a(2):a(4),a(1):a(3),:,jmin:jmax)=fillit;
          end
        else % one frame only
          if ~v.rgbyes
            m=v.Movi(:,:,frame); m(bw)=clr; v.Movi2(:,:,frame)=m;
          else
            %Movi(a(2):a(4),a(1):a(3),:,framenum)=fillit;
          end
        end
        if ~newmovie; v.Movi=v.Movi2;
          % set(vh.img,'cdata',v.Movi(:,:,frame); drawnow
        end
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        if newmovie
          v0.callingfig=vh.fig; setappdata(0,'v0',v0)
          figname=[' mask_' num2str(v0.fignum)];
          eval([mfilename figname figname figname])
        end

      case 'save'
        jmax=round(get(vh.lfs,'value'));
        jmin=1; %%%%%%%%%%%%%%%%%%%%%%%
        len=length(v.list); %if len==1; jmin=1; jmax=1; end
        if ~isempty(v.picdir); cd (v.picdir); end
        [fname,pname]=uiputfile; %('*.*','Base name for image(s)? (use no periods for AVI format)',100,500);
        if fname==0; return; end
        try; if strcmp(fname(end-1:end),'.*'); fname=fname(1:end-2); end; catch; end
        v0.savedir=pname; % setappdata(0,'savedir',pname);
        nn=findstr(fname,'.');
        if isempty(nn); nn=0; end
        if nn(end)==length(fname-4);
          fmt=fname(end-2:end);
          fname=fname(1:nn(end-1));
        else
          fmt=inputdlg({'Format for save? mat, tif, jpg, avi'},'Format?',1,{'mat'});
          fmt=fmt{:};
        end
        if strcmp(fmt,'mat')
          lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
          v.list=v.list(lo:hi); v.list2=[];
          movi=v.Movi(:,:,lo:hi);
          try; if strcmp(fname(length(fname)-3:length(fname)),'.mat')
              fname=fname(1:length(fname)-4); end; catch; end
          save([pname fname '.' fmt],'movi','v');
          return
        end

        a=[]; % comment out to have labels, etc. dropped
        if ~isempty(a) || (v.srf && ~strcmp(fmt,'avi'))
          if v.srf; disp ('Capturing surface. Wait...')
          else disp('Dropping text, lines, rectangles...'); end
          F=getframe; a=F.cdata; sz=size(a);
          if isa(v.Movi,'uint8') || v.srf; Movi2 = uint8(0); else Movi2=uint16(0); end
          if v.rgbyes;
            Movi2= Movi2(ones(1,sz(1)-1),ones(1,sz(2)-1),ones(1,3),ones(1,len));
          else
            Movi2= Movi2(ones(1,sz(1)-1),ones(1,sz(2)-1),ones(1,len));
          end
          for j=jmin:jmax % 1:length(list);
            %jj=j-jmin+1;
            if v.rgbyes; m=v.Movi(:,:,:,j); else m=v.Movi(:,:,j);end
            if v.srf; set(vh.img,'cdata',m,'zdata',m);
            else set(vh.img,'cdata',m); drawnow; end
            F=getframe; % F is structure array containing RGB image
            a=F.cdata; % a is RGB image, uint8
            a=a(1:end-1,1:end-1,:);
            if v.rgbyes;
              Movi2(:,:,:,j)=a;
            else
              mm=rgb2ind(a,colormap); % uint16!!
              Movi2(:,:,j)=mm(:,:);
            end
          end
          v.Movi=Movi2;
        end
        %****************************************
        if (fname ~= 0)
          if strcmp(fmt,'avi');
            nf=length(v.list);
            prompt={'Frames per second (1-15)?',...
              'Pause at start (seconds)?',...
              'Pause at end (seconds)?',...
              ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
              ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
              ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
              'Compression? (cinepak, indeo3, indeo5, MSVC, none'};
            title='AVI variables';
            lineno=1; defans={'15','1','1','0','0','0','cinepak'};
            answer=inputdlg(prompt,title,lineno,defans);
            if isempty(answer); return; end
            fps=str2double(answer{1}); padit1=round(str2double(answer{2}));
            padit2=str2double(answer{3}); padit3=str2double(answer{4});
            padit4=str2double(answer{5}); padit5=str2double(answer{6}); comp=answer{7};
          end
          buttonvis('abort')
          figure(vh.fig); axes(vh.ax); % Because dialog windows reset gcf and gca!!!
          jj=0; % jmax-jmin+1; jj=0; % padit1=15; padit2=15;
          for j=jmin:jmax
            if getappdata(0,'abort'); return; end
            jj=jj+1;
            n=['0000' num2str(j)]; n1=char(n(end-3:end));
            f=[pname fname '.' n1 '.' fmt];
            htxt=text(20,50,[num2str(j) '/' num2str(jmax)],...
              'color','red','fontsize',18); drawnow
            disp([num2str(j) '/' num2str(jmax)])
            pause (.1)
            srf=0; %%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(fmt,'tif');
              if v.rgbyes; % size(size(Movi),2)>3
                imwrite(v.Movi(:,:,:,j),f);%,'description',imgdesc{j});
              else
                imwrite(v.Movi(:,:,j),f);%,'description',imgdesc{j});
              end
            elseif strcmp(fmt,'avi')
              if srf; set(hsrf,'cdata',Movi(:,:,j),'zdata',Movi(:,:,j));
              else
                if ~v.rgbyes;
                  set(vh.img,'cdata',v.Movi(:,:,j));
                else
                  set(vh.img,'cdata',v.Movi(:,:,:,j));
                end
              end
              set(htxt,'visible','off')
              drawnow
              m(jj)=getframe; %
              set(htxt,'visible','on')
              rpt=round((j==jmin)*(padit1*fps)+(j==jmax)*(padit2*fps)+(j==padit3 | j==padit4 | j==padit5)*fps);
              if rpt
                for jjj=1:rpt
                  jj=jj+1;
                  m(jj)=m(jj-1);
                end
              end
            else % jpg
              if isa(v.Movi,'uint16'); msgbox('Convert to 8 bit'); return; end
              if v.rgbyes; % size(size(Movi),2)>3
                a=v.Movi(:,:,:,j);
              else % 8 or 16 bit
               % lo=get(vh.minslider,'value');
                aa=double(v.Movi(:,:,j));
                % if isa(v.Movi,'uint16'); aa=aa-lo; hi=max(aa(:)); fac=65336/hi; aa=uint16(aa).*fac; end
                a=ind2rgb(aa,colormap);
              end
              % a=ind2rgb(aa,colormap);
              imwrite(a,f);
            end
            delete(htxt)
          end
          if strcmp(fmt,'avi');
            disp (['saving ' fname '.avi using ' comp ' compression...'])
            htxt=text(20,50,['saving ' fname '.avi using ' comp ' compression...'],...
              'color','red','fontsize',18);
            disp(['Saving ' fname '.avi using ' comp ' compression...'])
            pause (.1)
            try
              movie2avi(m,[pname fname],'FPS',fps,'compression',comp);
            catch
              errordlg(['AVI Error! ' comp ' compression. Save failed.']);
              disp(['AVI ' comp ' compression failed!']); disp('');
            end
          end
          clear m
        end
        try delete(htxt); catch end
        %v.Movi=Movi0;
        buttonvis

      case 'close'
        try
          if v.play; v.play=0; v.close=1;
          else close (vh.fig)
          end
        catch
          close(vh.fig)
        end
      case 'moveax2'
        pos=get(vh.ax2,'position');
        if pos(2)>.5; pos(2)=.2; else pos(2)=.85; end
        set(vh.ax2,'position',pos)
      case 'singlepixel'
        if v.rgbyes; return; end
        v.singlepixel=~v.singlepixel;
        if v.singlepixel
          m=getfig('Which figure for measurements?');
          v.singlepixelfig=m(1,1);
          v2=getappdata(v.singlepixelfig,'v');
        %  if size(v2.Movi)~=size(v.Movi)
        %    msgbox('Images are not the same size','replace'); return
        %  end
          prompt={'radius?' '8 neighbors? (0=no, or type first frame for linear fit?',...
            'Differentiate? (0=no; 1=yes)'}; title='Radius? Frame 1 for fit? Differentiate';
          lineno= 1; def={'0' '0' '0'};
          inp=inputdlg(prompt,title,lineno,def);
          rad=str2double(inp{1}); v.firstfit=str2double(inp{2}); v.dydata=str2num(inp{3});
          set(vh.singlepixel,'backgroundcolor','red')
          mx=get(vh.figsize,'max');
          set(vh.figsize,'value',0.9*mx)
          eval([mfilename ' figsize'])
          axes(vh.ax2)
          set(vh.ax2,'visible','on','userdata',rad)
          set(vh.ax2,'ylimmode','auto')
          %axes(vh.ax2)
          grid on
          line('xdata',[0 0],'ydata',[0 0],...
            'tag','singlepixelline',...
            'marker','none','markersize',4);
          line('xdata',[0 0],'ydata',[0 0],...
            'marker','none','tag','singlepixelfit'); % keeps ymin=0 even with ylimmode=auto

          set(vh.img,'ButtonDownFcn','')
          set(vh.img,'ButtonDownFcn',[mfilename ' singlepixel2'])
          setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
        else % turn off
          v.lastx=[]; v.lasty=[]; v.lastydata=[];
          set(vh.ax2,'visible','off')
          set(vh.singlepixel,'backgroundcolor',[0.83 0.82 0.78])
          delete(findobj(vh.fig,'type','line'))
          delete(findobj('tag','neighbors'))
          set(vh.img,'ButtonDownFcn',[mfilename ' pixval'])
          axes(vh.ax)
          set(vh.endothresh,'visible','off')
          set(vh.endothreshtxt,'visible','off')
          set(vh.figsize,'value',1)
          eval([mfilename ' figsize'])
        end
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

      case 'singlepixel2'
        dydata=v.dydata;
        xy=round(get(vh.ax,'currentpoint')); xpt=xy(1,1); ypt=xy(1,2);
        vh2=getappdata(v.singlepixelfig,'vh');
        v2=getappdata(vh2.fig,'v');
        Movi=v2.Movi;
        ffs=round(get(vh2.ffs,'value'));
        lfs=round(get(vh2.lfs,'value'));
        xdata=(1:lfs-ffs+1)';
        button=get(vh.fig,'selectiontype');
        if (strcmp(button,'normal'))
          %sz=size(Movi,3);
          rad=get(vh2.ax2,'userdata'); if isempty(rad); set(vh2.ax2,'userdata',0);end
          npix=4*rad*(rad+1)+1;
          omitzeros=0;
          if rad>0
            y1=xy(1,2)-rad; y2=xy(1,2)+rad; x1=xy(1,1)-rad; x2=xy(1,1)+rad;
            m=Movi(y1:y2,x1:x2,:);
            h=findobj(vh.fig,'type','rectangle');
            delete(h)
            rectangle('position',[x1-.5, y1-.5, 2*rad+1, 2*rad+1])
            nn=0;
            for j=ffs:lfs
              nn=nn+1;
              mm=m(:,:,j);
              if omitzeros
                mm(mm==0)=[];
                bw=mm>0; npix=sum(bw(:));
              end
              ydata(nn,1)=sum(mm(:))/npix;
            end
          else
            ydata=Movi(xy(1,2),xy(1,1),ffs:lfs);
            ydata=reshape(ydata,size(xdata,1),1);
          end

          % linear fit
          jj0=v.firstfit;
          if jj0
            y=double(ydata(jj0:end));
            x=(0:size(y,1)-1)';
            a0=(y(1)-y(end))/size(y,1); b0=y(1);
            opts=fitoptions('method','nonlinearleastsquares',...
              'StartPoint',[a0 b0]);
            ftype=fittype('a*x+b','coeff',{'a' 'b'});
            [yres]=fit(x,y,ftype,opts);
            yfit=yres.a*x+yres.b;
            xx=x+jj0;
          end

          h2=findobj(gcf,'tag','singlepixelline');
          hfit=findobj(gcf,'tag','singlepixelfit');
          if isempty(h2);
            axes(vh.ax2)
            prompt={'Marker? (none o s .)' 'Y axis: auto scale (1) or include origin (0)?'};
            title='Marker and Y axis scaling'; lineno=1; def={'none' '1'};
            inp=inputdlg(prompt,title,lineno,def);
            mk=inp{1}; yauto=str2num(inp{2});
            line('xdata',[0 0],'ydata',[0 0],...
              'tag','singlepixelline',...
              'marker',mk,'markersize',4)
            if ~yauto; line('xdata',[0 0],'ydata',[0 0],'marker','none'); end % dummy line
            set(vh.ax2,'xlim',[0 size(xdata,1)])
          end
          if dydata; ydata=diff(ydata); ydata=[0; ydata]; end
          set(findobj(gcf,'tag','singlepixelline'),...
            'xdata',xdata,'ydata',ydata)
          if jj0;set(hfit,'xdata',xx,'ydata',yfit,'marker','none','color','red'); end
          v.lastydata=ydata; v.lastx=xy(1,1); v.lasty=xy(1,2);
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          if jj0; neighbors(xpt, ypt); end

        else % right button
          clr=[rand/2 rand/2 rand/2];
          line(v.lastx,v.lasty,'marker','*','color',clr) % mark image
          axes(vh.ax2)
          line(xdata,v.lastydata,'color',clr) % draw line on graph
          %axes(vh.ax)
        end

      case 'rgbgaintxt' % reset
        % v.rgbgain=[1 1 1];
        set(vh.rgbgain,'value',1);
        eval([mfilename ' rgbgain'])
        %set(vh.rgbgaintxt,'string','1 1 1')
      case 'rgbgain'
        a=get(vh.rgbgain,'value'); % returns a cell array
        v.rgbgain=[a{1} a{2} a{3}];
        set(vh.rgbgaintxt,'string',[num2str(v.rgbgain(1)) ' : ' num2str(v.rgbgain(2)) ' : ' num2str(v.rgbgain(3))])
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        if ~v.play; eval([mfilename ' fs']); end
      case 'minmax' % LO & HI SLIDERS, non-RGB movie
        lohi=get(vh.ax,'clim')
        mn=get(vh.minslider); mx=get(vh.maxslider);
        loval=mn.Value; if loval<mn.Min; set(vh.minslider,'Min',loval); end
        rlo=floor(loval); 
        dlo=sign(loval-lohi(1));
        hival=mx.Value; % get(vh.maxslider,'value');
      
        if dlo % low slider moved
          loval=round(loval+(rlo==lohi(1))*dlo);
          if loval<mn.Min; set(vh.minslider,'Min',loval); end
          set(vh.minslider,'value',loval);
        else
          rhi=ceil(hival); dhi=sign(hival-lohi(2));
          hival=round(hival+(rhi==lohi(2))*dhi);
          if hival>mx.Max; set(vh.maxslider,'Max',hival); end
          set(vh.maxslider,'value',hival);
        end

        if loval>=hival;
          mx=max(v.Movi(:)); mn=min(v.Movi(:));
         % mx=255; if isa(v.Movi,'uint16'); mx=65536; end
          prompt={'Lo?' 'Hi?'}; title='Set Lo and Hi'; lineno=1;
          def={num2str(mn) num2str(mx)};
          inp=inputdlg(prompt,title,lineno,def);
          if isempty(inp); inp=def; end
          loval=str2double(inp{1}); hival=str2double(inp{2});
          if loval>=hival; hival=2*loval+(loval==0); end
          set(vh.minslider,'Min',loval,'Max',hival,'value',loval);
          set(vh.maxslider,'Min',loval,'Max',hival,'value',hival)
        end
        set(vh.minmaxmode,'string',[num2str(loval) ' : ' num2str(hival)])
        set(vh.ax,'clim',[loval hival])
        a=get(vh.img,'cdata');
        aa=find(a>hival); totsum=sum(a(aa));
        bw=a>hival; bwL=bwlabel(bw,4); nareas=max(bwL(:));
        blo=sum(sum(a<loval)); bhi=sum(sum(a>hival)); bok=sum(sum(a>=loval & a<=hival));
        str=[num2str(bok) ' pixels in range.',...
          'Pixel outliers: ' num2str(blo) '<min; ' num2str(bhi) '>max (tot=' num2str(totsum) ')' char(10),...
          num2str(nareas) ' areas'];
        disp(str)
        
      case 'minmaxmode'
        v.minmaxmode=~v.minmaxmode;
       if v.minmaxmode % auto
          set(vh.ax,'climmode','auto')
          [lohi]=get(vh.ax,'clim')
          set(vh.minmaxmode,'string',[num2str(lohi(1)) ' ' num2str(lohi(2))])
          str='off';
        else
          lo=min(v.Movi(:)); hi=max(v.Movi(:));
          set(vh.ax,'clim',[lo hi])
          eval([mfilename ' minmax'])
          str='on';
        end
        set(vh.minslider,'visible',str)
        set(vh.maxslider,'visible',str)
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
      case 'miscpopup'
        val=get(vh.miscpopup,'value');
        switch val
          case 1 % title
            return
          case 2 % clock
            inp=questdlg('circle or rectangle?','Clock shape?','circle','rectangle','circle');
            shape=0; if strcmp(inp,'rectangle'); shape=1; end
            v.play=0; setappdata(vh.fig,'v',v);
            set(vh.figsize,'value',1)
            eval([mfilename ' figsize'])
            hdlg=msgbox('Select region to contain clock','Getregion','replace');
            uiwait(hdlg);
            len=length(v.list);
            v.square=~shape; setappdata(vh.fig,'v',v)
            set(vh.fig,'userdata','hello');
            bbgetrect % draw rectangle, move it and click to close
            waitfor(vh.fig,'userdata')
            v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
            sq=v0.pos; % getappdata(0,'pos'); % round(v.pos);
            if ~shape; % circle
              sq=round(v.pos); sq0=sq;
              x=sq(1)+sq(3)/2; y=sq(2)+sq(4)/2; rad=sq(3)/2;
              prompt={'How many frames/revolution?' 'Color?'};
              title='Round clock'; lineno=1; def={num2str(len), '1 1 1'};
              vals=inputdlg(prompt,title,lineno,def); if isempty(vals); return; end
              fpr=str2double(vals{1}); clr=str2num(vals{2});
              pos=[x-rad y-rad rad*2 rad*2]; twohands=(len>=fpr);
              rev=60; step=rev/fpr;
            else % rectangle
              sq0=sq;
            end
            buttonvis('abort')
            Movi2=v.Movi;
            szx=size(Movi2,1); szy=size(Movi2,2);
            for j=1:len
              if getappdata(0,'abort'); return; end
              if ~shape
                tt=(j-1)*step; theta=2*pi*tt/rev-pi/2;
                ttot=j*step/(12*rev); theta3=2*pi*ttot-pi/2;
                x2=x+0.9*rad*cos(theta); y2=y+0.9*rad*sin(theta);
                x3=x+0.5*rad*cos(theta3); y3=y+0.5*rad*sin(theta3);
              else
                sq(3)=sq0(3)*j/len;
              end
              if v.rgbyes
                try
                  a0(:,:,1)=v.rgbgain(1)*v.Movi(:,:,1,j);
                catch
                  keyboard;
                end
                a0(:,:,2)=v.rgbgain(2)*v.Movi(:,:,2,j);
                a0(:,:,3)=v.rgbgain(3)*v.Movi(:,:,3,j);
                set(vh.img,'cdata',a0);
                % set(vh.img,'cdata',v.Movi(:,:,:,j));
              else
                set(vh.img,'cdata',v.Movi(:,:,j));
              end
              drawnow
              if ~shape % circle
                hclock(1)=rectangle('position',pos,'curvature',[1 1],'edgecolor',clr);
                hclock(2)=line([x;x2],[y;y2],'color',clr);
                if twohands; hclock(3)=line([x;x3],[y;y3],'color',clr); end
              else
                try
                  hclock(1)=rectangle('position',sq0,'edgecolor','red');
                  %  disp(sq)
                  hclock(2)=rectangle('position',sq,'facecolor','white'); drawnow
                catch
                  disp('Clock error');
                end
              end
              F=getframe(vh.ax); % drop into image
              a=F.cdata;
              if v.rgbyes;
                sz1=min(szx,size(a,1)); sz2=min(szy,size(a,2));
                Movi2(:,:,:,j)=a(1:sz1,1:sz2,:); % bbblock(sq(1),sq(2),Movi2(:,:,:,j),a);
              else
                a=rgb2gray(a);
                Movi2(:,:,j)=a(1:szx,1:szy);
              end
              delete(hclock);
            end
            buttonvis
            v.Movi2=Movi2;
            setappdata(vh.fig,'v',v);
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' clock_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname]) % to make nargin=3

          case 3 % clone
            f1=round(get(vh.ffs,'value')); f2=round(get(vh.lfs,'value'));
            if v.rgbyes
              v.Movi2=v.Movi(:,:,:,f1:f2);
            else
              v.Movi2=v.Movi(:,:,f1:f2);
            end
            set(vh.fs,'value',1);
            v0.rgbyes2=v.rgbyes;
            v.list2=v.list(f1:f2); setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' clone_' num2str(v0.fignum)];
            eval([mfilename figname figname figname])

          case 4 % resize
            szx=size(v.Movi,2); szy=size(v.Movi,1); szz=size(v.Movi,3+v.rgbyes);
            sz=get(0,'screensize'); mxx=sz(3); mxy=sz(4);
            mxfac=floor(min(mxx/szx, mxy/szy)*10)/10;
            prompt={['Zoom factor? (max=' num2str(mxfac) ')'],...
              'pad x (add pixels on right side)','pad y (add pixels on bottom)'};
            def={'1','0','0'};
            lineno=1; title='Zoom or Pad? (not both)';
            inp=inputdlg(prompt,title,lineno,def); if isempty(inp); return; end
            zf=str2double(inp{1}); padx=str2double(inp{2}); pady=str2double(inp{3});
            if zf==1 % pad
              Movi=v.Movi;
              b=uint8(0);
              if padx
                b=b(ones(1,szy),ones(1,padx),ones(1,szz));
                if v.rgbyes; b=b(ones(1,szy),ones(1,padx),ones(1,3),ones(1,szz));end
                Movi=[v.Movi b];
              end
              if pady
                szx=size(Movi,2);
                b=b(ones(1,pady),ones(1,szx),ones(1,szz));
                if v.rgbyes; b=b(ones(1,pady),ones(1,szx),ones(1,3),ones(1,szz));end
                Movi=[Movi; b];
              end
              v.Movi2=Movi;
            elseif zf ~= 1 % imresize
              interpmode=questdlg('Zoom interpolation mode? (nearest is fastest)','Interpolation mode',...
                'nearest','bilinear','bicubic','nearest');
              buttonvis('abort')
              zoomfac=zf;
              if v.rgbyes; Movix=imresize(v.Movi(:,:,:,1),zoomfac);
              else Movix=imresize(v.Movi(:,:,1),zoomfac); end
              rows=size(Movix,1); cols=size(Movix,2); len=length(v.list); % just to get final size of img
              v.Movi2=uint16(0); if isa(v.Movi,'uint8'); v.Movi2=uint8(0); end
              if v.rgbyes; v.Movi2= v.Movi2(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
              else v.Movi2= v.Movi2(ones(1,rows),ones(1,cols),ones(1,len)); end % resizing uints
              htxt=text(20,50,'...','fontsize',32,'color','red');
              for j=1:len
                if getappdata(0,'abort'); return; end
                disp([num2str(j) '/' num2str(length(v.list))])
                set(htxt,'string',[num2str(j) '/' num2str(length(v.list))]); pause(.1)
                if v.rgbyes; v.Movi2(:,:,:,j)=imresize(v.Movi(:,:,:,j),zoomfac,interpmode);
                else
                  try
                    v.Movi2(:,:,j)=imresize(v.Movi(:,:,j),zoomfac,interpmode);
                  catch
                    keyboard;
                  end
                end
              end
            end % zf ==1
            buttonvis
            v.list2=v.list;
            % delete (htxt);
            v0.rgbyes2=v.rgbyes;
            setappdata(vh.fig,'v',v);

            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' resize_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 5 % montage
            h2=findobj(0,'type','figure','visible','off'); delete(h2)
            m=getfig('Which figs to montage? (enter just one -> break out each frame)'); % col1=handle, col2=fignum
            scrnsz=get(0,'screensize'); maxwd=scrnsz(1,3);
            prompt={'Maximum width?(pixels)'}; title='Max width of montage?';
            lineno=1; def={num2str(maxwd)};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            %nfigs=size(m,1);
            maxwd=str2num(inp{1});
            buttonvis('abort'); drawnow
            ok=0; widest=0; name=''; minval=1e12; nn=3;
            for jj=1:size(m,1) % get sizes of image stacks
              name=[name '_' num2str(m(jj,2))];
              vv=getappdata(m(jj,1),'v');
              a=vv.Movi; % getappdata(mm(jj,1),'Movi');
              mn=min(a(:)); if mn<minval; minval=mn; end
              if size(size(a),2)==4; nn=3;
              elseif isa(a,'uint8'); nn=1; elseif isa(a,'uint16'); nn=2; end
              if ~ok; ok=nn; else if nn~=ok; ok=-1; end; end

              mm(jj,2)=size(a,2); % X
              widest=max(mm(jj,2),widest);
              mm(jj,3)=size(a,1); % Y
              mm(jj,4)=length(vv.list);
            end
            if ok<1; h2=msgbox('Images must all be the same format','replace');
              waitfor(h2); buttonvis; return; end

            switch size(mm,1)
              case 1 % break out single movie to tiles
                sz=size(a); szx=sz(2); szy=sz(1);
                maxcol=floor(maxwd/szx); xtot=maxcol*szx;
                maxrow=ceil(size(a,3+v.rgbyes)/maxcol); ytot=maxrow*szy;
                Movi2=uint8(0); if isa(v.Movi,'uint16'); Movi2=uint16(0); end
                Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,1));
                if v.rgbyes; Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,3),ones(1,1)); end
                xnow=1; ynow=1; nn=0; list2={''};
                for j=1:maxrow % this is breaking out single movie
                  for k=1:maxcol
                    nn=nn+1;
                    disp(nn)
                    if nn<=sz(end)
                      little=a(:,:,nn); if v.rgbyes; little=a(:,:,:,nn); end
                      if size(size(a),2)==4
                        Movi2=bbblock(xnow,ynow,Movi2,little);
                      else
                        Movi2=bbblock(xnow,ynow,Movi2,little);
                      end
                    end
                    xnow=xnow+size(a,2);
                  end
                  xnow=1;
                  ynow=ynow+size(a,1);
                end
              otherwise % montage 2 or more movies
                maxwd=max(maxwd,max(mm(:,2))); % max width must be >= widest image
                xnow=1; ynow=1; mxy=0; xtot=0; mxx=0;
                for jj=1:size(mm,1) % figure positions of each image stack
                  if xnow+mm(jj,2)>maxwd % start new row
                    ynow=ynow+mxy; mm(jj,6)=ynow; mm(jj,5)=1;
                    xnow=mm(jj,2); mxy=mm(jj,3); mxx=mm(jj,2);
                  else
                    mxy=max(mxy,mm(jj,3)); mxx=mxx+mm(jj,2);
                    mm(jj,5)=xnow; mm(jj,6)=ynow; xnow=xnow+mm(jj,2); xtot=max(xtot,mxx);
                  end
                end
                xtot=max(widest,min(xtot,maxwd));
                ytot=ynow+mxy; len=max(mm(:,4));
                Movi2=uint16(0); if isa(vv.Movi,'uint8'); Movi2=uint8(0); end
                Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,len));
                Movi2=Movi2+64000;
                if v.rgbyes; Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,3),ones(1,len)); end
                if min(v.Movi(:))<0; Movi2=double(Movi2); end
                %xnow=1; ynow=1; lasty=0;
                minval=1e12;
                for jj=1:size(mm,1)
                  if getappdata(0,'abort'); return; end
                  (num2str(size(mm,1)-jj))
                  vv=getappdata(m(jj,1),'v');
                  little=vv.Movi;
                  mn=min(little(:)); if mn<minval; minval=mn; end
                  %sz=size(little); %szx=sz(1,2); szy=sz(1,1);
                  xnow=mm(jj,5); ynow=mm(jj,6);
                  for k=1:mm(jj,4) % len
                    disp([num2str(jj) '/' num2str(size(mm,1)) ' : ' num2str(k) '/' num2str(mm(jj,4))])
                    if v.rgbyes %size(size(little),2)==4
                      Movi2(:,:,:,k)=bbblock(xnow,ynow,Movi2(:,:,:,k),little(:,:,:,k));
                    else
                      try
                        Movi2(:,:,k)=bbblock(xnow,ynow,Movi2(:,:,k),little(:,:,k));
                      catch
                        disp(lasterr);
                      end
                    end
                    list2{k}=name;
                  end
                end
            end % switch/case
            Movi2(Movi2==64000)=minval-1;
            buttonvis
            v.Movi2=Movi2; v.list2=list2; v0.rgbyes2=v.rgbyes;
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' montage_' name];
            eval([mfilename figname figname figname])

          case 6 % subtract frame(s) from others (or vice versa)
            if v.rgbyes; return; end
            % lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
            prompt={'Bkg images will be averaged. First bkg image?',...
              'Last bkg image?',...
              'Number of iterations?',...
              'Subtract all non-zero pixels (0) or perform imregionalmax (1)?',...
              'Keep bkg values? (0=no; 1=yes)',...
              'Output image: how to display negative values: as negative (0), zero (1) or make v-lut image (2)?'};
            title='Subtract base image from others';
            lineno=1; def={'1' '1' '1' '0' '0' '0'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp{1}); return; end
            firstbkg0=str2double(inp{1});
            lastbkg0=str2double(inp{2});
            numiter=str2double(inp{3});
            doimreg=str2num(inp{4});
            keepbkg=str2num(inp{5});
            negvals=str2num(inp{6});
            framesperiter=floor(size(v.Movi,3)/numiter);
            v.list2={}; nn=0;
            Mall=double(v.Movi(:,:,1:numiter)*0);
            a=v.Movi(:,:,1); 
            bw=a~=min(a(:));
            for iter=1:numiter % get average bkg frame
              firstbkg=(iter-1)*framesperiter+firstbkg0;
              lastbkg=(iter-1)*framesperiter+lastbkg0;
              f1=lastbkg+1; % (iter-1)*framesperiter+1;
              f2=iter*framesperiter;
              
              M1=double(v.Movi(:,:,firstbkg)); % get avg bkg
              for j=firstbkg+1:lastbkg
                M1=M1+double(v.Movi(:,:,j));
              end
              M1=M1/(lastbkg-firstbkg+1); % avg bkg this iteration
              if keepbkg; nn=nn+1; Mall(:,:,nn)=M1; v.list2(nn)={'bkg'}; end
              for j=f1:f2; % subtract avg bkg from these frames
                nn=nn+1;
                Mall(:,:,nn)=double(v.Movi(:,:,j))-M1;
                v.list2(nn)=v.list(j);
              end % for j=f1...
            end % for iter=1:numiter
            
            M1=Mall(:,:,1);
            for j=2:size(Mall,3);
              M1=M1+Mall(:,:,j);
            end
            M1=M1./size(Mall,3); % average
            
           % bw=M1~=0;
            if doimreg      %   imregionalmax on average image to find brightest single pixels
              bw=imregionalmax(M1,8);
              nsum=0; ok=1; % multiple iterations of bwmorph remove in order to shrink spots
              while ok
                bw=bwmorph(bw,'shrink'); % shrink each spot to a single pixel
                nsumnew=sum(bw(:));
                if nsumnew == nsum; ok=0; end
                nsum=nsumnew;
              end % while ok
            end % if imreg
            
            [y x]=find(bw>0); %find(a>=loval);
            %       xyz(:,1:2)=[x y];
            z=[];
            for j=1:size(Mall,3)
              b=Mall(:,:,j);
              z0=b(bw>0);
              z(:,j)=z0;
              if doimreg; b(bw==0)=0; Mall(:,:,j)=b; end
            end
            %          z(:,end+1)=mean(z')';
            xyz=[x y z];
            xyz=sortrows(xyz,-size(xyz,2));
          %  xyz=xyz';
            v.zdata=double(xyz); v.z2=[]; v.zavg=[]; v.xdata=[];
            v.newname='pixvals_';
            v0.callingfig=vh.fig;
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            bbplot % xyz
            msgbox(['Col 1=x; Col 2=y; Col 3=vals for frame ' num2str(f1) ',etc.'])
            v0=getappdata(0,'v0');
            v=getappdata(v0.callingfig,'v');
            
            switch negvals
              case 0 % keep negative
                bkg=min(Mall(:))-1;
                for j=1:size(Mall,3); 
                  a=Mall(:,:,j); a(~bw)=bkg; Mall(:,:,j)=a;
                end
                v.Movi2=Mall;
                 v0.callingfig=vh.fig;
                figname=[' subtract_frames_' num2str(v0.fignum)];
                setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
                eval([mfilename figname figname figname])
              case 1 % make them zero
                %if ~makevlut;
                v.Movi2=uint16(Mall);
                v0.callingfig=vh.fig;
                figname=[' subtract_frames_' num2str(v0.fignum)];
                setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
                eval([mfilename figname figname figname])
                % return
              case 2 % vlut
                mn=round(min(Mall(:))); % this better be <0
                mx=round(max(Mall(:))); % and this >0
                mx2=max([abs(mn) abs(mx)]);
                M=round(Mall+mx2);
                % next line makes colorlut symmetrical about mx2
                M(1,1,1)=0; if abs(mn)>abs(mx); M(1,1,1)=mx2*2; end
                if isa(v.Movi,'uint8')
                  vrange=2*mx2;
                  if vrange>256;
                    f=128/mx2; % vrange;
                    M=round(M.*f);
                    mx2=mx2*f;
                  end
                  M=uint8(M);
                elseif isa(v.Movi,'uint16')
                  M=uint16(M);
                end
                
                v.list2=v.list; %(lo:hi); %end
                v.Movi2=M;
                setappdata(vh.fig,'v',v);
                v0.callingfig=vh.fig; setappdata(0,'v0',v0)
                
                zv=127; % make v.lut
                a=zeros(256,3); ared=(0:128)'; ablue=(128:-1:0)';
                a(128:end,1)=ared; a(1:129,3)=ablue;
                a=a/max(a(:));
                save([v0.homedir 'color\v.lut'],'a', '-ASCII')
                v.mapname2='v';
                setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
                
                str=[' All_minus_avg(' inp{1} '-' inp{2} ')'];
                eval ([mfilename str str str]) % to make nargin=3
                msgbox(['NOTE! The new colorlut is named v.lut.',...
                  'Note that ' num2str(mx2) ' =zero. To keep pixels with ',...
                  'this value black, move the 2 brightness sliders symmetrically.',...
                  'With v.lut applied, BLUE pixels are NEGATIVE (dimmer than base images), ',...
                  'and red pixels are positive (brighter than base images). ',...
                  'Pixels that did not change have a value of ' num2str(mx2),...
                  '. Apply the ColorBar (click ClrBar)'],'replace');
            end % switch negvals
            
          case 7 % drop labels
            % if v.rgbyes; return; end
            set(vh.figsize,'value',1); %setappdata(vh.fig,'vh',vh)
            eval([mfilename ' figsize'])
            len=length(v.list); frame=get(vh.fs,'value');
            str=['image to drop into? (1-' num2str(len) ')'];
            prompt={['First ' str] ['Last ' str]};
            title='Drop labels'; lineno=1; def={num2str(frame) num2str(frame)};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            fi=str2double(inp{1}); la=str2double(inp{2});
            if fi>la || fi<1 || la>len; return; end
            buttonvis('abort') % setup
            for j=fi:la
              if getappdata(0,'abort'); return; end
              disp (['Drop labels into frame #' num2str(j)])
              aa=v.Movi(:,:,j);
              if v.rgbyes;
                aa(:,:,1)=v.rgbgain(1)*v.Movi(:,:,1,j);
                aa(:,:,2)=v.rgbgain(2)*v.Movi(:,:,2,j);
                aa(:,:,3)=v.rgbgain(3)*v.Movi(:,:,3,j);
              end
              set(vh.img,'cdata',aa)
              F=getframe(vh.ax); %,sq);
              a=F.cdata;
              if v.rgbyes; v.Movi(:,:,:,j)=a(1:end-1,1:end-1,:);
              else
                a=rgb2gray(a);
                if isa(v.Movi,'uint16'); a=uint16(a); end
                v.Movi(:,:,j)=a(1:size(v.Movi,1),1:size(v.Movi,2));
                %       v.Movi(:,:,j)=a(1:end-1,1:end-1);
              end
            end
            buttonvis
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            eval([mfilename ' erase'])

          case 8 % concatenate
            hfig0=gcf;
            mm=getfig('Which figures to concatenate?');
            if isempty(mm); return; end
            nfigs=size(mm,1); if nfigs<2; return; end
            buttonvis('abort'); drawnow
            for j=1:nfigs % get max size, number of frames
              v=getappdata(mm(j,1),'v');
              sz=size(v.Movi); if size(sz)<3; sz=[sz 1]; end
              cc(j,1)={class(v.Movi)};
              szall(j,:)=sz;
            end
            szmax=max(szall); npics=sum(szall(:,3));
            newmovi=zeros(szmax(1),szmax(2),npics);
            nnext=1; newlist=[]; names='';
            for j=1:nfigs % load up the new movie
                names=[names '_' num2str(mm(j,2))];
                v=getappdata(mm(j,1),'v');
                newlist=[newlist v.list];
                newmovi(1:szall(j,1), 1:szall(j,2),nnext:nnext+szall(j,3)-1)=v.Movi;
                nnext=nnext+szall(j,3);
            end    
            switch cc{j,1} % class
                case 'uint8'; newmovi=uint8(newmovi);
                case 'uint16'; newmovi=uint16(newmovi);
            end
            figure(hfig0)
            buttonvis
            v=getappdata(hfig0,'v'); vh=getappdata(hfig0,'vh');            
            v.Movi2=newmovi; v.list2=newlist;
            setappdata(hfig0,'v',v)
            v0.callingfig=hfig0; setappdata(0,'v0',v0)
            figname=[' concatentate_' names];
            eval([mfilename figname figname figname])
          
          case 9 % flip
            flipit=questdlg('Flip Vertical, Horizontal, or Both?','Flip images','Vert','Horiz','Both','Vert');
            for j=1:length(v.list);
              if ~strcmp(flipit,'Horiz'); v.Movi(:,:,j)=v.Movi(end:-1:1,:,j); end
              if ~strcmp(flipit,'Vert'); v.Movi(:,:,j)=v.Movi(:,end:-1:1,j); end
            end
            v.play=1;
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            playmovie

            case 10 % 2FrameDiff
           % str=['This routine will plot the values of 2 images - one value on the x axis,',...
           %   ' and the other on the y axis (values less than low cutoff in both are ignored). The images are set by the first & last frame sliders.',...
           %   ' Do you want to continue?'];
           % inp=questdlg(str,'2 Frame Diff');
           % if ~strcmp(inp,'Yes'), return; end
           bkg=min(v.Movi(:));
           
            inp=inputdlg({'Background value?'},'2FrameDiff',1,{num2str(bkg)});
            bkg=str2num(inp{1});
            f1=round(get(vh.ffs,'value')); f2=round(get(vh.lfs,'value'));
            loval=get(vh.minslider,'value');
            m1=double(v.Movi(:,:,f1)); m2=double(v.Movi(:,:,f2));
            m1=reshape(m1,[],1); m2=reshape(m2,[],1);
           % idx1=find(m1<=loval);idx2=find(m2<=loval);
            idx1=find(m1==bkg);idx2=find(m2==bkg);
            idx=unique([idx1;idx2]);
            m1(idx)=[];
            m2(idx)=[];
          
            %a=m1+m2; m1(a<=loval)=[]; m2(a<=loval)=[];         
            v.zdata=double([m1 m2]);           
            v.z2=v.zdata;
            v.zavg=[]; v.newname='2FrameDiff';
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            bbplot

          case 11 % Digitize
            msg={'Begin by digitizing 3 points: Origin, known X value, known Y value. ' ,...
              'Left click to select point, right click to finish, ',...
              'Then you will be asked to type in the values of these points. ',...
              'After this, you can begin digitizing. Left click to select, ',...
              'right click to end. Values will be displayed in the editor. ',...
              'You can choose to do another series, or quit.'};
            h2=msgbox(msg,'replace');
            waitfor(h2)
            [px py]=getpts;
            dpx=px(2)-px(1); dpy=py(3)-py(2); px0=px(1); py0=py(1);
            prompt={'What were the values?; Origin X', 'Origin Y' 'X' 'Y'};
            title='Digitize'; lineno=1; def={'0' '0' '100' '100'};
            inp=inputdlg(prompt,title,lineno,def);
            x0=str2double(inp{1}); y0=str2double(inp{2}); x1=str2double(inp{3}); y1=str2double(inp{4});
            xpp=(x1-x0)/dpx; ypp=(y1-y0)/dpy;
            ok=1;
            while ok
              [px py]=getpts;
              px=px(1:end-1); py=py(1:end-1);
              x=(px-px0)*xpp; y=(py-py0)*ypp;
              disp(x)
              dlmwrite([v0.homedir 'junk.txt'],[x y],'\t')
              edit ([v0.homedir 'junk.txt'])
              inp=questdlg('Do another?', 'Do another?');
              ok=0;
              if strcmp(inp,'Yes'); ok=1; end
            end

          case 12 % cut/fill
            v.play=0; setappdata(vh.fig,'v',v)
            a=round(getrect); % returns x,y,wd,ht
            lastrect=v0.lastrect;
            if isempty(lastrect); lastrect=a; end
            a(3)=a(1)+a(3); a(4)=a(2)+a(4);
            prompt={'Fill color value?',...
              'Fill inside(0) or outside (1) selectedregion?',...
              'Fill this image only (0) or all images (1)',...
              ['X Left? Type 0 to use last rectangle: (' num2str(lastrect) '}'],...
              'Y Top' 'X Right' 'Y Bottom'};
            defans={'0' '0' '1',...
              num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4))};
            aa=inputdlg(prompt,'Cut : Fill',1,defans);
            if isempty(aa); return; end
            if strcmp(aa{4},'0'); a=lastrect;
            else
              a(1)=max(1,str2double(aa{4})); a(2)=max(1,str2double(aa{5}));
              a(3)=min(size(v.Movi,2),str2double(aa{6})); a(4)=min(size(v.Movi,1),str2double(aa{7}));
            end
            v0.lastrect=a;
            jmin=round(get(vh.ffs,'value')); jmax=round(get(vh.lfs,'value'));
            fillit=round(str2double(aa{1})); fillout=str2double(aa{2}); dest=str2double(aa{3});
            if dest==1; % all frames
              if ~v.rgbyes
                if fillout % fill outside
                  for jj=jmin:jmax; % 1:size(Movi,3)
                    bb=v.Movi(a(2):a(4),a(1):a(3),jj);
                    v.Movi(:,:,jj)=0;
                    v.Movi(:,:,jj)=bbblock(a(1),a(2),v.Movi(:,:,jj),bb);
                  end
                else
                  v.Movi(a(2):a(4),a(1):a(3),jmin:jmax)=fillit;
                end
              else
                v.Movi(a(2):a(4),a(1):a(3),:,jmin:jmax)=fillit;
              end
            else
              framenum=round(get(vh.fs,'value'));
              if ~v.rgbyes
                v.Movi(a(2):a(4),a(1):a(3),framenum)=fillit;
              else
                v.Movi(a(2):a(4),a(1):a(3),:,framenum)=fillit;
              end
            end
            v.play=1;
            setappdata(vh.fig,'v',v)
            playmovie

          case 13 % move/copy
            v.play=0; setappdata(vh.fig,'v',v)
            v0.pos=[]; v0.pos0=[]; setappdata(0,'v0',v0)
            set(vh.fig,'userdata','hello'); % set(hfig,'interruptible','on');
            bbgetrect % draw rectangle, move it and click to close
            waitfor(vh.fig,'userdata')
            v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
            a=v0.pos0; % original rect (x y wd ht)
            % a=[a(1) a(1)+a(3)-1 a(2) a(2)+a(4)-1];
            a=[a(2) a(2)+a(4)-1 a(1) a(1)+a(3)-1];
            b=v0.pos; % new rect
            % b=[b(1) b(1)+b(3)-1 b(2) b(2)+b(4)-1];
            b=[b(2) b(2)+b(4)-1 b(1) b(1)+b(3)-1];
            prompt={'Fill color value? (negative number to leave intact)',...
              'Apply to this image only (0) or all images (1)'}; % ,...
            def={'0' '1'}; %,...
            inp=inputdlg(prompt,'Cut : Move',1,def);
            if isempty(inp); return; end
            fillit=str2num(inp{1}); dest=str2num(inp{2});
            frame=round(get(vh.fs,'value'));
            f1=frame; f2=frame; if dest; f1=1; f2=size(v.list,2); end
            for j=f1:f2
              if ~v.rgbyes
                Movi=v.Movi; if length(v.list)==1; Movi(:,:,2)=Movi; end            
                cut=Movi(a(1):a(2),a(3):a(4),j);
                if fillit>=0; Movi(a(1):a(2),a(3):a(4),j)=fillit; end
                Movi(b(1):b(2),b(3):b(4),j)=cut;
                if length(v.list)==1; v.Movi=Movi(:,:,1); end
              else
                cut=v.Movi(a(1):a(2),a(3):a(4),:,j);
                if fillit>=0; v.Movi(a(1):a(2),a(3):a(4),:,j)=fillit; end
                v.Movi(b(1):b(2),b(3):b(4),:,j)=cut;
              end
            end
            v.play=1;
            setappdata(vh.fig,'v',v)
            playmovie
          case 14 % 3d
            if v.rgbyes
              hdlg=msgbox('Convert to 8 bit first','replace');
              uiwait(hdlg); return
            end
            if ~v.srf % make 3d
              v.play=0;
              a=round(getrect);
              xl=a(1);xu=xl+a(3);yl=a(2);yu=yl+a(4);
              v.Movi2=double(v.Movi(yl:yu,xl:xu,:));
              v.srf=1;
              setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)
              v0.callingfig=vh.fig; setappdata(0,'v0',v0)
              str=[' 3D_' num2str(v0.fignum)];
              eval([mfilename str str str])
              v.srf=0;
              setappdata(vh.fig,'v',v);
            else % make 3d movie
              figsize=get(vh.figsize,'value');
              prompt={'Advance movie? (y/n)' 'Number of frames?' 'Azimuth start?' 'Azimuth end?',...
                'Elevation start?' 'Elevation end?'};
              def={'y' '30' '0' '180' '38' '145'};
              str=inputdlg(prompt,'Label',1,def); % str=cell array
              if isempty(str); return; end
              Movi=v.Movi;
              advance=strcmp(str{1},'y'); nsteps=str2double(str{2});
              az0=str2double(str{3}); azend=str2double(str{4});
              el0=str2double(str{5}); elend=str2double(str{6});
              fi=round(get(vh.ffs,'value')); la=round(get(vh.lfs,'value'));

              daz=(azend-az0)/(nsteps-1); del=(elend-el0)/(nsteps-1);
              zoomfac=2;
              Movi2=uint8(0); sx=figsize*zoomfac*size(Movi,1); sy=figsize*zoomfac*size(Movi,2);
              Movi2=Movi2(ones(1,sx),ones(1,sy),ones(1,3),ones(1,nsteps));
              Movi2(:,:,1,:)=212; Movi2(:,:,2,:)=208; Movi2(:,:,3,:)=200;
              Mframe=fi;
              minix=1e9; miniy=1e9; maxix=0; maxiy=0;
              axis vis3d
              for nn=1:nsteps
                Mframe=Mframe+1; if Mframe>la; Mframe=fi; end
                disp ([num2str(nn) '/' num2str(nsteps)])
                if advance;
                  set(vh.img,'zdata',Movi(:,:,Mframe),'cdata',Movi(:,:,Mframe)); drawnow
                end
                az=az0+daz*(nn-1); % azimuth
                el=el0+del*(nn-1); el=el-(round(el)==180); % elevation
                view(az,el); drawnow

                F=getframe; % F is structure array containing RGB image
                mm=F.cdata; % mm is RGB image, uint8 - with 'axis vis3d' these are diff. sizes
                maxix=max(size(mm,1),maxix); maxiy=max(size(mm,2),maxiy);
                minix=min(size(mm,1),minix); miniy=min(size(mm,2),miniy);
                % The image captured by 'getframe' changes size with different rotations.
                % This is because 'axis vis3d' holds the aspect ratio constant.
                % Thus, each new frame must be centered in Movi2 (ssx,sx,dx,xmin, etc).
                ssx=min(sx,size(mm,1)); ssy=min(sy,size(mm,2));
                dx=max(0,round((sx-ssx)/2)); dy=max(0,round((sy-ssy)/2));
                xmin=max(1,dx); xmax=ssx+dx-(dx>0); ymin=max(1,dy); ymax=ssy+dy-(dy>0);
                Movi2(xmin:xmax,ymin:ymax,:,nn)=mm(1:ssx,1:ssy,:);
                v.list2{nn}=['3d.' num2str(az) '.' num2str(el)];
              end
              % xmin=round((sx-minix)/2); xmax=xmin+minix-2;
              % ymin=round((sy-miniy)/2); ymax=ymin+miniy-1;
              xmin=round((sx-maxix)/2); xmax=xmin+maxix-2;
              ymin=round((sy-maxix)/2); ymax=ymin+maxiy-1;
              Movi2=Movi2(xmin:min(xmax,sx),ymin:min(ymax,sy),:,:);
              v.Movi2=Movi2;
              v.srf=0; v.rgbyes=1;
              v0.callingfig=vh.fig;
              setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
              eval([mfilename ' 3dmovie' ' 3dmovie' ' 3dmovie'])
              v.srf=1; v.rgbyes=0; setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            end

          case 15 % revorder
            nmax=length(v.list);
            list2=v.list;
            for j=1:floor(nmax/2);
              jj=nmax-j+1; v.list(jj)=v.list(j); v.list(j)=list2(jj);
              if ~v.rgbyes
                a=v.Movi(:,:,j); v.Movi(:,:,j)=v.Movi(:,:,jj); v.Movi(:,:,jj)=a;
              else
                a=v.Movi(:,:,:,j); v.Movi(:,:,:,j)=v.Movi(:,:,:,jj); v.Movi(:,:,:,jj)=a;
              end
            end
            n1=round(get(vh.ffs,'value')); n2=round(get(vh.lfs,'value'));
            n2new=nmax-n1+1; n1new=nmax-n2+1;
            set(vh.ffs,'value',n1new); set(vh.lfs,'value',n2new);
            set (vh.ffstxt,'string',['First ' num2str(n1new)]);
            set (vh.lfstxt,'string',['Last ' num2str(n2new)]);
            setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh); setappdata(0,'v0',v0)

          case 16 % reverse color
            v.Movi=max(v.Movi(:))-v.Movi;
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          case 17 % interp framesf
            prompt={'Insert how many frames between each existing frame?'};
            title='Interpolate frames'; def={'2'}; lineno=1;
            inp=inputdlg(prompt,title,lineno,def);
            ins=str2double(inp{1});
            len=size(v.Movi,3); addit=(len-1)*ins;
            ngap=ins+1;
            v.Movi2=v.Movi*0;
            v.Movi2(:,:,end+1:end+addit)=0;
            v.Movi2(:,:,end)=v.Movi(:,:,end);
            for j=1:len-1
              m1=double(v.Movi(:,:,j)); m2=double(v.Movi(:,:,j+1));
              v.Movi2(:,:,(j-1)*ngap+1)=v.Movi(:,:,j);
              v.list2=v.list(j);
              for k=1:ins
                frame=(j-1)*ngap+k+1;
                v.Movi2(:,:,frame)=uint16(((ngap-k)*m1+k*m2)/ngap);
                v.list2(frame)={[v.list{j} '+' num2str(k)]};
              end % for k
            end % for j
            v.list2(end+1)=v.list(end);
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' interp_frames_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])
       
          case 18 % cull selected frames
            prompt={'Cull initial n' 'Keep how many?' 'Cull how many?'};
            title='Cull selected frames'; lineno=1; def={'0' '1' '1'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            n0=str2num(inp{1}); n1=str2num(inp{2}); n2=str2num(inp{3});
            v.list2={}; v.Movi2=v.Movi*0; nold=0; nnew=0; sz=n1+n2;
            nnew=0; nold=n0;
            while nold<length(v.list)
              nold=nold+1; ntest=rem(nold-n0,sz);
              if ntest>0 & ntest<=n1 %     nold-floor(nold/sz)*sz<= n1
                nnew=nnew+1;  v.list2(nnew)=v.list(nold);
                if v.rgbyes; v.Movi2(:,:,:,nnew)=v.Movi(:,:,:,nold);
                else; v.Movi2(:,:,nnew)=v.Movi(:,:,nold);
                end % if v.rgbyes...
              end % if ntest...
            end % while nold...
            if v.rgbyes; v.Movi2=v.Movi2(:,:,:,1:nnew);
            else; v.Movi2=v.Movi2(:,:,1:nnew); end 
              v0.rgbyes2=v.rgbyes;
            setappdata(vh.fig,'v',v)
            v0.callingfig=gcf; setappdata(0,'v0',v0)
            figname=[' CullFrames_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 19 % edge detector
            prompt={'Which type? s=Sobel, p=Prewitt, r=Robert, l=Log, c=Canny?',...
              'Clean singles (0=no; 1=yes)'};
            title='Edge Detector';
            def={'s' '0'}; lineno=1;
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            cleanit=str2num(inp{2});
            switch inp{1}
              case 'r'
                str='robert';
              case 'l'
                str='log';
              case 'c'
                str='canny';
              otherwise
                str='sobel';
            end
            lo=get(vh.ffs,'value'); hi=get(vh.lfs,'value');
            nn=0; v.Movi2=v.Movi(:,:,lo:hi);
            for j=lo:hi
              nn=nn+1;
              disp(j)
              if strcmp(str,'canny')
                thresh=[0 .1]; sigma=2;
                [bw,thresh]=edge(v.Movi(:,:,j),str,thresh,sigma);
               % disp(thresh)
              else
              bw=edge(v.Movi(:,:,j),str);
              end
              if cleanit; bw=bwmorph(bw,'clean'); end
              mx=255; % uint8(bw)*255;
              if isa(v.Movi,'uint16'); 
                mx=max(v.Movi(:))*2; end
               % a=uint16(bw)*mx; end
                v.Movi2(:,:,nn)=v.Movi(:,:,nn); 
               v.Movi2(bw)=mx; % :,:,nn)=v.Movi(:,:,nn)+a; %uint8(bw);
            end
          %  v.Movi2=255*v.Movi2;
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            setappdata(vh.fig,'v',v)
            figname=[' ' str '_' num2str(v0.fignum)];
            eval([mfilename figname figname figname])
          case 20 % BW Morph
            % bridge, clean, close
            % diag, dilate, erode, fill,
            % hbreak, majority, open, remove,
            % shrink, skel, spur, thicken,
            % thin,
            a=v.Movi;
            if ~strcmp(class(v.Movi),'logical')
              lo=get(vh.minslider,'value');
              frame=get(vh.fs,'value');
              a(a<=lo)=0; a=logical(a);
              set(vh.img,'cdata',a(:,:,frame))
              limits=get(vh.ax,'clim');
              set(vh.ax,'clim',[0 1])
            end
            prompt={['There are 16 operations to choose from: ',...
              char(10) 'bridge' char(10) 'clean' char(10) 'close',...
              char(10) 'diag' char(10) 'dilate' char(10) 'erode',...
              char(10) 'fill' char(10) 'hbreak' char(10) 'majority',...
              char(10) 'open', char(10) 'remove' char(10) 'shrink',...
              char(10) 'skel' char(10) 'spur' char(10) 'thicken' char(10) 'thin']};
            title='BWMorph'; lineno=1; def={'clean'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); set(vh.ax,'clim',limits); return; end
            for j=1:size(a,3)
              disp(j)
              a(:,:,j)=bwmorph(a(:,:,j),inp{1});
            end
            v.Movi2=255*uint8(a);
            set(vh.ax,'clim',limits)
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            name=[' bwmorph_' inp{1}];
            eval([mfilename name name name])

          case 21 % Rotate
            prompt={'Rotate counterclockwise how many degrees?'};
            title='Rotate'; lineno=1; def={'12'};
            inp=inputdlg(prompt,title,lineno,def);
            degrees=str2num(inp{1});
            fi=round(get(vh.ffs,'value')); la=round(get(vh.lfs,'value'));
            [sy,sx,sz]=size(v.Movi);
            pts=[round(sx/2);round(sy/2)];
            v.Movi2=v.Movi;
            rot=mod(degrees, 90);
            if ~rot; 
              rot=-degrees/90;  
              if rot ~=2; a=zeros(sx,sy,sz); v.Movi2=uint8(a); end            
            end
            
            if v.rgbyes
              for j=fi:la
                for k=1:3
                  disp(['Plane ' num2str(k) ' of image ' num2str(j) ' of ' num2str(la-fi+1)])
                  drawnow
                  b=double(v.Movi(:,:,k,j));
                [b,pts2]=bbrotate_image(degrees,b,pts);
                [sy2,sx2]=size(b);
                dsy=round((sy2-sy)/2); dsx=round((sx2-sx)/2);
                b=b(dsy:dsy+sy-1,dsx:dsx+sx-1);
                v.Movi2(:,:,k,j)=uint8(b);
                end
              end
            v0.rgbyes2=1;
            else
            for j=fi:la
              disp(['Image ' num2str(j) ' of ' num2str(la-fi+1)])
              drawnow
              a=v.Movi(:,:,j);
              if rot<0 % use rot90
                b=rot90(a); %,90*(-rot));
              else
                b=double(a);
                [b,pts2]=bbrotate_image(degrees,b,pts);
                [sy2,sx2]=size(b);
                dsy=round((sy2-sy)/2); dsx=round((sx2-sx)/2);
               % b=b(dsx:dsx+sx-1,dsy:dsy+sy-1);
                b=b(dsy:dsy+sy-1,dsx:dsx+sx-1);
              end
              if v.bitdepth==8; v.Movi2(:,:,j)=uint8(b);
              else v.Movi2(:,:,j)=uint16(b); end
            end %for j=fi:la
            end % if v.rgbyes
            v.list2=v.list;
            %if isa(a,'uint8'); v.Movi2=uint8(b); end
            setappdata(vh.fig,'v',v)

            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            name=[' rotate' num2str(degrees) '_'];
            eval([mfilename name name name])

            
        end % misc popup

     
      case 'imgprocesspopup'
        val=get(vh.imgprocesspopup,'value');
        switch val
          case 1 % title   calc mean  cv for each non-zero pixel
            a=double(v.Movi); sz=size(a);
            a=shiftdim(a,2);
            a=reshape(a,sz(3),[]);
            b=std(a);
            c=mean(a);
            b(c==0)=[]; c(c==0)=[];
            cv=b./c;
            cvbar=mean(cv);
            disp(['Mean cv of non-zero pixels = ' num2str(cvbar)])
          case 2 % subtract bkg

            set(vh.fig,'userdata','hello');
            bbdraw
            waitfor (vh.fig,'userdata')
            clc
            v=getappdata(vh.fig,'v');
            x=round(v.xdraw);
            y=round(v.ydraw);
            x(end+1)=x(1); y(end+1)= y(1); x3=[]; y3=[];
            for j=2:size(x,2); % Interpolate - fill in gaps
              [xx, yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
              x3=[x3;xx(1:max(1,end-1))]; y3=[y3;yy(1:max(1,end-1))];
            end
            bw=(roipoly(v.Movi(:,:,1),x3,y3));
            npix=sum(bw(:));
            disp([num2str(npix) ' pixels'])
            row=0; v.Movi2=v.Movi;
            jmin=get(vh.ffs,'value');
            jmax=get(vh.lfs,'value');
            for j=jmin:jmax
              row=row+1;
              m=v.Movi(:,:,j);
              avg=sum(sum(m(bw)))/npix; % avg
              m=m-avg;
              v.Movi2(:,:,j)=m;
            end
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' bkgsub_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 3 % add mult data
            prompt={'Add' 'Multiply (to raise to power, type -2 for square)',...
              'Normalize each image to min-to-max? (0=no, 1=yes)'};
            title='New = (Old+Add) * (or ^) Mult. Type Add and Mult'; lineno=1;
            def={'0' '1' '0'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            add=str2double(inp{1}); mult=str2double(inp{2}); norm=str2num(inp{3});
            lo=round(get(vh.minslider,'value')); hi=round(get(vh.maxslider,'value'));             
            first=round(get(vh.ffs,'value')); last=round(get(vh.lfs,'value'));
            if add
              movi=v.Movi(:,:,first:last);
              bkg=min(movi(:)); bw=movi(:,:,1)==bkg;
              movi=movi+add;
             % movi(bw)=bkg; 
              v.Movi(:,:,first:last)=movi;
              setappdata(vh.fig,'v',v)
            return
            end
            
            if norm % stretch each image individually to min-max for the stack
              a=v.Movi; a=a-lo; hi=hi-lo; v.Movi2=v.Movi;
              for j=1:length(v.list)
                b=double(v.Movi(:,:,j)); bmax=max(b(:)); fac=hi/bmax; b=b*fac;
                b=uint16(b); if isa(v.Movi,'uint8'); b=uint8(b); end
                v.Movi2(:,:,j)=b;
              end
              v.list2=v.list;
              setappdata(vh.fig,'v',v)
              v0.callingfig=vh.fig; setappdata(0,'v0',v0)
              figname=[' normalize_' num2str(v0.fignum)];
              eval ([mfilename figname figname figname])
              return
            end

            if add==0 && mult==1; return; end
            % if v.rgbyes; return; end
            buttonvis('abort')
            fi=round(get(vh.ffs,'value'));
            la=round(get(vh.lfs,'value'));
            htxt=text(20,150,[num2str(fi) '/' num2str(la)],'fontsize',24,'color','red');
            v.Movi2=v.Movi;
            if v.rgbyes; a=v.Movi(:,:,:,fi:la); else
              a=v.Movi(:,:,fi:la); end
            mx=double(max(a(:)));
            if mult<0; mx=mx^abs(mult); end
            for jj=fi:la
              set(htxt,'string',[num2str(jj) '/' num2str(la)]); drawnow
              if getappdata(0,'abort'); return; end
              disp ([num2str(jj) '/' num2str(la)])
              if v.rgbyes; a=double(v.Movi2(:,:,:,jj)); else a=double(v.Movi2(:,:,jj)); end
              a=a+add;
              if mult~= 1;
                if mult>0; a=a.*mult; 
                else
                  a=a.^abs(mult);
                  a=a./mx;
                end
              end
              if isa(v.Movi2,'uint16'); v.Movi2(:,:,jj)=uint16(a*65536);
              else
                if v.rgbyes; v.Movi2(:,:,:,jj)=uint8(a*255); else v.Movi2(:,:,jj)=uint8(a*255);end; end
            end
            buttonvis; delete(htxt)
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig;
            if v.rgbyes; v0.rgbyes2=1; end
            setappdata(0,'v0',v0)
            figname=[' add/mult_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])
          case 4 % fft
            if v.rgbyes; msgbox('RGB images! Cannot do fft','replace'); return; end
            buttonvis('abort')
            if getappdata(0,'abort'); set(habort,'visible','off'); return; end
            jmin=round(get(vh.ffs,'value')); jmax=round(get(vh.lfs,'value'));
            linecolor='red'; % first line color
            sz=min(size(v.Movi,1), size(v.Movi,2)); % size of frame (must be square)
            hfftfig=figure('tag','fftfig','position',[100 400 300 300],...
              'doublebuffer','on'); % make new window
            %hax=axes('xlim',[0 sz],'visible','off','ylim',[0 sz]); % new axes
            him=image('cdatamapping','scaled'); % new image
            colormap(jet(256))
            v.Movi2=uint16(0); % save fft's in Movi2
            v.Movi2= v.Movi(ones(1,sz),ones(1,sz),ones(1,jmax-jmin+1));
            nn=0;
            for j=jmin:jmax % loop through movie (fft for each image)
              nn=nn+1;
              if getappdata(0,'abort'); return; end
              f=double(v.Movi(:,:,j));
              F=fft2(f,sz,sz); % 2D fft, padded to sz x sz
              F=fftshift(F); % put low frequencies at center
              F2=abs(F); F2=log10(F2); % log plot
              F2=F2.*F2; % power spectrum
              d=diag(F2); % diagonal line to plot (from center to lower right)
              d=d(floor(size(d,1)/2+1):end); % plot from center to corner only
              if j==jmin; yfac=sz/max(d(:)); % scale y data to first image
                s=size(d,1); x=log10(1:size(d,1))';
                xy(:,1)=x; dmax=max(x(:)); x=x.*2*s/dmax; % scale x data
              else linecolor='white';
              end
              xy(:,nn+1)=d;
              d=smoothn(d,[5,5]); % smooth it
              d=d*yfac;
              figure(hfftfig) % pop window
              set(him,'cdata',F2); drawnow % show fft
              line(x,d,'color',linecolor); % plot line
  
            drawnow; pause(0.5)
            v.Movi2(:,:,nn)=uint16(F2); % save for new window
            end % for jmin:jmax
            v.z2=xy(:,2:end); v.zdata=v.z2; v.xdata=double(xy(:,1)); v.list=v.list(jmin:jmax);
            v.newname='FFT'; v.zavg=[];
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            figure(vh.fig)
            buttonvis
            close(hfftfig)
            bbplot
            figure(vh.fig) % must pop calling window
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            eval([mfilename ' fft' ' fft' ' fft'])

          case 5 % Erode-Dilate
            frame=round(get(vh.fs,'value'));
            locut=get(vh.minslider,'value');
            a=v.Movi(:,:,frame);
            a(a<=locut)=0;
            bwa=(a>0);
            se=getstrel; % make structure element
            v=getappdata(vh.fig,'v'); % to get v.semode
            bwb=imerode(bwa,se);
            bwc=imdilate(bwb,se); % mask
            bwc(a==0)=0;
            d=a; d(bwc>0)=0; % d is the 'tubes'
            e=a; e(bwc==0)=0; % e is the islands
            bw=d>0; bwl=bwlabel(bw);
            v.Movi2=uint16(e); %v.Movi(:,:,frame);
            v.Movi2(:,:,2)=d;
            v.Movi2(:,:,3)=bwl;
            v.list2={'islands' 'tubes' 'coloredtubes'};
            setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            eval([mfilename ' ErodeDilate' ' ErodeDilate' ' ErodeDilate'])
          case 6 % Regionprops
            try; a=v.reg; catch; v.reg=[1 1 0 1 1 0 0 0 0];end
            prompt={'Area' 'MajorAxisLength' 'MinorAxisLength' 'ConvexArea' 'Eccentricity',...
              'Orientation' 'EquivDiameter' 'Solidity' 'Extent'};
            title='Regionprops: 0=no; 1=yes'; lineno=1;
            def={num2str(v.reg(1)),num2str(v.reg(2)),num2str(v.reg(3)),num2str(v.reg(4)),...
              num2str(v.reg(5)),num2str(v.reg(6)),num2str(v.reg(7)),num2str(v.reg(8)),num2str(v.reg(9))};
            inp=inputdlg(prompt,title,lineno,def);
            v.reg=[1 1 1 1 1 1 1 1 1];
            for j=size(v.reg,2):-1:1
              if ~str2double(inp{j});
                prompt(j)=[]; v.reg(j)=0;
              end
            end
            frame=round(get(vh.fs,'value'));
            locut=get(vh.minslider,'value');
            a=v.Movi(:,:,frame);
            a(a<=locut)=0;
            bwtubes=a>0;
            bwl=bwlabel(bwtubes);
            set(vh.img,'cdata',bwl)
            str={};
            for j=1:size(prompt,2); str(j)={[num2str(j) '. ' prompt{j}]};
            end
            data=regionprops(bwl, prompt);
            clc; disp(str)
            msgbox(str,'replace')
            for j=1:size(prompt,2)
              dd(:,j)=[data.(prompt{j})]';
            end
            %dd=sortrows(dd,1);
            dlmwrite([v0.homedir 'junk.txt'],dd,'delimiter','\t','precision',6)
            edit 'junk.txt'
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          case 7 % contour
            frame=round(get(vh.fs,'value'));
            a=v.Movi(:,:,frame);
            nlines=4;
            inp=inputdlg('How many countour lines? (0 to quit)', 'Contour', 1, {num2str(nlines)});
            nlines=str2double(inp{:});
            % [C,h]=imcontour(a,nlines);
            figure; imcontour(a,nlines);
            return

          case 8 % outliers
            szx=size(v.Movi,2); szy=size(v.Movi2,1);
            prompt={'First bkg image?' 'Last bkg image?' 'How many SDs?'};
            title='Outlier analysis';
            try
              def=v.outlier;
            catch
              v.outlier={'1' '10' '3'}; def=v.outlier;
            end
            lineno=1;
            inp=inputdlg(prompt,title,lineno,def);
            v.outlier=inp;
            b1=str2num(inp{1}); b2=str2num(inp{2});
            nsd=str2num(inp{3});
            %a=zeros(b2-b1+1,szx*szy);
            nn=0;
            for j=b1:b2
              nn=nn+1;
              a(nn,:)=reshape(v.Movi(:,:,j),1,szx*szy);
            end
            vvar=var(double(a));
            mmean=mean(double(a));
            vvar=double(reshape(vvar,szy,szx));
            ssd=sqrt(vvar);
            mmean=reshape(mmean,szy,szx);
            %  varmean=vvar./mmean; varmean=varmean*100;
            lolim=mmean-nsd*ssd; lolim(lolim<0)=0;
            hilim=mmean+nsd*ssd; hilim(ssd==0)=63000;

            v.Movi2=v.Movi; % (:,:,b3:b4);
            v.list2=v.list; %(b3:b4);
            nn=0;
            for j=1:size(v.Movi2,3) % b3:b4
              nn=nn+1;
              a0=double(v.Movi2(:,:,nn)); a=a0;
              a(a0==0)=63000;
              b=(a<=lolim);
              a(a==63000)=0;
              c=(a>=hilim);
              a=a0*0+100;
              a(b)=0;
              a(c)=200;
              v.Movi2(:,:,nn)=a;
              %disp([sum(b(:)), sum(c(:))])
            end

            %v.Movi2=uint16(varmean);
            %v.list2={'100*var/mean'};
            % v.Movi2=uint16(vvar);

            setappdata(vh.fig,'v',v)
            set(0,'currentfigure',vh.fig);
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            eval([mfilename ' outliers' ' outliers' ' outliers'])

          case 9 % gaussian fit
            %str1=['This routine will performe a 3D gaussian fit to the ',...
            % 'selected region(s). You can choose whether to fit one region '...,
            % 'through the image stack, or fit several regions in just the ',...
            % 'displayed image plane.'];
            %  h=msgbox(str1); waitfor(h)
            str2=['OUTPUT: 3D image stack of gaussian fits and graph figure ',...
              'with results, in 8 columns: c1=xpos of max; c2=ypos of max; c3=',...
              'max F of fit; c4=constant; c5-7=X,Y,Z variances; c8=correlation coefficient.',...
              'c9=FWHM'];

            inp=questdlg('A= One area thru stack. B= Multiple areas but only this frame each',...
              'Gaussian fit','A','B','Cancel','A');
            if strcmp(inp,'Cancel'); return; end
            dostack=strcmp(inp,'A');

            lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
            if ~dostack;
              inp=questdlg('Blank out selected regions?','Blank or not?');
              if strcmp(inp,'Cancel'); return; end
              blankit=strcmp(inp,'Yes');
              lo=0; hi=0;
            end
            tot=num2str(hi-lo+1); % size(M,3);

            set(0,'currentfigure',vh.fig)
            tol=.001; mxit=1000; dsp='off'; lscale='on'; % 'iter';
            oldopts=optimset('lsqcurvefit');
            options=optimset(oldopts,'TolX',tol,'MaxIter',mxit,'Display',dsp,'LargeScale',lscale); %,'MaxFunEvals',mxfunevals);
            ok=1; nspots=0; xmax=0; ymax=0; v.Movi2=v.Movi;
            while ok % select regions
              set(vh.fig,'userdata','hello');
              bbgetrect % draw rectangle, move it and click to close
              waitfor(vh.fig,'userdata')
              v0=getappdata(0,'v0');
              nspots=nspots+1;
              framenow=get(vh.fs,'value');
              pos(nspots,1:4)=v0.pos; % getappdata(0,'pos'); % xl yl width height
              a0(nspots,1)=max(1,pos(nspots,1)); % xlo
              a0(nspots,2)=max(1,pos(nspots,2)); % ylo, from the TOP
              a0(nspots,3)=a0(nspots,1)+pos(nspots,3); % xhi
              a0(nspots,4)=a0(nspots,2)+pos(nspots,4); % yhi
              a0(nspots,5)=framenow; % frame #
              xmax=max(xmax,pos(nspots,3)); ymax=max(ymax,pos(nspots,4));
              if dostack
                ok=0;
              else
                if blankit
                  v.Movi(a0(nspots,2):a0(nspots,4),a0(nspots,1):a0(nspots,3),:)=0; drawnow
                  set(vh.img,'cdata',v.Movi(:,:,framenow)); drawnow
                  setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
                end
                inp=questdlg('Do another?', 'Gaussian fit area',...
                  'Yes','No','No, cancel last one','Yes');
                if strcmp(inp,'No, cancel last one'); nspots=nspots-1;
                  if ~nspots; return; end; ok=0; end
                if ~strcmp(inp,'Yes'); ok=0; end
              end % if dostack
            end % while ok

            v.Movi=v.Movi2;
            v.Movi2=[];
            nn=0; v.list2=[];
            ZZ=zeros(ymax+1,2*(xmax+1));
            for spot=1:nspots
              aa=a0(spot,1:4);
              frame0=a0(spot,5);
              htxt=text('string','','position',[2 2],'fontsize',12,...
                'backgroundcolor','yellow');
              m=double(v.Movi(aa(2):aa(4),aa(1):aa(3),frame0));
              [szy,szx,szz]=size(m);
              [c,r,h] = meshgrid(1:szx,1:szy,1:szz); % 3 arrays, each szx by szy
              % in 'c' the values in each column are identical
              % in 'r' the values in each row are identical
              % in 'h', all values are 1
              % c,r, and h are the same size (size of m)
              pts=[r c h]; % this is just r,c, and h pasted horizontally
              % the number of rows is the same as r,c,and h,
              % the number of columns is 3x r,c,and h (horizontal paste)
              buttonvis('abort')

              for j=lo:hi
                frame=j; if ~j; frame=frame0; end
                set(htxt,'string',[num2str(nn) '/' tot])
                if getappdata(0,'abort'); return; end
                nn=nn+1;
                v.list2{nn}=v.list{frame};
                m0=v.Movi(:,:,frame);
                m=double(m0(aa(2):aa(4),aa(1):aa(3)));

                b=double(min(m(:)));
                a=double(max(m(:)))-b;
                sc=3; sr=sc; sh=sc;
                c0=szx/2;
                r0=szy/2;
                h0=0;
                f=[b a c0 sc r0 sr h0 sh]; % Coeffs
                % disp(f')
                lb=0; ub=64000; %2*max(m(:)); % lower and upper bounds

                %[ff, resnorm, resid, exitflag]=lsqcurvefit(@gauss3D,f,pts,m,lb,ub,options);
                [ff]=lsqcurvefit(@gauss3D,f,pts,m,lb,ub,options);

                if ff(3)<0 || ff(3)>size(m,1) || ff(5)<0 || ff(5)>size(m,2)
                  zz(nn,1:8)=-1;
                  set(vh.img,'cdata',m0); drawnow
                  disp(['peak of frame ' num2str(frame) ' out of bounds'])
                else % not out of bounds
                  Z0=ff(1)+ff(2).*exp(-((c-ff(3)).^2/ff(4)+(r-ff(5)).^2/ff(6)+(h-ff(7)).^2/ff(8)));
                  Z=uint16(Z0);
                  Zm=uint16(bbpaste(Z,m,'horizontal'));
                  ymax=ff(5)+aa(2)-1; xmax=ff(3)+aa(1)-1;
                  zz(nn,1)=xmax; % xpos of max g(3)+offset
                  zz(nn,2)=ymax; % ypos of max g(5)+offset
                  zz(nn,3)=ff(2); % max(Z(:)); %g(2); % gauss max
                  zz(nn,4)=ff(1); % constant (total F is gauss max + constant)
                  zz(nn,5)=ff(4)/2; % x variance
                  zz(nn,6)=ff(6)/2; % y variance
                  zz(nn,7)=ff(8)/2; % h variance
                  zz(nn,8)=corr2(m,Z);
                  zz(nn,9)=2*1.1774*sqrt((zz(nn,5)+zz(nn,6))/2); % FWHM
                  m0(aa(2):aa(4),aa(1):aa(3))=Z;
                  ymax=round(ymax); xmax=round(xmax);
                  m0(ymax-1,xmax)=0; m0(ymax+1,xmax)=0;
                  m0(ymax,xmax-1)=0; m0(ymax,xmax+1)=0;
                  v.Movi2(:,:,nn)=m0;
                  set(vh.img,'cdata',m0); drawnow

                  szy2=size(Zm,1); szx2=size(Zm,2);
                  ZZ(1:szy2,1:szx2,nn)=Zm;

                  if dostack
                    prog=Z(round(ff(5)),:); % 2D profile
                    proo=m(round(ff(5)),:);
                    zzz(:,(nn-1)*2+1)=prog;
                    zzz(:,(nn-1)*2+2)=proo;
                  end
                end % out of bounds
              end % for frame=lo:hi
            end % for spot=1:nn
            buttonvis
            delete(htxt)
            v.Movi2=ZZ;
            v.srf=01; % set to 1 for 3d
            v.zdata=zz; v.z2=zz;
            if dostack;
              % v.zdata=zzz; v.z2=zzz; % this give a profile of a horizontal line
              %   through the center
            end
            setappdata(vh.fig,'v',v)
            set(0,'currentfigure',vh.fig);
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            eval([mfilename ' GaussianFit' ' GaussianFit' ' GaussianFit'])
            v.srf=0;
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            bbplot % all data
            msgbox(str2,'replace')

          case 10 % watershed
            if isa(v.Movi,'uint8'); 
              v.Movi=uint16(v.Movi); v.bitdepth=16; 
              set(vh.bitdepth,'string','16-->8bits/Clip')              
              setappdata(vh.fig,'v',v)
            end
              %msgbox('Your movie is only 8 bits. Convert to 16 bits','replace'); return; end
            eval([mfilename ' wat'])
        
          case 11 % spot tracker
            v.points=[];
            prompt={'Max xy distance between frames?' ,...
              'Max frame gaps?',...
              'use all (1) or only those present in first frame (0)?',...
              'minimun length? (pixels)',...
              'Min mean brightness?',...
              'Plot straight line (0) or entire track (1)?',...
              'Annotate plot? (0=no; 1=first point; 2=last point; 3=spot num; 4=track len; 5=1st frame; 6=mean F)'};
            title='SPOT TRACKER'; lineno=1;
            try; def=v.tracker; catch; def={'4' '0'  '1' '12' '0' '1' '12'}; end
            inp=inputdlg(prompt,title,lineno,def);
            v.tracker=inp;
            max_linking_distance=str2num(inp{1});
            max_gap_closing=str2num(inp{2});
            useall=str2num(inp{3});
            minlen=max(2,str2num(inp{4}));
            thresh=str2num(inp{5});
            plottrack=str2num(inp{6});
            txt=[0 0 0 0 0 0]; tt=inp{7};
            for j=1:4; txt(j)=~isempty(findstr(tt,num2str(j))); end
            conn=8; v.Movi2=v.Movi;
            lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
            nn=0; hh=line;
            for frame=lo:hi
              nn=nn+1;
              m0=v.Movi(:,:,frame); m=m0;
              set(vh.img,'cdata',m)
              minval=min(m(:));
              lo  =get(vh.minslider,'value');
              m(m<lo)=0;
              m=m+1;
              bw=imregionalmax(m,conn);
              nsum=0; ok=1; % multiple iterations of bwmorph remove to shrink spots
              while ok
                ok=ok+1;
                bw=bwmorph(bw,'shrink'); % shrink each spot to a single pixel
                nsumnew=sum(bw(:));
                if nsumnew==nsum; ok=0; end; nsum=nsumnew;
              end
              disp(['Frame ' num2str(frame) ' has ' num2str(nsum) ' regions'])
              index=find(bw);
              [y x]=ind2sub(size(m),index);
              xy=[x y];
              set(hh,'xdata',xy(:,1),'ydata',xy(:,2),...
                'marker','o', 'markeredgecolor','g','linestyle','none')
              drawnow
              points(nn,1)={xy};
            end % for frame=lo:hi
            v.points=points;
            setappdata(vh.fig,'v',v)
            debug = true;
            disp('SimpleTracker...')

            %%%%%%%%%%%%%%%%%%% SIMPLETRACKER%%%%%%%%
            [tracks, adjacency_tracks, A]=simpletracker(points, max_linking_distance, max_gap_closing, debug);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            delete(hh)
            firstframe=[];
            if ~useall
              first=ones(size(tracks,1),1);
              ok=1; nn=0; % remove tracks not present in first image
              while ok
                nn=nn+1;
                a=tracks{nn};
                if isnan(a(1)); ok=0; end
              end
              tracks=tracks(1:nn-1); adjacency_tracks=adjacency_tracks(1:nn-1);
            else
              for k=1:size(tracks,1)
                a=tracks{k}; b=find(a>0);
                first(k)=b(1);
              end
            end % if ~useall

            n_tracks = numel(tracks);
            colors={'r' 'g' 'b' 'y' 'm' 'c'}; sz=size(colors,2);
            all_points = vertcat(points{:});
            nn=0; v.zdata=[];
            disp([num2str(n_tracks) ' tracks'])
            disp(['Length Max F'])
            for i_track = 1 : n_tracks
              track = adjacency_tracks{i_track};
              track_points = all_points(track, :);
              a=track_points;
              ncolor=mod(i_track,sz)+4*~mod(i_track,sz); % bb
              v.points=a; setappdata(vh.fig,'v',v)

              if size(a,1)>=minlen
                b=zeros(size(a,1),1);
                for k=1:size(a,1)
                  b(k,1)=v.Movi(a(k,2),a(k,1),k);
                end
                bmax=max(b);
                bmean=mean(b);

                if bmean>thresh
                  disp([size(a,1), bmax])
                  nn=nn+1;
                  if plottrack % plot straight line (0) or full track (1)
                    plot(a(:,1), a(:, 2), 'color', colors{ncolor}) % entire track
                  else
                    line('xdata',[a(1,1) a(end,1)],'ydata',[a(1,2) a(end,2)],...
                      'linestyle','-','color',colors{ncolor}) % straight line
                  end
                  if txt(1); line(a(1,1), a(1,2),...
                    'marker','o','markerfacecolor',colors{ncolor}); end % first point=circle
                  if txt(2); line(a(end,1), a(end,2),...
                   'marker','s','markerfacecolor',colors{ncolor}); end % last point=square
                  str0={num2str(nn) num2str(size(a,1)) num2str(first(i_track)) num2str(round(bmean))};
                  str=' '; for kk=3:6; if txt(kk); str=[str '-' str0{kk-2}]; end; end
                  text('position',[a(1,1), a(1,2)],...
                    'HorizontalAlignment','Left',...
                    'string',str, 'color',colors{ncolor}) % text
                  adiff=diff(a);
                  b1=adiff(:,1); b1=b1.^2;
                  b2=adiff(:,2); b2=b2.^2;
                  c=sqrt(b1+ b2);
                  v.zdata(nn,1)=mean(c); % mean dxy/frame
                  v.zdata(nn,2)=std(c); % std dxy/frame
                  dx=a(1,1)-a(end,1); dy=a(1,2)-a(end,2);
                  dxy=sqrt(dx^2+dy^2);
                  v.zdata(nn,3)=dx; % total dx
                  v.zdata(nn,4)=dy; % total dy
                  v.zdata(nn,5)=dxy; % total dxy
                  v.zdata(nn,6)=bmax; % max F
                  v.zdata(nn,7)=bmean; % mean F

                end % if b>thresh
              end % if size(a,1)>minlen
            end
            disp([num2str(nn) ' tracks plotted'])
            v.z2=[]; v.zavg=[]; v.xdata=[];  v.newname='tracker_';
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            bbplot
            str=['Col 1=mean dxy/frame; Col2=std dxy/frame; Col3=total dx; ', ...
              'Col4=total dy; Col5=total dxy; Col6=max F; Col7=meanF'];
            msgbox(str)
            disp(str)
              
          case 12 % denoise
            sz=size(v.Movi,3);
            prompt={[num2str(sz) ' frames total. Denoise in subsets of how many frames?']}; title='Denoise'; lineno=1;
            def={num2str(sz)};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            numperset=str2num(inp{1}); nsets=floor(sz/numperset);

            buttonvis('abort')
            nn=0; v.Movi2=v.Movi;
            for j=1:nsets
              first=(j-1)*numperset+1; last=first+numperset-1;
              disp(['Denoising frames ' num2str(first) '-' num2str(last)])
              movi=v.Movi(:,:,first:last);

              [xsize,ysize,zsize]=size(movi);
              mean_frame=mean(movi,3);
              disp('repmat...')
              mean_stack=repmat(mean_frame,[1,1,zsize]);
              %remove mean - compute svd
              A_raw=single(reshape(movi,[xsize*ysize,zsize]));
              %A_raw_zero_mean=A_raw - repmat(mean(A_raw,2),[1,zsize]);
              disp('svd....')
              [U,S,V]=svd(A_raw,0);
              %singular_values=S*ones(zsize,1);
              %figure(3); plot(log(singular_values)); hold on
              % keep only first few modes
              singular_value_cutoff=20;
              S_cut=S;
              S_cut(singular_value_cutoff:zsize,singular_value_cutoff:zsize)=0;
              % reconstruct stack from truncated svd
              disp('transpose...')
              A_denoised=U*S_cut*transpose(V);
              if getappdata(0,'abort'); return; end
              disp('reshape...')
              denoised_stack_temp1=reshape(A_denoised,[xsize,ysize,zsize]);
              denoised_stack_temp2=denoised_stack_temp1 - repmat(mean(denoised_stack_temp1,3),[1,1,zsize]);
              v.Movi2(:,:,first:last)=uint16(denoised_stack_temp2+mean_stack);
            end

            buttonvis
            setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            eval([mfilename ' denoise' ' denoise' ' denoise'])

          case 13 % pixvals to table;  write pixel positions and values (x,y,z) to table           
            inp=inputdlg({'Background value?'},'Background?',1,{'0'});
            bkg=str2num(inp{1}); % if 0>1
            %a=double(v.Movi(:,:,1));
             a=get(vh.img,'cdata'); a=double(a); 
            %loval=min(a(:));
              v.zdata=a(a~=bkg); % a(a>loval);
              v.z2=[]; v.zavg=[]; v.xdata=[];
          v.newname='pixvals_'; 
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          bbplot         
          return
           % end
            
            
            %  col 1=x, col 2=y, cols 3-end = z vals for each frame
           str=['This will write pixel values to a table, ' char(10),...
               'uisng either ALL non-zero pixels, or those found by imregionalmax.' char(10),...
               'If the latter, the imregionalmax is performed on the image displayed in the framebuffer,' char(10),...
               'and all other calculations on the images from low to high (set by the first/last sliders.' char(10),...
               'The output has n+3 columns, where n is the number of images. Columns 1&2 are the x&y positions ' char(10),...
               'of the pixels, and the last column is the average of the others. The table is sorted by ' char(10),...
               'the last column'];
            hh=msgbox(str);
            waitfor(hh)
            a=get(vh.img,'cdata');
            f1=round(get(vh.ffs,'value')); f2=round(get(vh.lfs,'value'));
            loval=get(vh.minslider,'value'); loval=max(loval,1);
            hival=get(vh.maxslider,'value');
            a(a<loval)=0; a(a>hival)=0;
          % imregionalmax to find brightest single pixels
          conn=8;
          bw_imreg=imregionalmax(a,conn);
          nsum_imreg=0; ok=1; % multiple iterations of bwmorph remove to shrink spots
          while ok
            ok=ok+1;
            bw_imreg=bwmorph(bw_imreg,'shrink'); % shrink each spot to a single pixel
            nsumnew=sum(bw_imreg(:));
            if nsumnew == nsum_imreg; ok=0; end
            nsum_imreg=nsumnew;
          end

            a_imreg=a; 
            a_imreg(~bw_imreg)=0;
          bw=(a>=loval);
          suma=sum(bw(:));

          prompt={[num2str(suma) ' total pixels per frame >=' num2str(loval) ,...
            'and <=' num2str(hival) ' ('  num2str(nsum_imreg) ' by imregionalmax. Frame ',...
            num2str(f1) '-' num2str(f2),...
            '. Write x,y,z values to a table? Use all pixels (1 - enter negative bkg if not zero) or imregionalmax (0)?']};
          title='Write pixel values to a table?'; lineno=1; def={'0'};
          inp=inputdlg(prompt,title,lineno, def);
          if isempty(inp); return; end
          useall=str2num(inp{1});
          if ~useall;
            a=a_imreg; 
            bw=bw_imreg; 
            suma=sum(bw(:));
          end

          [y x]=find(a>=loval); %find(a>=loval);
          bw=bw*0; bw(a>=loval)=1;
          xyz(:,1:2)=[x y]; n=0;
          for j=f1:f2
            n=n+1;
            b=v.Movi(:,:,j);
            z=b(bw>0); %a(bw); %double(a(y,x));
            xyz(:,n+2)=z;
          end
          str='Col 3=pixel intensity';
          if size(xyz,2)>3
            m1=xyz(:,3:end)';
            m2=mean(m1)';
            xyz=[xyz m2];
            str=['Cols 3-' num2str(size(xyz,2)-1) ' =intensity data (one col per image). Col ' num2str(size(xyz,2)) '=mean values'];
          end
          xyz=sortrows(xyz,-size(xyz,2));          
          if useall<0; b=xyz(:,3)== -useall;  xyz(b,:)=[]; end
          v.zdata=double(xyz); v.z2=[]; v.zavg=[]; v.xdata=[];
          v.newname='pixvals_'; 
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          bbplot         
          str=['Col 1=x; Col 2=y; ' str]; 
          msgbox(str,'replace')

        case 14 % find bleached region
          hh=msgbox('Set current frame to last image before bleach','replace');
          waitfor(hh)
          v=getappdata(vh.fig,'v');
          m=v.Movi(:,:,v.frame)-v.Movi(:,:,v.frame+1);
          mn=0; mx=max(m(:)); dthresh=(mx-mn)/4;
          clr='rgbkmyckrgbk'; j=0;
          for thresh=mn+dthresh:dthresh:mx-dthresh
            j=j+1; clr2=clr(j);
            disp(thresh)
            bw=(m>=thresh);
            [bwL]=bwlabel(bw,8);
            s=regionprops(bwL,'Area','BoundingBox');
            sa=double([s.Area]);
            n=find(sa==max(sa(:))); n=n(1);
            bb=s(n).BoundingBox;
            rectangle('position',bb,'edgecolor',clr2,'curvature',[1 1])
            drawnow
          end % for thresh
          case 15 % sort pixels
            str=['This will display a table of all non-background pixel values in the image stack. ',...
              'Each column shows the value of ',...
              'pixels at one position. Rows are sorted with the average brightest first. ',...
              'Each row contains all data from one image in the stack, with ',...
              '4 extra rows at the end: mean, variance, X position, Y position'];
            hh=msgbox(str,'replace'); waitfor(hh)            
            bkg=0; if strcmp('double',class(v.Movi)); v.Movi=round(v.Movi); bkg=min(v.Movi(:)); end
            a=v.Movi(:,:,1);
            idx=(1:numel(a))';
            [x y]=ind2sub(size(a),idx);
            a0=double(zeros(numel(a),size(v.Movi,3) )); b0=a0;
            nframes=size(v.Movi,3);
            for j=1:nframes
              m=double(v.Movi(:,:,j)); a0(:,j)=m(:);
            end
            mn=mean(a0')'; %mnb=mean(b0')'; 
            vari=var(a0')'; %varib=var(b0')';
            if nframes==1; mn=a0'; vari=a0'*0; end
            a0(:,nframes+1)=mn; %b0(:,nframes+1)=mnb;
            a0(:,nframes+2)=vari; %	(:,nframes+2)=varib;
            a0(:,nframes+3)=x; %b0(:,nframes+3)=x;
            a0(:,nframes+4)=y; %b0(:,nframes+4)=y;
            a0=sortrows(a0,-(nframes+1)); % the minus sign means sort descending
            findbkg=a0(:,nframes+1)==bkg;
            a0(findbkg>0,:)=[];
           v.zdata=a0'; %b0'; 
           v.z2=[];
             setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            bbplot
          
            
               buttonvis
          case 16 % nearest neighbor
            if v.rgbyes; return; end
            str=['This routine will determine the nearest neighbor distance',...
              ' (in pixels) for every pixel equal to the max value.',...
              ' OUTPUT: 2 graphs (raw data and mean&stddev)'];
            hh=msgbox(str,'replace'); waitfor(hh)
            lo=round(get(vh.ffs,'value')); hi=round(get(vh.lfs,'value'));
            mx=get(vh.maxslider,'value');
            col=0; v.zdata=[];
            for frame=lo:hi
              a0=double(v.Movi(:,:,frame));
              a=reshape(a0,size(a0,1)*size(a0,2),1);
              [a idx]=sort(a,'descend');
              a(a<mx)=[];
              idx=idx(1:size(a,1));
              disp(size(idx));
              [x0 y0]=ind2sub(size(a0),idx);
              rr=0; col=col+1;
              for r=1:size(idx,1)
                x=(x0-x0(r)).^2;
                y=(y0-y0(r)).^2;
                dd=x+y; dd(r)=1e9;
                rr=rr+1;
                mn=sqrt(min(dd));
                v.zdata(rr,col)=mn;
              end
            end
            v.zdata(~v.zdata)=NaN;
            v.z2=[];
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            bbplot
            set(0,'currentfigure',vh.fig)
            for j=1:size(v.zdata,2)
              a=v.zdata(:,j);
              a=a(~isnan(a));
              mm(j,1)=mean(a); mm(j,2)=std(a);
            end
            v.zdata=mm;
            setappdata(vh.fig,'v',v)
            drawnow
            bbplot

          case 17 % hotspot
            %msg=['This routine will average background images ',...
            % 'A new figure will open with up to SEVEN new images for each iteration: ',...
            % '1. Hot Spots. 2. Avg bkg; 3-5 are SCALED stddev, cv, and difference, ',...
            % 'and 6-7 are RAW stddev, and cv images. ',...
            % 'NOTE: If you want to print out the pixel values, ',...
            % 'add 1 to all values, then re-mask with zeroes'];
            % hh=msgbox(msg); pos=get(hh,'position'); set(hh,'position',[10 10 pos(3) pos(4)])
            prompt={'First bkg image?',...
              'Last bkg image?',...
              'First hotspot image?',...
              'Last hotspot image?',...
              'How many iterations?'};
            title='Hot spot analysis';
            try
              def=v.hotspot;
            catch
              v.hotspot={'1' '4' '5' '8' '1'}; def=v.hotspot;
            end
            lineno=1;
            inp=inputdlg(prompt,title,lineno,def);
            v.hotspot=inp;
            itertot=str2double(inp{5});
            v.Movi2=v.Movi(:,:,1); v.list2=v.list(1:itertot);
            diter=floor(length(v.list)/itertot);
            for iter=1:itertot
              if itertot>1; disp([num2str(iter) '/' num2str(itertot)]); end
              bkgfirst=str2double(inp{1})+(iter-1)*diter;
              bkglast=str2double(inp{2})+(iter-1)*diter;
              subimg1=str2double(inp{3})+(iter-1)*diter;
              subimg2=str2double(inp{4})+(iter-1)*diter;
              m=double(v.Movi(:,:,bkgfirst));
              img0=double(v.Movi(:,:,1)).*0;
              index=(find(m>0))';
              jj=0; rawvals=[]; %rawvals2=[];
              for j=bkgfirst:bkglast
                jj=jj+1;
                b=double(v.Movi(:,:,j));
                rawvals(jj,:)=b(index);
              end

              mm=mean(rawvals); %s=std(rawvals);
              if bkgfirst==bkglast; mm=rawvals; end
              bkgmean=img0; bkgmean(index)=mm;
              %bkgsd=img0;
              m=double(v.Movi(:,:,subimg1));
              index2=(find(m>0))';
              jj=0; rawvals2=[];
              for j=subimg1:subimg2
                jj=jj+1;
                b=double(v.Movi(:,:,j));
                rawvals2(jj,:)=b(index2);
              end
              mm=mean(rawvals2); %s=std(rawvals2);

              if bkgfirst==bkglast; mm=rawvals2; end
              hotmean=img0; hotmean(index2)=mm;
              %hotsd=img0;

              dif=double(hotmean-bkgmean);
              v.Movi2(:,:,end+1)=uint16(dif); % hot spot
              % v.Movi2(:,:,end+1)=uint16(bkgmean); % 1. avg bkg
              % v.Movi2(:,:,end+1)=uint16(bkgsd); % 5. raw std dev
              % v.Movi2(:,:,end+1)=uint16(bkgcv); % 6. raw cv
              % v.Movi2(:,:,end+1)=uint16(dif); % 7. raw difference image
              % if size(v.list,2)>size(v.list,1); v.list=v.list'; end
              str=['[avg_' num2str(subimg1) '-' num2str(subimg2) ']-[avg_' num2str(bkgfirst) '-' num2str(bkglast) ']'];
              % v.list2=[v.list2; {str}]; %[v.list; {'mean'; 'stddev'; 'cv'; str}];
              v.list2(iter)={str};
            end
            v.Movi2=v.Movi2(:,:,2:end);
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)

            figname=[' hotspot_' str '_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])
          case 18 % count spots with vals >minslider
            str=['This will binarize the image at the value of the low slider. ',...
              'Pixels with values at or below the low slider will be set to 0, ',...
              'and the rest to 1. The resulting spots will be measured. For each ',...
              'image, the number and size of spots will be returned.'];
            hh=msgbox(str,'replace');
            waitfor(hh)
            loval=get(vh.minslider,'value');
            bw=v.Movi>loval;
            mx=0;
            b=zeros(1000,size(bw,3));
            for j=1:size(bw,3)
              bwl=bwlabel(bw(:,:,j),8);
              stats=regionprops(bwl,'area');
              a=[stats.Area]'; mx=max(mx,max(a(:)));
              for k=1:size(a,1); b(a(k,1),j)=b(a(k,1),j)+1; end
              nspots(j)=size(a,1); avgsize(j)=mean(a);
              aa=a; aa(aa==1)=[]; nspots2(j)=size(aa,1); avgsize2(j)=mean(aa);
              disp(['Frame ' num2str(j) ': ' num2str(nspots(j)) ' spots. Avg size= ' num2str(avgsize(j))])
            end
            avgnspots=mean(nspots); varnspots=var(nspots); avgsz=mean(avgsize);
            disp(['Avg # spots = ' num2str(avgnspots) '. var=' num2str(varnspots) ' Avg size=' num2str(avgsz)])
            avgnspots2=mean(nspots2); varnspots2=var(nspots2); avgsz2=mean(avgsize2);
            disp('OMIT SINGLES:')
            disp(['Avg # spots = ' num2str(avgnspots2) '. var=' num2str(varnspots2) ' Avg size=' num2str(avgsz2)])
            v.zdata=b(1:mx,:); v.z2=v.zdata; v.zavg=[];
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            bbplot
          case 19 % randomize non-bkg pixels
            v.Movi2=v.Movi;
            bkg=0;if strcmp(num2str(min(v.Movi(:))),class(v.Movi)); bkg=min(v.Movi(:)); end
            for j=1:size(v.Movi,3)
              a=v.Movi(:,:,j);
              pos=find(a>bkg);
              val=a(pos);
              rnd=rand(size(pos,1),1);
              posrnd=sortrows([pos rnd],2);
              pos2=posrnd(:,1);
              a(pos2)=val;
              v.Movi2(:,:,j)=a;
            end
            v.list2=v.list;
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' scramble_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 20 % Normalize each frame to brightest image
            a=v.Movi(:,:,1); b=a==0; npix=size(a,1)*size(a,2); f=1-sum(b(:))/npix;
            prompt={['Normalize brightest pixels: fraction to take? (1=all; ',...
              num2str(f) '=non-zero'],...
              'Apply to those pixels only (0) or all pixels (1)?'};
            title='Normalize each frame brightness'; lineno=1;
            try
              ff={num2str(v.normcutoff)};
            catch
              ff={'0.3'};
            end
            def=[ff {'1'}];
            inp=inputdlg(prompt,title,lineno,def);
            v.normcutoff=str2double(inp{1}); doall=str2double(inp{2});
            sz=size(v.Movi,1)*size(v.Movi,2);
            lastval=round(sz*v.normcutoff);
            for frame=1:length(v.list)
              a=v.Movi(:,:,frame);
              b=reshape(a,size(a,1)*size(a,2),1);
              [b,idx]=sort(b,'descend');
              b=b(1:lastval);
              fac0(frame)=sum(b(:));
              idx0(:,frame)=idx(1:lastval);
            end
            maxfac=max(fac0(:));
            v.Movi2=v.Movi;
            for j=1:length(v.list)
              disp(j)
              a=double(v.Movi(:,:,j));
              fac=maxfac/fac0(j);
              if doall
                a=a.*fac;
              else
                idx=idx0(:,j);
                a(idx)=a(idx)*fac;
              end
              v.Movi2(:,:,j)=a;
            end
            v.list2=v.list;
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' normalize_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 21 % contrast boost using adapthisteq
            frame=get(vh.fs,'value'); v.Movi2=v.Movi;
            prompt={'# of tiles','contrast (0-1)',...
              'histogram shape (flat, gauss, exp)',...
              'histogram parameter'};
            title='Contrast enhancement with adapthisteq';
            lineno=1; def={'8','0.01','gauss','0.4'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            a=str2num(inp{1}); numtiles=[a a];
            cliplimit=str2num(inp{2});
            a=str2num(inp{3}); distribution='uniform';
            if strcmp(a,'gauss'); distribution='rayleigh'; end
            if strcmp(a,'exp'); distribution='exponential'; end
            alpha=str2num(inp{4});

            a=get(vh.img,'cdata'); mx=max(a(:));
            if strcmp(distribution,'uniform');
              b=adapthisteq(a,'numtiles',numtiles,...
                'cliplimit',cliplimit,'nbins',256,...
                'range','original','distribution',distribution);
            else;  b=adapthisteq(a,'numtiles',numtiles,...
                'cliplimit',cliplimit,'nbins',256,...
                'range','original','distribution',distribution,...
                'alpha',alpha);
            end
            b=b-min(b(:)); mx2=max(b(:)); fac=double(mx2)/double(mx);
            b=b./fac;
            % set(vh.img,'cdata',b)
            v.Movi2(:,:,frame)=b;
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' adapthisteq_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])

          case 22 % hotspots chong
              if isempty(v.mask);
                a=v.Movi(:,:,1); bkg=min(a(:));                
                 v.mask=a>bkg;
                % msgbox('First, make a mask'); return
             end
              prompt={'First background frame?',...
                'First peak frame?',...
                'Step size?',...
                'How to deal with negative values (0=leave negative. 1=set to value of 1'};
              title='Chongs hotspots'; lineno=1; def={'2' '3' '10' '0'};
              inp=inputdlg(prompt, title, lineno, def);
              f1=str2num(inp{1}); t1=str2num(inp{2});
              dt=t1-f1;
              df=str2num(inp{3});
              negnum=str2num(inp{4});

              lf=size(v.list,2);
              v.Movi2=double(v.Movi(:,:,1))*0;              
           %   mv=double(v.Movi2);
              n=0;
              for j=f1:df:lf
                  disp([num2str(j) ' / ' num2str(lf)])
                  drawnow                  
                  %try; 
                    m2=double(v.Movi(:,:,j+dt))-double(v.Movi(:,:,j)); 
                  n=n+1;
                  v.Movi2(:,:,n)=m2;
                  %catch; end
                  %   mv(:,:,n)=m2; % this holds double values (includes negatives)
              end
              v.Movi2=round(v.Movi2);
              bkg=min(v.Movi2(:))-1;             
              for j=1:size(v.Movi2,3)
                  a=v.Movi2(:,:,j);                  
                  a(v.mask==0)=bkg; 
                  v.Movi2(:,:,j)=a;
              end
              switch negnum
                case 1 % make bkg=0 and negatives =1
              if bkg<0; 
                v.Movi2(v.Movi2>bkg & v.Movi2<1)=1; %v.Movi2-bkg; 
                v.Movi2(v.Movi2<0)=0;  % bkg=0 and pixels that dimmed =1
              %  str=['Background= ' num2str(bkg) ', so this was added to each pixel'];
              str='Pixels that dimmed all have a value of 1';
              end
              v.Movi2=uint16(v.Movi2);
              case 0
                str='Negative pixels are not changed.';
              end
            %  msgbox(str)
              
           
              v.list2=v.list(1:size(v.Movi2,3));
              %v.mv=mv;
              setappdata(vh.fig,'v',v)
              v0.callingfig=vh.fig; setappdata(0,'v0',v0)
              figname=[' hotspots_' num2str(v0.fignum)];
              eval ([mfilename figname figname figname])
              
              
              
              return
              v0=getappdata(0,'v0'); % this will calculate std
              figure(v0.callingfig)
              vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v');
              mvar=zeros(n,size(v.Movi2,2)*size(v.Movi2,1));
              for j=1:n
                  mvar(j,:)=double(reshape(v.mv(:,:,j),1,[]));
              end
              %  mvar=reshape(mv,n,[]); % ???? this does not work
              a=mean(mvar);
              b=std(mvar);
              b= 100*b./a; % coefficient of variation
              v.Movi2=v.Movi(:,:,1);
              a=reshape(a,size(v.Movi2,1),[]);
              b=reshape(b,size(v.Movi2,1),[]);
              v.Movi2(:,:,1)=uint16(a);  % new movie: frame 1=mean; frame 2=std
              v.Movi2(:,:,2)=uint16(b);
              setappdata(vh.fig,'v',v)
              v0.callingfig=vh.fig; setappdata(0,'v0',v0)
              figname=[' hotspots_mean_cv_' num2str(v0.fignum)];
              eval ([mfilename figname figname figname])
            
          case 23 % del2 - discrete laplacian
            avg=double(mean(v.Movi,3)); % average of stack
            b=del2(avg);                % LaPlacian
            thresh=-2.2*std(b(:));      % threshold, negative, normalized
            c=b<thresh;                 % binary mask
            d=bwlabel(c);               % binary mask with areas numbered
            disp('ok')
            set(vh.img,'cdata',c); set(vh.ax,'clim', [0 1])
          case 24 % imregionalmax
            m0=double(get(vh.img,'cdata')); m=m0;
            mx=max(m(:));
            m(m==mx)=mx-1;
            minval=min(m(:));
            lo  =get(vh.minslider,'value');
            m(m<lo)=0;
            m=m+1; conn=8;
            bw=imregionalmax(m,conn);
            nsum=0; ok=1; % multiple iterations of bwmorph remove to shrink spots
            while ok
              ok=ok+1;
              bw=bwmorph(bw,'shrink'); % shrink each spot to a single pixel
              nsumnew=sum(bw(:));
              if nsumnew==nsum;
                disp([num2str(ok) ' shrink cycles. ' num2str(nsum) ' regions'])
                ok=0;
              end;
              nsum=nsumnew;
            end
            n=sum(bw(:));
            prompt={['imregionalmax found ' num2str(n) ' regions. ',...
              'Keep the brightest N. What is N?']};
            title='imregionalmax'; lineno=1; def={num2str(n)};
            inp=inputdlg(prompt,title,lineno,def);
            nshow=min(str2num(inp{1}), n);
            index=find(bw); i2=[index m0(index)];
            z2=sortrows(i2,-2);
            bw2=bw; bw2(bw)=0;
            bw2(z2(1:nshow,1))=1;
            
            [y x]=ind2sub(size(m),index);
            xyz=sortrows([x y m0(bw)],-3);
            v.zdata=xyz; v.z2=[]; v.zavg=[];
            setappdata(vh.fig,'v',v)
            bbplot
            figure(vh.fig)
            
            m=m0; m(m0>0)=round(mx/2);
            line('xdata',xyz(1:nshow,1),'ydata',xyz(1:nshow,2),...
              'marker','o','markersize',2, 'markeredgecolor','r','linestyle','none')
            m(bw2)=mx;
            v.Movi2(:,:,1)=m0;
            v.Movi2(:,:,2)=m; v.list={'imregmax01' 'imregmax02'};
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' imregionalmax_' num2str(v0.fignum)];
            eval ([mfilename figname figname figname])
            
          case 25 % add amount to certain pixels
            if v.rgbyes; disp('NO RGB...'); return; end
            prompt={'amount to add' 'how many pixels? (0=all)',...
              'if not all pixels, select random (0) or brightest (1) fixed location (2)',...
              'first image?' 'skip how many to next image?'};
            title='add to selected pixels'; lineno=1;
            def={'7' '0' '1' '1' '0'};
            inp=inputdlg(prompt,title,lineno,def);
            addit=str2num(inp{1}); npix=str2num(inp{2}); mode=str2num(inp{3});
            img1=str2num(inp{4}); skip=str2num(inp{5});
            v.Movi2=v.Movi;
            bkg=0; if strcmp('double',class(v.Movi)); v.Movi=round(v.Movi); bkg=min(v.Movi(:)); end
            a=v.Movi(:,:,1); idx=(1:numel(a))'; [x y]=ind2sub(size(a),idx);
            nframes=size(v.Movi,3); rnd=rand(numel(a),1);         
            for j=img1:skip:nframes
              m=double(v.Movi(:,:,j));
              a=[m(:) x y]; a((a(:,1)==bkg),:)=[]; 
              rnd2=rnd; if mode<2; rnd2=rand(size(a,1),1); end
              a=[a rnd2(1:size(a,1))]; 
              a=sortrows(a,-1-3*(mode==0));              
              b=a(1:npix,1); b=b+addit; a(1:npix,1)=b;
              for k=1:npix
                v.Movi2(a(k,2),a(k,3),j)=a(k,1);
              end
            end
            setappdata(vh.fig,'v',v)
            v0.callingfig=vh.fig; setappdata(0,'v0',v0)
            figname=[' add_to_pixvals'];
            eval ([mfilename figname figname figname]);
            
        end % imgprocess popup

      case 'newbitdepth'
        v.play=0; setappdata(vh.fig,'v',v);
        if v.rgbyes % RGB to 3 8 bit grayscale images
          inp=questdlg('Change RGB to?', 'Change RGB to 8 bit image(s)',...
            '--> 8 bit grayscale', '--> 3x 8 bit (r,g, and b)',...
            '--> 8 bit grayscale');
          switch inp
            case '--> 8 bit grayscale'
              v.Movi2=v.Movi(:,:,1,:);
              hi=length(v.list);
              for j=1:hi
                disp([num2str(j) ' / ' num2str(hi)])
                drawnow
                a=v.Movi(:,:,:,j);
                v.Movi2(:,:,j)=rgb2gray(a);
              end 
              v.list2=v.list; v0.rgbyes2=0; v.Movi2=uint8(v.Movi2);
              setappdata(vh.fig,'v',v)
              figname=[' RGB-->8bit_' num2str(v.fignum)];
            case '--> 3x 8 bit (r,g, and b)'
              sz=size(v.Movi);
              if length(v.list)==1; sz(end+1)=1; end
              v0.rgbyes2=0; str='RGB'; setappdata(0,'v0',v0)
              for j=1:3
                v.Movi2=zeros(sz(1),sz(2),sz(4)); v.Movi2=uint8(v.Movi2);
                for k=1:sz(4)
                  v.Movi2(:,:,k)=v.Movi(:,:,j,k);
                end
                a=v.Movi2;
                if max(a(:))
                  setappdata(vh.fig,'v',v)
                  v0.callingfig=vh.fig; setappdata(0,'v0',v0)
                  figname=[' ' str(j) '->8bit_' num2str(v.fignum)];
                  eval ([mfilename figname figname figname]);
                end
                v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
              end
              return
          end % switch inp

        else
          switch v.bitdepth
            case 8
              inp=questdlg('Change 8 bits to?', 'Change 8 bit images',...
                '--> stretch 0 255', '--> 16 bit', '--> RGB','--> stretch 0 255');
              switch inp
                case '--> stretch 0 255'
                  lo=round(get(vh.minslider,'value')); hi=round(get(vh.maxslider,'value'));
                  vv=v.Movi; vv(vv>hi)=hi; vv=vv-lo;
                  vv=uint8(double(vv).*255/(hi-lo));
                  v.Movi2=vv;
                  figname=[' stretch_0_255_' num2str(v.fignum)];
                case '--> 16 bit'
                  v.Movi2=uint16(v.Movi);
                  figname=[' 8-->16bit_' num2str(v.fignum)];
                case '--> RGB'
                  sz=size(v.Movi);
                  if length(v.list)==1; sz(end+1)=1; end
                  m=getfig('Fig numbers for Red, Green, and (optional) Blue?');
                  if isempty(m); return; end
                  if size(m,1)==1 % make RGB from frames 1-3
                    m0=zeros(sz(1),sz(2),3,1);
                    for j=1:min(sz(3),3)
                      m0(:,:,j,1)=v.Movi(:,:,j,1);
                    end
                  else % make RGB from 2 or 3 different movies
                    if size(m,1)==2; m(3,1:2)=0; end
                    m0=zeros(sz(1),sz(2),3,sz(3));
                    for j=1:3
                      if m(j,1)>0
                        vv=getappdata(m(j,1),'v');
                        if isa(vv.Movi,'uint16') | v.rgbyes;
                          msgbox('Convert to 8 bits','replace'); return;
                        end
                        for k=1:sz(3)
                          m0(:,:,j,k)=vv.Movi(:,:,k);
                        end
                      end
                    end % for j=1:3
                  end % if size(m,1)==1
                  v.Movi2=uint8(m0); v0.rgbyes2=1;
                  figname=[' 8bit-->RGB_' num2str(v.fignum)];
              end
            case 16
              mn=get(vh.minslider); mx=get(vh.maxslider);               
              inp=questdlg(['Change 16 bit images to 8 bits or Clip to lo-hi (',...
                num2str(mn.Value) ' - ' num2str(mx.Value) ')?'], 'Change 16 bit images',...
                '16 --> 8 bits', 'Clip lo-hi','16 --> 8 bits');               
               switch inp
                   case '16 --> 8 bits'                
                 lo=round(get(vh.minslider,'value')); hi=round(get(vh.maxslider,'value'));
              vv=v.Movi; vv(vv>hi)=hi; vv=vv-lo;
              vv=uint8(double(vv).*255/(hi-lo));
              v.Movi2=vv;
              figname=[' 16->8bit_' num2str(v.fignum)];
                 case 'Clip lo-hi'
                   v.Movi(v.Movi>mx.Value)=mx.Value;
                   v.Movi=v.Movi-mn.Value; mxx=max(v.Movi(:));
                  set(vh.minslider,'Min',0,'Max',mxx,'Value',0)
                  set(vh.maxslider,'Min',0,'Max',mxx,'value',mxx)
                  set(vh.minmaxmode,'string',[ '0 : ' num2str(mxx)])
                  setappdata(vh.fig,'v',v); return
               end
          end

        end % if v.rgbyes
        setappdata(vh.fig,'v',v)
        v0.callingfig=vh.fig; setappdata(0,'v0',v0)
        eval ([mfilename figname figname figname]);
 
      case 'binwd'
        vv=get(vh.binwdslider);
        ss=vv.SliderStep;
        prompt={'Value' 'Min' 'Max' 'Stepsize1' 'Stepsize2'}; title='Bin Width'; lineno=1;
        def={num2str(vv.Value) num2str(vv.Min) num2str(vv.Max) num2str(ss(1)) num2str(ss(2))};
        inp=inputdlg(prompt,title,lineno,def);
        val=str2num(inp{1}); mn=str2num(inp{2}); mx=str2num(inp{3}); 
        ss=[str2num(inp{4}) str2num(inp{5})];
        if mn>mx; mn=mx-1; end 
        if val<mn | val>mx; val=mn; end
        set(vh.binwdslider,'Min',mn,'Max',mx,'Value',val,'SliderStep',ss)
        v.binwd=val;
        setappdata(vh.fig,'v',v);
        eval([mfilename ' binwdslider'])
        hh=findobj(vh.fig,'type','line'); delete(hh)
        bbhisto2
      case 'binwdslider'                  
        vv=get(vh.binwdslider);
        if vv.Value>=vv.Max; vv.Max=vv.Max+abs(vv.Max); vv.Value=vv.Max; end
        if vv.Value<=vv.Min;
          newmin=vv.Min-abs(vv.Min);
          maxnbins=1000;
          minbinwd=(max(v.z2(:))-min(v.z2(:)))/maxnbins;
          vv.Value=max(newmin,minbinwd); vv.Min=vv.Value;    
        end
        set(vh.binwdslider,'min',vv.Min,'max',vv.Max,'value', vv.Value)
        v.binwd=vv.Value;
        set(vh.binwd,'string',num2str(v.binwd))
        setappdata(vh.fig,'v',v)
        hh=findobj(gcf,'type','line'); delete(hh)
        bbhisto2
      case 'binshiftslider'
        v.binshift=get(vh.binshiftslider,'value');
        set(vh.binshifttxt,'string',['Shift ' num2str(v.binshift)])
        setappdata(vh.fig,'v',v)
        hh=findobj(gcf,'type','line'); delete(hh)
        bbhisto2
      case 'histointegrate' % 0=histogram; 1=norm; 2=integrate; 3=integrate & normalize
        v.histointegrate=v.histointegrate+1;
        if v.histointegrate>3; v.histointegrate=0; end
        hh=findobj(vh.fig,'type','line'); delete(hh)
        setappdata(vh.fig,'v',v)
        bbhisto2

         case 'histogauss' % gaussian y = f*a*exp(-((x-xbar)/sd)^2/2*var)
           h=findobj(gcf,'userdata','histofitline');
           try; delete(h); catch; end
           y=v.z2(:,1);
           a=v.histodata(:,2); 
           peak=0; %v.histodata(find(a==max(a)),1); peak=peak(1);
           pos=v.rectsel;
           if isempty(pos); pos=get(gca,'xlim'); pos(2)=0;
           else    pos(2)=pos(1)+pos(3); % selected x window to be fit
           end
           prompt={[ 'peak to reflect on? (mean=' num2str(mean(v.z2))] 'edit results? (0=no; 1=yes)'};
           title='Gaussian reflected on left half'; lineno=1;
           def={num2str(peak) '0'};
           inp=inputdlg(prompt,title,lineno,def);
           %pos=[str2num(inp{1}) str2num(inp{2})];
           peak=str2num(inp{1}); editres=str2num(inp{2});
           pos=get(gca,'xlim');

           y1=y(y<peak);
           y2=2*peak-y1;
           y3=y(y==peak);
           
           y=double([y1; y2; y3]);
           v.z2=y; v.histodata0=v.histodata;
           setappdata(vh.fig,'v',v)
           bbhisto2 % draws the reflected histogram
           v=getappdata(vh.fig,'v');
           a=findobj(gca,'type','line'); set(a(1),'color','blue')
           vari=var(y); a=1/sqrt(2*pi*vari);
           xmin=min(y); xmax=max(y); xbar=mean(y);
           bwcalc=(xmax-xmin)/100; nbins=100;
           x=linspace(xmin,xmax,nbins)';
           xx=(x-xbar).^2;
           b=xbar;
           c=-2*vari;
           Y=a*exp(((x-b).^2)/c);
           areaobs=v.binwd*size(y,1); areacalc=sum(Y(:))*bwcalc;
           f=double(areaobs/areacalc);
           Y=Y*f;
           line('xdata',x,'ydata',Y,...
             'userdata','histofitline')
           a=v.histodata0; a(:,3:4)=0;
           a(1:size(v.histodata),3)=v.histodata(:,2);
           a(:,4)=a(:,2)./(a(:,2)+a(:,3)); % fraction 
           nn=0;
           for j=0.7:0.1:1.0
             nn=nn+1;
         %   n1(nn,1)=j;
          % n1(nn,2)=sum(a(a(:,4)>=j,2));          
          n1(nn,1)=sum(a(a(:,4)>=j,2));
           end
           disp(n1)
           f='junk.txt'; fpath=v0.homedir;
           dlmwrite([v0.homedir 'junk.txt'],a,'\t')
           if editres; edit 'junk.txt' ; end% c1=mid-bin; c2=obs #; c3=reflected #; c4=diff (obs-refl);

           setappdata(vh.fig,'v',v)
        
      case 'plottoorig' % v.z2 to v.zdata
        if isempty(v.z2); return; end
        v.zdata=v.z2;
        setappdata(vh.fig,'v',v)
        eval([mfilename ' ploterase'])
        eval([mfilename ' newplot'])
      
      case 'ploterase'
        v.z2=[]; v.zavg=[]; v.dxarrow=0; v.avgon=0; v.zsem=[];
        hh=findobj(vh.fig,'type','line'); delete(hh);
        hh=findobj(vh.fig,'type','text'); delete(hh);
        setappdata(vh.fig,'v',v)

      case 'xposexy' % transpose
        eval([mfilename ' ploterase'])
        v.zdata=v.zdata';
        v.xdata=[];
        v.yinstr='0';
        setappdata(vh.fig,'v',v)
      case 'newplot'
        clc
        v.linesel=[]; xinfo=''; yinfo='';
        try; a=v.xinstr;
        catch; v.xinstr='0'; v.yinstr='0'; v.omitstr=''; v.omitcond='';
        end
        z=v.zdata;
        prompt={'Graph (0) or Histogram (1)?',...
          'X column or Op (0=row number)',...
          'Y column(s) (0=all; use "to" for range (e.g., "5 to 12")) or Op',...
          ['Include all data, or only from some rows?' char(10),...
          'Array z has ' num2str(size(z,1)) ' rows and ' num2str(size(z,2)),...
          ' columns. Examples:' char(10),...
          'Plot data only from rows 3 to 20: Enter r3:20' char(10),...
          'Plot data only if value in column 4 is >0.5: Enter c4)>0.5']  };
        title=['File has ' num2str(size(v.zdata,2)) ' columns and ' num2str(size(v.zdata,1)) ' rows.'];
        lineno=1;
        def={num2str(v.histo); v.xinstr; v.yinstr; v.omitstr};
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        v.histo=str2double(inp{1});
        v.xinstr=inp{2}; v.yinstr=inp{3}; v.omitstr=inp{4};
        
        % Omit rows
        if ~isempty(v.omitstr) % make z (only rows selected) from zz
          switch(v.omitstr(1))
            case {'r' 'R'}
              str2=['z=z(' v.omitstr(2:end) ',:);'];
            case {'c' 'C'}
              str2=['z=z(z(:,' v.omitstr(2:end) ',:);'];
          end
          setappdata(vh.fig,'v',v)
          try; eval(str2); catch; disp('Omit failed!'); end
          v=getappdata(vh.fig,'v');
          
        end
        
        % get Y data
        a=findstr(v.yinstr,'to');
        if ~isempty(a);
          n1=str2num(v.yinstr(1:a-1)); n2=str2num(v.yinstr(a+2:end));
          v.yinstr=''; for j=n1:n2; v.yinstr=[v.yinstr ' ' num2str(j)]; end
        end
        
        a=str2num(v.yinstr);
        if isempty(a) % string, not number
          eval(['yy=' v.yinstr]);
        else
          if a==0; a=1:size(z,2); v.yinstr=num2str(a); end
          try
            yy=z(:,a);
          catch
            return;
          end
          if isfield(v,'colheaders')
            %            yinfo={['Col ' num2str(a) ': ' v.colheaders{a}]};
          end
        end
        % get X data
        a=str2num(v.xinstr);
        if isempty(a)
          eval(['xx=' v.xinstr]);
        elseif a<1 || a>size(z,2)
          xx=(1:size(yy,1))';
        else xx=z(:,a(1));
          if isfield(v,'colheaders')
            xinfo={['Col ' num2str(a) ': ' v.colheaders{a}]};
          end
        end
        if isempty(xinfo); xinfo={['Xcol: ' v.xinstr]}; end
        if isempty(yinfo); yinfo={['Ycol(s): ' v.yinstr]}; end
        omitinfo={['Omit if: ' v.omitstr]};
        xlabel(xinfo); ylabel(yinfo)
        xy=[xx yy];
        v.xdata=double(xy(:,1));
        if size(v.z2,2)
          v.z2=bbpaste(v.z2, yy, 'horizontal');
        else
          v.z2=yy;
        end
        v.z2original=v.z2;
        setappdata(vh.fig,'v',v)
        bbplot2
      case 'plotzoom'
        if v.plotzoom;
          inp=questdlg('Zoom again?');
          if strcmp(inp,'Yes'); v.plotzoom=0; end
        end
        v.plotzoom=~v.plotzoom;
        switch v.plotzoom
          case 0
            v.newzoom=0; setappdata(vh.fig,'v',v) % used for arrow keys
            set(vh.plotzoom,'backgroundcolor',[1 .8 .5])
            set(vh.plotax,'xlimmode','auto','ylimmode','auto')
          case 1
            v.newzoom=1; setappdata(vh.fig,'v',v) % used for arrow keys
            set(vh.plotzoom,'backgroundcolor','red')
            pos=getrect;
            set(vh.plotax,'xlim',[pos(1), pos(1)+pos(3)])
            zoomy=0;
            if zoomy; set(vh.plotax,'ylim',[pos(2), pos(2)+pos(4)]); end
        end
        drawnow
        setappdata(vh.fig,'v',v)
      case 'plotcut'  
        xmode=get(vh.plotax,'xlimmode');
        if strcmp(xmode,'auto'); return; end
        xlimit=get(vh.plotax,'xlim');
        prompt={'Xlow', 'Xhigh'}; title='Cut X'; lineno=1;
        def={num2str(round(xlimit(1))), num2str(round(xlimit(2)))};
        inp=inputdlg(prompt,title,lineno,def);
        xlo=str2num(inp{1}); xhi=str2num(inp{2});
     %   aa=find(v.xdata<xlo | v.xdata>xhi);
       % v.xdata(aa)=[]; v.xdata=double(v.xdata-min(v.xdata));        
       v.xdata=[];
         v.newzoom=0;  v.plotzoom=0; % used for arrow keys
            set(vh.plotzoom,'backgroundcolor',[1 .8 .5])
            set(vh.plotax,'xlimmode','auto','ylimmode','auto')
       % v.z2(aa,:)=[]; 
       v.z2(xhi:end,:)=[]; v.z2(1:xlo,:)=[];
       v.zavg=[]; 
        setappdata(vh.fig,'v',v)
        bbplot2
       
      case 'ploterase'
        delete(gcbo)
      case 'plotresetfit'
        v.plotfitdata=[]; v.lastplotfitexpr=[];
        h2=findobj(vh.fig,'userdata','plotfitline'); delete(h2)
        h2=findobj(vh.fig,'type','text'); delete(h2)
        h2=findobj(vh.fig,'userdata','plotfit0'); set(h2,'visible','off')
        try; delete(findobj(vh.fig,'userdata','plotlinemanual')); catch; end
        setappdata(vh.fig,'v',v)
      case 'plotfitpopup'
        v.lastplotfitexpr=[];
        nn=get(vh.plotfitpopup,'value');
        switch nn
          case 1 % single expl decay + cnst
            v.plotfitmodel=1;
          case 2 % double expl decay + cnst
            v.plotfitmodel=2;
          case 3 % single expl rist + cnst
            v.plotfitmodel=3;
          case 4
            v.plotfitmodel=4;
          case 5
            v.plotfitmodel=5;
          case 6
            v.plotfitmodel=6;
          case 7
            v.plotfitmodel=7;
          case 8
            v.plotfitmodel=8;
          case 9 % HELP
            str={'#1 = Single Expl Decay + constant.',...
              ' y=y01*exp(k1*x) + cnst',...
              '',...
              '#2 = Double Expl Decay + constant',...
              ' y=y01*exp(k1*x) + y02*exp(k2*x) + cnst',...
              '',...
              '#3 = Single Expl Rise + constant',...
              ' y=y01*(1-exp(k1*x)) + constant',...
              '',...
              '#4 = Linear Regression',...
              'y=y01*x + constant',...
              '',...
              '#5 = Gaussian fit',...
              'y=a*exp(-((x-b)/c)^2)' };
            '',...
              '#6 = expl decay + sigmoid rise',...
              'y=A*exp(-x/B) + C/(1+D*exp(-E*(x-F)))'
            str2='';
            for j=1:size(str,2); str2=[str2; str(j)]; end
            msgbox(str2,'replace')
        end
        setappdata(vh.fig,'v',v)
      case 'plotfit'
        plotfit
      case 'plotfitsubexpl'
        A=checkslider(vh.plotfitA,'Slider A'); B=checkslider(vh.plotfitB, 'Slider B');
        x=v.xdata;
        expr='A*exp(-x/B)';
        yfit=eval(expr);
        v.z2=v.z2-yfit;
        v.zdata(:,7)=v.z2;
        bbplot2
        setappdata(vh.fig,'v',v)
        
      case 'plotfitslider'
        % h=findobj(vh.fig,'userdata','plotfitline'); delete(h)
        A=checkslider(vh.plotfitA,'Slider A'); set(vh.plotfitAtxt,'string',num2str(A))
        B=checkslider(vh.plotfitB, 'Slider B'); set(vh.plotfitBtxt,'string',num2str(B))
        C=checkslider(vh.plotfitC, 'Slider C'); set(vh.plotfitCtxt,'string',num2str(C))
        D=checkslider(vh.plotfitD, 'Slider D'); set(vh.plotfitDtxt,'string',num2str(D))
        E=checkslider(vh.plotfitE, 'Slider E'); set(vh.plotfitEtxt,'string',num2str(E))
        x=double(v.xdata);
        expr=v.plotfitexpr;
        disp(' ')
        switch v.plotfitmodel
          case 1 % expl udecay + c
            disp(['A0(x=' num2str(x(1)) ')=' num2str(A),...
              '; y(x=' num2str(x(1)) ')=' num2str(A+C),...
              '; Integral expl=' num2str(A*B)])
            x=x-v.xoffset;
            yfit=eval(v.plotfitexpr);
            x=x+v.xoffset;
          case 2 % dbl expl decay + c
            yfit=eval(v.plotfitexpr);
          case 3 % expl riseyfit=eval(v.plotfitexpr);
            x=x-v.xoffset;
            yfit=eval(v.plotfitexpr);
            x=x+v.xoffset;
          case 4 % linear
            yfit=eval(expr);
          case 5 % gaussian
            yfit=eval(v.plotfitexpr);
          case 6 % expl decay + sigmoid rise
            p1=findstr(expr,'+'); p1=p1(1);
            yfit1=eval(expr(1:p1-1)); yfit2=eval(expr(p1+1:end));
            yfit=yfit1+yfit2;
            set(vh.plotline1,'xdata',x, 'ydata',yfit1)
            set(vh.plotline2,'xdata', x,'ydata',yfit2)
            a1=cumsum(yfit1); a2=cumsum(yfit2);
            yy=v.z2(:,1); if ~isempty(v.zavg); yy=v.zavg; end
            A0=A/exp(-x(1)/B); Aintg=A0*B;
            disp(['A0=' num2str(A0) '; Expl integral=' num2str(Aintg)])
          case 7 % expl decay and expl^E rise
            p1=findstr(expr,'+'); p1=p1(1);
            yfit1=eval(expr(1:p1-1)); yfit2=eval(expr(p1+1:end));
            yfit=yfit1+yfit2;
            set(vh.plotline1,'xdata',x, 'ydata',yfit1)
            set(vh.plotline2,'xdata', x,'ydata',yfit2)
            a1=cumsum(yfit1); a2=cumsum(yfit2);
            yy=v.z2(:,1); if ~isempty(v.zavg); yy=v.zavg; end
            A0=A/exp(-x(1)/B); 
            Aintg=round(A*B); % A0*B;
            %disp(['A0=' num2str(A0) '; Expl integral=' num2str(Aintg)])
           % disp(['Intg=' num2str(Aintg)])  
             disp('Expl integral; A; B; C; D; E; Rsquared')
            disp(Aintg)           
          case 8 % expl fall + delayed expl rise
            p1=findstr(expr,'+'); p1=p1(1);
            yfit1=eval(expr(1:p1-1)); yfit2=eval(expr(p1+1:end));
            yfit=yfit1+yfit2;
            set(vh.plotline1,'xdata',x, 'ydata',yfit1)
            set(vh.plotline2,'xdata', x,'ydata',yfit2)
            a1=cumsum(yfit1); a2=cumsum(yfit2);
            yy=v.z2(:,1); if ~isempty(v.zavg); yy=v.zavg; end
            A0=A/exp(-x(1)/B); 
            Aintg=round(A*B); % A0*B;
            disp('Expl integral; A; B; C; D; E; Rsquared')
            disp(Aintg)
            %disp(['Int=' num2str(Aintg)])    
        end
        
        set(vh.plotline0,'xdata',x,'ydata',yfit,'color','black'); drawnow
        % calculate Rsqd
        yobs=v.yobs0;
        sstot=sum((yobs-mean(yobs)).^2);
        sserr=sum((yobs-double(yfit)).^2);
        rsq=1-sserr/sstot;
        %disp(['A= ' num2str(A) char(10) 'B= ',...
         % num2str(B) char(10) 'C= ' num2str(C) char(10) 'D= ',...
          %num2str(D) char(10) 'E= ' num2str(E) char(10) 'R^2= ',...
         % num2str(rsq)])                
        disp([A; B; C; D; E; rsq])         
        try; showit=v.showdata; catch; showit=0; v.showdata=0; end
        if showit
          clc
          disp('NOTE: First column is observed, followed by fitted values')
          v.showdata=0;
          try; b=[yfit1 yfit2]; catch; b=[]; end
          a0=v.z2; if v.avgon; a0=v.zavg; end 
          a=[a0 b yfit];
          f='junk.txt'; fpath=v0.homedir;
          dlmwrite([v0.homedir 'junk.txt'],a,'\t')
          edit 'junk.txt'
        end
        setappdata(vh.fig,'v',v)
      case 'plotfitdisp'
         v.showdata=1;
         setappdata(vh.fig,'v', v)
         eval([mfilename ' plotfitslider'])
      case 'plotfitholdget'
        inp=questdlg('Hold or recall?', 'Hold or recall?', 'Hold', 'Recall', 'Hold');
        switch inp
          case 'Save'
            v.holdplotfit(1,1)=get(vh.plotfitA,'value');v.holdplotfit(2,1)=get(vh.plotfitB,'value');
            v.holdplotfit(3,1)=get(vh.plotfitC,'value');v.holdplotfit(4,1)=get(vh.plotfitD,'value');
            v.holdplotfit(5,1)=get(vh.plotfitE,'value');
            setappdata(vh.fig,'v',v)
          case 'Recall'
            set(vh.plotfitA,'value',v.holdplotfit(1,1)); set(vh.plotfitB,'value',v.holdplotfit(2,1));
            set(vh.plotfitC,'value',v.holdplotfit(3,1));set(vh.plotfitD,'value',v.holdplotfit(4,1));
            set(vh.plotfitE,'value',v.holdplotfit(5,1))
            eval([mfilename ' plotfitslider'])
        end
        
      case 'plotline'
        a=get(gcbo);
        v.selectall=0;
        slct=find(v.linesel==gcbo); % already selected?
        mclr=a.MarkerFaceColor;
        linewd=a.LineWidth;
        button=get(vh.fig,'selectiontype');
        if (strcmp(button,'normal'))
          if ~isempty(slct) % select all
            v.selectall=1;
            v.linesel=findobj(vh.fig,'type','line','userdata','plotline');
            set(v.linesel,'Color',[0 1 1],'LineWidth',linewd)
          else % select this one only
            v.linesel=unique([v.linesel; gcbo]);
            set(gcbo,'Color',[0 1 1],'LineWidth',linewd+1)
          end
        elseif (strcmp(button,'alt')); % right button
          if isempty(slct) % deselect all
            v.linesel=[];
            bbplot2
          else % deselect this one
            v.linesel(v.linesel==gcbo)=[];
            set(gcbo,'Color',mclr,'LineWidth',max(0.1,linewd-1))
          end
        end
        setappdata(vh.fig,'v',v)
      case 'plotfitwindow'
        if ~isempty(v.rectsel);
          v.rectsel=[];
          try
            delete(vh.rectsel);
          catch
          end
          set(vh.plotfitwindow,'backgroundcolor',[1 .7 .7])
          h2=findobj(vh.fig,'type','rectangle'); delete(h2)
        else
          set(vh.plotfitwindow,'backgroundcolor',[1 0 0])
          v.rectsel=getrect;
          vh.rectsel=rectangle('position',v.rectsel);
        end
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
      case 'plotsave'
        try; cd (v.picdir); catch; end
        [f fpath]=uiputfile('*.mat','Save Matlab file');
        try
          v.Movi=[]; v.Movi2=[];
          setappdata(vh.fig,'v',v);
        catch
        end
        try
          save([fpath f],'v')
          v.picdir=fpath;
        catch; disp('no joy')
        end
        try; cd (v0.homedir); catch; end
      case 'plotload'
        pastemode='none';
        if size(v.z2,2)
          prompt='How to paste files?'; title='Paste horizontal or vertical?';
          choices={'horizontal' 'vertical' 'cancel'}; def='horizontal';
          pastemode=questdlg(prompt,title,choices{:},def);
          if strcmp(pastemode,'cancel'); return; end
        end
        cd (v.picdir)
        [f fpath]=uigetfile({'*.mat';'*.daq'},'Pick Matlab file');
        z2=v.z2; zdata=v.zdata;
        if strcmp(f(length(f)-2:end),'daq')
          try
            [v.zdata,v.xdata,abstime]=daqread([fpath f]); v.picdir=fpath;
          catch
            return
          end
          v.zdata=[v.xdata v.zdata];
          t = fix(abstime); disp('First trigger at:'); sprintf('%d:%d:%d',t(4),t(5),t(6))
          pastemode='none'; z2=[];
        else
          try
            load([fpath f]); v.picdir=fpath;
            %v.zdata=vdat;
          catch
            return
          end
        end
        if exist('vdat'); 
            v.zdata=vdat; v.xdata=[]; v.zavg=[];         
        else
        if ~strcmp('none',pastemode);
          v.zdata=bbpaste(zdata,v.z2,pastemode);
          v.z2=bbpaste(z2,v.z2,pastemode);
        end
        v.zavg=[]; v.avgon=0;
        if size(z2,2)
          v.xdata=double((1:size(v.z2,1))');
        else
          if ~isfield(v,'xdata'); v.xdata=double((1:size(v.z2,1))'); end
        end
        end
        v.linesel=[];
        v.name=[f '_' num2str(v0.fignum)];
        set(vh.fig,'name',v.name)
        eval([mfilename ' plotresetfit'])
        setappdata(vh.fig,'v',v)
        return
      case 'plotload2'
        bbmakelist
        v=getappdata(vh.fig,'v');
        list=v.list; picdir=v.picdir;
        y=[]; zdata=v.zdata; z2=v.z2;
        pastemode=0; % 0=paste horiz, 1=paste vert
        for j=1:length(list)
          try
            load([picdir list{j}])
            if pastemode
              y=[y; v.z2(:,1)];
              if size(v.z2,2)>1; disp([list{j} ' has ' num2str(size(v.z2,2)) ' columns']); end
            else
              y=bbpaste(y,v.z2,'horizontal');
            end
            disp(list{j})
          catch
            disp(['   Error loading ' list{j}])
          end
        end
        v.z2=bbpaste(z2,y, 'horizontal');
        v.zdata=bbpaste(zdata,y,'horizontal'); v.zavg=[];
        cd (v0.homedir)
        v.xdata=double((1:size(v.z2,1))');
        v.linesel=[];
        v.name=[list{1} '_' num2str(v0.fignum)];
        set(vh.fig,'name',v.name)
        eval([mfilename ' plotresetfit'])
        setappdata(vh.fig,'v',v)
        bbplot2
        return
      case 'plotnewgraph'
        v.newname=v.name;
        setappdata(vh.fig,'v',v)
        bbplot
        return

      case 'plotpaste'
            f='junk.txt'; fpath=v0.homedir;
            dlmwrite([v0.homedir 'junk.txt'],[],'\t')
            edit 'junk.txt'
            h2=msgbox('Paste, save, click OK when done','replace');
            waitfor(h2)
            v.newname='Paste';
            z=importdata([fpath f],'\t'); 
             v.zdata=z; v.zavg=[]; v.z2=[]; v.xdata=[];
        v.linesel=[]; v.name=f;
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
        bbplot2
          case 'plottextfile'
            try
              cd (v.picdir);
            catch
            end
            [f fpath]=uigetfile('*.txt','Pick ASCII file');
            if isempty(f); return; end
            v.picdir=fpath;
            try
              cd v0.homedir;
            catch
            end
            v.newname=f;
         
        z=importdata([fpath f],'\t'); % z.data holds the data
        if isstruct(z);
          n=fieldnames(z); clc
          disp([f ' contains the following fields:'])
          for j=1:size(n,1)
            disp([num2str(j) ': ' n{j}])
            v.(n{j})=z.(n{j});
          end
          z=z.data;
        end
        v.zdata=z; v.zavg=[]; v.z2=[]; v.xdata=[];
        v.linesel=[]; v.name=f;
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
        bbplot2
      case 'plotexport'
        [fname,pname]=uiputfile('*.txt','File name?');
        zz=v.zdata;
        if size(v.z2,2)
          inp=questdlg('Export ALL data or currently plotted data?',...
            'All or plotted?','ALL','plotted','cancel','plotted');
          if strcmp(inp,'cancel'); return; end
          if strcmp(inp,'ALL'); zz=v.zdata;
          else zz=v.z2;
            if ~isempty(v.zavg); zz=v.zavg(:,end); end
          end
        end
        dlmwrite([pname fname],zz,'delimiter','\t','precision',6)

      case 'plotnormalize'
        try
          v.normalize=~v.normalize;
        catch
          v.normalize=1; v.z2original=v.z2;
        end
        switch v.normalize
          case 0
            v.z2=v.z2original;
          case 1
            prompt={'First point?' 'Last point?'};
            title='First, last points to average?';
            lineno=1; def={'1' '1'};
            inp=inputdlg(prompt,title,lineno,def);
            p1=str2double(inp{1}); p2=str2double(inp{2});
            for j=1:size(v.z2,2)
              norm=mean(v.z2(p1:p2,j));
              disp(norm)
              v.z2(:,j)=100*v.z2(:,j)./norm;
            end
        end
        setappdata(vh.fig,'v',v)
        bbplot2
      case 'plotsymbol'
        try
          v.sym=v.sym+1;
        catch
          v.sym=0;
        end
        if v.sym>2; v.sym=0; end
        setappdata(vh.fig,'v',v)
        bbplot2
      case 'plotgrid'
        try
          v.isgrid=~v.isgrid;
        catch
          v.isgrid=1;
        end
        if v.isgrid; grid on; else grid off; end
        setappdata(vh.fig,'v',v)
      case 'plotdispdata' % Displays data - no editing possible
        zz=v.zdata;
        if size(v.z2,2)
          inp=questdlg('Display ALL data or currently plotted data?',...
            'All or plotted?','ALL','plotted','cancel','plotted');
          if strcmp(inp,'cancel'); return; end
          if strcmp(inp,'ALL'); zz=v.zdata;
          else zz=v.z2;
            if ~isempty(v.zavg); zz=v.zavg(:,end); end
            if ~isempty(v.zsem); zz=[zz v.zsem]; end;
            if v.histo; zz=v.histodata; end
          end
        end
        dlmwrite([v0.homedir 'junk.txt'],zz,'\t')
        edit 'junk.txt'

      case 'plotclose'
        delete(vh.fig)
        return
      case 'plotdispfit'
        f=[v0.homedir 'junk.txt'];
        %disp('Columns: 1:First X point 2:F0 3:dF 4:EndoTau')
        disp(['Plot fit equation: ' v.plotfitexpr])
        %dlmwrite(f,v.plotfitdata,'\t')
        dlmwrite(f,v.plotfitexpr,'')
        dlmwrite(f,v.plotfitdata,'-append','delimiter','\t')
        edit 'junk.txt'
      case 'plotsmoothtxt'
        val=round(get(vh.plotsmooth,'value'));
        prompt={'Smooth how many points? (odd number)'};
        title='Smooth'; lineno=1; def={num2str(val)};
        inp=inputdlg(prompt,title,lineno,def);
        val2=str2double(inp{:});
        mx=round(get(vh.plotsmooth,'max'));
        set(vh.plotsmooth,'value',val2,'max',max(val2,mx))
        eval([mfilename ' plotsmooth'])
      case 'plotsmooth'
        val=round(get(vh.plotsmooth,'value'));
        if round(val/2) == val/2;  val=val+1; end
        v.smooth=val; % val=2*val+1;
        v.z2=v.z2original;
        set(vh.plotsmoothtxt,'string',['Smooth ' num2str(v.smooth)]);
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
        bbplot2
      case 'plotreset'
        v.z2=[]; v.zdata=[]; v.zavg=[];
        v.xdata=[]; v.histo=0;
        v.linesesl=[]; v.rectsel=[]; v.plotfitdata=[];
        h2=findobj(vh.fig,'type','rectangle'); delete(h2)
        h2=findobj(vh.fig,'type','text'); delete(h2)
        h2=findobj(vh.fig,'type','line'); delete(h2)
        set(vh.plotsmooth,'value',0)
        set(vh.plotsmoothtxt,'string','Smooth 1')
        xlabel(''); ylabel('');
        setappdata(vh.fig,'v',v)
        bbplot2

      case 'subtractbkg' % subbkg sub bkg subtract bkg
        inp=questdlg('Subtract smoothed or Draw baseline?',...
          'Subtract bkg',...
          'SubtractSmoothed','Draw','Draw');
        switch inp
          case 'FitExpByEye'
            return
          case 'SubtractSmoothed'
            % elseif strcmp(inp,'SubtractSmoothed')
            z3=v.z2
            if ~isempty(v.zavg)
              v.zavg(:,1)=v.zavg(:,1)-v.zavg(:,2);
              v.zavg(:,2)=[];
            else           
              v.z2=v.z2original-v.z2;
            end
            set(vh.plotsmooth,'value',0); set(vh.plotsmoothtxt,'string','Smooth 1')
            v.smooth=1;
            setappdata(vh.fig,'v',v)
            set(gca,'ylimmode','auto')
            bbplot2

            try; a=v.Movi; catch; return; end
            callingfig=v.callingfig;
            vv=getappdata(callingfig,'v');
            if size(vv.Movi,3) ~= size(v.z2,1);
              msgbox('Number of movie frames selected for display does not equal number of background points! Subtraction not possible','replace');
              return;
            end
            inp=questdlg('Subtract background values from images?');
            if strcmp(inp,'No'); return; end
            m=double(vv.Movi);
            rnd=rand; m(m==0)=rnd; %bkg
            for j=1:size(m,3)
              a=m(:,:,j); 
              a(a~=rnd)=a(a~=rnd)-z3(j,1);
              m(:,:,j)=a;
            end
            mn=min(m(:)); m(m==rnd)=mn-1;
            vv.Movi2=m;
            
            setappdata(callingfig,'v',vv)
            v0.callingfig=callingfig; setappdata(0,'v0',v0)
            str=[' bkgsubtract_' num2str(v0.fignum)];
            eval([mfilename str str str])

          case 'Draw'
            if isempty(v.linesel);
              h2=findobj(vh.fig,'type','line','userdata','plotline');
              if size(h2,1)==1; v.linesel=h2; v.selectall=1;
              else msgbox('First select a line','replace'); return; end
            end
            str=['Left click to select multiple points (points ',...
              'will be fit by interp1 using spline). Right click to end'];
            hh=msgbox(str,'replace');
            waitfor(hh)
            hh=findobj(vh.fig,'type','line','userdata','plotline');
            set(hh,'buttondownfcn','')
            [x y]=getpts;
            x(end)=[]; y(end)=[];
            [x,m,n]=unique(round(x)); y=y(m);
            try
              xi=v.xdata; if isempty(xi); xi=(1:size(v.z2,1))'; end
            catch; xi=(1:size(v.z2,1))'; end
            yi=interp1(x,y,xi,'spline');
            v.zavg=[];
            hline=line(xi,yi);
            inp=questdlg('Subtract this?');
            if ~strcmp(inp,'Yes'); return; end
            for j=1:size(v.linesel,1)
              col=size(hh,1)-find(hh==v.linesel(j))+1;
              v.z2(:,col)=v.z2(:,col)-yi; % get(v.linesel(j),'ydata')';
            end
            v.z2original=v.z2;
            delete(hline)
            hh=findobj(vh.fig,'type','line','userdata','plotline');
            set(hh,'buttondownfcn',[mfilename ' plotline'])
            setappdata(vh.fig,'v',v)
            bbplot2
        end
      case 'plotchop'
        z=v.z2;
        try
          def={num2str(v.chop)};
        catch
          def={'10'}; v.chop=1;
        end
        inp=inputdlg({'Interval (# points)?'},'Chop X axis',1,def);
        v.chop=round(str2double(inp{:}));
        nintervals=floor(size(z,1)/v.chop);
        zz=zeros(v.chop,size(z,2)*nintervals);
        col=0;
        for zcol=1:size(z,2)
          for j=1:nintervals
            col=col+1;
            zrow=(j-1)*v.chop+1;
            zz(:,col)=z(zrow:zrow+v.chop-1,zcol);
          end
        end
        v.z2=zz; v.z2original=zz;
        v.zavg=[];setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
        bbplot2

      case 'avgonoff' %Avg on/off
        try; a=v.avgon; catch; v.avgon=0; v.xbw=0; end
        v.xavg=[];
        v.avgon=~v.avgon;
        v.smooth=1; set(vh.plotsmooth,'value',1); set(vh.plotsmoothtxt,'string','smooth 1')
        if v.avgon;
          prompt={'Show SEM? (0=no)' 'X binning? Type number of bins (0=no xbinning)'}; title='Avg on/off';
          lineno=1; def={'0' '0'};
          inp=inputdlg(prompt,title,lineno,def);
          z=v.z2original';
          v.zavg=nanmean(z)';
          v.zsem=[]; if str2num(inp{1}); v.zsem=std(z)'/sqrt(size(z,1)); end % SEM
          nbins=str2num(inp{2});
          if nbins
            v.xbw=(max(v.xdata)-min(v.xdata))/nbins+1/nbins;
            xy=[v.xdata v.zavg]; xy=sortrows(xy,1);
            xdata=xy(:,1); ydata=xy(:,2);
            nn=0;
            for j=xy(1,1):v.xbw:xy(end,1)+v.xbw
              nn=nn+1;
              rows=find(xdata>=j & xdata<j+v.xbw);
              yvals=ydata(rows);
              if size(yvals,1)
                res(nn,1)=j; % left edge of x bin
                res(nn,2)=mean(yvals);
                res(nn,3)=std(yvals)/sqrt(size(yvals,1)); % SEM
                res(nn,4)=size(rows,1); % number of points
              else
                nn=nn-1;
              end % if size(yvals,1)
            end % for j=floor...
            v.xavg=res; v.zavg=[]; v.zsem=[];
          end % if nbins
        else % averaging turned off
          v.zavg=[]; v.zsem=[]; v.z2=v.z2original;
        end % turn on/off
        setappdata(vh.fig,'v',v)
        bbplot2
      case 'plotpopup' % MISC PLOT POPUP
        nn=round(get(vh.plotpopup,'value')); set(vh.plotpopup,'value',1)
        z2=v.z2; 
        switch nn % 2=LinearRegression;3=Avg;4=Xcov;5=Model;6=Save;7=Scale;8=Movie
          case 1 %
            return
          case 2 % LinReg
            x=(1:size(z2,1))';
            for j=1:size(z2,2)
              y=z2(:,j);
              p=polyfit(x,y,1);
              y2=p(1)*x+p(2);
              y=y+(p(2)-y2);
              z2(:,j)=y;
            end
            v.z2=z2;
            setappdata(vh.fig,'v',v)
            bbplot2
          case 3 % Y axis scale
            if strcmp(get(gca,'YLimMode'),'manual')
              set(gca,'YLimMode','auto')
            else
              a=get(gca,'ylim');
              prompt={'Y axis minimum?' 'Y axis MAX?'};
              title='Y axis scale'; lineno=1;
              def={num2str(a(1)), num2str(a(2))};
              inp=inputdlg(prompt,title,lineno,def);
              set(gca,'ylim',[str2num(inp{1}), str2num(inp{2})])
            end
            return
          case 4 % Xcov Xcorr
            z=v.z2;
            prompt={'Auto (0) or Cross (1) correlation?',...
              'Xcorr (0) or Xcov (1)?',...
              'Entire plot (0) or cut in half (1)?',...
              'Omit first point (0) or not (1)'};
            title='Auto/Cross Correlation/Covariance'; lineno=1;
            def={'1' '0' '0' '1'};
            inp=inputdlg(prompt,title,lineno,def);
            corrmode=str2num(inp{1});
            corrcov=str2num(inp{2});
            chopit=str2num(inp{3});
            ofp=str2num(inp{4}); % OmitFirstPoint (0=no; 1=yes)
            z2=[];
            switch corrmode
              case 1 % 'cross'
                ncol=0;
                for j=1:size(z,2)-1
                  for k=j+1:size(z,2)
                    ncol=ncol+1;
                    if corrcov
                      [c]=xcov(z(:,j),z(:,k));
                    else
                      [c]=xcorr(z(:,j),z(:,k),'coeff');
                    end
                    c0=(size(c,1)+1)/2; % middle point
                    if chopit; c=c(c0+ofp:end); end
                    z2(:,ncol)=c;
                    vv=var(z(:,j));
                    avg=mean(z(:,j));
                    str=['Trace ' num2str(j) '( vs ' num2str(k) '): ',...
                      'variance (' num2str(j) ')=' num2str(vv) '; mean=' num2str(avg) '; var/mean=' num2str(vv/avg) ];
                    disp(str)
                  end
                end
              case 0 % 'auto'
                for ncol=1:size(z,2)
                  if corrcov
                    [c]=xcov(z(:,ncol));
                  else
                    [c]=xcorr(z(:,ncol));
                  end
                  c0=(size(c,1)+1)/2; % middle point
                  if chopit;     c=c(c0+ofp:end); end
                  z2(:,ncol)=c;
                  vv=var(z(:,ncol));
                  avg=mean(z(:,ncol));
                  str=['Trace ' num2str(ncol)  ': ',...
                    'variance=' num2str(vv) '; mean=' num2str(avg) '; var/mean=' num2str(vv/avg) ];
                  disp(str)
                end
            end % switch/case
            v.z2=z2; v.xdata=[1:size(v.z2)]';
            v.xdata=v.xdata-size(z,1);
            v0.xscaler='log'; % setappdata(0,'xscaler','log')
            setappdata(vh.fig,'v',v)
            grid on
            bbplot2
            
          case 5 % fft
            % return
            v.z2=[];
            for j=1:size(z2,2)
              F=fft(z2(:,j)); % 2D fft, padded to sz x sz
              F=fftshift(F); % put low frequencies at center
              F2=abs(F);
              F2=log10(F2); % log plot
              F2=F2.*F2;
              F2=F2(floor(size(F2,1)/2+1):end); % plot from center to corner only
              F2=F2(2:end,1);
              v.z2(:,j)=F2;
            end
            setappdata(vh.fig,'v',v)
            bbplot2
          case 6 % differentiate
            aa=zeros(1,size(v.z2,2));
            v.z2=[aa; diff(v.z2)];
            setappdata(vh.fig,'v',v)
            bbplot2
          case 7 % Save
            [fname,pname]=uiputfile('*.txt','File name?');
            if (fname ~= 0)
              if isempty(findstr(fname,'.txt')); fname=[char(fname) '.txt']; end
              z3=v.z2;
              save([pname fname],'z3', '-ASCII')
            end
          case 8 % Get Peaks
            prompt={'First baseline point' '# baseline points',...
              'First peak point' '# peak points',...
              'Mode (avg,max,min)'}; title='Measure peak'; lineno=1;
            def=v.getpeak;
            v.getpeak=inputdlg(prompt,title,lineno,def);
            b1=str2double(v.getpeak{1}); db=str2double(v.getpeak{2});
            p1=str2double(v.getpeak{3}); dp=str2double(v.getpeak{4});
            peakmode=v.getpeak{5};
            zz=zeros(size(v.z2,2),3);
            for j=1:size(v.z2,2)
              y=v.z2(:,j); yp=y(p1:p1+dp-1);
              zz(j,1)=mean(y(b1:b1+db-1));
              switch peakmode
                case 'avg'; zz(j,2)=mean(yp);case 'max'; zz(j,2)=max(yp); case 'min'; zz(j,2)=min(yp); end
                zz(j,3)=zz(j,1)-zz(j,2);
            end
            dlmwrite([v0.homedir 'junk.txt'],zz,'\t')
            edit 'junk.txt'
            setappdata(vh.fig,'v',v)
          case 9 % Movieplot
            v.z3=v.z2;
            try; v.xdata2=v.xdata; catch; v.xdata=double([1:size(v.z2,1)]'); v.xdata2=v.xdata; end
            if isempty(v.xdata); v.xdata=double([1:size(v.z2,1)]'); v.xdata2=v.xdata; end
            outfmt=questdlg('Output format?','Output format','8bit','16bit','RGB','8 bit');
            set(gca,'units','pixels'); pos=get(gca,'position');
            prompt={'width' 'height'}; title='Size of movie?';
            lineno=1; def={num2str(pos(3)) num2str(pos(4))};
            inp=inputdlg(prompt,title,lineno,def);
            pos(3)=str2double(inp{1}); pos(4)=str2double(inp{2});
            set(gca,'position',pos)

            v.nobuttonchange=1; hh=findobj(vh.fig,'type','uicontrol');
            set(hh,'visible','off')
            set(gca,'xlimmode','manual','ylimmode','manual');
            dim=2; 
              for j=1:size(v.z3,dim)
              switch dim
                case 1 % movie along x axis
              v.z2=v.z3(1:j,:);
              v.xdata=double(v.xdata2(1:j,1));
                case 2 % one frame per column
              v.z2=v.z3(:,j);
              v.xdata=[];
              end 
              setappdata(vh.fig,'v',v)
              bbplot2
              if j==1;
                F=getframe(gca); a=F.cdata; sz=size(a);
                Moviplot=uint16(0); v.rgbyes=0;
                if strcmp(outfmt,'8bit') || strcmp(outfmt,'RGB'); Moviplot=uint8(0); end
                Moviplot=Moviplot(ones(1,sz(1)),ones(1,sz(2)),ones(1,size(v.z3,dim)));
                if strcmp(outfmt,'RGB');
                  Moviplot=Moviplot(ones(1,sz(1)),ones(1,sz(2)),ones(1,3),ones(1,size(v.z3,dim)));
                  v.rgbyes=1;
                end
              end
              F=getframe(gca);
              a=F.cdata;
              if ~strcmp(outfmt,'RGB')
                a=rgb2gray(a);
                Moviplot(:,:,j)=a;
              else
                Moviplot(:,:,:,j)=a;
                v.rgbyes=1;
              end
              v.list2{j}=num2str(j);
              end
             v.z2=v.z3;
             setappdata(vh.fig,'v',v)
             bbplot2
            
            v.fmt='TIF';

            v.play=0; v.framestep=1; v.histo=0; v.thresh=0;
            v.swing=0; v.figname=''; v.fmt=''; v.square=0;
            vplay.swingdir=1; v.normalize=0; v.zsem=[];
            v.srf=0; v.close=0; v.label=0; v.minmaxmode=0;
            v.singlepixel=0; v.pausefirst=0; v.pauselast=0;
            v.minarea=90; % for auto ROI
            v.frame=1;
            vplay.frame=v.frame;
            setappdata(vh.fig,'vplay',vplay);

            v.nobuttonchange=0;
            v.Movi2=Moviplot; v.list=v.list2;
            set(gca,'xlimmode','auto','ylimmode','auto');
            setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
            buttonvis

            v0.callingfig=vh.fig;
            setappdata(0,'v0',v0)
            str=[' Moviplot_' num2str(v0.fignum)];
            eval([mfilename str str str])

          case 10 % MEPPs case 'mepp
            prompt={ 'Number of points before peak to blank?',...
              'Number of points AFTER peak to blank?'};
            title='MEPP detector'; lineno=1;
            def={'3' '5'};
            inp=inputdlg(prompt,title,lineno,def);           
            v.npre=str2double(inp{1});
            v.npost=str2double(inp{2});
            buttonvis('mepp')
            vv=v.z2; v.nmepp=0; v.scroll=2;
            xlimit=get(gca,'xlim'); v.thresh=mean(v.z2(:));
            try; delete(vh.meppline); catch; end
            vh.meppline=line('xdata',xlimit,'ydata',[v.thresh v.thresh],'color','red'); 
            name=get(vh.fig,'name');
            ylimit=get(gca,'ylim'); v.meppthreshfac=(ylimit(2)-ylimit(1))/200;
     %       set(gca,'ylim',ylimit)
            set(gca,'ylimmode','auto')
            name=get(vh.fig,'name');
            set(vh.fig, 'WindowScrollWheelFcn',@bbscroll,'name',name)
            setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
            
          case 11 % interpolate
            [rows,cols]=size(v.z2);
            if cols~=1; msgbox('Please plot just one curve','replace'); return; end
            minx=min(v.xdata); maxx=max(v.xdata);
            stepit=(maxx-minx)/100; if stepit>1; stepit=round(stepit); end
            prompt={['This will interpolate values from min X (',...
              num2str(minx) ') to max X (' num2str(maxx) '). Step size?']};
            def={num2str(stepit)};
            lineno=1; title='Interpolate';
            inp=inputdlg(prompt,title,lineno,def);
            stepit=str2double(inp{1});
            y=v.z2(:,1); x=v.xdata; xi=minx:stepit:maxx;
            yi=interp1(x,y,xi);
            dlmwrite([v0.homedir 'junk.txt'],[xi' yi'],'\t')
            edit 'junk.txt'
          case 12 % sort rows
            prompt={['Array has ' num2str(size(v.zdata,2)) ' columns. Sort by which?'],...
              'Sort descending (d) or ascending (a)?'};
            title='Sort by rows'; lineno=1; def={'1' 'd'};
            inp=inputdlg(prompt,title,lineno,def);
            col=str2double(inp{1}); direction=inp{2};
            x=sortrows(v.zdata,col);
            if strcmp(direction,'d'); x=flipdim(x,1); end
            v.zdata=x;
            setappdata(vh.fig,'v',v)
          case 13 % make image
            prompt={['v.zdata has ' num2str(size(v.zdata,1)) ' rows and ',...
              num2str(size(v.zdata,2)) ' columns. Column for X position?'],...
              'Column for Y position?',...
              'Column for Brightness?'};
            title='Make image from graph data'; lineno=1;
            def={'1' '2' '3'};
            inp=inputdlg(prompt,title,lineno,def);
            xcol=str2double(inp{1}); ycol=str2double(inp{2}); zcol=str2double(inp{3});
            xx=v.zdata(:,xcol); yy=v.zdata(:,ycol); zz=v.zdata(:,zcol);
          %  dz=min(zz)*(min(zz)<0); zfac=255/(max(zz)-dz);
         %   disp(['z=round(z- ' num2str(dz) ')*' num2str(zfac) ')'])
          %  if dz<0; disp(['Zero value = ' num2str(-min(zz)*zfac)]); end
          %  zz=round((zz-dz)*zfac);
          %  i=uint8(0); i=i(ones(1,max(xx)),ones(1,max(yy)),ones(1,1));
            i=zeros(max(xx),max(yy)); 
            bkg=min(zz);
            i=i+bkg;  
            ind=sub2ind(size(i),xx,yy);
            i(ind)=zz;
            v.list={'makeimage'};

            makehotspots=0;
            if makehotspots
              ii=i;
              z=sortrows(v.zdata,zcol);
              for j=1:10
                i2=i;
                xx=z((j-1)*100+1:j*100,xcol);
                yy=z((j-1)*100+1:j*100,ycol);
                ind=sub2ind(size(i),xx,yy);
                i2(ind)=255;
                ii(:,:,j)=i2;
                v.list(j)={'makeimage'};
              end
              i=ii;
            end

            v0.callingfig=vh.fig;
            v.Movi2=i; v.Movi=v.Movi2;
            v.list2=v.list;
            v.rgbyes=0; v.fmt=''; v.frame=1; 
            setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
            eval([mfilename ' makeimg' ' makeimg' ' makeimg'])
          case 14 % 3d plot
            str='This routine will plot all columns, with each one offset';
            h=msgbox(str,'replace'); waitfor(h)
            z=v.zdata;
            figure
            axis auto
            view (44,14)
            rotate3d on
            grid;
            x=1:size(z,1);
            y=zeros([1,size(z,1)]);
            for col=1:size(z,2)
              y=y+1;
              zz=z(:,col);
              line(x,y,zz);
              drawnow
            end
            return
            % the following makes a mesh of the data
            %z=v.zdata;
            %[X Y]=meshgrid(1:size(z,2),1:size(z,1));
            %mesh (X,Y,z)
            %set(gca,'clim',[0 100000])
            %colormap('gray')
            %rotate3d on
          case 15 % marker size
            def={num2str(v.msz)};
            inp=inputdlg({'Marker size? (for proportionate enter 0)'},'Marker size',1,def);
            m=str2num(inp{1});
            if m==0;
              v.circles=1;
            else
              v.circles=0; v.msz=m;
            end
            setappdata(vh.fig,'v',v)
            bbplot2
          case 16 % nearest neighbor NN and neighborhood
            prompt={['Neighborhood: Type column numbers of x and y positions, max F, ',...
              'and distance (pixels) to edge of neighborhood. Three new columns ',...
              'will be appended to the data table containing the results: ',...
              'distance to nearest neighbor, # pixels in neighborhood, F (single pixel)',...
              'minus avg F in neighborhood.' ,...
              'What is the X column?'] 'Y column?' 'Max F column?',...
              'Distance (pixels) to edge of neighborhood?',...
              'Number of randomized iterations (will add 1 more column)?'};
            title='Nearest neighbor'; lineno=1; def={'0' '0' '0' '0' '0'};
            inp=inputdlg(prompt,title,lineno,def);
            xcol=str2num(inp{1}); ycol=str2num(inp{2});
            fcol=str2num(inp{3}); maxdist=str2num(inp{4});
            niter=str2num(inp{5});
            if xcol==0 | ycol==0; return; end
            rnd=rand(size(v.zdata,1),1);
            xyf=[v.zdata(:,xcol) v.zdata(:,ycol) v.zdata(:,fcol)];
            x0=v.zdata(:,xcol); y0=v.zdata(:,ycol); f0=v.zdata(:,fcol);
            res=zeros(size(xyf,1),3);
            if niter; tmp=zeros(size(xyf,1),niter); end
            for j=1:size(v.zdata,1)
              disp([num2str(j) ' / ' num2str(size(v.zdata,1))]); drawnow
              x=x0(j,1); y=y0(j,1); %f=xyf(j,3);
              dx=x0-x; dy=y0-y;
              dxy=sqrt(dx.^2+dy.^2);
              fdxy=[f0 dxy];
              fdxy=sortrows(fdxy,2);
              nnabors=sum(fdxy(:,2)<=maxdist); % includes self
              res(j,1)=(fdxy(2,2)); % NN
              res(j,2)=nnabors; % # in neighborhood
              % res(j,3)=sqrt(sum((fdxy(2:nnabors,1)-f0(j)).^2)/(nnabors-1));
              res(j,3)=f0(j)-mean(fdxy(2:nnabors,1));
              if niter % randomize F positions
                for iter=1:niter
                  rnd=rand(size(xyf,1),1); % randomize F's
                  [b ind]=sortrows(rnd); c=xyf(:,3);
                  c=c(ind);
                  % tmp(j,iter)=sqrt(sum((c(1)-c(2:nnabors)).^2)/(nnabors-1));
                  tmp(j,iter)=c(1)-mean(c(2:nnabors));
                end
              end
            end
            v.zdata=[v.zdata res];
            if niter
              tmp=sort(tmp);
              tmp=mean(tmp')';
              v.zdata=[v.zdata tmp];
            end
            setappdata(vh.fig,'v',v)
          case 17 % binomial distribution
            prompt={'# AZs?' 'quantum content?',...
              '# shocks/trial?' '#trials?' '#random runs? (0=binomial calc'};
            title='Binomial sim'; lineno=1; def={'750' '35' '1' '100' '100'};
            inp=inputdlg(prompt,title,lineno,def);
            n=str2num(inp{1}); % #AZs
            m=str2num(inp{2});  % quantum content
            ns=str2num(inp{3}); % # shocks/trial
            N=str2num(inp{4}); % # trials
            nrand=str2num(inp{5}); % randomization process
            mt=m*ns; % number of quanta per trial
            if nrand
              aztot=zeros(n,nrand);
              for nn=1:nrand
                disp([num2str(nn) ' / ' num2str(nrand)])
                az=zeros(n,2);
                for j=1:N
                  r=rand(n,1); az(:,2)=r; az=sortrows(az,2);
                  az(1:mt,1)=az(1:mt,1)+1;
                end
                az=sortrows(az,1);
                aztot(:,nn)=az(:,1);
              end
              az=sort(mean(aztot')');
            else
              % p(k)=(n!/(k!*(n-k)!)*p^k*(1-p)^(n-k)
              % N=#trials
              p=mt/n;
              pk=binopdf([1:100],100,.05)';
              %pk=binopdf([1:n],n,p)';
              az=pk*N;
            end
            if isempty(v.zdata)
              v.zdata=az(:,1);
            else
              v.zdata=[v.zdata az(:,1)];
            end
            setappdata(vh.fig,'v',v)
          case 18 %  Look for BUMP in Rocio's data
            ask=1;
            if ask
              prompt={'trough start?' 'plateau start?' 'dp1?' 'dp2?'};
              title='BUMP';
              lineno=1; def={'40' '80' '10' '20'};
              inp=inputdlg(prompt, title, lineno, def);
              p1=str2num(inp{1}); p2=str2num(inp{2});
              dp1=str2num(inp{3}); dp2=str2num(inp{3});
              k1=mean(z2(p1:p1+dp1,1));
              k2=mean(z2(p2:p2+dp2,1));
              j=1;
              a(j,1)=k1; a(j,2)=k2; a(j,3)=100*(k1-k2)/k2; a(j,4)=p1; a(j,5)=p2;

            else % no user input
              dp1=10; dp2=20; % # points to average
              for j=1:size(v.z2,2)
                qcmin=999999; qcmax=0;
                for p1=25:60
                  qc=mean(z2(p1:p1+dp1,j));
                  disp(qc)
                  if qc<qcmin; qcmin=qc; p1a=p1; end
                end
                for p2=40:75
                  qc=mean(z2(p2:p2+dp2,j));
                  if qc>qcmax; qcmax=qc; p2a=p2; end
                end
                k1=qcmin; k2=qcmax;
                %k1=mean(z2(p1:p1+10,j)); k2=mean(z2(p2:p2+10,j));
                disp([k1 k2 k1-k2 100*(k1-k2)/k2])
                a(j,1)=k1; a(j,2)=k2; a(j,3)=100*(k1-k2)/k2; a(j,4)=p1a; a(j,5)=p2a;
              end
            end % user input
            dlmwrite([v0.homedir 'junk.txt'],a,'\t')
            edit ([v0.homedir 'junk.txt'])
          case 19 % var(m) versus m
            try; a=v.varm; catch; v.varm=5; v.m=50; end
            prompt={'Var(m)?' 'm?'}; title='Var(m) versus m'; lineno=1;
            def={num2str(v.varm) num2str(v.m)};
            inp=inputdlg(prompt,title,lineno,def);
            v.varm=str2num(inp{1}); v.m=str2num(inp{2});
            m=v.m; minmmax=round(m/0.99);
            p0=[0:.01:.99]'; p02=p0.*p0; dp=p0-p02;
            m0=[0:10:500]'; 
            res=[0,0];nn=0;
            for x=minmmax:50:1000
              y=x*dp; % var(m) curve
              dx=v.m-p0*x;
              dy=v.varm-y;
              dxy=dx.*dx+dy.*dy;
              mindiff=sqrt(min(dxy));
              pos=find(dxy==min(dxy));
              nn=nn+1;
              res(nn,1)=p0(pos); % release prob
              res(nn,2)=x; % m
              res(nn,3)=mindiff; % var(m) minimim distance to observed
              
              res2(:,2*nn-1)=x*p0; % this makes parabolas x,y,x,y...
              res2(:,2*nn)=y;
            end
           v.zdata=res; setappdata(vh.fig,'v',v)
           bbplot2
          case 20 % EPP amp from chopped data
            mn=min(v.zdata); mn=mn/2;
            mx=max(v.zdata);
            v.z2=(mx-mn)';
            setappdata(vh.fig,'v',v)
            bbplot2
          case 21 % sort columns - first odds, then evens
            zz=v.zdata*0;
            nn=1; fac=floor(size(zz,2)/2);
            for j=1:2:size(zz,2)
              zz(:,nn)=v.zdata(:,j);
              zz(:,fac+nn)=v.zdata(:,j+1);
              nn=nn+1;
            end
            v.zdata=zz;
            setappdata(vh.fig,'v',v)
          case 22 % cull selected rows
            prompt={'Cull initial n' 'Keep how many?' 'Cull how many?'};
            title='Cull selected rows'; lineno=1; def={'0' '1' '1'};
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); return; end
            n0=str2num(inp{1}); n1=str2num(inp{2}); n2=str2num(inp{3});
            z=v.zdata*0; 
            nnew=0; sz=n1+n2;
            nnew=0; nold=n0;
            while nold<size(z,1);
              nold=nold+1; ntest=rem(nold-n0,sz);
              if ntest>0 & ntest<=n1 %     nold-floor(nold/sz)*sz<= n1
                nnew=nnew+1; 
               z(nnew,:)=v.zdata(nold,:); 
              end % if ntest...
            end % while nold...
            v.zdata=z(1:nnew,:);
            setappdata(vh.fig,'v',v)
           % v0.callingfig=vh.fig; setappdata(0,'v0',v0)
           % figname=[' CullFrames_' num2str(v0.fignum)];
           % eval ([mfilename figname figname figname])
        end % plot popup plotpopup

      case 'meppcalc'       
        name=get(vh.fig,'name');
          set(vh.fig, 'WindowScrollWheelFcn','','name',name)        
        vv=v.z2; mxmepp=[];
        while max(vv(:))>=v.thresh;
          if getappdata(0,'abort'); v.thresh=1e9; end
          mx=max(vv(:));
          [y x]=find(vv==mx); xx=y(1);
          x1=max(1,y-v.npre); x2=min(size(vv,1),y+v.npost);
          %      x3=max(1,xx-1); x4=min(length(vv),xx+2);
          v.nmepp=v.nmepp+1;
          mxmepp(v.nmepp,2)=y; mxmepp(v.nmepp,1)=x; mxmepp(v.nmepp,3)=mx;
          %   disp([num2str(v.nmepp) '. ' num2str(mxmepp(v.nmepp,1)) ' ' num2str(mxmepp(v.nmepp,2))])
          text('tag','meppmarker','position',[y,mx],'fontsize',24,...
            'horizontalalignment','center','color','red','string','*');
             vv(x1:x2,x)=0;
        end
        mxmepp=sortrows(mxmepp,[1,2]);
        sz=size(v.z2,1);
        for j=1:size(v.z2,2)
          a=mxmepp; 
          b=a(:,1)==j; a(~b,:)=[];
       nmepps=size(a,1); freq=nmepps/sz;
        disp(['Trace ' num2str(j) ': ' num2str(nmepps) ' events. Freq = ',...
          num2str(freq) '.'])
        end
        drawnow
        buttonvis
        dlmwrite([v0.homedir 'junk.txt'],mxmepp,'\t')
        edit 'junk.txt'
        
      case 'wat' % watershed
        v.play=0; v.watshowoff=0; setappdata(vh.fig,'v',v);
        frame=get(vh.fs,'value');
        v.Movi2=v.Movi(:,:,frame);                               
        set(vh.fs,'value',1);
        v0.rgbyes2=v.rgbyes;
        v.list2=v.list(frame); setappdata(vh.fig,'v',v)
        v0.callingfig=vh.fig; setappdata(0,'v0',v0)
        figname=[' watershed_' num2str(v0.fignum)];
        eval([mfilename figname figname figname])
        
        vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v');
        figure(vh.fig)
        v.watlast=[0 0]; % last two areas selected (for merging)
        v0.vOriginal=v; % setappdata(0,'vOriginal',v) % used on exiting
        v0.watlabel=0; % setappdata(0,'watlabel',0)
        setappdata(0,'v0',v0) % vh.fig,'v',v)
        conn=4;
        a0=v.Movi;  % for watershed        
        if max(a0(:))==255; a0(a0==255)=254; end
        mx=double(max(a0(:)))+1;
        lo=round(get(vh.minslider,'value'));
        hi=round(get(vh.maxslider,'value'));
        v0.watlo=lo; v0.watnoedge=0;
        a=a0;
        a(a<=lo)=mx; % make background brightest
        acomp=mx-a;
        clc
        disp(['Low cutoff ' num2str(lo)])
        disp('Watershed...')
        
        % ***********************************
        wat=watershed(acomp,conn);
        % ***********************************
        
        v0.watoutline=(wat==0);
        a0=v.Movi;
        a0(v0.watoutline)=127;
        v.Movi=a0;
        watmax=max(wat(:));
        disp([num2str(watmax) ' areas'])
        A08bit=v.Movi;
        if isa(v.Movi,'uint16') % convert 16 bit to 8 bit RGB
          fac=255.0/(double(max(A08bit(:))-min(A08bit(:)))); % hi-lo;
          vv=double(v.Movi);
          vv(vv>hi)=hi;
          vv(vv<lo)=lo;
          vv=vv-lo;
          vv=vv.*fac;
          A08bit=round(vv);
        end
        for j=1:3;
          rgb(:,:,j)=A08bit;
        end
        disp('regionprops...')
        stats=regionprops(wat,'Area','PixelIdxList');
        % find max(or avg) value for each area
        usemax=01; % 0=useavg; 1=usemax
        for j=1:watmax
          pixpos=stats(j).PixelIdxList;
          pixvals=a0(pixpos);
          if usemax
            maxpix(j)=double(max(pixvals(:)));
          else
            maxpix(j)=sum(pixvals(:))/size(pixvals,1);
          end
        end
        aau=unique(sort([stats.Area]'));
        v0.watstats=stats;
        v0.watmaxpix=maxpix;
        set(vh.watbrithresh,'min',lo,'max',max(a0(:)+1),'value',lo)
        set(vh.watbrithreshtxt,'string',['Thresh= ' num2str(lo)])
        v.Movi2=v.Movi;
        v0.wat=wat;
        idx.size=[1:watmax,1]; idx.bri=idx.size; idx.all=idx.size;
        v0.edgespots=unique([wat(:,1)' wat(1,:) wat(:,end)' wat(end,:)]); % edge spots
        v0.watidx=idx;
        v0.watrgb=rgb;
        minstep=1/size(aau,1); maxstep=5*minstep;
        set(vh.watminslider,'min',1,'max',size(aau,1),'value',1,'sliderstep',[minstep maxstep])
        set(vh.watmaxslider,'min',1,'max',size(aau,1),'value',size(aau,1),'sliderstep',[minstep maxstep])
        set(vh.img,'buttondownfcn',[mfilename ' watbutton'])
        setappdata(vh.fig,'vh',vh);
        setappdata(vh.fig,'v',v)
        setappdata(0,'v0',v0)
        eval([mfilename ' watslider']) % gets the number selected to be correct
        eval([mfilename ' watbrithresh'])
        buttonvis('watershed')
        
      case 'watslider' % 3 sliders come here
        wat=v0.wat; %getappdata(0,'wat');
        idx=v0.watidx; %getappdata(0,'watidx');
        stats=v0.watstats; % getappdata(0,'watstats');
        % area sliders
        aa=[stats.Area];
        aau=unique(sort(aa));
        vmin=round(get(vh.watminslider,'value'));
        vmax=round(get(vh.watmaxslider,'value'));
        newmin=min(vmin,vmax); newmax=max(vmin,vmax);
        set(vh.watminslider,'value',newmin);
        set(vh.watmaxslider,'value',newmax)
        minarea=aau(vmin);
        maxarea=aau(vmax);
        set(vh.watmaxtxt,'string',['Max ' num2str(maxarea)])
        set(vh.watmintxt,'string',['Min ' num2str(minarea)])
        idx.size=find(aa>=minarea & aa<=maxarea);
        % brightness threshold slider
        maxpix=v0.watmaxpix; % getappdata(0,'watmaxpix');
        bri=round(get(vh.watbrithresh,'value'));
        idx.bri=find(maxpix>=bri);
        bri=num2str(round(bri));
        set(vh.watbrithreshtxt,'string',['Thresh= ' bri]);
        a=ismember(idx.size,idx.bri);
        idx.all=idx.size(a>0);
        v0.watidx=idx; setappdata(0,'v0',v0)
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
        %     buttonvis('watershed')
        if v0.watlabel; eval([mfilename ' watlabel']); end
        eval([mfilename ' watrgb'])
        
      case 'watnoedge'
        idx=v0.watidx;
        v0.watnoedge=~v0.watnoedge;
        if v0.watnoedge
          a=~ismember(idx.bri,v0.edgespots); idx.bri(a==0)=[];
          a=~ismember(idx.size,v0.edgespots); idx.size(a==0)=[];
        else
          idx.size=unique([idx.size v0.edgespots]);
          idx.bri=unique([idx.bri v0.edgespots]);
        end
        a=ismember(idx.size,idx.bri);
        idx.all=idx.size(a>0);
        v0.watidx=idx; setappdata(0,'v0',v0)
        setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
        eval([mfilename ' watrgb'])
        
      case 'watselectall'
        wat=v0.wat;
        idx=v0.watidx;
        maxwat=max(wat(:));
        idx.size=1:maxwat; idx.bri=1:maxwat; idx.all=1:maxwat;
        v0.watidx=idx;
        setappdata(0,'v0',v0)
        if v0.watlabel; eval([mfilename ' watlabel']); end
        eval([mfilename ' watrgb'])
      case 'watselectnone'
        idx=v0.watidx; % getappdata(0,'watidx');
        idx.size=[]; idx.bri=[]; idx.all=[];
        v0.watidx=idx;
        setappdata(0,'v0',v0)
        if v0.watlabel; eval([mfilename ' watlabel']); end
        eval([mfilename ' watrgb'])
      case 'watbrightness' % brightness of display
        bri=get(vh.watbrightness,'value');
        bri=num2str(round(bri*10)/10);
        set(vh.watbrightnesstxt,'string',['Brightness = ' bri]);
        setappdata(vh.fig,'v',v)
        eval([mfilename ' watrgb'])
      case 'watmerge' % merge v.watlast(2) into v.watlast(1)
        wat=v0.wat;
        n1=v.watlast(1); n2=v.watlast(2); a=v0.watrgb(:,:,3,1);
        bw=(wat==n1); sz1=sum(bw(:)); b=a(bw); avg1=sum(b(:))/sz1;
        bw=(wat==n2); sz2=sum(bw(:));  b=a(bw); avg2=sum(b(:))/sz2;
        v0.wat(v0.wat== v.watlast(2))=v.watlast(1);
        setappdata(0,'v0',v0);
        disp(['Merged area ' num2str(n2) ' (' num2str(sz2),...
          ' pixels) into area ' num2str(n1), ' (' num2str(sz1),...
          ' pixels) -> new area ' num2str(n1) ' (' num2str(sz1+sz2) ' pixels.'])
        
      case 'watbutton'
        wat=v0.wat; % getappdata(0,'wat');
        idx=v0.watidx; % getappdata(0,'watidx');
        stats=v0.watstats; % getappdata(0,'watstats');
        button=get(vh.fig,'selectiontype');
        [x y]=bbgetcurpt(gca);
        x=round(x);y=round(y);
        nn=wat(y,x,1);  % switch x&y for images!!
        if nn==0;
          disp('Area 0 = border');
          return
        else
          switch button
            case 'normal'
              v.watlast=[v.watlast(2) nn];
              idx.size=unique([idx.size nn]);
              idx.bri=unique([idx.bri nn]);
            case 'alt'
              idx.size(idx.size==nn)=[];
              idx.bri(idx.bri==nn)=[];
          end
        end
        idx.all=[];
        for j=1:max(wat(:));
          if (sum(idx.size==j)&& sum(idx.bri==j))
            idx.all=[idx.all j];
          end
        end
        % For disp only
        Movi0=get(vh.img,'cdata'); % v0.Movi0;
        thresh=0.25;
        aa=[stats.Area];
        aau=unique(aa);
        npix=aa(nn);
        pixpos=stats(nn).PixelIdxList;
        pixvals=Movi0(pixpos);
        mx=max(pixvals(:));
        pixvals2=pixvals(pixvals>=mx*thresh);
        npix2=size(pixvals2,1);
        avg=round(mean(pixvals));
        avg2=round(mean(pixvals2));
        disp(['Spot #' num2str(nn) '. Npix= ' num2str(npix) '. Max= ' num2str(mx)  '. Avg= ' num2str(avg) ])
        v0.watidx=idx; setappdata(0,'v0',v0) % setappdata(0,'watidx',idx)
        setappdata(vh.fig,'v',v)
        if v0.watlabel; eval([mfilename ' watlabel']); end
        eval([mfilename ' watrgb'])
        
      case 'watareahisto'
        stats=v0.watstats; % getappdata(0,'watstats');
        aa=[stats.Area]; aa=sort(aa)'; aa=aa(1:end-1,1);
        v.histo=1; v.zdata=aa; v.xdata=[]; v.z2=aa; v.zavg=[];
        setappdata(vh.fig,'v',v)
        bbplot
      case 'watsave'
        [fname,pname]=uiputfile;
        if fname==0; return; end
        F=getframe;
        a=F.cdata;
        imwrite(a,[pname fname],'jpg')
      case 'watcalc'
        mm=getfig('Figure for ROI calculations? (0=auto)');
        if isempty(mm); return; end
        figure(mm(1,1))
        vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
        npics=size(v.Movi,3); v0.Movi0=v.Movi;
        v.rgbyes=0;
        v.Movi2=v.Movi;
        if ~isa(v.Movi2,'uint8')
         a=double(v.Movi2); a=a-min(a(:)); 
         a=a./max(a(:)); a=a.*254; a=uint8(a); v.Movi2=a;
        end
         % if max(v.Movi2(:))==255; v.Movi2=v.Movi2-1; end
        wat=v0.wat;
        bwat=logical(~wat); % for adding wat outlines to movie
        idx=v0.watidx;
        stats=v0.watstats;
        rgb=v0.watrgb;
        figcalc=v0.figcalc;
        lastroi=v0.lastroi;
        if isempty(lastroi);
          lastroi={};
        else
          inp=questdlg([num2str(size(lastroi,2)) ' regions preexisting. Keep or discard?'],...
            'Keep preexisting ROIs?','Keep','Discard','Keep');
          if strcmp(inp,'Discard'); lastroi={}; end
        end
        prompt={'Threshold (fraction of brightest pixel)?',...
          'Perform gaussian fit (0=no; 1=yes)',...
          'Keep size constant? (0=no; 1=yes)',...
          'Show regions as outlines (0) or spots (1) or brightest pixel (2 or 3 (dilated))?',...
          'All calculations (0) or ROI only (1=mean; 2=sum; 3=area)?'};
        title='Watershed calculate options';
        lineno=1; def={'0.7' '0' '0' '0'  '0'};
        inp=inputdlg(prompt, title, lineno, def);
        if isempty(inp); return; end
        r=str2double(inp{1}); dogauss=str2num(inp{2});
        lockspot=str2num(inp{3});
        showspots=str2num(inp{4});
        roionly=str2num(inp{5});
        edgedist=0;
        spon=size(idx.all,2);
        hrect=findobj('tag','watrect'); delete(hrect); drawnow
        a0=v0.Movi0;
        rgbx=rgb; % selected spots are red off; green on; blue on
        row=0;
        bw0=wat<0;
        hh=text('position',[10 10],'string','',...
          'color','white','fontsize',18); % ,'horizontalalignment','center');
        if edgedist;
          bw=a0>v0.watlo; bw2=bwmorph(bw,'remove'); % remove interior pixels
          [ye xe]=find(bw2>0); % edge pixels
        end
        maxorig=max(v.Movi2(:));
        aa=idx.all'; % these are the spot numbers to use
        for j=size(aa,1):-1:1
          nn=find(wat==aa(j));
          if isempty(nn); aa(j)=[]; 
          else
             npixtot(j)=size(nn,1);
          end
        end
        nspots=size(aa,1);
        npics=size(v0.Movi0,3); ok=1;
        
        if roionly %%%%%%%%%%%%%%%%%%
          res=zeros(npics,nspots);
          v.Movi2=uint16(v.Movi(:,:,1))*0;
          for spot=1:nspots
            disp(['Spot ' num2str(spot) '/' num2str(nspots)])
            drawnow
            bw=(wat==aa(spot));
            for pic=1:npics
              p=v0.Movi0(:,:,pic); sz=sum(bw(:));
              fac=sz; if roionly==2; fac=1; end
              if roionly<3
                res(pic,spot)=sum(p(bw))/fac; % mean or total
                if npics==1; res(2,spot)=sz; end
              else
                res(pic,spot)=sz;
              end
            end % for pic=1:nspots
            if npics==1 %
              v.Movi2(bw)=res(pic,spot);
            end
          end % for spot=1:nspots
          v.zdata=res; v.z2=res; v.zavg=[]; v.xdata=[];
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          bbplot
          v0.callingfig=vh.fig; v0=getappdata(0,'v0');
          v.newname='integral_spots'; v.list2=v.list; v0.rgbyes2=0;
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          eval([mfilename ' intspot intspot intspot'])
          v=getappdata(v0.callingfig,'v')
          return
        end % if roionly
        
        %%%%%%%%f%%%%%%%%%%%%%%% BIG LOOP STARTS %%%%%%%%%%%%%%%%%
        %     buttonvis('abort'); pause(0.2)
        res=zeros(npics*nspots,9); restmp=zeros(nspots,3);
        if dogauss; resgauss=zeros(npics*nspots,4); end
        for pic=1:npics
          a0=v0.Movi0(:,:,pic);
          set(hh,'string',['Image #' num2str(pic) ' / ' num2str(npics)])
          drawnow
          for spot=1:nspots*ok
            row=row+1;
            rdest=(spot-1)*npics+pic; % destination row #
            res(rdest,1)=pic;
            res(rdest,2)=aa(spot); % spot; % spot #
            res(rdest,3:7)=0; % xpos(max), ypos(max), npix, avg, mx
            % res(rdest,8) will be NN Fmaxobs (see below)
            if getappdata(0,'abort'); ok=0; end
            aa=idx.all'; nn=aa(spot);
            pixpos=stats(nn).PixelIdxList; %positions of pixels, this spot
            pixvals=a0(pixpos); % values of pixels, this spot
            sumspot(spot)=sum(pixvals);
            mx(spot)=double(max(pixvals(:))); % max F
            mn(spot)=double(min(pixvals(:)));
            if ~lockspot | pic==1
              if spot==1; Lspot=(a0)*0; end
              thresh=mn(spot)+(mx(spot)-mn(spot))*r;
              pixvals2=pixvals(pixvals>=thresh);
              pixpos2=pixpos(pixvals>=thresh);
              bbw=logical(a0*0);
              bbw(pixpos2)=1;
           %  if r<.9; bbw=bwmorph(bbw,'majority'); end % trim off tags
              npix(spot)=sum(bbw(:)); % size(pixvals2,1);
              if sum(bbw(:)) % some pixels are above thresh
                L=bwlabeln(bbw); % look for fragmented regions (orphans)
                nregions=max(L(:));
                bigspot=1;
                if nregions>1;
                  disp(['thresh= ' num2str(thresh) '. ' num2str(nregions) ' regions'])
                  npix(spot)=0;
                  for j=1:nregions % keep only biggest orphan
                    nn=sum(sum(L==j));
                    if nn>npix(spot); bigspot=j; npix(spot)=nn; end
                  end
                end % if nregions>1
                L(L~=bigspot)=0; % solid spot
                L=logical(L);
                Lspot(L>0)=spot;
              end % if sum(bw(:))
            end % if ~lockspot | pic==1
          end % spon
          bbox=regionprops(Lspot,'BoundingBox'); % for gaussian fit
          nn=0;
           restmp=restmp*0;
          for spot=1:spon           
            %  disp([num2str(spot) ' / ' num2str(spon)])
            if npix(spot)
              rdest=(spot-1)*npics+pic;
              b=find(Lspot==spot);
              c=a0(b);
              mx=max(a0(b)); pos=find(a0(b)==mx); pos=pos(1);
              [y x]=ind2sub(size(a0),b(pos));
              % sumspot=sum(c);
              res(rdest,3)=x;
              res(rdest,4)=y;
              res(rdest,5)=max(c);
              res(rdest,6)=npixtot(spot); % entire spot
              res(rdest,7)=sumspot(spot); % entire spot
              res(rdest,8)=npix(spot);
              res(rdest,9)=npix(spot)*mean(c); % total dF
              
              res2(pic,spot)=mean(c);
              restmp(spot,:)=[x y max(c)];
              % distance to edge
              if edgedist
                edgedistcol=9;
                y2=ye-y; y3=y2.^2; x2=xe-x; x3=x2.^2;
                d1=sqrt(y3+x3);
                res(rdest,edgedistcol)=min(d1);  % pixels to nearest edge
                d2=[xe ye d1];
                d3=sortrows(d2,3);
                %line([x d3(1,1)],[y d3(1,2)]); drawnow
              end % edgedist
              
              %gaussian fit
              resgauss(rdest,:)=0;
              if dogauss
                aa=round(bbox(spot).BoundingBox);
                frame=1; nn=nn+1;
                m=double((a0(aa(2):aa(2)+aa(4)-1,aa(1):aa(1)+aa(3)-1,frame)));
                [szy,szx,szz]=size(m);
                [c,r,h] = meshgrid(1:szx,1:szy,1:szz); % 3 arrays, each szx by szy
                pts=[r c h]; % this is just r,c, and h pasted horizontally
                frame=1;
                tol=.001; mxit=1000; dsp='off'; lscale='on'; % 'iter';
                oldopts=optimset('lsqcurvefit');
                options=optimset(oldopts,'TolX',tol,'MaxIter',mxit,'Display',dsp,'LargeScale',lscale); %,'MaxFunEvals',mxfunevals)
                b=double(min(m(:)));
                a=double(max(m(:)))-b;
                sc=3.00; sr=sc; sh=sc;
                c0=double(szx/2);
                r0=double(szy/2);
                h0=0;
                f=[b a c0 sc r0 sr h0 sh]; % Coeffs
                lb=0; ub=64000; %2*max(m(:)); % lower and upper bounds
                [ff]=lsqcurvefit(@gauss3D,f,pts,m,lb,ub,options);
                if ff(3)<0 || ff(3)>size(m,1) || ff(5)<0 || ff(5)>size(m,2)
                  resgauss(rdest,:)=0;
                  resgauss(rdest,1)=res(rdest,3); % x observed
                  resgauss(rdest,2)=res(rdest,4); % y observed
                  resgauss(rdest,3)=res(rdest,7); % max observed
                  %set(vh.img,'cdata',m0); drawnow
                  disp(['peak of spot ' num2str(spot) ' out of bounds'])
                else % not out of bounds
                  Z0=ff(1)+ff(2).*exp(-((c-ff(3)).^2/ff(4)+(r-ff(5)).^2/ff(6)+(h-ff(7)).^2/ff(8)));
                  Z=uint16(Z0);
                  Zm=uint16(bbpaste(Z,m,'horizontal'));
                  ymax=ff(5)+aa(2)-1; xmax=ff(3)+aa(1)-1;
                  resgauss(rdest,1)=xmax; % xpos of max g(3)+offset
                  resgauss(rdest,2)=ymax; % ypos of max g(5)+offset
                  resgauss(rdest,3)=ff(2); % max(Z(:)); %g(2); % gauss max
                  resgauss(rdest,4)=ff(1); % constant (total F is gauss max + constant)
                  xvar=ff(4)/2; % x variance
                  yvar=ff(6)/2; % y variance
                  %resgauss(rdest,5)=ff(4)/2; % x variance
                  %resgauss(rdest,6)=ff(6)/2; % y variance
                  %resgauss(rdest,7)=ff(8)/2; % h variance
                  resgauss(rdest,5)=corr2(m,Z);
                  resgauss(rdest,6)=2*1.1774*sqrt((xvar+yvar)/2); % FWHM
                end % gauss out of bounds
              end % if dogauss
            end % if npix(spot)
          end % for spot=1:spon
          
          switch showspots
            case 1 % showspots (filled)
             %Loutline=bwmorph(Lspot,'clean');
              a=Lspot; a=a>0;
              if r==1; a=bwmorph(a,'shrink'); end
            case 0 % outlined spots
              Loutline=bwmorph(Lspot,'remove');
              a=v.Movi2(:,:,pic);
              a(Loutline)=0; 
            case {2,3} % max F
              a=v.Movi(:,:,pic); % Lspot*0;
              a(a==255)=254;
              for j=1:size(restmp,1)
              a(restmp(j,2),restmp(j,1))=255;
              end
             % xy=round(res(:,3:4));
             % if dogauss; xy=round(resgauss(:,1:2)); end
             % for j=1:size(xy,1)
             %   if xy(j,1)==0; xy(j,1)=res(j,3); xy(j,2)=res(j,4); end
             %   a(xy(j,2),xy(j,1))=max(v.Movi(:))+1;
             % end
              if showspots>2
                bw=(a==255); bw=bwmorph(bw,'dilate'); a(bw)=255;
              end
          end
          v.Movi2(:,:,pic)=a;
          drawnow
        end % for pic=1:
        
        if 0>1
        set(hh,'string','Nearest Neighbor... Please wait...')
        drawnow
        if dogauss  % do nearest neighbor
          x0=resgauss(:,1); y0=resgauss(:,2);
          for j=1:size(resgauss,1)
            x=x0(j,1);
            y=y0(j,1);
            if (x+y)==0; x=res(j,3); y=res(j,4); end
            dx=x0-x; dy=y0-y;
            dxy=dx.^2+dy.^2;
            dxy=sqrt(sort(dxy));
            resgauss(j,7)=dxy(2); %NN gauss
          end
        else
          x0=res(:,3); y0=res(:,4);
          tic
          for j=1:size(res,1)
            x=x0(j,1); y=y0(j,1);
            dx=x0-x; dy=y0-y;
            dxy=dx.^2+dy.^2;
            dxy=sqrt(sort(dxy));
            res(j,9)=dxy(2); %NN maxFobs
          end
          toc
        end % if dogauss
        end
        str='';      
        %%%%%%%%%%%%%%%%% BIG LOOP ENDS %%%%%%%%%%%%%%
        
        if dogauss; res=[res resgauss]; end
        if ok
          v0.lastroi=lastroi;
          v.zdata=res; v.z2=v.zdata;
          v.xdata=[]; v.zavg=[];
          v.histo=0;
          v0.callingfig=vh.fig;
          v.newname='outline'; v.list2=v.list; v0.rgbyes2=0;
          setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
          eval([mfilename ' outline outline outline'])
          frame=round(get(vh.fs,'value'));
          setappdata(vh.fig,'v',v)
          bbplot
          set(0,'currentfigure',vh.fig)
          v=getappdata(vh.fig,'v');
          v0.callingfig=vh.fig; setappdata(0,'v0',v0)
          if 0>1
            v.zdata=res2'; v.z2=v.zdata;
            v.xdata=[]; v.zavg=[];
            v.histo=0;
            setappdata(vh.fig,'v',v)
            bbplot
          end
        end % ok=1
        
        str=[str 'C1=pic. C2=spot. C3=xpos(maxFobs). C4=ypos. C5=maxFobs.' char(10) ,...
          'C6=npixtot. C7=sumF(tot spot).' char(10),...
          'C8=npix (F>' num2str(r) 'Fmax). C9=sumF (F>' num2str(r) 'Fmax). ']; x
        if dogauss;
          str=[str ' C9=xpos(maxGauss). C10=ypos. ',...
            'C11=maxFgauss. C12=bkgGauss. C13=corrcoeff. C14=FWHM. C15=NN maxFgauss'];
        end
        h=msgbox(str,'Table','replace'); sz=get(0,'screensize');
        %   set(h,'position',[750 550 300 80]);
        delete(hh)
        
      case 'watlabel'
        v0.watlabel=~v0.watlabel;
        if v0.watlabel
          buttonvis('abort'); drawnow
          wat=v0.wat;
          idx=v0.watidx;
          wat2=ismember(wat,idx.all);
          %wat=wat2.*wat;
          wat(~wat2)=0;
          stats2=regionprops(wat,'Centroid');
          for j=1:size(idx.all,2)
            if getappdata(0,'abort');
              delete(findobj(vh.fig,'type','text'))
              buttonvis('watershed'); return; end
            nn=idx.all(j);
            xy=stats2(nn).Centroid;
            text(xy(1),xy(2),num2str(j),'color','red','horizontalalignment','center'); drawnow
          end
        else
          delete(findobj(vh.fig,'type','text'))
        end
        setappdata(0,'v0',v0)
        buttonvis('watershed')
        setappdata(vh.fig,'v',v)
        eval([mfilename ' watrgb'])
        
      case 'watshowoff'
        v.watshowoff=~v.watshowoff;
        setappdata(vh.fig,'v',v)
        eval([mfilename ' watrgb'])
      case 'watabort'
        buttonvis
        v=v0.vOriginal; % getappdata(0,'vOriginal');
        lo=min(v.Movi(:)); hi=max(v.Movi(:));
        set(vh.minslider,'min',lo,'max',hi,'value',lo) % low slider
        set(vh.maxslider,'min',lo,'max',hi,'value',hi)
        set(vh.ax,'clim',[lo hi])
        set(vh.img,'cdata',v.Movi(:,:,get(vh.ffs,'value')));
        set(vh.img,'buttondownfcn',[mfilename ' pixval'])
        v.rgbyes=0;
        v.newname='watershed';
        v0.wat=[]; v0.watstats=[]; v0.watrgb=[]; v0.watidx=[]; v0.watlo=[]; setappdata(0,'v0',v0)
        setappdata(vh.fig,'v',v)
        eval([mfilename ' minmax'])
      case 'wathelp'
        str=['Green=selected areas. Red=deselected areas. The AREA sliders',...
          ' limit selected areas by number of pixels (area).',...
          ' Left click to select a single area.',...
          ' RIGHT click to DEselect a single area. Click CALCULATE to find',...
          ' average fluorescence of each selected area.'];
        msgbox(str,'Watershed Areas','replace')
        return
        
      case 'watrgb'
        wat=v0.wat;
        idx=v0.watidx;
        rgb=v0.watrgb; rgb=rgb-min(rgb(:));
        rgb=rgb/max(rgb(:)); % original v.Movi with watoutline
        watmax=max(wat(:));
        spoton=logical(ismember(wat,idx.all)); % binary 2d image
        spotoff=logical(~ismember(wat,idx.all));
        aa=rgb(:,:,1); aa(spoton>0)=0;
        rgb(:,:,1)=aa;
        bb=rgb(:,:,2); bb(spotoff>0)=0; rgb(:,:,2)=bb;
        bbb=bb>0;
        % disp([num2str(sum(bbb(:))) ' pixels selected'])
        try; if v.watshowoff;
            cc=rgb(:,:,3); cc(spotoff>0)=max(rgb(:));
            rgb(:,:,3)=cc; end % boost reds
        catch; v.watshowoff=0; end
        for k=1:3; cc=rgb(:,:,k); cc(v0.watoutline)=127; rgb(:,:,k)=cc; end
        fac=get(vh.watbrightness,'value');
        rgb=rgb*fac;
        rgb(rgb>1)=1; rgb(rgb<0)=0; %rgb=rgb/max(rgb(:));
        v.Movi=rgb; v.rgbyes=1;
        %******************
        set(vh.img,'cdata',rgb)
        %******************
        spon=size(idx.all,2); % max(bww(:));
        set(vh.wattxt,'string',[num2str(spon) ' / ' num2str(watmax) ' regions'])
        setappdata(vh.fig,'v',v);
        setappdata(vh.fig,'vh',vh)
        
      case 'pvcolor0'
        v0.callingfig=vh.fig; setappdata(0,'v0',v0)
        set(vh.color,'string','')
        h=openfig('pvcolor','new'); vh2=guihandles(h);
        grid on
        set(vh2.fig, 'WindowButtonDownFcn', [mfilename ' colorbuttondown'],...
          'WindowButtonMotionFcn','',...
          'WindowButtonUpFcn', '',...
          'KeyPressFcn',[mfilename ' colorkeypress'],...
          'doublebuffer','on');
        set(gcf,'currentaxes',vh2.ax); set(vh2.ax,'ylim',[0 1]);
        set(0,'currentfigure',vh2.fig)
        v2.cmap=get(v0.callingfig,'colormap'); v2.colorstep=10;
        v2.radio=[0 0 0]; v2.smoothmode='spline';
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2); setappdata(0,'v0',v0)
        eval([mfilename ' colorplotlut'])

      case 'colorkeypress'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        k=get(gcf,'currentcharacter');
        k=double(k); if isempty(k); return; end
        dx=0; dy=0;
        switch k
          case 30; %'u'
            dy=0.01;
          case 31; %'d'
            dy=-0.01;
          case 28; %'l'
            dx=-1;
          case 29; %'r'
            dx=1;
        end
        if dy
          if v2.radio(1); a=v2.cmap(:,1); a(a>0)=a(a>0)+dy; v2.cmap(:,1)=a; end
          if v2.radio(2); a=v2.cmap(:,2); a(a>0)=a(a>0)+dy; v2.cmap(:,2)=a; end
          if v2.radio(3); a=v2.cmap(:,3); a(a>0)=a(a>0)+dy; v2.cmap(:,3)=a; end
        elseif dx
          for j=1:3
            if v2.radio(j);
              v2.cmap(1+(dx>0):end-(dx<0),j)=v2.cmap(1+(dx<0):end-(dx>0),j);
              v2.cmap(1*(dx>0)+end*(dx<0),j)=0; end
          end
        end
        if v2.radio(1); set(vh2.r,'ydata',v2.cmap(:,1)); end
        if v2.radio(2); set(vh2.g,'ydata',v2.cmap(:,2)); end
        if v2.radio(3); set(vh2.b,'ydata',v2.cmap(:,3)); end
        v2.cmap(v2.cmap>1)=1; v2.cmap(v2.cmap<0)=0;
        set(v0.callingfig,'colormap',v2.cmap)
        drawnow
        setappdata(vh2.fig,'v2',v2)
      case 'colorkbd'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        keyboard
      case 'colorstep'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        v2.colorstep=round(get(vh2.colorstep,'value'));
        set(vh2.colorsteptxt,'string',['Smooth ' v2.smoothmode ' ' num2str(v2.colorstep)])
        setappdata(vh2.fig,'v2',v2)
      case 'colorstepmode'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        inp=questdlg('Smoothing mode?','Smoothing mode','linear','spline','cubic','linear');
        v2.smoothmode=inp;
        set(vh2.colorsteptxt,'string',['Smooth ' v2.smoothmode ' ' num2str(v2.colorstep)])
        setappdata(vh2.fig,'v2',v2)
      case 'colorradio'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        a=get(vh2.radio,'value');
        for j=1:3;
          v2.radio(j)=a{j};
        end
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'colorbuttondown'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        if ~sum(v2.radio); disp('Turn on a color'); return; end
        set(vh2.fig, 'WindowButtonMotionFcn', [mfilename ' colorbuttonmotion'],...
          'WindowButtonUpFcn', [mfilename ' colorbuttonup'])
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'colorbuttonup'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        set(vh2.fig, 'WindowButtonDownFcn', [mfilename ' colorbuttondown'],...
          'WindowButtonMotionFcn','',...
          'WindowButtonUpFcn', '')
        set(v0.callingfig,'colormap',v2.cmap)
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'colorbuttonmotion'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        v2.cmap=get(v0.callingfig,'colormap'); sz=size(v2.cmap,1);
        xy=get(vh2.ax,'currentpoint');
        xx=max(1,min(sz,round(xy(1,1))));
        yy=max(0,min(1,xy(1,2)));
        dx=v2.colorstep; %mode='v5cubic'; % nearest,linear,spline,pchip,cubic,v5cubic
        nearend=xx<3 |xx>sz-3; %(xx<dx | xx>(sz-dx));
        x1=max(1,xx-dx); x2=min(sz,xx+dx);
        y1=v2.cmap(x1,:); y2=v2.cmap(x2,:);
        x=[1 round((x2-x1+1)/2) x2-x1+1]';

        xi=[1:x2-x1+1]';
        if v2.radio(1);
          if nearend; v2.cmap(xx,1)=yy; else
            Y=[y1(1) yy y2(1)]';
            v2.cmap(x1:x2,1)=interp1(x,Y,xi,v2.smoothmode);end
          set(vh2.r,'ydata',v2.cmap(:,1)); end
        if v2.radio(2)
          if nearend; v2.cmap(xx,2)=yy; else
            Y=[y1(2) yy y2(2)]';
            v2.cmap(x1:x2,2)=interp1(x,Y,xi,v2.smoothmode); end
          set(vh2.g,'ydata',v2.cmap(:,2)); end
        if v2.radio(3)
          if nearend; v2.cmap(xx,3)=yy; else
            Y=[y1(3) yy y2(3)]';
            v2.cmap(x1:x2,3)=interp1(x,Y,xi,v2.smoothmode); end
          set(vh2.b,'ydata',v2.cmap(:,3)); end

        v2.cmap(v2.cmap>1)=1; v2.cmap(v2.cmap<0)=0;
        set(v0.callingfig,'colormap',v2.cmap)
        drawnow
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'colorgetlut'
        vh=getappdata(v0.callingfig,'vh');
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        %cd([v0.homedir 'color'])
        [f p]=uigetfile([v0.homedir 'color\*.lut'],'Pick a color lut');
        try; v2.cmap=load([p f]); catch; return; end
        set(v0.callingfig,'colormap',v2.cmap)
        v.mapname=f(1:end-4);
        set(vh.color,'string',[v.mapname '.lut']);
        % setappdata(v0.callingfig,'vh',vh)
        hh=findobj(vh2.fig,'type','line'); delete(hh);
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
        eval([mfilename ' colorplotlut'])
        return
      case 'colorplotlut'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        xvals=[1:size(v2.cmap,1)];
        set(vh2.ax,'xlim',[1 size(v2.cmap,1)])
        vh2.r=line('xdata',xvals, 'ydata',v2.cmap(:,1),'color','r');
        vh2.g=line('xdata',xvals, 'ydata',v2.cmap(:,2),'color','g');
        vh2.b=line('xdata',xvals, 'ydata',v2.cmap(:,3),'color','b');
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'colorsavelut'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        [f p]=uiputfile([v0.homedir 'color\*.lut'],'Save LUT');
        try; a=v2.cmap; save([p f],'a','-ASCII');
          v.mapname=f(1:end-4); set(vh.color,'string',[v.mapname '.lut']);
          setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
        catch; return; end
        setappdata(vh2.fig,'v2',v2); setappdata(vh2.fig,'vh2',vh2)
      case 'coloredit'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        f=[v0.homedir 'color\junk.lut']; a=v2.cmap;
        save(f,'a','-ASCII')
        edit(f)
        hh=msgbox('Edit, save file, click OK','replace');
        waitfor(hh)
        v2.cmap=load(f);
        v.mapname=''; set(vh.color,'string','')
        set(v0.callingfig,'colormap',v2.cmap)
        setappdata(gcf,'vh2',vh2); setappdata(vh2.fig,'v2',v2)
        eval([mfilename ' colorplotlut'])

      case 'colorquit'
        vh2=getappdata(gcf,'vh2'); v2=getappdata(vh2.fig,'v2');
        close(vh2.fig)
        set(0,'currentfigure',v0.callingfig)

        return

    end % switch varargin
end % switch nargin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% FUNCTIONS START HERE %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setup
vh=getappdata(gcf,'vh');
v=getappdata(vh.fig,'v');
v0=getappdata(0,'v0');
s=which(mfilename);
v0.homedir=s(1:end-length(mfilename)-2);
% under homedir directory put directory 'color' (for luts)
cd (v0.homedir)
try
  cd ('color')
catch
  disp(['Setting up directory ' v0.homedir 'color with default color luts...'])
  mkdir('color')
  %cd ('color')
  list={'autumn';'bone'; 'colorcube'; 'cool'; 'copper'; 'flag';...
    'gray'; 'hot'; 'hsv'; 'jet'; 'lines'; 'pink'; 'prism';...
    'spring'; 'summer'; 'white'; 'winter'};
  for j=1:size(list,1); disp(list{j})
    map=eval(['colormap(' list{j} '(256))']);
    save([v0.homedir 'color\' list{j} '.lut'],'map', '-ASCII')
  end
  save([v0.homedir 'color\custom.lut'],'map', '-AScii')
  %wrap.lut is created here
  a=colormap('gray(256)'); a(1,3)=1; a(end,2:3)=0;
  save([v0.homedir 'color\wrap.lut'],'a','-ASCII')
end

cd (v0.homedir)
format compact; % no double spacing
format short g;
more off
pathold = path;
pathnew = v0.homedir;
path(pathnew,pathold);
clc
setappdata(gcf,'v',v); setappdata(0,'v0',v0)
function setupv0
v0.fignum=0; 
v0.colorbarposition='east'; v0.fbr=[]; v0.fbg=[]; v0.fbb=[];
v0.rlist=[];v0.glist=[];v0.blist=[];
v0.callingfig=[]; v0.rgbyes=0; abort=0; v0.lastInterlacedMovi=[];
v0.list3=[]; v0.hfigcalc=[]; v0.nframes=0; v0.lastsmooth=[];
v0.roivars=[];v0.lastroi=[];v0.savedir=[];v0.lastrect=[];v0.fakevars=[];
v0.zz=[]; v0.xscaler=[]; v0.vOriginal=[]; v0.watlabel=[];v0.figcalc=[];
v0.Movi0=[];v0.watlo=[];v0.watstats=[];v0.watmaxpix=[];
v0.wat=[];v0.watidx=[];v0.watrgb=[];v0.watline=[];v0.watauto=[];v0.fb=[];
v0.figxy=[];v0.endothreshslider=[];v0.pos0=[];v0.pos=[];
s=which(mfilename); v0.homedir=s(1:end-length(mfilename)-2);;
setappdata(0,'v0',v0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bbmakelist(varargin)
v0=getappdata(0,'v0');
vh=getappdata(gcf,'vh');
v=getappdata(vh.fig,'v');
v.piclistdir=v0.homedir;
v.picpath='./';
exit=0;
while (exit == 0)
  %%%%%%%%%%%%%%%   Directory
  try
    v.picdir=char(textread([v.piclistdir 'picdir.txt'],'%s'));
  catch
    v.picdir=v.piclistdir; bbdlmwrite([v.piclistdir 'picdir.txt'],char(v.piclistdir),'')
  end
  try
    cd (v.picdir)
  catch
    v.picdir=v.piclistdir;
    bbdlmwrite([v.piclistdir 'picdir.txt'], char(v.piclistdir),'')
    cd (v.picdir)
  end
  if (~exist([v.piclistdir 'piclist.txt']));
    v.list=[]; bbdlmwrite([v.piclistdir 'piclist.txt'],v.list,'');
  end
  wd=pwd;
  choices={'MENU:';...
    's=show list, i=Info about image';...
    'd(or ls)=dir, b=base names (unique first fields)';...
    'sk=skip, c=cut, cc=include';...
    'x=erase list, cd=change directory';...
    'e=edit, z=make RGB from 3 lists'};

  %%%%%%%%%%%% List of images (piclist.txt)
  v.list=textread([v.piclistdir 'piclist.txt'],'%s');
  v.list2=v.list;
  disp(char(choices))
  disp(['Current directory ' wd]);
  sz=size(v.list,1);
  if (sz);
    disp(' '); disp(['CURRENT LIST: ' num2str(sz) ' entries: ' v.list{1} ' ... ' v.list{end}])
  else
    disp('List: 0 entries')
  end
  beep
  inp=input ('Type base name (wild cards OK) (ENTER=use current list)\n\n','s');
  switch inp
    case 'i'
      prompt=['Which number? (1-' num2str(sz) '; ENTER=all)\n\n'];
      inp=input(prompt,'s');
      if isempty(inp);
        for j=1:sz
          try
            info=imfinfo([v.picdir v.list{j}]);
          catch
            disp (['Error reading ' v.list{j}])
          end;
        end
      else
        try
          info=imfinfo([v.picdir v.list{str2double(inp)}]);
        catch
          disp (['Error reading ' v.list{inp}])
          disp(info)
        end;
      end
    case 'cd'
      [f v.picpath]=uigetfile('*.*','Select a file');
   
      cd (v.picpath)
      bbdlmwrite([v.piclistdir 'picdir.txt'],v.picpath,'')
      bbdlmwrite([v.piclistdir 'piclist.txt'],f,'')
    case 's' % Show list
      clc
      disp(char(v.list))
  %    disp(v.list{:});
      input ('Press ENTER');
    case 'ls'
      ls
      disp('Press ENTER'); pause
    case ''
      clc;
      if ~(isempty(v.list)); exit=1; end % more off; disp(char(list)); more on;
    case 'd'
      dir; disp('Press ENTER'); pause
    case 'c'
      c=input('Omit if it contains string - type string (ENTER=abort)\n\n','s');
      if ~(isempty(c));
        nn=1; list2={};
        for j=1:length(v.list);
          if isempty(findstr(c,v.list{j}));nn=nn+1; list2(nn)=v.list(j);end
        end
        bbdlmwrite([v.piclistdir 'piclist.txt'],char(list2{:}),'')
      end
    case 'cc'
      c=input('Include if it contains string - type string (ENTER=abort)\n\n','s');
      if ~(isempty(c));
        nn=1;list2={};
        for j=1:length(v.list);
          if findstr(c,v.list{j}); list2(nn)=v.list(j); nn=nn+1; end
        end
        bbdlmwrite([v.piclistdir 'piclist.txt'],char(list2{:}),'')
      end
    case 'sk'
      prompt={'Skip initial n' 'Take how many?' 'Skip how many?'};
      title='Skip'; lineno=1; def={'0' '1' '1'};
      inp=inputdlg(prompt,title,lineno,def);
      n0=str2double(inp{1}); n1=str2double(inp{2}); n2=str2double(inp{3});
      list2=v.list(n0+1:end); a=zeros(length(list2),1); sz=n1+n2;
      nn=0;
      for j=1:length(list2)
        nn=nn+1; if nn>sz; nn=1; end
        if nn<=n1; a(j)=1; end
      end
      list2(~a)=[];
      bbdlmwrite([v.piclistdir 'piclist.txt'],char(list2{:}),'')
    case 'x'
      v.list=[]; bbdlmwrite([v.piclistdir 'piclist.txt'],v.list,'')    
    case 'e'
      edit ([v.piclistdir 'piclist.txt'])
      input ('Press ENTER when done','s')
      pause (.1)
    case 'b'
      disp(['reading ' v.picdir '...'])
      a=dir([v.picdir '*.tif']);
      disp('taking the first 7 characters only to make basename list')
      b={a.name};
      for j=1:size(b,2); % base name
        a=b{j};
        a=a(1:7);
        b{j}=a;
      end
      basenames=unique(b) ; % CELL array, for CHAR use f=unique(b,'rows')
      disp('TIF & JPG base names: ');lst='';
      for j=1:size(basenames,2);
        lst=[lst ' ' char(basenames{j})];
        disp(['			' char(basenames{j})]);
      end
      input('Press ENTER')
    otherwise
      %structlist=dir([v.picpath inp]); celllist={structlist.name};
      structlist=dir(inp); celllist={structlist.name};
      celllist=celllist'; % charlist2=zeros(size(structlist,1),1);
      v.list=[v.list; celllist];
      charlist=sortrows(char(v.list));
      bbdlmwrite([v.piclistdir 'piclist.txt'],charlist,'');
      v.list=charlist; v.list2=v.list;
      % does directory (wd) end with '\'?
      a=find(wd=='\'); if ~isempty(a); if a(end) ~= size(wd,2); wd=[wd '\']; end; end
      bbdlmwrite([v.piclistdir 'picdir.txt'],wd,'');
  end % switch inp
end % while exit==0
v.name=v.list{1}; x=find(v.name=='.');
try
  v.name=v.name(1:x(end-1)-1);
catch
end
setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% bbdlmwrite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bbdlmwrite(filename, m, varargin)
% a skeletonized form of dlmwrite
% MAG & WJB Feb 2005
if nargin; dlm=varargin{1}; else dlm=''; end
r=0; c=0; precn=5; NEWLINE=sprintf('\n');
try
  precnIsNumeric = isnumeric(precn);
  if ischar(precn); cpxprec = [precn strrep(precn,'%','%+') 'i']; end
  isCharArray = ischar(m);
catch
  rethrow(lasterror);
end
fid = fopen(filename ,'wb');
if fid == (-1); error('bbdlmwrite failure to open %s', filename); end
[br,bc] = size(m);
for i = 1:r
  for j = 1:bc+c-1
    fwrite(fid, dlm, 'uchar'); % write empty field
  end
  fwrite(fid, NEWLINE, 'char'); % terminate this line
end
% start dumping the array, for now number format float
realdata = isreal(m);
useVectorized = realdata && precnIsNumeric && isempty(strfind('%\',dlm)) && numel(dlm) == 1;
if useVectorized; format = sprintf('%%.%dg%s',precn,dlm); end
if isCharArray
  vectorizedChar = isempty(strfind('%\',dlm)) && numel(dlm) == 1;
  format = sprintf('%%c%c',dlm);
end
for i = 1:br
  % start with offsetting col of matrix
  if c
    for j = 1:c; fwrite(fid, dlm, 'uchar'); end
  end
  if isCharArray
    if vectorizedChar
      str = sprintf(format,m(i,:));
      str = str(1:end-1);
      fwrite(fid, str, 'uchar');
    else
      for j = 1:bc-1 % maybe only write once to file...
        fwrite(fid, [m(i,j),dlm], 'uchar'); % write delimiter
      end
      fwrite(fid, m(i,bc), 'uchar');
    end
  elseif useVectorized
    str = sprintf(format,m(i,:));
    % strip off the last delimiter
    str = str(1:end-1);
    fwrite(fid, str, 'uchar');
  else
    rowIsReal = isreal(m(i,:));
    for j = 1:bc
      if rowIsReal || isreal(m(i,j))
        % print real numbers
        if precnIsNumeric
          % use default precision or precision specified. Print as float
          str = sprintf('%.*g',precn,m(i,j));
        else
          % use specified format string
          str = sprintf(precn,m(i,j));
        end
      else
        % print complex numbers
        if precnIsNumeric
          % use default precision or precision specified. Print as float
          str = sprintf('%.*g%+.*gi',precn,real(m(i,j)),precn,imag(m(i,j)));
        else
          % use complex precision string
          str = sprintf(cpxprec,real(m(i,j)),imag(m(i,j)));
        end
      end

      if(j < bc)
        str = [str,dlm];
      end
      fwrite(fid, str, 'uchar');
    end
  end
  fwrite(fid, NEWLINE, 'char'); % terminate this line
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadmovie
v0=getappdata(0,'v0');
vh=getappdata(gcf,'vh');
v=getappdata(vh.fig,'v');

rlist=v0.fbr; glist=v0.fbg; blist=v0.fbb;

%***************** RGB from 3 lists ******************
if size(rlist,1) || size(glist,1) || size(blist,1)
  info=imfinfo([v.picdir rlist{1}]);
  v.fmt=info.Format; v.bitdepth=info.BitDepth;
  rows=info.Height; cols=info.Width;
  len=max(size(blist,1),max(size(rlist,1),size(glist,1)));
  v.pse=1:len*0;
  Movi=uint8(0); if v.bitdepth==16; Movi=uint16(0); end
  OK=0;
  removelast=0;
  while ~OK
    try
      disp (['Allocating memory for ' num2str(len) ' RGB frames...'])
      Movi=Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
      OK=1;
    catch
      if removelast==0; list=list(2:len); end
      len=len-1;
      if removelast==1; list=list(1:len); end
      disp('Not enough memory. Removing last frame from list...')
      disp ([rlist(len) glist(len) blist(len) ' now last in list'])
    end
  end % while
  Movi=Movi*0;
  for frame=1:len
    if size(rlist,1)>=frame; Movi(:,:,1,frame)=imread([v.picdir rlist{frame}],v.fmt); end
    if size(glist,1)>=frame; Movi(:,:,2,frame)=imread([v.picdir glist{frame}],v.fmt); end
    if size(blist,1)>=frame; Movi(:,:,3,frame)=imread([v.picdir blist{frame}],v.fmt); end
  end
  if v.bitdepth==16
    fac=65535/double(max(Movi(:)));
    disp(['Multiplying by ' num2str(fac)])
    Movi=uint16(double(Movi)*fac);
  end
  v.Movi=Movi;
  v.rgbyes=1;
  setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
  return
end % RGB from 3 lists

rr=0; cc=0;
v.imtype=finfo([v.picdir v.list{1}]); % 'im' = image; 'avi'=avi movie; 'unknown'=3I log file 
switch v.imtype
  case 'mat'
    % all in list must be .mat format, same bitdepth!
    szxmax=0; szymax=0;ntot=0;
    for j=1:length(v.list)
      vv=v; % ??? v.list changes for reasons I do not understand
      load([v.picdir v.list{j}]); v=vv;
      if ~exist('movi'); msgbox([v.list ' is not a pv movie'],'replace'); return; end     
      m{j}=movi;
      if size(movi,1)>szymax; szymax=size(movi,1); end
      if size(movi,2)>szymax; szxmax=size(movi,2); end
      ntot=ntot+size(movi,3);
    end
    v.Movi=zeros(szymax, szxmax, ntot);
     switch class(movi)
          case 'uint8'; v.bitdepth=8; v.Movi=uint8(v.Movi);
          case 'uint16'; v.bitdepth=16; v.Movi=uint16(v.Movi);
          case 'double'; v.bitdepth=64;
     end
     nframes=1;
    for j=1:length(v.list)
      movi=m{j}; nnew=size(movi,3);
      v.Movi(1:size(movi,1),1:size(movi,2),nframes:nframes+nnew-1)=movi;
      for jj=nframes:nframes+nnew-1
        v.list2{jj}=[v.list{j} '.' num2str(jj-nframes)];
      end
      nframes=nframes+nnew;
    end
    v.rgbyes=0;
    v.list=v.list2;
    
  case 'im'
    disp('image')
    numstack=ones(length(v.list),1);
    info=imfinfo([v.picdir v.list{1}]);
    rows=info(1).Height;
    cols=info(1).Width;
    nframes=length(v.list);
    framesperstack=size([info.Height],2); % first image is a stack
    if framesperstack>1
      stacks_same_size=1; % assume all images in the list are stacks of same size (1) or not (0)
      if stacks_same_size
        rows=info(1).Height;
        cols=info(1).Width;
        nframes=framesperstack*length(v.list);
        numstack=ones(length(v.list)); numstack=numstack*framesperstack;
        disp([num2str(nframes) ' frames. ' num2str(length(v.list)) ' image stacks: Assuming each stack has ',...
          num2str(framesperstack) ' images, each ' num2str(cols) 'x' num2str(rows)])
      else
        disp ('checking image x,y, and z size of each image...')
        for k=1:length(v.list)
          info=imfinfo([v.picdir v.list{k}]);
          numstack(k,1)=size([info.Height],2);
          rows=max(rr,info(1).Height);
          cols=max(cc,info(1).Width);
          disp(['Image ' num2str(k) ' has ' num2str(numstack(k,1)) ' images, each ' num2str(cols) 'x' num2str(rows)])
        end
        nframes=sum(numstack);
      end
    end

    info=imfinfo([v.picdir v.list{1}]);
    try
      a=info.PhotometricInterpretation;
      v.rgbyes=strcmp(a,'RGB'); % findstr(a,'RGB');
    catch
      v.rgbyes=0;
    end
    v.bitdepth=info(1).BitDepth;
    ctype=info(1).ColorType;
    fmt=info(1).Format; v.fmt=fmt;
    disp([fmt ' ' num2str(v.bitdepth) ' bit ' ctype])

    switch v.bitdepth
      case 8
        v.Movi = uint8(0);
        if strcmp(ctype,'truecolor');
          v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,nframes));
        else
          v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,nframes));
        end
      case {16, 48}
        ok=0;
        while ok==0;
          %try
          v.Movi = uint16(0);
          v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,nframes));
          if v.bitdepth==48;
            v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,nframes));
          end
          ok=1;
          % catch
          %  len=len-1; v.list=v.list(1:nframes);
          %  disp(['Out of memory. Length=',num2str(nframes)])
          %end
        end

      case 24
        v.Movi=uint8(0);
        v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,nframes));
        v.rgbyes=1;
      otherwise
        beep
        disp(['bitdepth = ' num2str(v.bitdepth)]);
        keyboard
        return
    end
    v.Movi2=v.Movi;
    disp(['Size of frame: ' num2str(rows) ' rows x ' num2str(cols) ' cols'])

    habortt=msgbox('Click to abort','Loading...','replace'); drawnow
    %ctype='hello'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    frame=1;
    for imgnum = 1:length(v.list)
      disp ([num2str(imgnum) '/' num2str(nframes)]);
      %try
      if numstack==1 & strcmp(ctype,'indexed') | strcmp(ctype,'truecolor')% | strcmp(fmt,'jpg')
        [a]=imread([v.picdir v.list{imgnum}],fmt);
        sz=size(a); rr=sz(1); cc=sz(2);
        if v.rgbyes; v.Movi(1:rr,1:cc,:,imgnum)=a;
        else; v.Movi(1:rr,1:cc,imgnum)=a; end
      else
        for jj=1:numstack(imgnum,1);
          a=imread([v.picdir v.list{imgnum}],jj);
          v.list2{frame}=[v.list{imgnum} ': ' num2str(jj)];
          sz=size(a); rr=sz(1); cc=sz(2);
          if v.rgbyes; v.Movi(1:rr,1:cc,:,frame)=a;
          else; v.Movi(1:rr,1:cc,frame)=a; end
          frame=frame+1;
        end
      end
      pause(.01)
    end
    delete(habortt)
    if numstack>1; v.list=v.list2; end

  case 'avi'
    % v.rgbyes=1;
    disp(['Reading AVI movie ' v.list{1}])
 %  mov=VideoReader([v.picdir v.list{1}]);
    info=aviinfo([v.picdir v.list{1}]);
    len=info.NumFrames; rows=info.Height; cols=info.Width; nframes=len;
    v.rgbyes=~strcmp(info.ImageType,'grayscale');

    if v.rgbyes; v.Movi=uint8(0); v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
    else v.Movi=uint16(0); v.Movi= v.Movi(ones(1,rows),ones(1,cols),ones(1,len));
    end

    readmode=1; % 1=aviread; 2=mmreader
    if readmode==1;
      mov=aviread([v.picdir v.list{1}]);
      for frame=1:len
        disp(['Frame ' num2str(frame) '/' num2str(len)])
        if v.rgbyes;
          v.Movi(:,:,:,frame)=mov(frame).cdata;
        else   v.Movi(:,:,frame)=mov(frame).cdata;
        end
        v.list{frame}=num2str(frame);
      end
      v.bitdepth=8; % ?
    else
      mov=mmreader([v.picdir v.list{1}]);

      v.Movi=read(mov);
      for j=1:len; v.list(j)={num2str(j)}; end
    end

    v.bitdepth=16; % 24
    % v.list={};
  case 'unknown' % .log files on 3I microscope come here.   
    srchlist={'Capture Date-Time:' 'Microns Per Pixel'};
    wdn=[4 4]; % word number in the line
    for j=1:length(v.list)
      a=importdata(v.list{j});
      s0=v.list{j};
      for k=1:length(srchlist)
        for kk=1:length(a) % line number
          b=a{kk};
          if findstr(b,srchlist{k});
            wd=regexp(b,'\S+','match'); % parses to words
            c=wd{wdn(k)};
            if strcmp(srchlist{k},'Capture Date-Time:')
              cc=datevec(c); tsec=cc(4)*3600+cc(5)*60+cc(6);
              if j==1; tsec0=tsec; end
              tsec=tsec-tsec0; c=num2str(tsec);
            end
            s0=[s0 char(9) c]; 
          end; end; end
      disp(s0)
    end
    setappdata(vh.fig,'v',v); return
end % mat, image, avi, or unknown (text)

set(vh.bitdepth,'string',[num2str(v.bitdepth) ' bits'])
v.pse=1:nframes; v.pse=v.pse.*0;
v.Movi2=v.Movi;
setappdata(gcf,'v',v); setappdata(0,'v0',v0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function playmovie
v0=getappdata(0,'v0'); vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v');
vplay=getappdata(vh.fig,'vplay');
vplay.frame=v.frame; setappdata(vh.fig,'vplay',vplay)
h=line;
while (v.play)
  v=getappdata(vh.fig,'v');
  vplay=getappdata(vh.fig,'vplay');
  set(vh.fs,'value',vplay.frame);
  str=[num2str(vplay.frame) ': ' v.list{vplay.frame}];
  set(vh.picname,'string',str);
  set(vh.picsize,'string',[num2str(size(v.Movi,2)) ' x ' num2str(size(v.Movi,1))])
  if ~v.rgbyes ;
    a=v.Movi(:,:,vplay.frame);
  else
    a(:,:,1)=v.rgbgain(1)*v.Movi(:,:,1,vplay.frame);
    a(:,:,2)=v.rgbgain(2)*v.Movi(:,:,2,vplay.frame);
    a(:,:,3)=v.rgbgain(3)*v.Movi(:,:,3,vplay.frame);
    %if ~isempty(v0.watlo); a(v0.watoutline)=127; end
  end
  set(vh.img,'cdata',a)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 drawnow
  if v.srf; set(vh.img,'zdata',a); end
  if v.zoom
    i=get(vh.img,'cdata');
    try
      %disp(v.pos)
      i=i(v.pos(2):v.pos(2)+v.pos(4),v.pos(1):v.pos(1)+v.pos(3));
      i=flipdim(i,1);
      set(v.zoomimg,'cdata',i); catch; end
  end
  if v.minmaxmode % auto scaling
    lohi=get(vh.ax,'clim');
    set(vh.minmaxmode,'string',[num2str(lohi(1)) ': ' num2str(lohi(2))])
  end

  if 0>1
  try; z=v.points;
    z=v.points; %{vplay.frame};
   set(h,'xdata',z(vplay.frame,1),'ydata',z(vplay.frame,2),...
     'marker','o','linestyle','none','markerfacecolor','r')
  catch; end
  drawnow
  end % if 0>1

  try
    pausedur=v.pse(vplay.frame);
  catch
    pausedur=0;
  end
  if vplay.frame==v.firstframe && v.pausefirst; pausedur=1; end
  if vplay.frame==v.lastframe && v.pauselast; pausedur=1; end
  switch v.swing
    case 0
      nextframe=vplay.frame+v.framestep;
      if nextframe>v.lastframe;
        nextframe=v.firstframe;
        if v.pauselast;pausedur=1; end
      end
    case 1
      nextframe=vplay.frame+v.framestep*vplay.swingdir;
      if nextframe>v.lastframe
        nextframe=v.lastframe-v.framestep;
        vplay.swingdir=-1;
        if v.pauselast;pausedur=1; end
      elseif nextframe<v.firstframe
        nextframe=v.firstframe+v.framestep;
        vplay.swingdir=1;
        if v.pausefirst;pausedur=1; end
      end
  end
  pause(min(1,pausedur))
  % disp(pausedur)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  vplay.frame=nextframe;
  setappdata(vh.fig,'vplay',vplay)
  if v.close; close(vh.fig); end
  if length(v.list)<2; v.play=0; setappdata(vh.fig,'v',v); end
end % while v.play
v.frame=vplay.frame;
setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)

% ---------------------------------------------
function configfig
v0=getappdata(0,'v0'); vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v');
len=length(v.list);
% Now that we know the movie length, etc. set various sliders...
if len==1; buttonvis; end
v.firstframe=1; v.lastframe=len;
v.zoom=0;

set(vh.lfs,'value',len)
set(vh.picname,'string',v.list{1})
set(vh.fs,'max',len,'sliderstep',[min(.5,1/len) min(1,5/len)])

set(vh.ffs,'max',len,'sliderstep',[min(.5,1/len) min(1,4/len)])
set(vh.lfs,'max',len,'value',len,'sliderstep',[min(.5,1/len) min(1,4/len)]);
set(vh.lfstxt,'string',['Last ' num2str(len)])
set(vh.framestep,'max',len+(len==1))

set(vh.picsize,'string',[num2str(size(v.Movi,2)) ' x ' num2str(size(v.Movi,1))])

% fig name, size and position
xy=v0.figxy; % getappdata(0,'figxy');
v.fignum=v0.fignum+1;
v0.fignum=v0.fignum+1;
setappdata(0,'v0',v0); setappdata(vh.fig,'v',v)
set(vh.fig,'name',[v.figname '_' num2str(v0.fignum)]);
dxy=25; xymax=240; uu=get(vh.fig,'units');
if strcmp(uu,'normalize'); dxy=0.07; xymax=0.4; end
if isempty(xy); xy=20; end % set lower left corner
xy=xy*(xy<xymax)+dxy; v0.figsxy=xy;
v0.figxy=xy;
pos=get(vh.fig,'position'); pos(1:2)=xy;
set(vh.fig,'position',pos)
scrnsz=get(0,'screensize'); scrnx=scrnsz(3); scrny=scrnsz(4);
figsize=get(vh.figsize,'value');
try; vh2=getappdata(v0.callingfig,'vh');
figsize=get(vh2.figsize,'value'); end

v.maxsizefac=min((scrnx-60)/size(v.Movi,2),(scrny-120)/size(v.Movi,1)); % max size
set(vh.figsize,'max',v.maxsizefac,'value',min(figsize,v.maxsizefac))
%if v.maxsizefac<1; 
 % set(vh.figsize,'value',v.maxsizefac)
  %set(vh.figsizetxt,'string',['FigSize ' num2str(round(v.maxsizefac*100)/100)]) %eval([mfilename ' figsize'])
%end
cdmapping='scaled'; % direct or scaled
if v.srf;
  sec='none'; %[.5 .5 .5]; % 'black'; % 'interp'; [r g b], 'none', 'flat
  vh.img=surface(v.Movi(:,:,1));
  colormap(jet); v.mapname='jet';
  set(vh.img,'cdata',v.Movi(:,:,1),'zdata',v.Movi(:,:,1),...
    'tag','hsrf','edgecolor',sec);
  set(vh.ax,'xlim',[1,size(v.Movi,2)], 'ylim',[1,size(v.Movi,1)],...
    'zlim',[min(v.Movi(:)) max(v.Movi(:))],'ydir','rev')
  view(30,66)
  rotate3d on
  axis normal % vis3d % so size (evident zoom) is constant during rotation
else
  if v.rgbyes; a=v.Movi(:,:,:,1); 
  else a=v.Movi(:,:,1); end
vh.img=image(a,'cdatamapping',cdmapping,...
    'buttondownfcn',[mfilename ' pixval']);
  axis image
end
mn=min(v.Movi(:)); mx=max(mn+1, max(v.Movi(:)));
set(vh.ax,'climmode','manual','clim',[mn mx])

% RGB on non-RGB sliders
if v.rgbyes
  delete(vh.minslider); 
  delete(vh.maxslider); 
  delete(vh.minmaxmode)
  bitdepthstr='RGB-> 8 bit';
  set(vh.bitdepth,'string',bitdepthstr)
else
    try
  delete(vh.rgbgaintxt); 
  delete(vh.rgbgain)
  set(vh.minslider,'min',mn,'max',mx,'value',mn)
  set(vh.maxslider,'min',mn,'max',mx,'value',mx)
  set(vh.minmaxmode,'string',[num2str(mn) ' : ' num2str(mx)])
  str='8-->16bit,RGB...'; 
  if v.bitdepth==16; str='16-->8bits/Clip'; end
  set(vh.bitdepth,'string',str)
    catch; end
end

try; map=v.mapname; catch; v.mapname='gray'; end
try; map=load([v0.homedir 'color\' v.mapname '.lut']); catch; end
try; colormap(map); catch; colormap('gray'); end
set(vh.color,'string',[v.mapname '.lut'])
eval([mfilename ' figsize'])

%axis off
set(findobj('type','uicontrol'),'units','pixels')
name=get(vh.fig,'name');
set(vh.fig,'handlevisibility','on',...
  'doublebuffer','on',...
  'units','pixels',...
  'visible','on',...
  'WindowScrollWheelFcn',@bbscroll,'name',name)
drawnow
pause(0.1)
buttonvis
if ~strcmp(v.fmt,'GIF'); set(vh.img,'cdatamapping','scaled'); end

endothreshslider=v0.endothreshslider; % getappdata(0,'endothreshslider');
v0.endothreshslider=0;
if isempty(endothreshslider); end % endothreshslider=0; end
setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
if length(v.list)<2; v.scroll=0; end
vplay.frame=1;
vplay.swingdir=1;
setappdata(vh.fig,'vplay',vplay); setappdata(0,'v0',v0)
% ----------------------------------------------
function [x,y] = bbgetcurpt(axHandle)
%GETCURPT Get current point.
%  [X,Y] = GETCURPT(AXHANDLE) gets the x- and y-coordinates of
%  the current point of AXHANDLE. GETCURPT compensates these
%  coordinates for the fact that get(gca,'CurrentPoint') returns
%  the data-space coordinates of the idealized left edge of the
%  screen pixel that the user clicked on. For IPT functions, we
%  want the coordinates of the idealized center of the screen
%  pixel that the user clicked on.
%  Steven L. Eddins, March 1997
%  Copyright 1993-1998 The MathWorks, Inc. All Rights Reserved.
%  $Revision: 1.2 $ $Date: 1997/11/24 15:55:45 $

pt = get(axHandle, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

% What is the extent of the idealized screen pixel in axes
% data space?

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position');
set(axHandle, 'Units', axUnits);

axPixelWidth = axPos(3);
axPixelHeight = axPos(4);

axXLim = get(axHandle, 'XLim');
axYLim = get(axHandle, 'YLim');

xExtentPerPixel = abs(diff(axXLim)) / axPixelWidth;
yExtentPerPixel = abs(diff(axYLim)) / axPixelHeight;

x = x + xExtentPerPixel/2;
y = y + yExtentPerPixel/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BBPASTE %%%%%%%%%%%%%%%%%%%
function c=bbpaste(a,b,pastemode) %
val=nan; % value of unfilled cells
switch pastemode
  case 'horizontal' % horizontal paste
    rows=max(size(a,1), size(b,1)); cols=size(a,2)+size(b,2);
    c=zeros(rows,cols); c=c+val;
    c(1:size(a,1),1:size(a,2))=a;
    c(1:size(b,1),size(a,2)+1:end)=b;
  case 'vertical' % vertical paste
    cols=max(size(a,2), size(b,2)); rows=size(a,1)+size(b,1);
    c=zeros(rows,cols); c=c+val;
    c(1:size(a,1),1:size(a,2))=a;
    c(size(a,1)+1:end,1,size(a,2))=b;
end

%******************************* BBDRAW ******************************
function bbdraw(varargin)
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
switch (nargin)
  case 0
    source=[mfilename ' bbdraw'];
    disp ('Left button down to start, up to end')
    set(vh.fig, 'Pointer','circle',...
      'WindowButtonDownFcn','',...
      'WindowButtonMotionFcn','',...
      'WindowButtonupFcn','');
    set(vh.img,'buttondownfcn',[source ' down';]);
    v.xdraw=[]; v.ydraw=[];
    setappdata(vh.fig,'v',v)
    drawnow
  case 1
    source=[mfilename ' bbdraw'];
    switch(varargin{:})
      case 'down'
        x=[];y=[];
        vh.drawline=line('tag','lines','xdata',x,'ydata',y,'Visible', 'on', 'Clipping', 'on', ...
          'Color', 'r', 'LineStyle', '-'); %, 'EraseMode', 'xor');
        set(vh.img,'buttondownfcn','')
        set(vh.fig, 'WindowButtonDownFcn', '',...
          'WindowButtonMotionFcn', [source ' move;']);
        set(vh.fig,'windowbuttonupfcn',[source ' up'])
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
      case 'move'
        [xnow,ynow] = bbgetcurpt(vh.ax);
        v.xdraw=[v.xdraw xnow];
        v.ydraw=[v.ydraw ynow];
        setappdata(vh.fig,'v',v)
        set(vh.drawline,'xdata',v.xdraw,'ydata',v.ydraw,'visible','on');
        drawnow
      case 'up'
        set(vh.fig,'pointer','arrow',...
          'WindowButtonMotionFcn', '',...
          'WindowButtonupFcn', '',...
          'WindowButtonDownFcn','',...
          'userdata','')
        delete (vh.drawline)
        setappdata(vh.fig,'vh',vh); setappdata(vh.fig,'v',v)
    end
end

%%%%%%%%%%%%%%%%%%%%%% BBPLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bbplot
% calls to here: ROI, import data, new graph, <pv pv>, watershed,
% f neighbor
vh0=getappdata(gcf,'vh'); v0=getappdata(0,'v0');
v1=getappdata(vh0.fig,'v');
import=0;
v.binwd=0;
v1.z2original=v1.z2;
try
  zz=v1.zimport; import=1;
  v1.zimport=[];
  setappdata(vh0.fig,'v',v1);
catch
  zz=[];
end
h=openfig('pvplot','new');
a=findobj(h,'type','image'); if ~isempty(a); delete(a); end
a=findobj(h,'type','line'); if ~isempty(a); delete(a); end
vh=guihandles(h);
v=v1; % this transfers data (z, z2, etc) to new fig
set(vh.fig,'keypressfcn',[mfilename ' keypress' ' keypress'])
if ~isempty(zz); v.zdata=zz; v.z2=zz; v.zavg=[]; end
pos=get(vh.fig,'position');
pos(1)=max(1,pos(1)-rand*40); pos(2)=max(1,pos(2)-rand*40);
set(vh.fig,'position',pos)

v.callingfig=vh0.fig;
try
  if v.dummy; delete(vh0.fig); v.dummy=0; end;
catch
end
%try
% x=v.xdata;
%catch
%  v.xdata=[1:size(v.z2,1)]'; x=v.xdata;
%end
h2=findobj(vh.fig,'type','line'); delete(h2)
v.sym=0; v.isgrid=0; v.smooth=1; v.normalize=0;
v.linesel=[]; v.rectsel=[]; v.plotzoom=0;
v.plotfitdata=[]; v.plotfitmodel=1;
v0.fignum=v0.fignum+1;
v.fignum=v0.fignum;
try
  v.name=[v1.newname '_' num2str(v0.fignum)];
catch
  v.name='noname';
end
set(vh.fig,'name',v.name,'visible','on')
setappdata(0,'v0',v0)
setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh) % new fig
if ~import;
  bbplot2
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% BBPLOT2 %%%%%%%%%%%%%%%%%%%%
function bbplot2 % (varargin) % This does the plotting

vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
v.linesel=[]; setappdata(vh.fig,'v',v);
if v.histo; bbhisto; return; end
v.loi=0;
z=v.z2;
try
  if ~isempty(v.zavg); z=v.zavg(:,end); end;
catch
  v.zavg=[];
end

if v.smooth>1
  val=v.smooth; %round(get(vh.plotsmooth,'value'));
        if round(val/2) == val/2;  val=val+1; end
        v.smooth=val; % val=2*val+1;
       
        set(vh.plotsmoothtxt,'string',['Smooth ' num2str(v.smooth)]);
        v.std=0; %.67;
        v.z2=v.z2original;
       % if isempty(v.z2); v.z2=v.zdata; end
        if ~isempty(v.zavg); v.z2=v.zavg; end
       % zz=v.z2; 
        sz=size(v.z2,1); p1=1; p2=sz;
        padit=1; 
        if padit
          zrev=v.z2(end:-1:1,:);
          zz=[zrev; v.z2; zrev]; p1=sz+1; p2=2*sz;
        end
        for jj=1:size(z,2)        
          z3=smoothn(zz(:,jj),[v.smooth 1],'g', 0.65);
          v.z2(:,jj)=z3(p1:p2); % unpad
        end
     setappdata(vh.fig,'v',v)
  z=v.z2;
  
end

try
  xdata=v.xdata;
catch
  v.xdata=[]; xdata=[];
end
if isempty(xdata); xdata=(1:size(z,1))';
end
if size(xdata,1)~=size(z,1); xdata=[1:size(z,1)]'; end

try
  sym=v.sym;
catch
  v.sym=0;
end
sym=v.sym; % 0=marker; 1=line; 2=both
if sym~=1 & size(v.z2,1)>100000;
  inp=questdlg('>100,000 points - plot as line only?');
  if strcmp(inp,'Yes'); sym=1; end
end
xjitter=0; yjitter=0;
h2=findobj(vh.fig,'userdata','plotline'); delete(h2)
h2=findobj(vh.fig,'tag','semline'); delete(h2)
clr={'r' 'g' 'b' 'k'}; % 'y' 'm' 'c'};
symb={'o' 's' '^' 'd' 'v' 'x' '+' '*' 'p' 'h'};
if sym==1; symb={'none'}; end
typ={'-' ':' '--' '-.'};
if sym==0; typ={'none'}; end
clr2=0; symb2=0; typ2=0; str={}; cc=0; rr=1;

tt=size(z,1);
first=1; last=size(z,2);
buttonvis('abort')
stepit=1; nmax=101;
if last>nmax;
  stepit=round(last/nmax);
  prompt=[num2str(last) ' plots. Show all (all) or skip ' num2str(stepit-1) '? (skip)'];
  title='Skip some or plot all?';
  inp=questdlg(prompt,title,'all','skip','skip');
  if strcmp(inp,'all'); stepit=1; end
end

eppcalc=0; % correct EPP for NLS and divide by mEPP -> m
if eppcalc
  vm=40;
  rp=-10;
  vmini=.58;
  vo=vm-rp;
  vv=z(:,2)*vo;
  vv2=vmini*(vo-z(:,2));
  z(:,2)=vv./vv2;
end

for jj=first:stepit:last % 1:size(z,2);
  if getappdata(0,'abort'); return; end
  try; msz=v.msz; catch; v.msz=3; msz=3; end %3; % 4-3.99*histo;
  clr2=(clr2+1)*(clr2<size(clr,2))+(clr2==size(clr,2));
  symb2=symb2+(clr2==1); if symb2>size(symb,2); symb2=1; end
  typ2=typ2+(clr2==1 & symb2==1); if typ2>size(typ,2); typ2=1; end
  typ2=1; %%%%%%%%%%%%%%%%%%%%%%%%%%%
  cc=cc+1; if cc>6; rr=rr+1; cc=1; end
  str{rr,cc}=[num2str(jj) ': ' clr{clr2} symb{symb2} typ{typ2}];
  xcol=1;
  xxdata=xdata(1:tt,xcol)+(jj-1)*xjitter;
  yydata=z(1:tt,jj)+(jj-1)*yjitter;
  v.hline(1)=line(xxdata,yydata,...
    'tag',['line' jj],...
    'color',clr{clr2},...
    'linestyle',typ{typ2},...
    'linewidth',0.5,...
    'marker',symb{symb2},...
    'markeredgecolor',clr{clr2},...
    'markerfacecolor',clr{clr2},...
    'markersize',msz,...
    'visible','on',...
    'userdata','plotline',...
    'buttondownfcn',[mfilename ' plotline']);
  drawnow
  try
    a=v.zsem;
  catch
    v.zsem=[];
  end
  if ~isempty(v.zsem)
    for k=1:size(yydata,1)
      line([xxdata(k) xxdata(k)],[yydata(k) yydata(k)+v.zsem(k)],...
        'linestyle','-','color',clr{clr2},'tag','semline' )
    end
  end
  %pause
end % for jj=first:stepit:last
buttonvis
if size(str,1)<30; disp('Column#: color/symbol/line: '); disp(str); end
try; if ~isempty(v.xavg)
    xmid=v.xavg(:,1)+v.xbw/2;
    for j=1:size(v.xavg,1)
      line('xdata', [v.xavg(j,1) v.xavg(j,1)+v.xbw], 'ydata', [v.xavg(j,2) v.xavg(j,2)],'tag','semline')
      line('xdata',[xmid(j,1) xmid(j,1)], 'ydata',[v.xavg(j,2)-v.xbw/2 v.xavg(j,2)+v.xbw/2], 'tag','semline')
    end
    line('xdata', xmid, 'ydata', v.xavg(:,2),'tag','semline','marker','none',...
      'markerfacecolor','black', 'linestyle','none')
    v.xavg=[]; setappdata(vh.fig,'v',v)
  end; catch; end

if v.circles
    inp=inputdlg({'which col contains info about size?'},'Column?',1,{'14'});
    col=str2num(inp{1});
    if isempty(inp{:}); v.circles=0; setappdata(vh.fig,'v',v); return; end
    
    rad0=v.zdata(:,col); 
    minrad0=min(rad0(rad0>0));
    rad0=max(1,rad0-minrad0); rad0=rad0/max(rad0); 
    
    fillcircle(v.xdata,v.z2,rad0,255)
  
end

%       %%%%%%%%% BBBLOCK
function big=bbblock (varargin) % x,y,big,small)
% BBBLOCK: inserts a small array into a big array with the
% upper left corner at position x,y
% syntax: big=bbblock(x,y,big,small)
x=varargin{1}; y=varargin{2}; big=varargin{3}; small=varargin{4};
szx=size(small,2); szy=size(small,1);
if size(size(big),2)==3; big(y:y+szy-1,x:x+szx-1,:)=small;
else
  big(y:y+szy-1,x:x+szx-1)=small;
end

% -----------------------------------------
function m=getfig (varargin)
% m: c1=fig handle; c2=fignum
v0=getappdata(0,'v0');
h2=findobj('type','figure','visible','off'); delete(h2)
allfig=findobj(0,'type','figure');
allfig(:,2)=allfig(:,1)*0;
for j=size(allfig,1):-1:1 % get fignum
  vv=getappdata(allfig(j,1),'v');
  try
    if allfig(j,1)==gcf; m0(1,1)=gcf; m0(1,2)=vv.fignum; end
    allfig(j,2)=vv.fignum; catch;
    allfig(j,:)=[]; end
end
if size(allfig,1)==1; m=allfig; return; end
if nargin; prompt=varargin(1);
else
  prompt={'Figure numbers?'};
end
p2={['(choose from ' num2str(allfig(:,2)') ')']};
prompt={[prompt{:} ' ' p2{:}]};
title='Select Figure(s)'; lineno=1;
def={''};
inp=inputdlg(prompt,title,lineno,def);
if isempty(inp); mm=m0;
else
  mm=str2num(inp{1})';
end 
m=[];
for k=1:size(mm,1)
  if mm(k,1)==0 % only for 8bit to RGB
    m(k,1)=0; m(k,2)=0;
  else
  indx=find(allfig(:,2)==mm(k,1));
  if isempty(indx);
    m=m0;
  else
    m(k,1)=allfig(indx,1);
    m(k,2)=mm(k,1);
  end % if isempty(indx)
  end % if mm(k,1)==0
end
drawnow
%disp(allfig)
pause(0.01)
%%%%%%%%%%%%%%%%%%%%%%%%% Get Fig Handle %%%%%%%%%%%%%
function h=getfighandle(fignum)
allfig=findobj(0,'type','figure');
h=0;
for j=1:size(allfig,1)
  vv=getappdata(allfig(j,1),'v');
  if fignum==vv0.fignum; h=allfig(j); end
end

%%%%%%%%%%%%%%%%%%%%% bbalign %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e=bbalign(jj,xyalign,Movi,dmax,v)
%rgbyes=0; %%%%%%%%%%%%%%
if v.rgbyes; c=double(Movi(:,:,:,jj));
else c=double(Movi(:,:,jj)); end
szy=size(c,1); szx=size(c,2);
dx=xyalign(jj,1); dx=min(abs(dx),dmax)*sign(dx);
dy=xyalign(jj,2); dy=min(abs(dy),dmax)*sign(dy);
yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
if v.rgbyes; d=c(yl2:yu2,xl2:xu2,:); zz=zeros(szy,szx,3);
else d=c(yl2:yu2,xl2:xu2);
  bkg=round(sum(d(:))/numel(d)); % background
  zz=zeros(szy,szx); zz=zz+bkg;
end % cutout region to move
xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0);
e=bbblock(xx2,yy2,zz,d);

% -------------------------------------
function bbgetpts(varargin)
% BBGETPTS: For picking points.
source=[mfilename ' bbgetpts'];
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
set(0,'currentfigure',vh.fig)
switch (nargin)
  case 0
    disp ('Left button picks, right button ends (without picking)')
    %ht0=size(get(vh.img,'Cdata'));
    set(vh.fig, 'Pointer','crosshair',...
      'WindowButtonDownFcn','',...
      'WindowButtonMotionFcn','',...
      'WindowButtonupFcn','');
    set(vh.img,'buttondownfcn',[source ' down']);
    v.counter=0; v.x=[]; v.y=[];
    setappdata(vh.fig,'v',v);
    drawnow
  case 1
    switch(varargin{:})
      case 'down'
        button=get(vh.fig,'selectiontype');
        if (strcmp(button,'normal'))
          [xnow ynow] = bbgetcurpt(vh.ax);
          xnow=round(xnow); ynow=round(ynow);
          v.x=[v.x xnow]; v.y=[v.y ynow];
          rad=abs(v.roirad);
          for r=1:size(rad,2)
            rr=rad(r);
            xmin=xnow-rr-.5; ymin=ynow-rr-.5; wd=2*rr+1; ht=wd;
            rectangle ('position',[xmin ymin wd ht],'edgecolor','red'); 
          end
          v.counter=v.counter+1;
           text('position',[xnow ynow],'string',num2str(v.counter),...
            'color','red','fontsize',12,'horizontalalignment','center');          
          setappdata(vh.fig,'v',v)
        elseif (strcmp(button,'alt')); % right button
          set(vh.img,'buttondownfcn','');
          set(vh.fig,'userdata','','pointer','arrow',...
            'windowbuttondownfcn',[mfilename ' pixval']);
        end
    end
end

function bbgetrect(varargin)
% BBGETRECT: Drag out rectangle, tben position it. Coordinates are returned.
% Left click to start. Hold down button while dragging out
% rectangle. Rectangle size is set when button is released.
% Rectangle may then be moved to a new position, which is set
% by pressing left button again.
% Position ('pos') values (x,y,width,height) are placed in application-defined
% location in the current figure: setappdata(gca,'pos',[x,y,width,height).
try; vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
catch; return; end
source=[mfilename ' bbgetrect'];
switch (nargin);
  case 0
    if v.zoom
      v.square=1; sz=get(0,'screensize'); szx=sz(3); szy=sz(4);
      hh=gcf;
      lut=colormap; climit=get(vh.ax,'clim');
      try; a=get(v.zoomfig); figure(v.zoomfig);
      catch
        v.zoomfig=figure('position',[szx-400 szy-500 400 400],...
          'interruptible','off');
        v.zoomax=axes('position',[0 0 1 1]);
        v.zoomimg=image('CDataMapping','scaled');
      end
      colormap(lut);
      set(gca,'clim',climit,'visible','off');
      figure(hh)
    end
    v0.pos=[]; v0.pos0=[];

    set(vh.fig, 'Pointer', 'cross',...
      'WindowButtonDownFcn','',...
      'WindowButtonMotionFcn', '',...
      'WindowButtonupFcn', '');
    v.pos=[1 1 1 1]; v.dx=0;v.dy=0; v.x0=0; v.y0=0;
    rectangle('tag','rect','parent', vh.ax,'position', v.pos, ...
      'Visible', 'off', 'Clipping', 'off', ...
      'edgeColor', 'k', 'LineStyle', '-', 'EraseMode', 'xor');
    rectangle('tag','rect','Parent', vh.ax, 'position', v.pos, ...
      'Visible', 'off', 'Clipping', 'off', ...
      'edgeColor', 'w', 'LineStyle', '-', 'EraseMode', 'xor');
    set(vh.fig, 'WindowButtonDownFcn', [source ' down1;']);
  case 1
    switch(varargin{:})
      case 'down1'
        [v.x0,v.y0] = bbgetcurpt(gca);
        v.pos=round([v.x0 v.y0 1 1]); v.pos0=v.pos;
        v0.pos0=v.pos0;
        set(findobj('tag','rect'), 'position', v.pos, 'visible', 'on');
        set(vh.fig, 'WindowButtonDownFcn', '',...
          'WindowButtonupfcn', [source ' up'],...
          'WindowButtonMotionFcn', [source ' move1;']);
        ptr=nan; ptr=ptr(ones(1,16),ones(1,16));
        set(vh.fig,'PointerShapeCData', ptr,'Pointer', 'custom');
      case 'move1'
        [x,y] = bbgetcurpt(gca);
        if v.square
          ydis = abs(y - v.y0);
          xdis = abs(x - v.x0);
          if (ydis > xdis)
            x = v.x0 + sign(x - v.x0) * ydis;
          else
            y = v.y0 + sign(y - v.y0) * xdis;
          end
        end
        wd=max(1,abs(x-v.x0)); ht=max(1, abs(y-v.y0));
        xmin=min(x,v.x0); ymin=min(y,v.y0);
        v.pos=round([xmin ymin wd ht]);
        set (findobj('tag','rect'), 'position', v.pos, 'visible', 'on');
      case 'up'
        [v.x1,v.y1] = bbgetcurpt(gca); % new ref pt
        v.x0=v.pos(1); v.y0=v.pos(2);
        v0.pos0=v.pos; % original position of rectangle
        set(vh.fig, 'WindowButtonDownFcn', [source ' down2;']);
        set(vh.fig, 'WindowButtonMotionFcn', [source ' move2;']);
      case 'move2'
        [x,y] = bbgetcurpt(gca);
        dx=x-v.x1; dy=y-v.y1;
        v.pos(1)=v.x0+dx;
        v.pos(2)=v.y0+dy;
        set (findobj('tag','rect'), 'position', v.pos);
        if v.zoom
          v.pos=round(v.pos);
          i=get(vh.img,'cdata');
          try
            i=i(v.pos(2):v.pos(2)+v.pos(4),v.pos(1):v.pos(1)+v.pos(3),:);
            i=flipdim(i,1);
            set(v.zoomimg,'cdata',i); catch; end
        end
      case 'down2'
        set(vh.fig,'pointer','arrow',...
          'WindowButtonDownFcn','',...
          'WindowButtonMotionFcn', '',...
          'WindowButtonupFcn', '')
        v.pos=round(v.pos);
        v0.pos=v.pos;
        delete (findobj(get(gca,'children'),'tag','rect'));
        set (vh.fig,'userdata','')
        v.square=0;
        if v.zoom
          v.zoom=0;
          set(vh.zoom,'BackgroundColor',[.92 .91 .85])
          delete(v.zoomfig)
        end
    end
end
setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
setappdata(0,'v0',v0)
%%%%%%%%%%%%%%%%%%%%%%%%%% BBINTLINE %%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y] = bbintline(x1, x2, y1, y2)
% BBINTLINE is the same as INTLINE.
%INTLINE Integer-coordinate line drawing algorithm.
%  [X, Y] = INTLINE(X1, X2, Y1, Y2) computes an
%  approximation to the line segment joining (X1, Y1) and
%  (X2, Y2) with integer coordinates. X1, X2, Y1, and Y2
%  should be integers. INTLINE is reversible; that is,
%  INTLINE(X1, X2, Y1, Y2) produces the same results as
%  FLIPUD(INTLINE(X2, X1, Y2, Y1)).
%  Steven L. Eddins, October 1994
%  Copyright 1993-1998 The MathWorks, Inc. All Rights Reserved.
%  $Revision: 5.4 $ $Date: 1997/11/24 15:56:03 $
dx = abs(x2 - x1);
dy = abs(y2 - y1);
% Check for degenerate case.
if ((dx == 0) && (dy == 0))
  x = x1;
  y = y1;
  return;
end
flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
if (flip)
  x = flipud(x);
  y = flipud(y);
end

% -----------------------------------------------------------
function snglpix % single pixel analysis of ROI
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
lastroi=v0.lastroi;
Movi=v.Movi;
bw=v.mask;
if isempty(bw)
  a=lastroi{:};
  x=a(:,1); y=a(:,2);
  bw=roipoly(Movi,x,y);
end
prompt={'First background frame?',...
  'Last background frame?',...
  'Which frame for peak?'};
title='Background/peak frame number'; lineno=1;
def={'1' '1' '3'};
inp=inputdlg(prompt,title,lineno,def);
if isempty(inp); return; end
firstbkg=str2double(inp{1});
lastbkg=str2double(inp{2});
peakframe0=str2double(inp{3});
peakframe=str2double(inp{3})-lastbkg+1;
z=[];
last=round(get(vh.lfs,'value'));
disp(['Using Frames ' num2str(lastbkg) ' to ' num2str(last)])
[r,c]=ind2sub([size(Movi,1),size(Movi,2)],find(bw));
msz=last-lastbkg+1;
m=ones(msz,1);
col=0;

hxy=line('marker','o','markerfacecolor','none','markeredgecolor','red');
figfocus=gcf;
buttonvis('abort')
sz=size(v.Movi); szx=sz(2);

%lo=get(vh.ffs,'value'); hi=get(vh.lfs,'value');
h2=figure('position',[20 20 20+szx 120]);
hdata=line('marker','none','linestyle','-','color','black');
hfit=line('marker','none','linestyle','-','color','red');
hbkg=line('marker','none','linestyle','-','color','red');

makemovie=0; % to make a movie for powerpoint
mstart=round(size(r,1)/2);
mend=mstart+200;

for j=mstart*makemovie+1:size(r)
  if getappdata(0,'abort'); return; end
  col=col+1;
  disp([num2str(j) '/' num2str(size(r,1))])
  z(1,col)=r(j); z(2,col)=c(j);
  m(:,1)=double(Movi(r(j),c(j),lastbkg:last));
  mm(:,1)=double(Movi(r(j),c(j),1:size(Movi,3))); % entire length
  set(hdata,'xdata',(1:size(mm,1))','ydata',mm) % graph data
  set(hxy,'xdata',c(j),'ydata',r(j)) % mark pixel on image
  f0=mean(mm(firstbkg:lastbkg)); %  m(1,1); % prestim F
  jj=peakframe;
  df0=m(jj)-f0;
  z(3,col)=f0; % initial F     `
  z(4,col)=df0; % dF

  % endo half time
  jj0=jj;
  endothresh=f0+0.5*df0;
  while m(jj,1)>endothresh && jj<size(m,1)
    jj=jj+1;
  end
  dj=jj-1;
  if jj>=size(m,1); dj=0; end
  z(5,col)=dj;

  % curve fitting
  y=m(jj0:end);
  x=(1:size(y,1))';
  % linear
  opts=fitoptions('method','nonlinearleastsquares',...
    'StartPoint',[df0/msz m(1)]);
  ftype=fittype('a*x+b','coeff',{'a' 'b'});
  [yres,gof]=fit(x,y,ftype,opts);
  yfit=yres.a*x+yres.b;
  set(hxy,'xdata',c(j),'ydata',r(j))
  figure(h2)
  set(hdata,'xdata',(1:size(mm,1))','ydata',mm) % graph data
  set(hfit,'xdata',x+peakframe0-1,'ydata',yfit)
  set(hbkg,'xdata',[firstbkg lastbkg],'ydata',[f0 f0])
  drawnow

  if j>=(mstart & j<=mend) && makemovie
    drawnow
    figure(figfocus)
    F1=getframe; a1=F1.cdata;
    figure(h2)
    F2=getframe; a2=F2.cdata;
    if makemovie==1;
      makemovie=2;
      sz1=size(a1); sz2=size(a2);
      v.M1=uint8(0); v.M2=uint8(0);
      v.M1=v.M1(ones(1,sz1(1)),ones(1,sz1(2)),ones(1,3),ones(1,1));
      v.M2=v.M2(ones(1,sz2(1)),ones(1,sz2(2)),ones(1,3),ones(1,1));
    end
    try
      v.M1(:,:,:,end+1)=a1;
      v.M2(:,:,:,end+1)=a2;
    catch
      disp('xxxxxxxxxxxxxxxxxxxxxxx');
    end
  end
  if j==mend && makemovie
    disp('Saving movies as yy1 and yy2')
    v.M1=v.M1(:,:,:,2:end); v.M2=v.M2(:,:,:,2:end);
    for k=1:size(v.M1,4)
      n1=['000' num2str(k)]; n1=char(n1(end-2:end));
      imwrite(v.M1(:,:,:,k),['yy1.' n1 '.tif'],'tif')
      imwrite(v.M2(:,:,:,k),['yy2.' n1 '.tif'],'tif')
    end
  end
  figure(h2)

  z(6,col)=yfit(1)-f0; % dF according to fit
  z(7,col)=yres.a; % slope;
  z(8,col)=gof.rsquare; % r2;
end

m0=0*Movi(:,:,1);
index=sub2ind([size(Movi,1),size(Movi,2)],z(1,:),z(2,:));
delete(hxy)

m=m0; % initial F
m(index)=z(3,:);
v.Movi2=m;

m=m0; % dF raw
m(index)=z(4,:);
v.Movi2(:,:,2)=m;

m=m0; % dF according to fit
m(index)=z(6,:);
v.Movi2(:,:,3)=m;

m=m0; % endo half time
m(index)=z(5,:);
v.Movi2(:,:,4)=m;

m=m0; % endo fit -slope
zz=-z(7,:); fac=-100/min(zz(:)); zz=zz*fac+100; mn=min(zz(:));
disp(['slope values multiplied by ' num2str(fac) ' and 100 added'])
if mn<0; zz=zz+mn; disp(['Add ' num2str(mn)]); end
m(index)=round(zz);
v.Movi2(:,:,5)=m;

m=m0; % endo r^2
zz=z(8,:)*100;
m(index)=round(zz);
v.Movi2(:,:,6)=m;


% OUTPUT: c1=x, c2=y, c3=F0, c4=dFraw, c5=endo half time
%         c6=dFfit, c7=-slope endo, c8=r^2

v.zdata=z; v.z2=[]; % y x F0 dFraw half-time dFfit slope r^2
v.list2={'F0' 'dFraw' 'dFfit' 'endo t1/2' 'endo slope' 'r^2'};
v0.endothreshslider=1;
setappdata(vh.fig,'v',v)
v0.callingfig=vh.fig; setappdata(0,'v0',v0)
figname=[' RiseTime.dF.endoT1/2_' num2str(v0.fignum)];
delete(h2)
buttonvis
eval([mfilename figname figname figname])

% ---------------------------------------------------------
function buttonvis (varargin)
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
try
  none=v.nobuttonchange;
catch
  none=0;
end
if none; return; end
try
  len=length(v.list);
catch
  len=0;
end
if nargin==0; lbl='normal'; else lbl=varargin{1}; end
if isempty(lbl); lbl='normal'; end
if strcmp(lbl,'abort'); setappdata(0,'abort',0); end
h0=findobj(vh.fig,'type','uicontrol');
if strcmp(lbl,'nobuttons');
  set(h0,'visible','off'); drawnow
else
  ud=get(h0,'userdata');
  for j=1:size(h0,1)
    vis='off';
    if findstr(ud{j},lbl); vis='on'; end
    if len==1; if findstr(ud{j},'singleoff'); vis='off'; end; end
    set(h0(j),'visible',vis)
  end
end
drawnow
% -----------------------------------------------------------
function plotfit
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
if v.histo; gaussfit; return; end
try; a=v.lastplotfitexpr; catch; v.lastplotfitexpr=[]; end
if isempty(v.linesel);
  h2=findobj(vh.fig,'type','line','userdata','plotline');
 % if size(h2,1)==1; v.linesel=h2; v.selectall=1;
 % else msgbox('First select a line','replace'); return; end
 v.linesel=h2; v.selectall=1;
end
A0=0; B0=0; C0=0; D0=0; E0=0; F0=0;
% get x range for fitting
pos=v.rectsel; % selected x window to be fit
if isempty(pos);
  xlimit=get(vh.plotax,'xlim'); p1x=xlimit(1); p2x=xlimit(2);
else
  p1x=pos(1); p2x=pos(1)+pos(3);
end
% get y data
cols=str2num(v.yinstr);
for j=1:size(v.linesel,1)
  zz(:,j)=get(v.linesel(j),'ydata')';
  %zz(:,j)=v.zdata(:,cols(j)); 
  if ~isempty(v.zavg); zz(:,j)=v.zavg; end
  clr(j,:)=get(v.linesel(j),'markerfacecolor');
end
% get x data
try; a=v.xdata; catch; v.xdata=[]; end
if isempty(v.xdata);  v.xdata=double((1:size(v.z2,1))'); end
if size(v.xdata,1) ~= size(zz,1); v.xdata=double((1:size(v.z2,1))'); end
x=double(v.xdata);
% trim x and zz to window width
b=x>=p1x & x<=p2x; % binary marking x window
xoffset=find(b==max(b)); xoffset=xoffset(1)-1;
x(~b)=[];
x0=x; start=1;
for j=1:size(zz,2) % Loop to end through each selected curve
  A0=0; B0=0; C0=0; D0=0; E0=0; F0=0;
  x=x0;
  y=zz(:,j); v.yobs0=y;
  y(~b)=[];
  yy=y; v.yobs=yy;
   nanny=isnan(x) | isnan(yy);
  x(nanny)=[]; yy(nanny)=[];
  switch v.plotfitmodel
    case 1 % y=A*exp(-x/B)+C
      ymid=yy(1)-(yy(1)-yy(end))/2;
      xind=find(yy<ymid);
      B0=x(xind(1));
      A0=yy(1)-yy(end);
      C0=mean(yy(end-1:end));
      expr='A*exp(-x/B)+C';
      xoffset=x(1);  x=x-x(1);
    case 2 % y=a*exp(-x/b)+c*exp(=x/d)+e
      ymid=yy(1)-(yy(1)-yy(end))/2;
      xind=find(yy<ymid);
      B0=x(xind(1));
      A0=yy(1)-yy(end); C0=A0; D0=B0;
      E0=yy(end);
      expr='A*exp(-x/B)+C*exp(-x/D)+E';
      xoffset=x(1); x=x-x(1);
    case 3 % y=A*(1-exp(-x/B))+C
      ymid=yy(1)-(yy(1)-yy(end))/2;
      xind=find(yy<ymid);
      B0=x(xind(1));
      A0=yy(end)-yy(1);
      C0=yy(1);
      expr='A*(1-exp(-x/B))+C';
      xoffset=x(1); x=x-x(1);
    case 4 % y=ax+b
      B0=yy(1);
      A0=double((max(yy(:))-min(yy(:)))/(max(x(:))-min(x(:))));
      expr='A*x+B';
    case 5 % y=A*exp((x-B)^2/(2*C))) gaussian: a=max height; b=x at peak; c=variance
      A0=mean(yy); B0=mean(x); C0=(B0-min(x))/2;
      expr='A*exp(-((x-B)/C).^2)';
      %expr='a*exp(-((x-b).^2/c))'; THIS DOES NOT WORK
    case 6 % decaying expl + sigmoid rise
      %for sigmoid: C=amplitude; D=steepness, E=time to half-max
      xmax=max(x);
      A0=1.1*yy(1); B0=xmax/4; C0=mean(yy(end-5:end));
      D0=0.1; %%%%%%%%%%% xmax/10;
      E0=.5*xmax;
      expr='A*exp(-x/B)+C*(1+exp(-D*(x-E))).^-1';
    case 7 % decaying expl + rising expl to a power  y=A*exp(-B/tau1) + C*((1-exp(-D/tau2))^E)
      xmax=max(x);
      A0=1.1*yy(1); B0=xmax/4; C0=mean(yy(end-5:end));
      D0=xmax/10;
      E0=10;
      expr='A*exp(-x/B)+C*((1-exp(-x/D)).^E)';    
    case 8 % decaying expl + delayed rising expl
      xmax=max(x);
      A0=1.1*yy(1); B0=xmax/4; C0=mean(yy(end-5:end));
      D0=B0;
      E0=10;
      expr='A*exp(-x/B)+max(0,C*(1-exp(-(x-D)/E)))'; 
  end
  if start
    prompt={'Edit the string to be fitted and starting fit values',...
      'A0' 'B0' 'C0' 'D0' 'E0' 'Lovals of coeffs (must be same # of entries as vars',...
      'Hivals of coeffs' 'Max # Iterations' 'Display iterations? (0=no; 1=yes)'};
    title='Edit fit string and starting values';
    lineno=1;
    expr0=expr; fitloval=[]; fithival=[]; fititer=400; fitdisp=0; % fitdisp: 0='notify'; 1='iter'
    if length(v.lastplotfitexpr); 
      %expr0=v.lastplotfitexpr; 
      fitloval=v.lastfitloval; 
      fithival=v.lastfithival; fititer=v.lastfititer; fitdisp=v.lastfitdisp;
    end
    def={expr0; num2str(A0); num2str(B0); num2str(C0); num2str(D0); num2str(E0);,...
      num2str(fitloval); num2str(fithival); num2str(fititer); num2str(fitdisp)};
    inp=inputdlg(prompt,title,lineno,def);
    expr=char(inp{1}); A0=str2num(inp{2}); B0=str2num(inp{3}); C0=str2num(inp{4});
    D0=str2num(inp{5}); E0=str2num(inp{6});
    v.lastfitloval=str2num(inp{7}); v.lastfithival=str2num(inp{8}); 
    v.lastfititer=str2num(inp{9}); v.lastfitdisp=str2num(inp{10});
    fitdisp='notify'; if v.lastfitdisp; fitdisp='iter'; end
    start0=[]; coeffstr={};
  end
    coeffstr={}; start0=[];
    str0='ABCDE'; n0=[A0 B0 C0 D0 E0]; 
    vis={'off' 'off' 'off' 'off' 'off'};
    for var0=1:5
      ss=str0(var0);
      if ~isempty(findstr(expr,ss))
        vis(var0)={'on'};
        start0=[start0 n0(var0)];
        coeffstr=[coeffstr ss];
      end
    end
    start=0;
  %end % if start
  
  % get rid of non-numbers
  nanny=isnan(x) | isnan(yy);
  x(nanny)=[]; yy(nanny)=[];
  A=0;B=0;C=0;D=0;E=0;F=0; rsqr=0;
  if ~isempty(coeffstr)
%%%%%%%%% DO THE FITTING HERE %%%%%%%%%%%%%
    opts=fitoptions('method','nonlinearleastsquares',...
      'StartPoint',start0);
    opts.Lower=v.lastfitloval; opts.Upper=v.lastfithival; 
    opts.MaxIter=v.lastfititer; opts.Display=fitdisp;
    ftype = fittype(expr,'coeff',coeffstr);
    [yres,gof]=fit(double(x),yy,ftype,opts);
    rsqr=gof.rsquare;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try; A=yres.A; catch; end; try; B=yres.B; catch; end
    try; C=yres.C; catch; end; try; D=yres.D; catch; end
    try; E=yres.E; catch; end; try; F=yres.F; catch; end
  end
  colr=clr(j,:);
  switch v.plotfitmodel
    case 1 % y=A*exp(-x/B) + C
      yfit=eval(expr);
      %A=A/exp(-v.xdata(xoffset)/B);
    case 2 % double exponential decaying + constant
      yfit=eval(expr);
    case 3 % single exponential rising to max + constant
      yfit=eval(expr);
    case 4 % linear regression
      %x=x-min(x);
      yfit=eval(expr);
      xoffset=0;       
      varcalc=var(yy-yfit); % release probability=1 - var(m)/m
      pp=1-varcalc/mean(yy);
      pp=round(pp*100)/100;
     
    case 5 % gaussian
      yfit=eval(expr);
      xoffset=0;
    case 6 % decaying expl + rising sigmoid
      %      disp(['RRP= ' num2str(round(A*B))])
      p1=findstr(expr,'+'); p1=p1(1);
      yfit1=eval(expr(1:p1-1));
      yfit2=eval(expr(p1+1:end));
      yfit=yfit1+yfit2;
      %*********
      tau1=3.5; tau2=9;
      endo1=cumsum(yfit1); endo2=cumsum(yfit2); endotot=endo1+endo2;
      v.zendotau=(tau1*endo1+tau2*endo2)./endotot;
      vh.plotline1=line(x,yfit1,'userdata','plotlinemanual','linestyle',':');
      vh.plotline2=line(x,yfit2,'userdata','plotlinemanual','linestyle',':');
      xoffset=0;
      disp(round(A*B))
     % for x1=1:5
     %   ytest=A*exp(-x1/B)+C*((1-exp(-x1/D)).^E);
     %   disp([x(x1) ytest yy(x1,1)])
     % end
    case 7 %  expr='A*exp(-x/B)+C*((1-exp(-D*x)).^E)';
      p1=findstr(expr,'+'); p1=p1(1);
      yfit1=eval(expr(1:p1-1));
      yfit2=eval(expr(p1+1:end));
      yfit=yfit1+yfit2;
      %*********
      tau1=3.5; tau2=9;
      endo1=cumsum(yfit1); endo2=cumsum(yfit2); endotot=endo1+endo2;
      v.zendotau=(tau1*endo1+tau2*endo2)./endotot;
      vh.plotline1=line(x,yfit1,'userdata','plotlinemanual','linestyle',':');
      vh.plotline2=line(x,yfit2,'userdata','plotlinemanual','linestyle',':');
      xoffset=0;
      disp(round(A*B))
    case 8 % expl fall + delayed expl rise -- A*exp(-x/B)+C*(1-exp(-(x-D)/E))
     p1=findstr(expr,'+'); p1=p1(1);
      yfit1=eval(expr(1:p1-1));
      yfit2=eval(expr(p1+1:end));
      yfit=yfit1+yfit2;
      %*********
      tau1=3.5; tau2=9;
      endo1=cumsum(yfit1); endo2=cumsum(yfit2); endotot=endo1+endo2;
      v.zendotau=(tau1*endo1+tau2*endo2)./endotot;
      vh.plotline1=line(x,yfit1,'userdata','plotlinemanual','linestyle',':');
      vh.plotline2=line(x,yfit2,'userdata','plotlinemanual','linestyle',':');
      xoffset=0;
      disp(round(A*B))
  end % switch
  v.plotfitters=findobj('userdata','plotfit0');
  set(vh.plotfitexpr,'string',['DISP: ' expr],'visible','on')
  set(vh.plotfitA,'value',A,'min',A-abs(A*3),'max',A+abs(A*3)+(A==0),'visible',vis{1})
  set(vh.plotfitAtxt,'string',num2str(A),'visible',vis{1})
  set(vh.plotfitB,'value',B,'min',B-abs(B*3),'max',B+abs(B*3)+(B==0),'visible',vis{2});
  set(vh.plotfitBtxt,'string',num2str(B),'visible',vis{2})
  set(vh.plotfitC,'value',C,'min',C-abs(C*3),'max',C+abs(C*3)+(C==0),'visible',vis{3})
  set(vh.plotfitCtxt,'string',num2str(C),'visible',vis{3})
  set(vh.plotfitD,'value',D,'min',D-abs(D*3),'max',D+abs(D*3)+(D==0),'visible',vis{4});
  set(vh.plotfitDtxt,'string',num2str(D),'visible',vis{4})
  set(vh.plotfitE,'value',E,'min',E-abs(E*3),'max',E+abs(E*3)+(E==0),'visible',vis{5})
  set(vh.plotfitEtxt,'string',num2str(E),'visible',vis{5})
  set(vh.plotfitholdget,'visible','on'); set(vh.plotfitsubexpl,'visible','on')
  % this is col number:
  if isempty(v.plotfitdata); col=1;
  else col=size(v.plotfitdata,2)+1; end
  %%%% draw line on graph
  xx=x+xoffset;
  xy=[xx yfit];
  xy=sortrows(xy,1);
  xx=xy(:,1); yfit=xy(:,2);
  vh.plotline0=line(xx,yfit,'buttondownfcn',[mfilename ' ploterase'],...
    'userdata','plotlinemanual','color',colr,'linewidth',2); drawnow
  %%%% display results and add to data table
  v.plotfitdata(:,col)=[A B C D E F rsqr];
  if v.plotfitmodel==4 % linreg
    v.plotfitdata(6,col)=pp;   
  end
  v.plotfitexpr=expr;
end
v.lastplotfitexpr=expr;
v.xoffset=xoffset;
setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)
% ------------------------------------------------------------
function se=getstrel
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
try
  a=v.semode;
catch
  v.semode={'square'};
end
prompt={['Shape of structure element? Type one of the following:',...
  ' diamond, disk, line, octagon, pair, rectangle, square']}';
title='Erode-Dilate'; lineno=1; def=v.semode;
inp=inputdlg(prompt,title,lineno,def);
v.semode=inp(1); def1={'4'};
switch v.semode{:}
  case {'diamond' 'square'}
    str={'Radius?'};
  case {'disk'}
    str={'Radius?' '0,4,6, or 8?'}; def2={'4'};
  case {'line'}
    str={'Length of line?' 'Angle (degrees)'}; def2={'45'};
  case {'octagon'}
    str={'Radius? (must be a multiple of 3)'}; def1={'3'};
  case {'pair' 'rectangle'}
    str={'Y offset?' 'X offset?'}; def1={'3'}; def2=def1;
end
prompt=str; title='Parameters'; lineno=1;
def=def1; if size(prompt,2)>1; def=[def def2]; end
inp=inputdlg(prompt,title,lineno,def);
for j=1:size(inp,1); val(j)=str2double(inp{j}); end
if size(inp,1)==1
  se=strel(v.semode{:},val(1));
else
  try
    se=strel(v.semode{:},val(1),val(2));
  catch
    se=strel(v.semode{:},val); % for pair
  end
end
setappdata(vh.fig,'v',v)
% ------------------------------------------------------------
function gaussfit
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
yy=v.histobins(:,1);
y=v.z2(:,1); % raw y values
nbins=size(v.histobins,1);
xmin=v.histoedge-v.binwd;
xmax=xmin+nbins*v.binwd;
x=linspace(xmin,xmax,nbins)';
vari=var(y); b0=mean(y);

prompt={'Mean #1' 'Variance #1' 'Mean #2 (0 if only 1 gaussian)' 'Variance #2'};
title='Initial guesses'; lineno=1;
def={num2str(b0) num2str(vari) '0' num2str(vari)};
inp=inputdlg(prompt,title,lineno,def);
b0=str2double(inp{1}); vari1=str2double(inp{2});
e0=str2double(inp{3}); vari2=str2double(inp{4});
ngauss=1+(e0~=0);

a0=1/sqrt(2*pi*vari1);
c0=-2*vari1;
expr='a*exp(((x-b).^2)/c)';
start0=[a0 b0 c0];
coeffstr={'a' 'b' 'c'};
if ngauss==2
  d0=1/sqrt(2*pi*vari2);
  f0=-2*vari2;
  expr=[expr '+d*exp(((x-e).^2)/f)'];
  start0=[start0 d0 e0 f0];
  coeffstr=[coeffstr {'d' 'e' 'f'}];
end

opts=fitoptions('method','nonlinearleastsquares',...
  'StartPoint',start0);
ftype = fittype(expr,'coeff',coeffstr);
[yres,gof]=fit(x,yy,ftype,opts);

a=yres.a; b=yres.b; c=yres.c; d=0; e=0; f=0;
Y1=a*exp(((x-b).^2)/c); Y=Y1;
if ngauss==2
  d=yres.d; e=yres.e; f=yres.f;
  Y2=d*exp(((x-e).^2)/f); Y=Y1+Y2;
end
line('xdata',x,'ydata',Y,'userdata','plotfitline')
if ngauss==2
  line('xdata',x,'ydata',Y1,'userdata','plotfitline')
  line('xdata',x,'ydata',Y2,'userdata','plotfitline')
end

v.plotfitdata=[a;b;sqrt(abs(c)/2);d;e;sqrt(abs(f)/2);gof.rsquare];
setappdata(vh.fig,'v',v)
% ------------------------------------------------------------
function keypress(varargin)
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
k=get(vh.fig,'currentcharacter');
figtype='img';
try
  a=vh.ax;
catch
  figtype='plott';
end
switch figtype
  case 'img'
    imgstr='aceklmpqrsvwxz';
    deststr={'align' 'collapse' 'erase' 'keyboard',...
      'label' 'maskit' 'crop' 'scrollmode',...
      'roi' 'smooth' 'save' 'wrap' 'close' 'zoom'};
    nn=findstr(k,imgstr);
    if isempty(nn); return; end
  case 'plott'
    imgstr='acdefghiklsvwxyz';
    deststr={'newplot' 'plotcut' 'plotdispdata' 'ploterase',...
      'plotfit',...
      'plotgrid',...
      'plotchop' 'plotimport' 'keyboard' 'plotload',...
      'plotsave' 'avgonoff',...
      'plotfitwindow' 'close' 'plotsymbol' 'plotzoom'};
    nn=findstr(k,imgstr);
    if isempty(nn); nn=double(k);
      xx=get(gca,'xlim');
      if v.newzoom
        v.newzoom=0;
        if v.dxarrow==0; v.dxarrow=round(size(v.zdata,1)/10); end
        prompt={'Step size (number of points)?'}; def={num2str(v.dxarrow)};
        inp=inputdlg(prompt,'Arrow step size',1,def);
        if isempty(inp); return; end
        v.dxarrow=str2num(inp{1}); setappdata(vh.fig,'v',v)
      end
      switch nn
        case 28 % left arrow
          xx2=xx-v.dxarrow;
        case 29 % right arrow
          xx2=xx+v.dxarrow;
      end
      set(gca,'xlim',xx2,'ylimmode','auto')
      return
    end
end

eval([mfilename ' ' deststr{nn}])
return

%********** BBHISTO***********************
function bbhisto
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
buttonvis('normal_histogram')
z=v.z2;
mn=min(z(:)); mx=max(z(:)); dx=mx-mn; %nbins=10;
v.histointegrate=0;
v.binwd=(mx-mn)/10;
if ~v.binwd || dx/v.binwd>200; v.binwd=(mx-mn)/10; end
v.binshift=0;

set(vh.binwd,'string',['BW=' num2str(v.binwd)])
set(vh.binshifttxt,'string',['BinShift=' num2str(v.binshift)])
mxbinwd=max(v.binwd,get(vh.binwdslider,'max'));
mnbinwd=min(v.binwd,get(vh.binwdslider,'min'));
set(vh.binwdslider,'max',mxbinwd,'min',mnbinwd,'value',v.binwd);
setappdata(vh.fig,'v',v)
bbhisto2

function bbhisto2
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
z=v.z2;
mn=min(z(:))-v.binshift*v.binwd; mx=max(z(:));
nbins=round((mx-mn)/v.binwd);
b=zeros(nbins+1,size(z,2));
ssum=zeros(size(z,2),2);
for c=1:size(z,2) % column of z
  z2=z(:,c);
  an=isnan(z2); z2(an)=[];
  sz=size(z2,1);
  for r=1:sz
    try
      rr=floor((z2(r,1)-mn)/v.binwd)+1;
      b(rr,c)=b(rr,c)+1;
      ssum(c,1)=ssum(c,1)+1;
      ssum(c,2)=ssum(c,2)+z2(r,1);
    catch
      keyboard;
    end
  end
  if v.histointegrate==1; b(:,c)=100*b(:,c)/sz; end
end
v.histobins2=b; % used for chi squared
b(2:end+1,:)=b;
b(1,:)=0;
b(end+1,:)=0;
for col=1:size(z,2)
  rr=0; ccol=col+1;
  for r=1:size(b,1)-1
    rr=rr+1;
    if col==1;
      x=mn+v.binwd*(r-1);
      cc(rr,1)=x;
      cc(rr+1,1)=x;
    end
    cc(rr,ccol)=b(r,col); rr=rr+1; cc(rr,ccol)=b(r+1,col);
  end
end
cc=double(cc);
if v.histointegrate>1
  for j=2:size(cc,2)
    cc(:,j)=cumsum(cc(:,j));
  end
  cc(:,2:end)=cc(:,2:end)/2;
  if v.histointegrate==3; % normalize
    for j=2:size(cc,2)
      cc(:,j)=100*cc(:,j)/cc(end,j);
    end
  end
end

xjitter=double(.2*v.binwd/size(ssum,1));
yjitter=0;
clrstr={'r' 'g' 'b' 'k'}; 
lw=1;
nclr=0;
disp('Avg N')
for j=1:size(ssum,1)
  disp([num2str(ssum(j,2)/ssum(j,1)) ' ' num2str(ssum(j,1))])
  nclr=nclr+1; if nclr>4; nclr=1; end
  line('xdata',cc(:,1)+xjitter*(j-1),...
    'ydata',cc(:,j+1)+yjitter*(j-1),...
    'linewidth',lw,...
    'color',clrstr{nclr},...
    'buttondownfcn',[mfilename ' plotline']);
end
vv=cc(:,2); for j=size(vv):-2:1; vv(j)=[]; end
v.histoedge=cc(1,1); v.histobins=vv; v.histodata=[];
for j=2:2:size(cc,1)
  a=cc(j,1)+v.binwd/2; v.histodata(j/2,:)=[a cc(j,2:end)];
end
if size(v.histobins2,2)>1 % do chi squared  
   chitable=[3.84 5.99 7.81 9.49 11.07 12.53 14.07 15.51 16.92 18.31,...
      19.68 21.03 22.36 23.68 25 26.3 27.59 28.87 30.14 31.41,...
      32.67 33.92 35.17 36.42 37.65 38.89 40.11 41.34 42.56 43.77];
    a=v.histobins2; b=a(:,1); c=a(:,2); d=(b-c).^2; e=d./c; e(isnan(e))=[]; chi2=sum(e);
    df=size(a,1)-1;
    str=['Col 1 vs Col 2: Chi squared =' num2str(chi2) '. DF=' num2str(df) '.'];
    if df<31;
      if chi2<=chitable(df); %str=[str '. p>0.05 (i.e., they are not significantly different)'];
        str=[str char(10) ' Because chi squared is less than ' num2str(chitable(df)) ',' char(10),...
          ' p>0.05. That is, the Expected fit (col 2) to the observed (col 1) ' char(10),...
          'distribution is not significantly different from random'];
      else  % str=[str '. p<0.05 (i.e., they are significantly different)']; end
        str=[str char(10) ' Because chi squared is greater than ' num2str(chitable(df)) ',' char(10),...
          ' p<0.05. That is, they are from different populations.'];
      end
    end
    % msgbox(str)
    disp(str)
end
setappdata(vh.fig,'v',v); setappdata(vh.fig,'vh',vh)

%----------------------------------------
function neighbors(xpt,ypt) % NINE GRAPHS FITTING DECAY - used in: case 'singlepixel'
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
h=findobj('type','figure','tag','neighbors');
if isempty(h); h=figure('tag','neighbors'); end
figure(h)
hline=findobj('tag','neighborline'); delete(hline)
ffs=round(get(vh.ffs,'value')); lfs=round(get(vh.lfs,'value'));
jj0=v.firstfit; bkg1=1; bkg2=jj0-1; nbkg=bkg2-bkg1+1;
x=xpt; xpos=[x-1 x x+1 x-1 x x+1 x-1 x x+1];
y=ypt; ypos=[y-1 y-1 y-1 y y y y+1 y+1 y+1];
for j=1:9
  x=xpos(j); y=ypos(j);
  xdata=(1:lfs-ffs+1)';
  ydata=double(v.Movi(y,x,ffs:lfs));
  ydata=reshape(ydata,size(xdata,1),1);
  avgbkg=sum(ydata(bkg1:bkg2))/nbkg;
  y=double(ydata(jj0:end));
  x=(0:size(y,1)-1)';
  a0=(y(1)-y(end))/size(y,1); b0=y(1);
  opts=fitoptions('method','nonlinearleastsquares',...
    'StartPoint',[a0 b0]);
  ftype=fittype('a*x+b','coeff',{'a' 'b'});
  [yres]=fit(x,y,ftype,opts);
  yfit=yres.a*x+yres.b;
  xx=x+jj0;
  dF1=yfit(1)-avgbkg; dF2=yfit(end)-yfit(1);
  disp([dF1 dF2])
  subplot(3,3,j)
  set(gca,'xlim',[0 size(xdata,1)])
  line('tag','neighborline','xdata',xdata,'ydata',ydata,'marker','none','color','black')
  line('tag','neighborline','xdata',xx,'ydata',yfit,'marker','none','color','red')
  line('tag','neighborline','xdata',[bkg1 bkg2],'ydata',[avgbkg avgbkg],'color','red')
end
disp(' ')
setappdata(vh.fig,'v',v)
%----------------------------------------
function roiedit (varargin)
vh=getappdata(gcf,'vh'); v0=getappdata(0,'v0');
v=getappdata(vh.fig,'v');
switch nargin
  case 0
    set(vh.img,'buttondownfcn','')
    lastroi=v0.lastroi;
    buttonvis('roiedit')
    hh=findobj('type','line');
    if ~isempty(hh); delete(hh); end
    clr='red';
    for j=1:size(lastroi,2)
      xy=lastroi{j};
      vh.h2(j)=line('xdata',xy(:,1),'ydata',xy(:,2),...
        'marker','.','markersize',4,...
        'linestyle','none','linewidth',0.05,'color',clr,...
        'markerfacecolor',clr,'markeredgecolor',clr,...
        'erasemode','normal','buttondownfcn',[mfilename ' roiedit roidown']);
    end
    set(vh.fig,'windowbuttondownfcn','')
  case 1
    switch varargin{1}
      case 'roidown'
        button=get(vh.fig,'selectiontype');
        if strcmp(button,'alt') % right button
          delete(gcbo)
        else
          [v.x0,v.y0]=bbgetcurpt(vh.ax);
          v.line=gcbo;
          v.r=get(v.line,'ydata'); v.c=get(v.line,'xdata');
          set(vh.fig, 'WindowButtonDownFcn', '',...
            'WindowButtonMotionFcn', [mfilename ' roiedit roimove'],...
            'windowbuttonupfcn',[mfilename ' roiedit roiup'])
          setappdata(vh.fig,'v',v)
        end
      case 'roimove'
        [x,y]=bbgetcurpt(vh.ax);
        dx=x-v.x0; dy=y-v.y0;
        r=round(v.r+dy); c=round(v.c+dx);
        set(v.line,'xdata',c,'ydata',r)
        drawnow
      case 'roiup'
        set(vh.fig, 'WindowButtonDownFcn', '',...
          'WindowButtonMotionFcn','','windowbuttonupfcn','')
      case 'roiall'
        set(findobj('type','line'),'buttondownfcn','')
        set(vh.img,'buttondownfcn',[mfilename ' pixval'])
        hh=findobj('type','line');
        vh2=getappdata(v.figfocus,'vh'); v2=getappdata(vh2.fig,'v'); Movi=v2.Movi;
        v.zz=[]; lastroi={}; bw0=v.Movi(:,:,1)<0;
        if ~isempty(hh)
          jmin=round(get(vh.ffs,'value'));
          jmax=round(get(vh.lfs,'value'));
          col=0;
          for j=1:size(hh,1)
            x=get(hh(j),'xdata')';
            y=get(hh(j),'ydata')';
            lastroi{j}=[x y];
            bw=roipoly(bw0,x,y);
            npix=sum(sum(bw));
            disp([num2str(npix) ' pixels'])
            if npix==0;
              xy=sub2ind(size(bw0),y,x);
              bw=bw0; bw(xy)=1; npix=sum(bw(:));
            end
            col=col+1;
            row=0;
            for jj=jmin:jmax; % get brightness (z) values
              row=row+1;
              m= Movi(:,:,jj);
              m(~bw)=0;
              zz(row,col)=sum(m(:));  % SUM
              if strcmp(v.calcmode,'a'); zz(row,col)=zz(row,col)/npix; end % AVERAGE
              if strcmp(v.calcmode,'b'); zz(row,col)=max(m(bw)); end   % MAX
            end % for jj=jmin:jmax
          end % for n=1:sze(hh)
          v.zz=zz;
        end % is ~isempty(hh)
        v0.lastroi=lastroi;
        setappdata(vh.fig,'v',v); setappdata(0,'v0',v0)
        buttonvis
        uiresume
      case 'roinone'
        set(findobj('type','line'),'buttondownfcn','')
        set(vh.img,'buttondownfcn',[mfilename ' pixval'])
        hh=findobj('type','line');
        if ~isempty(hh); delete(hh); end
        v.zz=[];
        v0.lastroi={}; setappdata(0,'v0',v0)
        setappdata(vh.fig,'v',v)
        buttonvis
        uiresume
    end % switch varargin
end % switch nargin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I = gauss3D(f, pts)
% extract c,r,and h from 'pts'
ncols=size(pts,2)/3; % # columns
r = pts(:,1:ncols,:); % the first one-third of the columns
c = pts(:,ncols+1:2*ncols,:); % the second one-third cols 3&4
h = pts(:,2*ncols+1:3*ncols,:);
% do the calculation
I=f(1)+f(2).*exp(-((c-f(3)).^2/f(4)+(r-f(5)).^2/f(6)+(h-f(7)).^2/f(8)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=checkslider(hh,str);
vv=get(hh); val=vv.Value;
if strcmp(vv.Visible,'off'),return; end
if val>=vv.Max || val<=vv.Min
  ss=vv.SliderStep;
  prompt={'Value' 'Min' 'Max' 'Stepsize1' 'Stepsize2'}; title=str; lineno=1;
  def={num2str(val) num2str(vv.Min) num2str(vv.Max) num2str(ss(1)) num2str(ss(2))};
  inp=inputdlg(prompt,title,lineno,def);
  val=str2num(inp{1}); mn=str2num(inp{2}); mx=str2num(inp{3}); 
  ss=[str2num(inp{4}) str2num(inp{5})];
  set(hh,'Min',mn,'Max',mx,'Value',val,'SliderStep',ss)
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function H=circle(center,radius,NOP,style)
%---------------------------------------------------------------------------------------------
% H=CIRCLE(CENTER,RADIUS,NOP,STYLE)
% This routine draws a circle with center defined as
% a vector CENTER, radius as a scaler RADIS. NOP is 
% the number of points on the circle. As to STYLE,
% use it the same way as you use the rountine PLOT.
% Since the handle of the object is returned, you
% use routine SET to get the best result.
%
%   Usage Examples,
%
%   circle([1,3],3,1000,':'); 
%   circle([2,4],2,1000,'--');
%
%   Zhenhai Wang <zhenhai@ieee.org>
%   Version 1.00
%   December, 2002
%---------------------------------------------------------------------------------------------

if (nargin <3),
 error('Please see help for INPUT DATA.');
elseif (nargin==3)
    style='b-';
end;
THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP)*radius;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
H=plot(X,Y,style);
%axis square;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fillcircle(xctr,yctr,rad0,clrmax);
xctr=round(xctr); yctr=round(yctr);% rad0=round(rad);
mm=getfig;
figure(mm(1,1))
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v'); v0=getappdata(0,'v0');
frame=round(get(vh.fs,'value'));
m=get(vh.img,'cdata'); m=m.*0;
radmax=10;
aa=[];
for circ=1:size(xctr,1)
  BW=[];
  %r=4; % for constant size circles
  r=round(radmax*rad0(circ)+(rad0(circ)==0));
  k=zeros(3*r+1,3*r+1); %zeros(3*r+1,3*r+1);
  x1=round(size(k,1)/2);
  y1=round(size(k,1)/2);
  xtl=x1-r; xtr=x1+r; xbl=x1-r; xbr=x1+r;
  ytl=y1+r; ytr=y1+r; ybl=y1-r; ybr=y1-r;
  for i=1:size(k,1)
    for j=1:size(k,2)
      x2=j; y2=i;
      val=floor(sqrt((x2-x1)^2 + (y2-y1)^2));
      BW(i,j)=(val==floor(r));
    end
  end
  SE=strel('disk',1); BW3=imdilate(BW,SE);
  I2=imfill(BW3,'holes');
  I2=uint16(I2); if isa(v.Movi,'uint8'); I2=uint8(I2); end
  clr=round(rad0(circ)*clrmax);
 % if clr>110; clr=255; end
 % if clr<=110; clr=45; end
  %if clr==255; keyboard; end
  I2(I2>0)=clr;
 % aa=[aa; size(I2,1) r clr];
  x00=xctr(circ)-x1; y00=yctr(circ)-y1-1; x0=x00+size(I2,1); y0=y00+size(I2,2)-1;
  try;
    m(y00:y0,x00:x0-1)=m(y00:y0,x00:x0-1)+I2;
  catch;  end
  v.Movi(:,:,frame)=m;
  set(vh.img,'cdata',v.Movi(:,:,frame)); drawnow
end % for circ=1:size(xctr,1)
set(vh.img,'cdata',v.Movi(:,:,frame))
setappdata(vh.fig,'v',v);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bbscroll(nada,scroll)
vh=getappdata(gcf,'vh'); v=getappdata(vh.fig,'v');
try; a=v.scroll; catch; v.scroll=0; end
sgn=1-2*(scroll.VerticalScrollCount<0); % sign of scroll
try
if length(v.list)<2; v.scroll=0; setappdata(vh.fig,'v',v); end; catch; end
switch v.scroll
  case 0 % figsize
    figfac=get(vh.figsize,'value');
    figfac=figfac-0.06*sgn;
    set(vh.figsize,'value',figfac)
    eval([mfilename ' figsize'])
  case 1 % frame number
    frame=get(vh.fs,'value'); % current frame
    fstep=get(vh.framestep,'value'); % framestep setting
    newval=round(min(v.lastframe,max(v.firstframe,frame+sgn*fstep)));
    set(vh.fs,'value',newval);
    eval([mfilename ' fs'])
  case 2 % MEPP threshold
    xx=get(gca,'xlim'); 
   %xx=vals.xdata; yy=vals.ydata; v.thresh(yy(1));
    yy=get(vh.meppline,'ydata'); v.thresh=yy(1);
    v.thresh=v.thresh-v.meppthreshfac*sgn;
    set(vh.meppline,'ydata',[v.thresh v.thresh],'xdata',xx)
    setappdata(vh.fig,'v',v)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out_image_m,out_ref_points_m] = bbrotate_image( degree, in_image_m, in_ref_points_m )
% see rotate_image for full documentation
% downloaded from Matlab site 101011
if (nargin == 0)
    out_image_m = [];
    return;
end

% check input
if ~exist('in_ref_points_m')
    in_ref_points_m = [];
end

% check for easy cases
switch (mod(degree,360))
case 0,     
    out_image_m      = in_image_m;
    out_ref_points_m = in_ref_points_m;
    return;
case 90,    
    out_image_m           = in_image_m(:,end:-1:1)';
    out_ref_points_m      = in_ref_points_m(end:-1:1,:);    
    out_ref_points_m(2,:) = size(out_image_m,1) - out_ref_points_m(2,:);
    return;
case 180,   % TBD for rotation of the ref_points
    out_image_m           = in_image_m(end:-1:1,end:-1:1);
    out_ref_points_m      = in_ref_points_m;
    out_ref_points_m(2,:) = size(out_image_m,2) - out_ref_points_m(2,:);
    out_ref_points_m(1,:) = size(out_image_m,1) - out_ref_points_m(1,:);
    return;
case 270,   
    out_image_m           = in_image_m(end:-1:1,:)';
    out_ref_points_m      = in_ref_points_m(end:-1:1,:);
    out_ref_points_m(1,:) = size(out_image_m,2) - out_ref_points_m(1,:);
    return;
otherwise,  % enter the routine and do some calculations
end

% wrap input image by zeros from all sides
zeros_row    = zeros(1,size(in_image_m,2)+2);
zeros_column = zeros(size(in_image_m,1),1);
in_image_m   = [zeros_row; zeros_column,in_image_m,zeros_column; zeros_row ];

% build the rotation matrix
degree_rad = degree * pi / 180;
R = [ cos(degree_rad), sin(degree_rad); sin(-degree_rad) cos(degree_rad) ];

% input and output size of matrices (output size is found by rotation of 4 corners)
in_size_x       = size(in_image_m,2);
in_size_y       = size(in_image_m,1);
in_mid_x        = (in_size_x-1) / 2;
in_mid_y        = (in_size_y-1) / 2;
in_corners_m    = [ [0,0,in_size_x-1,in_size_x-1] - in_mid_x;
                    [0,in_size_y-1,in_size_y-1,0] - in_mid_y ];
out_corners_m   = R * in_corners_m;

% the grid (integer grid) of the output image and the output image
[out_x_r,out_y_r]   = rotated_grid( out_corners_m );
out_size_x          = max( out_x_r ) - min( out_x_r ) + 1;
out_size_y          = max( out_y_r ) - min( out_y_r ) + 1;
out_image_m         = zeros( ceil( out_size_y ),ceil( out_size_x ) );
out_points_span     = (out_x_r-min(out_x_r))*ceil(out_size_y) + out_y_r - min(out_y_r) + 1;
if ~isempty( in_ref_points_m )
    out_ref_points_m    = (R * [in_ref_points_m(1,:)-in_mid_x;in_ref_points_m(2,:)-in_mid_y]);
    out_ref_points_m    = [out_ref_points_m(1,:)-min( out_x_r )+1;out_ref_points_m(2,:)-min( out_y_r )+1];
else
    out_ref_points_m    = [];
end
    
% % for debug
% out_image_m(out_points_span) = 1;
% return;
% % end of for debug

% the position of points of the output grid in terms of the input grid
in_cords_dp_m   = inv(R) * [out_x_r;out_y_r];

x_span_left     = floor(in_cords_dp_m(1,:) + in_mid_x + 10*eps );
y_span_down     = floor(in_cords_dp_m(2,:) + in_mid_y + 10*eps );
x_span_right    = x_span_left + 1;
y_span_up       = y_span_down + 1;
dx_r            = in_cords_dp_m(1,:) - floor( in_cords_dp_m(1,:) + 10*eps );
dy_r            = in_cords_dp_m(2,:) - floor( in_cords_dp_m(2,:) + 10*eps );

point_span_0_0  = x_span_left*ceil(in_size_y)  + y_span_down + 1; % position of combined index in output matrix
point_span_1_0  = x_span_left*ceil(in_size_y)  + y_span_up + 1;
point_span_0_1  = x_span_right*ceil(in_size_y) + y_span_down + 1;
point_span_1_1  = x_span_right*ceil(in_size_y) + y_span_up + 1;

out_image_m(out_points_span) = ...
    in_image_m( point_span_0_0 ).*(1-dx_r).*(1-dy_r) + ...
    in_image_m( point_span_1_0 ).*(1-dx_r).*(  dy_r) + ...
    in_image_m( point_span_0_1 ).*(  dx_r).*(1-dy_r) + ...
    in_image_m( point_span_1_1 ).*(  dx_r).*(  dy_r);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              Inner function implementation                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x_r,y_r] = rotated_grid( rect_points_m )
[temp,idx] = min( rect_points_m(1,:) );
if ( idx > 1 )
    rect_points_m = [ rect_points_m(:,idx:end) , rect_points_m(:,1:idx-1) ];
end

% put into variables so it is easier to access/read the numbers
x1 = rect_points_m(1,1);
x2 = rect_points_m(1,2);
x3 = rect_points_m(1,3);
x4 = rect_points_m(1,4);
y1 = rect_points_m(2,1);
y2 = rect_points_m(2,2);
y3 = rect_points_m(2,3);
y4 = rect_points_m(2,4);

% initialization for grid creation
clipped_top     = floor( y2 );
clipped_bottom  = ceil( y4 );
fraction_bottom = clipped_bottom - y4;
rows            = ( clipped_top - clipped_bottom );
left_crossover  = y1 - y4;
right_crossover = y3 - y4;

% calculate the position of the edges (left and right) along the y axis
m = [0:rows] + fraction_bottom ;
switch (y1)
case y2, x_left = repmat( ceil( x4 ),size(m) );
case y4, x_left = repmat( ceil( x2 ),size(m) );
otherwise 
    x_left = ( m >= left_crossover ).*ceil( x2 - (x1-x2)/(y1-y2)*(rows-m+2*fraction_bottom) ) + ...
        ( m < left_crossover ).*ceil( x4 + (x1-x4)/(y1-y4)*m );
end
switch (y3)
case y2,    x_right = repmat( floor( x4 ),size(m) );
case y4,    x_right = repmat( floor( x2 ),size(m) );
otherwise
    x_right = ( m >= right_crossover ).*floor( x2 - (x3-x2)/(y3-y2)*(rows-m+2*fraction_bottom) ) + ...
        ( m < right_crossover ).*floor( x4 + (x3-x4)/(y3-y4)*m );
end
      
% build the output vectors (initialize)      
vec_length = sum(x_right-x_left+1);
x_r = zeros(1,vec_length );
y_r = zeros(1,vec_length );

% build the grid into the output vectors
cursor = 1;
for n = 1:length(m)
    if ( x_right(n) >= x_left(n) )
        span        = cursor:(x_right(n) - x_left(n) + cursor);
        x_r( span ) = x_left(n):x_right(n);
        y_r( span ) = m(n) + y4;
        cursor      = cursor + x_right(n) - x_left(n) + 1; 
    end
end
% **********************************
% 

function [output Greg] = align_dfr(buf1ft,buf2ft,usfac)
% Default usfac to 1
if exist('usfac')~=1, usfac=1; end

% Compute error for no pixel shift
if usfac == 0,
    CCmax = sum(sum(buf1ft.*conj(buf2ft))); 
    rfzero = sum(abs(buf1ft(:)).^2);
    rgzero = sum(abs(buf2ft(:)).^2); 
    error = 1.0 - CCmax.*conj(CCmax)/(rgzero*rfzero); 
    error = sqrt(abs(error));
    diffphase=atan2(imag(CCmax),real(CCmax)); 
    output=[error,diffphase];
        
% Whole-pixel shift - Compute crosscorrelation by an IFFT and locate the
% peak
elseif usfac == 1,
    [m,n]=size(buf1ft);
    CC = ifft2(buf1ft.*conj(buf2ft));
    [max1,loc1] = max(CC);
    [max2,loc2] = max(max1);
    rloc=loc1(loc2);
    cloc=loc2;
    CCmax=CC(rloc,cloc); 
    rfzero = sum(abs(buf1ft(:)).^2)/(m*n);
    rgzero = sum(abs(buf2ft(:)).^2)/(m*n); 
    error = 1.0 - CCmax.*conj(CCmax)/(rgzero(1,1)*rfzero(1,1));
    error = sqrt(abs(error));
    diffphase=atan2(imag(CCmax),real(CCmax)); 
    md2 = fix(m/2); 
    nd2 = fix(n/2);
    if rloc > md2
        row_shift = rloc - m - 1;
    else
        row_shift = rloc - 1;
    end

    if cloc > nd2
        col_shift = cloc - n - 1;
    else
        col_shift = cloc - 1;
    end
    output=[error,diffphase,row_shift,col_shift];
    
% Partial-pixel shift
else
    
    % First upsample by a factor of 2 to obtain initial estimate
    % Embed Fourier data in a 2x larger array
    [m,n]=size(buf1ft);
    mlarge=m*2;
    nlarge=n*2;
    CC=zeros(mlarge,nlarge);
    CC(m+1-fix(m/2):m+1+fix((m-1)/2),n+1-fix(n/2):n+1+fix((n-1)/2)) = ...
        fftshift(buf1ft).*conj(fftshift(buf2ft));
  
    % Compute crosscorrelation and locate the peak 
    CC = ifft2(ifftshift(CC)); % Calculate cross-correlation
    [max1,loc1] = max(CC);
    [max2,loc2] = max(max1);
    rloc=loc1(loc2);cloc=loc2;
    CCmax=CC(rloc,cloc);
    
    % Obtain shift in original pixel grid from the position of the
    % crosscorrelation peak 
    [m,n] = size(CC); md2 = fix(m/2); nd2 = fix(n/2);
    if rloc > md2 
        row_shift = rloc - m - 1;
    else
        row_shift = rloc - 1;
    end
    if cloc > nd2
        col_shift = cloc - n - 1;
    else
        col_shift = cloc - 1;
    end
    row_shift=row_shift/2;
    col_shift=col_shift/2;

    % If upsampling > 2, then refine estimate with matrix multiply DFT
    if usfac > 2,
        %%% DFT computation %%%
        % Initial shift estimate in upsampled grid
        row_shift = round(row_shift*usfac)/usfac; 
        col_shift = round(col_shift*usfac)/usfac;     
        dftshift = fix(ceil(usfac*1.5)/2); %% Center of output array at dftshift+1
        % Matrix multiply DFT around the current shift estimate
        CC = conj(dftups(buf2ft.*conj(buf1ft),ceil(usfac*1.5),ceil(usfac*1.5),usfac,...
            dftshift-row_shift*usfac,dftshift-col_shift*usfac))/(md2*nd2*usfac^2);
        % Locate maximum and map back to original pixel grid 
        [max1,loc1] = max(CC);   
        [max2,loc2] = max(max1); 
        rloc = loc1(loc2); cloc = loc2;
        CCmax = CC(rloc,cloc);
        rg00 = dftups(buf1ft.*conj(buf1ft),1,1,usfac)/(md2*nd2*usfac^2);
        rf00 = dftups(buf2ft.*conj(buf2ft),1,1,usfac)/(md2*nd2*usfac^2);  
        rloc = rloc - dftshift - 1;
        cloc = cloc - dftshift - 1;
        row_shift = row_shift + rloc/usfac;
        col_shift = col_shift + cloc/usfac;    

    % If upsampling = 2, no additional pixel shift refinement
    else    
        rg00 = sum(sum( buf1ft.*conj(buf1ft) ))/m/n;
        rf00 = sum(sum( buf2ft.*conj(buf2ft) ))/m/n;
    end
    error = 1.0 - CCmax.*conj(CCmax)/(rg00*rf00);
    error = sqrt(abs(error));
    diffphase=atan2(imag(CCmax),real(CCmax));
    % If its only one row or column the shift along that dimension has no
    % effect. We set to zero.
    if md2 == 1,
        row_shift = 0;
    end
    if nd2 == 1,
        col_shift = 0;
    end
    output=[error,diffphase,row_shift,col_shift];
end  

% Compute registered version of buf2ft
if (nargout > 1)&&(usfac > 0),
    [nr,nc]=size(buf2ft);
    Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
    Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
    [Nc,Nr] = meshgrid(Nc,Nr);
    Greg = buf2ft.*exp(i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
    Greg = Greg*exp(i*diffphase);
elseif (nargout > 1)&&(usfac == 0)
    Greg = buf2ft*exp(i*diffphase);
end
return

function out=dftups(in,nor,noc,usfac,roff,coff)

[nr,nc]=size(in);
% Set defaults
if exist('roff')~=1, roff=0; end
if exist('coff')~=1, coff=0; end
if exist('usfac')~=1, usfac=1; end
if exist('noc')~=1, noc=nc; end
if exist('nor')~=1, nor=nr; end
% Compute kernels and obtain DFT by matrix products
kernc=exp((-i*2*pi/(nc*usfac))*( ifftshift([0:nc-1]).' - floor(nc/2) )*( [0:noc-1] - coff ));
kernr=exp((-i*2*pi/(nr*usfac))*( [0:nor-1].' - roff )*( ifftshift([0:nr-1]) - floor(nr/2)  ));
out=kernr*in*kernc;
return
%%%%%%%%%%%%%%%%%%%%%%%%
function [ target_indices target_distances unassigned_targets total_cost ] = hungarianlinker(source, target, max_distance)
% Jean-Yves Tinevez <jeanyves.tinevez@gmail.com>.
% However all credits should go to Yi Cao, which did the hard job of
% implementing the Munkres algorithm; this file is merely a wrapper for it.
    if nargin < 3
        max_distance = Inf;
    end
    n_source_points = size(source, 1);
    n_target_points = size(target, 1);
    D = NaN(n_source_points, n_target_points);    
    % Build distance matrix
    for i = 1 : n_source_points
        % Pick one source point
        current_point = source(i, :);        
        % Compute square distance to all target points
        diff_coords = target - repmat(current_point, n_target_points, 1);
        square_dist = sum(diff_coords.^2, 2);       
        % Store them
        D(i, :) = square_dist;        
    end
    % Deal with maximal linking distance: we simply mark these links as already
    % treated, so that they can never generate a link.
    D ( D > max_distance * max_distance ) = Inf;    
    % Find the optimal assignment is simple as calling Yi Cao excellent FEX
    % submission.
    [ target_indices total_cost ] = munkres(D);
    % Set unmatched sources to -1
    target_indices ( target_indices  == 0 ) = -1;    
    % Collect distances
    target_distances = NaN(numel(target_indices), 1);
    for i = 1 : numel(target_indices)
        if target_indices(i) < 0
            continue
        end        
        target_distances(i) = sqrt ( D ( i , target_indices(i)) );        
    end    
    unassigned_targets = setdiff ( 1 : n_target_points , target_indices );        

%%%%%%%%%%%%%
function [ target_indices target_distances unassigned_targets ] = nearestneighborlinker(source, target, max_distance)
% Jean-Yves Tinevez <jeanyves.tinevez@gmail.com>
    if nargin < 3
        max_distance = Inf;
    end  
    n_source_points = size(source, 1);
    n_target_points = size(target, 1);    
    D = NaN(n_source_points, n_target_points);    
    % Build distance matrix
    for i = 1 : n_source_points        
        % Pick one source point
        current_point = source(i, :);        
        % Compute square distance to all target points
        diff_coords = target - repmat(current_point, n_target_points, 1);
        square_dist = sum(diff_coords.^2, 2);        
        % Store them
        D(i, :) = square_dist;        
    end    
    % Deal with maximal linking distance: we simply mark these links as already
    % treated, so that they can never generate a link.
    D ( D > max_distance * max_distance ) = Inf;    
    target_indices = -1 * ones(n_source_points, 1);
    target_distances = NaN(n_source_points, 1);    
    % Parse distance matrix
    while ~all(isinf(D(:)))        
        [ min_D closest_targets ] = min(D, [], 2); % index of the closest target for each source points
        [ sorted_distances_junk, sorted_index ] = sort(min_D);        
        for i = 1 : numel(sorted_index)            
            source_index =  sorted_index(i);
            target_index =  closest_targets ( sorted_index(i) );            
            % Did we already assigned this target to a source?
            if any ( target_index == target_indices )                
                % Yes, then exit the loop and change the distance matrix to
                % prevent this assignment
                break                
            else                
                % No, then store this assignment
                target_indices( source_index ) = target_index;
                target_distances ( source_index ) = sqrt ( min_D (  sorted_index(i) ) );                
                % And make it impossible to find it again by putting the target
                % point to infinity in the distance matrix
                D(:, target_index) = Inf;
                % And the same for the source line
                D(source_index, :) = Inf;                
            end            
        end        
    end    
    unassigned_targets = setdiff ( 1 : n_target_points , target_indices );        

%%%%%%%%%%
function [assignment,cost] = munkres(costMat)
% Reference:
% "Munkres' Assignment Algorithm, Modified for Rectangular Matrices", 
% http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
% version 2.3 by Yi Cao at Cranfield University on 11th September 2011
assignment = zeros(1,size(costMat,1));
cost = 0;
validMat = costMat == costMat & costMat < Inf;
bigM = 10^(ceil(log10(sum(costMat(validMat))))+1);
costMat(~validMat) = bigM;
% costMat(costMat~=costMat)=Inf;
% validMat = costMat<Inf;
validCol = any(validMat,1);
validRow = any(validMat,2);
nRows = sum(validRow);
nCols = sum(validCol);
n = max(nRows,nCols);
if ~n
    return
end
maxv=10*max(costMat(validMat));
dMat = zeros(n) + maxv;
dMat(1:nRows,1:nCols) = costMat(validRow,validCol);
% Munkres' Assignment Algorithm starts here
%   STEP 1: Subtract the row minimum from each row.
minR = min(dMat,[],2);
minC = min(bsxfun(@minus, dMat, minR));
%   STEP 2: Find a zero of dMat. If there are no starred zeros in its
%           column or row start the zero. Repeat for each zero
zP = dMat == bsxfun(@plus, minC, minR);
starZ = zeros(n,1);
while any(zP(:))
    [r,c]=find(zP,1);
    starZ(r)=c;
    zP(r,:)=false;
    zP(:,c)=false;
end
while 1
%   STEP 3: Cover each column with a starred zero. If all the columns are
%           covered then the matching is maximum
    if all(starZ>0)
        break
    end
    coverColumn = false(1,n);
    coverColumn(starZ(starZ>0))=true;
    coverRow = false(n,1);
    primeZ = zeros(n,1);
    [rIdx, cIdx] = find(dMat(~coverRow,~coverColumn)==bsxfun(@plus,minR(~coverRow),minC(~coverColumn)));
    while 1
        %   STEP 4: Find a noncovered zero and prime it.  If there is no starred
        %           zero in the row containing this primed zero, Go to Step 5.  
        %           Otherwise, cover this row and uncover the column containing 
        %           the starred zero. Continue in this manner until there are no 
        %           uncovered zeros left. Save the smallest uncovered value and 
        %           Go to Step 6.
        cR = find(~coverRow);
        cC = find(~coverColumn);
        rIdx = cR(rIdx);
        cIdx = cC(cIdx);
        Step = 6;
        while ~isempty(cIdx)
            uZr = rIdx(1);
            uZc = cIdx(1);
            primeZ(uZr) = uZc;
            stz = starZ(uZr);
            if ~stz
                Step = 5;
                break;
            end
            coverRow(uZr) = true;
            coverColumn(stz) = false;
            z = rIdx==uZr;
            rIdx(z) = [];
            cIdx(z) = [];
            cR = find(~coverRow);
            z = dMat(~coverRow,stz) == minR(~coverRow) + minC(stz);
            rIdx = [rIdx(:);cR(z)];
            cIdx = [cIdx(:);stz(ones(sum(z),1))];
        end
        if Step == 6
            % STEP 6: Add the minimum uncovered value to every element of each covered
            %         row, and subtract it from every element of each uncovered column.
            %         Return to Step 4 without altering any stars, primes, or covered lines.
            [minval,rIdx,cIdx]=outerplus(dMat(~coverRow,~coverColumn),minR(~coverRow),minC(~coverColumn));            
            minC(~coverColumn) = minC(~coverColumn) + minval;
            minR(coverRow) = minR(coverRow) - minval;
        else
            break
        end
    end
    % STEP 5:
    %  Construct a series of alternating primed and starred zeros as
    %  follows:
    %  Let Z0 represent the uncovered primed zero found in Step 4.
    %  Let Z1 denote the starred zero in the column of Z0 (if any).
    %  Let Z2 denote the primed zero in the row of Z1 (there will always
    %  be one).  Continue until the series terminates at a primed zero
    %  that has no starred zero in its column.  Unstar each starred
    %  zero of the series, star each primed zero of the series, erase
    %  all primes and uncover every line in the matrix.  Return to Step 3.
    rowZ1 = find(starZ==uZc);
    starZ(uZr)=uZc;
    while rowZ1>0
        starZ(rowZ1)=0;
        uZc = primeZ(rowZ1);
        uZr = rowZ1;
        rowZ1 = find(starZ==uZc);
        starZ(uZr)=uZc;
    end
end
% Cost of assignment
rowIdx = find(validRow);
colIdx = find(validCol);
starZ = starZ(1:nRows);
vIdx = starZ <= nCols;
assignment(rowIdx(vIdx)) = colIdx(starZ(vIdx));
pass = assignment(assignment>0);
pass(~diag(validMat(assignment>0,pass))) = 0;
assignment(assignment>0) = pass;
cost = trace(costMat(assignment>0,assignment(assignment>0)));
function [minval,rIdx,cIdx]=outerplus(M,x,y)
ny=size(M,2);
minval=inf;
for c=1:ny
    M(:,c)=M(:,c)-(x+y(c));
    minval = min(minval,min(M(:,c)));
end
[rIdx,cIdx]=find(M==minval);
%%%%%%%%%
function [ tracks adjacency_tracks A ] = simpletracker(points, max_linking_distance, max_gap_closing, debug)
% Jean-Yves Tinevez < jeanyves.tinevez@gmail.com> November 2011 - 2012
%% Parse arguments
if nargin < 4
  debug = false;
end
if nargin < 3
  max_gap_closing = 3;
end
if nargin < 2
  max_linking_distance = Inf;
end
%% Frame to frame linking
if debug
  fprintf('Frame to frame linking.\n');
end
n_slices = numel(points);
current_slice_index = 0;
row_indices = cell(n_slices, 1);
column_indices = cell(n_slices, 1);
unmatched_targets = cell(n_slices, 1);
unmatched_sources = cell(n_slices, 1);
n_cells = cellfun(@(x) size(x, 1), points);
for i = 1 : n_slices-1
  source = points{i};
  target = points{i+1};
  disp([num2str(i) ' Hungarianlinker'])
  % Frame to frame linking
  [target_indices , distances_junk, unmatched_targets{i+1} ] = ...
    hungarianlinker(source, target, max_linking_distance);
  unmatched_sources{i} = find( target_indices == -1 );
  % Prepare holders for links in the sparse matrix
  n_links = sum( target_indices ~= -1 );
  row_indices{i} = NaN(n_links, 1);
  column_indices{i} = NaN(n_links, 1);
  % Put it in the adjacency matrix
  index = 1;
  for j = 1 : numel(target_indices)
    % If we did not find a proper target to link, we skip
    if target_indices(j) == -1
      continue
    end
    % The source line number in the adjacency matrix
    row_indices{i}(index) = current_slice_index + j;
    % The target column number in the adjacency matrix
    column_indices{i}(index) = current_slice_index + n_cells(i) + target_indices(j);
    index = index + 1;
  end
  current_slice_index = current_slice_index + n_cells(i);
end
row_index = vertcat(row_indices{:});
column_index = vertcat(column_indices{:});
link_flag = ones( numel(row_index), 1);
n_total_cells = sum(n_cells);
A = sparse(row_index, column_index, link_flag, n_total_cells, n_total_cells);
if debug
  fprintf('Creating %d links over a total of %d points.\n', numel(link_flag), n_total_cells)
  fprintf('Done.\n')
end
%% Gap closing
if debug
  fprintf('Gap-closing:\n')
end
current_slice_index = 0;
disp('finding targets...')
for i = 1 : n_slices-2
  % Try to find a target in the frames following, starting at i+2, and
  % parsing over the target that are not part in a link already.
  current_target_slice_index = current_slice_index + n_cells(i) + n_cells(i+1);
  for j = i + 2 : min(i +  max_gap_closing, n_slices)
    source = points{i}(unmatched_sources{i}, :);
    target = points{j}(unmatched_targets{j}, :);
    if isempty(source) || isempty(target)
      continue
    end
    target_indices = nearestneighborlinker(source, target, max_linking_distance);
    % Put it in the adjacency matrix
    for k = 1 : numel(target_indices)
      % If we did not find a proper target to link, we skip
      if target_indices(k) == -1
        continue
      end
      if debug
        fprintf('Creating a link between cell %d of frame %d and cell %d of frame %d.\n', ...
          unmatched_sources{i}(k), i, unmatched_targets{j}(target_indices(k)), j);
      end
      % The source line number in the adjacency matrix
      row_index = current_slice_index + unmatched_sources{i}(k);
      % The target column number in the adjacency matrix
      column_index = current_target_slice_index + unmatched_targets{j}(target_indices(k));
      A(row_index, column_index) = 1; %#ok<SPRIX>
    end
    new_links_target =  target_indices ~= -1 ;
    % Make linked sources unavailable for further linking
    unmatched_sources{i}( new_links_target ) = [];
    % Make linked targets unavailable for further linking
    unmatched_targets{j}(target_indices(new_links_target)) = [];
    current_target_slice_index = current_target_slice_index + n_cells(j);
  end
  current_slice_index = current_slice_index + n_cells(i);
end
if debug
  fprintf('Done.\n')
end
%% Parse adjacency matrix to build tracks
if debug
  fprintf('Building tracks:\n')
end
cells_without_source = find(all( A == 0, 1));
n_tracks = numel(cells_without_source);
adjacency_tracks = cell(n_tracks, 1);
for i = 1 : n_tracks
  tmp_holder = NaN(n_total_cells, 1);
  target = cells_without_source(i);
  index = 1;
  while ~isempty(target)
    tmp_holder(index) = target;
    line = full(A(target, :));
    target = find( line, 1, 'first' );
    index = index + 1;
  end
  adjacency_tracks{i} = tmp_holder ( ~isnan(tmp_holder) );
end
%% Reparse adjacency track index to have it right.
% The trouble with the previous track index is that the index in each
% track refers to the index in the adjacency matrix, not the point in
% the original array. We have to reparse it to put it right.
tracks = cell(n_tracks, 1);
for i = 1 : n_tracks
  adjacency_track = adjacency_tracks{i};
  track = NaN(n_slices, 1);
  for j = 1 : numel(adjacency_track)
    cell_index = adjacency_track(j);
    % We must determine the frame this index belong to
    tmp = cell_index;
    frame_index = 1;
    while tmp > 0
      tmp = tmp - n_cells(frame_index);
      frame_index = frame_index + 1;
    end
    frame_index = frame_index - 1;
    in_frame_cell_index = tmp + n_cells(frame_index);
    track(frame_index) = in_frame_cell_index;
  end
  tracks{i} = track;
end
disp('SimpleTracker is done')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = smoothn(X,sz,filt,std)

%SMOOTHN Smooth N-D data
%   Y = SMOOTHN(X, SIZE) smooths input data X. The smoothed data is
%       retuirned in Y. SIZE sets the size of the convolution kernel
%       such that LENGTH(SIZE) = NDIMS(X)
%
%   Y = SMOOTHN(X, SIZE, FILTER) Filter can be 'gaussian' or 'box' (default)
%       and determines the convolution kernel.
%
%   Y = SMOOTHN(X, SIZE, FILTER, STD) STD is a vector of standard deviations 
%       one for each dimension, when filter is 'gaussian' (default is 0.65)

%     $Author: ganil $
%     $Date: 2001/09/17 18:54:39 $
%     $Revision: 1.1 $
%     $State: Exp $

if nargin == 2,
  filt = 'b';
elseif nargin == 3,
  std = 0.65;
elseif nargin>4 | nargin<2
  error('Wrong number of input arguments.');
end

% check the correctness of sz
if ndims(sz) > 2 | min(size(sz)) ~= 1
  error('SIZE must be a vector');
elseif length(sz) == 1
  sz = repmat(sz,ndims(X));
elseif ndims(X) ~= length(sz)
  error('SIZE must be a vector of length equal to the dimensionality of X');
end

% check the correctness of std
if filt(1) == 'g'
  if length(std) == 1
    std = std*ones(ndims(X),1);
  elseif ndims(X) ~= length(std)
    error('STD must be a vector of length equal to the dimensionality of X');
  end
  std = std(:)';
end

sz = sz(:)';

% check for appropriate size
padSize = (sz-1)/2;
if ~isequal(padSize, floor(padSize)) | any(padSize<0)
  error('All elements of SIZE must be odd integers >= 1.');
end

% generate the convolution kernel based on the choice of the filter
filt = lower(filt);
if (filt(1) == 'b')
  smooth = ones(sz)/prod(sz); % box filter in N-D
elseif (filt(1) == 'g')
  smooth = ndgaussian(padSize,std); % a gaussian filter in N-D
else
  error('Unknown filter');
end


% pad the data
X = padreplicate(X,padSize);

% perform the convolution
Y = convn(X,smooth,'valid');

function h = ndgaussian(siz,std)

% Calculate a non-symmetric ND gaussian. Note that STD is scaled to the
% sizes in SIZ as STD = STD.*SIZ


ndim = length(siz);
sizd = cell(ndim,1);

for i = 1:ndim
  sizd{i} = -siz(i):siz(i);
end

grid = gridnd(sizd);
std = reshape(std.*siz,[ones(1,ndim) ndim]);
std(find(siz==0)) = 1; % no smoothing along these dimensions as siz = 0
std = repmat(std,2*siz+1);


h = exp(-sum((grid.*grid)./(2*std.*std),ndim+1));
h = h/sum(h(:));

function argout = gridnd(argin)

% exactly the same as ndgrid but it accepts only one input argument of 
% type cell and a single output array

nin = length(argin);
nout = nin;

for i=nin:-1:1,
  argin{i} = full(argin{i}); % Make sure everything is full
  siz(i) = prod(size(argin{i}));
end
if length(siz)<nout, siz = [siz ones(1,nout-length(siz))]; end

argout = [];
for i=1:nout,
  x = argin{i}(:); % Extract and reshape as a vector.
  s = siz; s(i) = []; % Remove i-th dimension
  x = reshape(x(:,ones(1,prod(s))),[length(x) s]); % Expand x
  x = permute(x,[2:i 1 i+1:nout]);% Permute to i'th dimension
  argout = cat(nin+1,argout,x);% Concatenate to the output 
end

function b=padreplicate(a, padSize)
%Pad an array by replicating values.
numDims = length(padSize);
idx = cell(numDims,1);
for k = 1:numDims
  M = size(a,k);
  onesVector = ones(1,padSize(k));
  idx{k} = [onesVector 1:M M*onesVector];
end

b = a(idx{:});



