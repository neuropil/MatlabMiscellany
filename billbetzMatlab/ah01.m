function ah01(varargin)
global v vh
switch nargin
  case 0
    close all
    h=openfig(mfilename,'new');
    vh=guihandles(h);
    set(vh.figure1,'userdata','','pointer','arrow',...
      'windowbuttondownfcn',[mfilename ' pixval']);
    axes(vh.axes1)
    v.x=[0:0.00001:0.01]';
    v.y=v.x;%voltages
    v.zoom=1;
    vh.line01=line('xdata',v.x,'ydata',v.y,'marker','.');
    vh.line02=line('xdata',v.x,'ydata',v.y,'color','red');
    axes(vh.axes2)
    vh.line03=line('xdata',v.x,'ydata',v.y,'marker','.','linestyle','none');
    axes(vh.axes3)
    vh.line04=line('xdata',0,'ydata',0);
    axes(vh.axes1)
    try
      a=v.dat;
      eval([mfilename ' plotit'])
    catch
      eval('ah01 loadfile')
    end
  case 1
    switch varargin{:}
      case 'grid'
        grid; axes(vh.axes2); grid; axes(vh.axes3); grid; axes(vh.axes1)
      case 'kbd'
        keyboard
      case 'scan'
        for j=1:size(v.mf,2)
          set(vh.frequency,'value',j)
          eval([mfilename ' plotit'])
          drawnow
          v.scan(j,1)=v.lagxcorr;
        end
        axes(vh.axes3)
        set(vh.axes3,'xlimmode','auto','ylimmode','auto')
        set(vh.line04,'visible','on','xdata',v.mf','ydata',v.scan,'linestyle','-','marker','o')
        set(vh.lag_txt,'string','phase lag (degrees) vs. frequency'); %'visible','off');
        %set(vh.d2xcorr_txt,'string','lag(us) vs frequency')
        axes(vh.axes1)
        
      case 'plotit'
        v.zoom=round(get(vh.zoom,'value'));
        set(vh.zoom_txt,'string',['zoom= ' num2str(v.zoom)])
        dx=0.005/v.zoom;
        set(vh.axes1,'xlim',[0.005-dx 0.005+dx])
        dblevel=round(get(vh.dblevel,'value'));
        set(vh.dblevel_txt,'string',['dblevel= ' num2str(dblevel)])
        frequency=round(get(vh.frequency,'value'));
        set(vh.frequency_txt,'string',['frequency= ' num2str(round(v.mf(frequency)))])
        
        td=squeeze(v.dat(dblevel,frequency,:));%%x (dB levels); y (frequency)
        set(vh.line01,'ydata',td)
        ylimit=get(gca,'ylim');
        ysin=sin(2*pi*v.mf(frequency)*v.x)*max(td)/2;
        set(vh.line02,'ydata',ysin);
        
        lagtest=round(get(vh.lagtest,'value')); set(vh.lagtest,'value',lagtest)
        set(vh.lagtest_txt,'string',['lag test= ' num2str(lagtest)])
        if lagtest>-1
          if lagtest==0
            xtest=v.x;
          else
            xtest=v.x+v.x(end)+0.00001; % make sine wave with selected lag
            xtest=[v.x; xtest]; p1=1001-lagtest;
            xtest=xtest(p1:p1+1000);
          end
          td=sin(2*pi*v.mf(frequency)*xtest)*max(td)/2;
          set(vh.line01,'xdata',v.x,'ydata',td)
        end
        
        axes(vh.axes2) % xcorr
        [c]=xcorr(ysin,td,'coeff');
        sz=(size(c,1)-1)/2;
        set(vh.axes2,'xlim',[-0.01/v.zoom 0.01/v.zoom])
        x=[-0.01:0.00001:0.01]; %[-sz:sz];
        set(vh.line03,'xdata',x,'ydata',c)
        
        axes(vh.axes3) % phase shift
        y1=[0; diff(c)]; % method #1 (minimum of second derivative)
        y2=[diff(y1); 0];
        yy=y2; 
        v.lagxcorr=1001-find(yy==min(yy));         
 %      v.lagxcorr=1001-find(c==max(c)); % method #2 (max value)   
        phaselag=360*v.mf(frequency)*v.lagxcorr*1e-5; % degrees
        if phaselag<0; phaselag=360+phaselag; end
        set(vh.lag_txt,'visible','on','string',['lag= ' num2str(phaselag) ' deg']);
        % set(vh.line04,'visible','off') % 'xdata',x,'ydata',y2,'marker','none','linestyle','-')
        set(vh.axes3,'xlim',[-0.01/v.zoom 0.01/v.zoom])
        % set(vh.axes3,'xlimmode','auto','ylimmode','auto')
       % set(vh.line04,'visible','on','xdata',x','ydata',y2,'linestyle','-','marker','o')
       % set(vh.lag_txt,'visible','off');
        axes(vh.axes1)
        
      case 'loadfile'
        [f fpath]=uigetfile('*','pickanyfile');
        load([fpath f])
        %v.x=[0:0.00001:0.01]';
        mem=memb;
        %%% intensity values
        dblevels = mem.GWF.Intensity.Min:mem.GWF.Intensity.Step:mem.GWF.Intensity.Max;
        %%% frequency values (250-13929 Hz)
        v.mf=1000*0.25*2.^((0:29)/5); v.mf=v.mf*2;
        for j=1:1:length(dblevels);
          xx=mem.GWF.Wave1(j).Data-mean(mem.GWF.Wave1(j).Data);
          x(j,:)=xx; %%%% for CM recordings
          xy(j,:,:)=reshape(x(j,:),20020,30);
          % Loop through all frequencies
          for i=1:length(v.mf);
            xy1=reshape(xy(j,:,i),1001,20);
            % Could insert interleaved column vectors of 0s here...
            
            % index into data vectors obtained with signals of common envelope
            % phase (i.e., alternating tone pips)
            odds=1:2:19;
            evens=2:2:20;
            xy2=xy1(:,odds)';
            xy3=xy1(:,evens)';
            
            XY2(i,:)=mean(xy2); % take mean across "odds" tone pips
            XY3(i,:)=mean(xy3); % take mean across "evens" tone pips
            XYZ(i,:)=mean(xy2)-mean(xy3); % difference between odds and evens
          end
          XY2Z(j,:,:)=XY2;
          XY3Z(j,:,:)=XY3;
          XYZZ(j,:,:)=XYZ; %23 x 30 x 1001 matrix... intensity x freq x samples
          v.dat=XYZZ;
        end
        eval ('ah01 plotit')
        
      case 'pixval'
        xy = get(gca,'currentpoint');
        disp([xy(1),xy(2)])
    end % switch varargin
end