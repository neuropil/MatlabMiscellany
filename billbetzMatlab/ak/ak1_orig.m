function ak1 (varargin)
global v vh
more off
% clear all
switch nargin
  case 0
    close all
    h=openfig(mfilename,'reuse');
    vh=guihandles(h);
    v.t1=.001;
    v.t2=120;
    v.meanfreq=20;
    v.p0=0.1;
    v.pnow=v.p0;
    v.taudep=0.05;
    v.cutoff=v.meanfreq*v.t1;
    v.rms=99999999; v.rmsmin=v.rms;
    v.histo=1; v.ctr=1;
    v.nruns=10;
    v.j10=0;
    v.noisefac=0.1;

    v.imax=5000;
    v.p0=0.1;
    v.dpfac=0.02;
    v.taudep=1;
    v.taufac=0.2;
    v.scanvars={'500' '500' '10000' '.02' '.05' '.8' '0' '.02' '.2' '.1' '.1' '5' '.02' '.05' '.5'};

    % calculate dummy observed data
    v.obs=[0:v.t1:v.t2-v.t1]'; % time
    b=rand(size(v.obs,1),1);
    v.obs(b>v.cutoff)=[];
    c=diff(v.obs(:,1));
    c=[0; c];
    c=1-exp(-c./v.taudep); % fractional recovery
    d=1-exp(-c./v.taufac);
    inow=v.imax;
    for j=1:size(v.obs,1)
      dfi=v.imax-inow;
      dfp=v.pnow-v.p0;
      inow=max(0,inow+dfi*c(j)-dfp*d(j));
      m=inow*v.pnow;
      inow=max(0,inow-m);
      % disp(m)
      v.obs(j,2)=m;
      v.pnow=min(v.p0,v.pnow+v.dpfac);
      % disp([a(j) m])
    end

    %   try; load('ak1vars.mat'); catch; end
    setappdata(vh.hfig,'v',v)
    eval([mfilename ' setvals'])
    eval([mfilename ' setup_ak1'])
    % set (vh.axes1,'xlim',[0 v.t2])

  case 1
    switch varargin{:}
      case 'vars'
        eval([mfilename ' getvals'])
        prompt={'Imax' 'p0' 'dp (facilitation)' 'tau (recovery from depression)' 'tau (recovery from facilitation)'};

        title='variables'; lineno=1;
        def=v.scanvars;
        inp=inputdlg(prompt,title,lineno,def);
        v.imax=str2num(inp{1});
        v.p0=str2num(inp{2});
        v.dpfac=str2num(inp{3});
        v.taudep=str2num(inp{4});
        v.taufac=str2num(inp{5});
        %  v.nruns=str2num(inp{6});
        %  v.noisefac=str2num(inp{7});
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak1'])

      case 'getvals'
        v.imax=round(get(vh.imax_slider,'value'));
        v.p0=get(vh.p0_slider,'value');
        v.dpfac=get(vh.dpfac_slider,'value');
        v.taudep=get(vh.taudep_slider,'value');
        v.taufac=get(vh.taufac_slider,'value');

        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak1'])
        %  eval([mfilename ' calc'])

      case 'setvals'
        v.scanit=0;
        save('ak1vars.mat','v');
        set(vh.imax_txt,'string',['Imax= ' num2str(v.imax)])
        set(vh.p0_txt,'string',['p0= ' num2str(v.p0)])
        set(vh.dpfac_txt,'string',['dp (facil)= ' num2str(v.dpfac)])
        set(vh.taudep_txt,'string',['tau (depn rec)= ' num2str(v.taudep)])
        set(vh.taufac_txt,'string',['tau (facil rec)= ' num2str(v.taufac)])

        set(vh.imax_slider,'value',v.imax)
        set(vh.p0_slider,'value',v.p0)
        set(vh.dpfac_slider,'value',v.dpfac)
        set(vh.taudep_slider,'value',v.taudep)
        set(vh.taufac_slider,'value',v.taufac)

      case 'reset'
        v.scanit=0;
        eval(mfilename)

      case 'loadrmsmin'
        v.scanit=0;
        load('ak1vars_rmsmin.mat')
        eval([mfilename ' setup_ak1'])

      case 'kbd'
        if v.scanit;
          v.scanrms=sortrows(v.scanrms,1);
          dlmwrite(['junk.txt'],[v.scanrms],'\t')
          edit ('junk.txt')
          v.scanit=0;
          disp('Type dbquit, press ENTER')
          eval([mfilename ' setvals'])
          eval([mfilename ' setup_ak1'])
        end
        keyboard

      case 'scanit'
        v.scanit=0;
        prompt={'Imax: min' 'step' 'max',...
          'p0: min', 'p0: step' 'p0: max',...
          'dp (facilitation): min' 'dp (facilitation): step' 'dp (facilitation): max',...
          'tau (depression recovery): min' 'step' 'max',...
          'tau (facilitation decay): min' 'step' 'max'};
        title='scan variables'; lineno=1;
        def=v.scanvars;
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end

        v.scanvars=inp;
        v.scanit=1;
        for j=1:size(v.scanvars); a(j,1)=str2num(v.scanvars{j}); end
        nn=zeros(5,1); for j=1:5; f1=(j-1)*3+1; nn(j,1)=(a(f1+2)-a(f1))/a(f1+1); end
        ntot=nn(1); for j=2:5; ntot=ntot*nn(j); end
        tottime=ntot/150; % seconds
        nn=0;
        v.scanrms=zeros(100,6); v.scanrms=v.scanrms+9999999;
        for j1=a(13):a(14):a(15)  % imax, p0, dpfac, taudep,taufac
          for j2=a(10):a(11):a(12)
            for j3=a(7):a(8):a(9)
              for j4=a(4):a(5):a(6)
                for j5=a(1):a(2):a(3)
                  v.taufac=j1; v.taudep=j2; v.dpfac=j3; v.p0=j4; v.imax=j5;
                  nn=nn+1;
                  %     disp(mod(nn,150))
                  if ~mod(nn,150)
                    disp(['~' num2str(round(tottime-nn/150) ) ' seconds to go'])
                  end
                  eval([mfilename ' setup_ak1'])
                  b=find(v.scanrms(:,1)==max(v.scanrms(:,1))); b=b(1);
                  if v.rms<v.scanrms(b);
                    v.scanrms(b,1)=v.rms; v.scanrms(b,2)=v.imax; v.scanrms(b,3)=v.p0;
                    v.scanrms(b,4)=v.dpfac; v.scanrms(b,5)=v.taudep; v.scanrms(b,6)=v.taufac;
                    str=['Imax= ' num2str(v.imax) char(10),...
                      'p0= ' num2str(v.p0) char(10),...
                      'dp(facilitation)= ' num2str(v.dpfac) char(10),...
                      'tau (depression recovery)= ' num2str(v.taudep) char(10),...
                      'tau (facilitation decay)= ' num2str(v.taufac) char(10),...
                      'RMS= ' num2str(round(v.rms)) char(10),...
                      'nn= ' num2str(nn)];
                    set(vh.results,'string',str); drawnow
                  end % if v.rms<v.rmsmin
                  drawnow
                end
              end
            end
          end
        end
        eval([mfilename ' kbd'])
        v.scanit=0;

        %   case 'saveit'
        %   [fname,pname]=uiputfile;
        %  save([pname fname],'v');

      case 'loadit'
        [fname,pname]=uigetfile;
        %  load([pname fname]); % for .mat files
        v.obs=dlmread([pname fname]); % for .txt files
        v.rmsmin=99999999;
        eval([mfilename ' setup_ak1'])

      case 'calc'
        v.dat=zeros(size(v.obs,1),1);
        c=diff(v.obs(:,1));
        c=[0; c];
        c=1-exp(-c./v.taudep); % fractional recovery
        d=1-exp(-c./v.taufac);
        inow=v.imax;
        for j=1:size(v.obs,1)
          dfi=v.imax-inow;
          dfp=v.pnow-v.p0;
          inow=max(0,inow+dfi*c(j)-dfp*d(j));
          m=inow*v.pnow;
          inow=max(0,inow-m);
          v.dat(j,2)=m;
          v.pnow=min(v.p0, v.pnow+v.dpfac);
        end

        ddat=v.obs(:,2)-v.dat(:,2);
        v.rms=sqrt(sum(ddat.^2));
        if v.rms<v.rmsmin
          v.rmsmin=v.rms;  save('ak1vars_rmsmin.mat','v');
        end % if rms<v.rmsmin
        if v.scanit; return; end

        str=['rms= ' num2str(round(v.rms)) char(10),...
          '. Min rms = ' num2str(round(v.rmsmin))];
        set(vh.results,'string',str)

        axes(vh.axes2)
        mx=max(max(v.obs(:,2)),max(v.dat(:,2)));
        set(gca,'xlim',[0 mx],'ylim', [0 mx]);
        vh.line0=line('xdata',[0 mx],'ydata',[0 mx]);
        vh.line2=line('xdata',v.obs(:,2),'ydata',v.dat(:,2),'linestyle','none','marker','.');
        axes(vh.axes1)

        vh.line01=line('xdata',v.obs(:,1),'ydata',v.dat(:,2),'color',[0 0 0],'linestyle','none','marker','.');
        vh.line0= line('xdata',v.obs(:,1),'ydata',v.obs(:,2),'color',[1 .6 .6],'linestyle','none','marker','.');

        axes(vh.axes3)
        dobs=diff(v.obs(:,1)); dobs=[0; dobs];
        vh.line4=line('xdata',dobs,'ydata',v.obs(:,2),'linestyle','none','marker','.');
        axes(vh.axes1)

      case 'setup_ak1'
        v.pnow=v.p0;
        v.obs(:,1)=v.obs(:,1)-v.obs(1,1);
        v.t2=v.obs(end,1);
        axes(vh.axes1)
        delete(findobj(vh.hfig,'type','line'))
        if ~v.scanit; set(vh.results,'string',''); end
        axes(vh.axes1)
        set(gca,'ylimmode','auto','xlim',[0 v.t2]);
        grid on
        eval([mfilename ' calc'])

    end % switch varargin

end % switch nargin
