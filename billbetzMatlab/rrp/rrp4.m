function rrp4 (varargin)
% v.n has 4 columns: c1=time (pt)last exo; c2=# exo events; c3=p0; c4= p now
global v vh
more off
switch nargin
  case 0
    close all
    h=openfig(mfilename,'reuse');v.deadtime=0;
    vh=guihandles(h);
    % main variables
    v.rrpgrow=0; v.rrpmode=2;
    v.rrpsize=1770; v.rrpavg=0.4; v.rrpstd=0.1; v.rrpskew=1;
    v.rtau=.2; v.rskew=1; v.deadtime=0; v.rthresh=0;
    v.rrpslow=1; v.recycslow=1;
    
    v.mx0=1; % max value to which p0 can grow
    v.npts=100; v.freq=100;
    v.bkg=get(vh.hfig,'color');
    v.nbins=100;
    v.histo=1;
    v.ctr=1;
    try; a=v.obs; catch; v.obs=[]; end
    v.noisefac=0; % fractional change (max) in p0
    v.cd=[]; %  do we have a directory for saving?
    try; load('rrpvars.mat'); catch; end
    eval([mfilename ' setvals'])
    v.calc=0; v.optim=0;
    optz
    set (vh.axes1,'xlim',[0 v.npts/v.freq])
    
  case 1
    switch varargin{:}
      case 'vars'
        eval([mfilename ' getvals'])
        prompt={'RRP size'  'RRP p (mean)' 'RRP p (std dev)',...
          'recruit tau (s)' 'rrp p0 skew factor' 'recruit time skew factor' 'recycle dead time',...
          'recruit p thresh' 'factor to slow rate of growth of rrp p',...
          'factor to slow p growth with multiple exo events' '# pts per run',...
          'noise factor?' 'max to which p0 can grow'};
        title='variables'; lineno=1;
        def={num2str(v.rrpsize),...
          num2str(v.rrpavg),...
          num2str(v.rrpstd),...
          num2str(v.rtau),...
          num2str(v.rrpskew),...
          num2str(v.rskew),...
          num2str(v.deadtime),...
          num2str(v.rthresh),...
          num2str(v.rrpslow),...
          num2str(v.recycslow),...
          num2str(v.npts),...
          num2str(v.noisefac),...
          num2str(v.mx0),...
          };
        inp=inputdlg(prompt,title,lineno,def);
        v.rrpsize=str2num(inp{1});
        v.rrpavg=str2num(inp{2});
        v.rrpstd=str2num(inp{3});
        
        v.rtau=str2num(inp{4});
        v.rrpskew=str2num(inp{5});
        v.rskew=str2num(inp{6});
        v.deadtime=str2num(inp{7});
        v.rthresh=str2num(inp{8});
        v.rrpslow=str2num(inp{9});
        v.recycslow=str2num(inp{10});
        
        v.npts=str2num(inp{11});
        v.noisefac=str2num(inp{12});
        v.mx0=str2num(inp{13});
        eval([mfilename ' setvals'])
        v.calc=0; v.optim=0;
        optz
        
      case 'getvals'
        v.rrpsize=round(get(vh.rrpsize_slider,'value'));
        v.rrpavg=get(vh.rrpavg_slider,'value');
        v.rrpstd=get(vh.rrpstd_slider,'value');
        v.rrpskew=get(vh.skew_slider,'value');
        
        v.rtau=round(100*get(vh.rtau_slider,'value'))/100;
        v.rskew=get(vh.rskew_slider,'value');
        v.deadtime=get(vh.deadtime_slider,'value');
        v.rthresh=get(vh.rthresh_slider,'value');
        
        v.rrpslow=get(vh.rrpslow_slider,'value');
        v.recycslow=get(vh.recycslow_slider,'value');
        
        eval([mfilename ' setvals'])
        
        v.calc=~v.histo;
        if ~isempty(v.obs); v.calc=1; end
        v.histo2=v.histo; v.histo=0;
        optz
        eval([mfilename ' drawlines2'])
        v.histo=v.histo2;
        
      case 'setvals'
        save('rrpvars.mat','v');
        set(vh.rrpsize_txt,'string',['RRP size= ' num2str(v.rrpsize)])
        set(vh.rrpavg_txt,'string',['RRP: p mean= ' num2str(v.rrpavg)])
        set(vh.rrpstd_txt,'string',['RRP: p std dev= ' num2str(v.rrpstd)])
        set(vh.skew_txt,'string',['p distribution skew= ' num2str(v.rrpskew)])
        
        set(vh.rtau_txt,'string',['recruit: tau= ' num2str(v.rtau)])
        set(vh.rskew_txt,'string',['recruit t skew= ' num2str(v.rskew)])
        set(vh.deadtime_txt,'string',['deadtime=' num2str(v.deadtime)])
        set(vh.rthresh_txt,'string', ['p thresh=' num2str(v.rthresh)])
        
        set(vh.rrpslow_txt,'string',['rrp slow=' num2str(v.rrpslow)])
        set(vh.recycslow_txt,'string',['recyc slow=' num2str(v.recycslow)])
        
        set(vh.rrpsize_slider,'value',v.rrpsize)
        set(vh.rrpavg_slider,'value',v.rrpavg)
        set(vh.rrpstd_slider,'value',v.rrpstd)
        set(vh.skew_slider,'value',v.rrpskew)
        
        set(vh.rtau_slider,'value',v.rtau)
        set(vh.rskew_slider,'value',v.rskew)
        set(vh.deadtime_slider,'value',v.deadtime)
        set(vh.rthresh_slider,'value',v.rthresh)
        
        set(vh.rrpslow_slider,'value',v.rrpslow)
        set(vh.recycslow_slider,'value',v.recycslow)
        
        set(vh.rrpgrow,'string',['p0 grow=' num2str(v.rrpgrow)])
        set(vh.rrpmode,'string',['rrp mode=' num2str(v.rrpmode)])
        
      case 'reset'
        eval(mfilename)
        
      case 'rrpgrow'
        v.rrpgrow=v.rrpgrow+1; if v.rrpgrow==4; v.rrpgrow=0; end
        set(vh.rrpgrow,'string',['p0 grow=' num2str(v.rrpgrow)])
        str='off'; if v.rrpgrow==1 | v.rrpgrow==3; str='on'; end
        set(vh.rrpslow_txt,'visible',str)
        set(vh.rrpslow_slider,'visible',str)
        
      case 'rrpmode'
        v.rrpmode=1+v.rrpmode; if v.rrpmode>2; v.rrpmode=0; end
        set(vh.rrpmode,'string',['rrp mode=' num2str(v.rrpmode)])
        vis='on'; if v.rrpmode~=1; vis='off'; end
        set(vh.rrpstd_txt,'visible',vis)
        set(vh.rrpstd_slider,'visible',vis)
        v.calc=0; v.optim=0; optz
        
      case 'histoonoff'
        v.histo=~v.histo;
        str='off'; if v.histo; str='on'; end
        set(vh.histoonoff,'string',['histo ' str])
        
      case 'kbd'
        keyboard
        
      case 'saveit'
        [fname,pname]=uiputfile;
        save([pname fname],'v');
        
      case 'loadit'
        if isempty(v.cd); cd([matlabroot '\work\data\']); end
        [fname,pname]=uigetfile('*.txt')
        %  load([pname fname]); % for mat files
        v.obs=dlmread([pname fname]); % for .txt files
        if size(v.obs,2)~=2;
          disp(['File has ' num2str(size(v.obs,2)) ' columns. I need 2 columns - time and amplitude'])
          return
        end
        v.fxmin=99999999;
        eval([mfilename ' setvals'])
        v.calc=0; v.optim=0; optz
        axes(vh.axes5)
        vh.line5a=line('xdata',v.obs(:,1),'ydata',v.obs(:,2),...
          'color','red','marker','.','linestyle','none'); %
        axes(vh.axes1)
        
      case 'go'
        set(findobj('callback',['rrp4' ' optim']),'backgroundcolor',v.bkg)
        v.calc=1; v.optim=0;
        optz
        v.calc=0;
        eval([mfilename ' drawlines2'])
        
      case 'helpp'
        str=['p0 grows: ' char(10),...
          '0 = p values cannot exceed their original (p0) values; ' char(10),...
          '1 = RRP p values can grow (to 1.0), recycled p values cannot increase above p0; ' char(10),...
          '2= only recycled p value can increase above initial level.'  char(10),...
          '3= all p values can grow (to 1.0)' char(10) char(10),...
          'rrp mode: ' char(10),...
          'how to distribute initial p values of rrp (0=random; 1=gaussian; 2=exponential)'];
        msgbox(str)
        
      case 'histogram'
        j=v.ctr;
        sz=size(v.colors,2);
        v.n2=v.n(v.esites>0,:); % eligibles only
        c5=v.n2(:,4);  c2=v.n2(:,2);
        x1=v.n2(c2==0,2); % rrp
        n1=histc(x1,v.edges);
        % color the bars
        mx=min(1,max(v.n2(:,2)));
        for kk= 0:mx
          x2=c5(c2==kk); if kk==mx; x2=c5(c2>=kk); end
          nn=histc(x2,v.edges);
          if size(nn,2)>1; nn=nn'; end
          try; n0(:,kk+1)=nn; catch; end
          % n0(:,kk+1)=nn;
        end
        %
        try; bar(v.edges,n0,'stacked'); catch; end % current distibution of p values
        set(vh.axes1,'xlim',v.xlimit,'ylim',v.ylimit)
        zz=findobj(gca,'type','patch'); % color the bars
        for jj=size(zz,1):-1:1
          ncolor=mod(jj,sz)+4*~mod(jj,sz);
        end
        if v.ctr; eval([mfilename ' drawlines']); end
        drawnow
        
      case 'drawlines'
        axes(vh.axes1)
        v.xx=[0:v.xstep:v.ctr/v.freq-v.xstep]';
        vh.line1=line('xdata',v.xx,'ydata',v.mnow(:,1),...
          'color','red','marker','none'); % mrecycled
        vh.line2=line('xdata',v.xx,'ydata',v.mnow(:,2),...
          'color','green','marker','none'); % mrrp
        vh.line3=line('xdata',v.xx,'ydata',v.mnow(:,3),...
          'color','blue'); % v.M
        v.ylimit=get(vh.axes1,'ylim');
        vh.line4=line('xdata',v.xx,'ydata',(v.ylimit(2)*v.mnow(:,4))/size(v.n,1),...
          'color','black','marker','.'); % RRP (%)
        drawnow
        
      case 'drawlines2'        
        str=['PLATEAU: ' char(10)];
        if isempty(v.obs)
          str=[str 'mean m= ' num2str(v.meanm) char(10),...
            ' (tot= ' num2str(sum(v.mnow(:,3))) ')' char(10),...
            'mean m (predicted)= ' num2str(v.meanm_predict) char(10),...
            'p (var)= ' num2str(v.p) char(10),...
            'p (mean sites)= ' num2str(v.p2) char(10),...
            'n= ' num2str(v.nplat) char(10),...
            '(Pts ' num2str(v.kk) '-' num2str(size(v.mnow,1)) ')' char(10)];
        else
          p1=51;
          varobs=var(v.obs(p1:end,2));
          mobs=mean(v.obs(p1:end,2));
          pobs=1-varobs/mobs; pobs=round(pobs*100)/100;
          varcalc=var(v.mnow(p1:end,3));
          mcalc=mean(v.mnow(p1:end,3));
          pcalc=1-varcalc/mcalc; pcalc=round(pcalc*100)/100;
          str=[str 'fxmin= ' num2str(round(v.fxmin*100)/100) char(10),...
            'obs p= ' num2str(pobs) char(10),...
            '. calc p=' num2str(pcalc)];
        end
        set(vh.results,'string',str)
        if ~v.histo; eval([mfilename ' drawlines']); end
        grid on
        
        axes(vh.axes2) % # exocytic events vs p0
        delete(findobj(gca,'type','line'))
        hist(v.n(:,2),100)
        vv=get(gca); x=(vv.XLim(2)-vv.XLim(1))/3+vv.XLim(1);
        y=(vv.YLim(2)-vv.YLim(1))/2+vv.YLim(1);
        str=[num2str(sum(v.n(:,2)==0)) ' zeros'];
        delete(findobj(gca,'type','text'))
        text('position', [x,y], 'string',str)
        drawnow
        
        axes(vh.axes3) %
        delete(findobj(gca,'type','line'))
        ninf=max(50,mean(v.mnow(end-10:end,3)));
        set(vh.axes3,'ylim',[0 ninf*3]); grid on
        vh.line5=line('xdata',v.xx,'ydata',v.mnow(:,5)/10,'color','black'); % n
        vh.line3=line('xdata',v.xx,'ydata',v.mnow(:,3),'color','blue'); % m
        
        axes(vh.axes4)
        delete(findobj(gca,'type','line'))
        dt2=v.dt/v.freq;
        hist(dt2,100)
        
        if ~isempty(v.obs)
          axes(vh.axes5)
          delete(findobj(gca,'type','line'))
          set(gca,'ylim',[0 100]); grid on
          vh.line5a=line('xdata',v.obs(:,1),'ydata',v.obs(:,2),...
            'color','red','marker','.','linestyle','none'); %
          vh.line6=line('xdata',v.obs(:,1),'ydata',v.mnow(:,3),'marker','.','linestyle','none','color','black');
        end
        %       x=[1:size(v.dt)]';
        %     line(x,v.dt,'linestyle','none','marker','.')
        axes(vh.axes1)
        
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      case 'optim'
        optimmethod=get(gco,'tag');
        set(vh.results,'string','')
        %  set(findobj('callback',['rrp4' ' optim']),'backgroundcolor',v.bkg)
        if isempty(v.obs); str='LOAD OBSERVED DATA';
          set(vh.results,'string',str); disp(str); return; end
        set(gco,'backgroundcolor',[1 0 0])
        v.histo2=v.histo; v.histo=0;
        v.multiobj=0; v.ctr=0; v.optimctr=0;
        v.replot=0; % replot each time new fxmin
        axes(vh.axes5);
        delete(findobj(gca,'type','line'))
        set(gca,'ylim',[0 100]); grid on
        vh.line5a=line('xdata',v.obs(:,1),'ydata',v.obs(:,2),...
          'color','red','marker','.','linestyle','none'); %
        vh.line6=line('marker','.','linestyle','none','color','black');
        axes(vh.axes1)
        v.fxmin=1e12;
        x=[100 v.rrpsize 5000,...
          0 v.rrpavg 1,...
          0 v.rrpstd 1,...
          .01 v.rrpskew 10,...
          .01 v.rtau .5,...
          .01 v.rskew 1,...
          0 v.deadtime 1,...
          0 v.rthresh 1,...
          0.1 v.rrpslow 10,...
          0.1 v.recycslow 10];
        v.scanvars=x; lb=[]; ub=[]; x0=[];
        for j=1:3:size(x,2)
          lb=[lb x(j)];
          ub=[ub x(j+2)];
          x0=[x0 x(j+1)];
        end
        nvars=size(x0,2);
        v.optim=1; v.calc=1;
        
        switch optimmethod
          case 'optim_ps' % PatternSearch'
            try; options=v.psoptions; catch; options=psoptimset; end
            disp('Using Pattern Search method...')
            disp(options)
            [X fval] = patternsearch(@optz, x0,[],[],[],[],lb,ub,[],options);
            
          case 'optim_ga' % GeneticAlgorithm'
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm method...')
            disp(options)
            [X fval] = ga(@optz,nvars,[],[],[],[],lb,ub,[],options);
            
          case 'optim_sa' % SimulatedAnnealing'
            try; options=v.saoptions; catch; options=saoptimset; end
            disp('Using Simulated Annealing method...')
            disp(options)
            [X fval] = simulannealbnd(@optz,x0,lb,ub,options);
            
          case 'optim_gs' % global search optimization
            try; options=v.gsoptions; gs=v.gs;
            catch; options=optimset; gs=GlobalSearch;
            end
            problem = createOptimProblem('fmincon','x0',x0,...
              'objective',@optz,'lb',lb,'ub',ub,'options',options);
            disp('Using Global Search method...')
            disp(options)
            [X fval]=run(gs,problem)
            
          case 'optim_ms'
            try; options=v.msoptions; catch; options=optimset; end
            problem = createOptimProblem('fmincon','objective', @optz,...
              'x0',x0,'lb',lb,'ub',ub,'options',options);
            ms = MultiStart; nruns=200;
            disp('Using MultiSearch method...')
            disp(options)
            [X,f] = run(ms,problem,nruns);
            
          case 'optim_gamo' % genetic alogrithm multiple objectives
            v.multiobj=1; nvars=size(x0,2);
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm MultiObjectives method...')
            disp(options)
            [X fval]= gamultiobj(@optz,nvars,[],[],[],[],lb,ub,options);
            
            v.res=sortrows([fval X],1); %; v.fval=fval;
            % v.res=rand(20,12); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
            str='Col 1 & 2 = pareto front vals. Col 3-end = variable values';
            str=[str char(10) 'c1=fx; c2=dvar; c3=rrpsize; c4=rrpavg; ' char(10),...
              'c5=rrpstd; c6=tau recruit; c7=rrpskew; c8=recruit skew;' char(10),...
              'c9=deadtime; c10=recruit thresh; c11=rrpslow; c12=recycle slow'];
            dlmwrite(['junk.txt'],[v.res],'\t')
            edit ('junk.txt'); drawnow
            disp(str)
            set(findobj('tag',optimmethod),'backgroundcolor',v.bkg)
            eval([mfilename ' checksliders'])
            eval([mfilename ' setvals'])
            v.optim=0; v.multiobj=0; sz=size(v.res,1); v.histo=0;
            for gamores=1:size(v.res,1)
              xx=v.res(gamores,3:end);
              %     xx=[1700; rand; rand; 1; .3; 1; 0; 0; 1; 1];
              v.rrpsize=xx(1);
              v.rrpavg=xx(2);
              v.rrpstd=xx(3);
              
              v.rtau=xx(4);
              v.rrpskew=xx(5);
              v.rskew=xx(6);
              v.deadtime=xx(7);
              v.rthresh=xx(8);
              v.rrpslow=xx(9);
              v.recycslow=xx(10);
              
              optz
              disp([num2str(gamores) ' / ' num2str(sz)])
              eval([mfilename ' go'])
              pause
            end % for gamores...
            return
            
        end % switch optimmethod
        disp('Done')
        set(findobj('tag','optimmethod'),'backgroundcolor',v.bkg)
        v.optim=0;
        
        
        
        eval([mfilename ' go'])
        v.histo=v.histo2;
        %disp (v.ctr)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'optim_setup'
        optimmethod=get(gco,'tag');
        switch optimmethod
          
          %Pattern search setup
          case 'ps_setup'
            try
              a=v.psoptions;
            catch
              v.ps1={'TolMesh' 'TolCon' 'TolX' 'TolFun',...
                'TolBind' 'MaxIter' 'MaxFunEvals' 'TimeLimit',...
                'MeshContraction' 'MeshExpansion',...
                'InitialMeshSize' 'MaxMeshSize',...
                'InitialPenalty' 'PenaltyFactor'};
              v.ps2_default={'1e-6' '1e-6' '1e-6' '1e-6',...
                '1e-3' '1000' '20000' 'Inf',...
                '0.5' '2.0' ,...
                '1.0' 'Inf',...
                '10' '100'};
              v.ps2=v.ps2_default;
            end
            prompt=v.ps1; def=v.ps2;
            title='PatternSearch - enter 0 in first line to reset to default';
            inp=inputdlg(prompt,title,1,def);
            if strcmp(inp{1},'0') % reset to default
              inp=v.ps2_default;
            end
            for j=1:size(v.ps1,2)
              v.ps2(j)=inp(j);
              eval(['psoptions.' v.ps1{j} '=' inp{j} ';']);
            end
            v.psoptions=psoptions;
            
            %Genetic algorithm options setup
          case 'ga_setup'
            try
              a=v.gaoptions;
            catch
              v.ga1={'PopulationSize' 'EliteCount'...
                'CrossoverFraction' 'ParetoFraction' 'MigrationInterval',...
                'MigrationFraction' 'Generations' 'TimeLimit' 'FitnessLimit',...
                'StallTimeLimit' 'TolFun' 'TolCon',...
                'InitialPenalty' 'PenaltyFactor'};
              v.ga2_default={'20' '2' '0.8' '0.35' '20' '0.2',...
                '100' 'Inf' '-Inf' 'Inf' '1e-6' '1e-6',...
                '10' '100'};
              v.ga2=v.ga2_default;
            end
            prompt=v.ga1;  def=v.ga2;
            title='Genetic algorithm -- enter 0 to reset to default';
            inp=inputdlg(prompt,title,1,def);
            if strcmp(inp{1},'0')
              inp=v.ga2_default;
            end
            for j=1:size(v.ga1,2)
              v.ga2(j)=inp(j);
              eval(['gaoptions.' v.ga1{j} '=' inp{j} ';']);
              % v.gaoptions=gaoptions;
            end
            v.gaoptions=gaoptions;
            
            %Simulated annealing options setup
          case 'sa_setup'
            try
              a=v.saoptions;
            catch
              v.sa1={'TolFun' 'MaxIter' 'MaxFunEvals'...
                'TimeLimit' 'ObjectiveLimit' 'StallIterLimit'...
                'InitialTemperature'};
              v.sa2_default={'1e-6' 'Inf' '15000'...
                'Inf' '-Inf' '2500' '100'};
              v.sa2=v.sa2_default;
            end
            prompt=v.sa1;  def=v.sa2;
            title='Simulated Annealing -- enter 0 to reset to default';
            inp=inputdlg(prompt,title,1,def);
            if strcmp(inp{1},'0')
              inp=v.sa2_default;
            end
            for j=1:size(v.sa1,2)
              v.sa2(j)=inp(j);
              eval(['saoptions.' v.sa1{j} '=' inp{j} ';']);
            end
            v.saoptions=saoptions;
            
            %global search sub options set up
          case 'gs_setup'
            try
              a=v.gs2;
            catch
              v.gs1={'MaxFunEvals' 'MaxIter' 'TolFun' 'TolX'};
              v.gs2_default={'1000' '500' '1e-6' '1e-6'};
              v.gs2=v.gs2_default;
            end
            prompt=v.gs1;  def=v.gs2;
            title='Global search options -- enter 0 to reset to default';
            inp=inputdlg(prompt,title,1,def);
            if strcmp(inp{1},'0')
              inp=v.gs2_default;
            end
            for j=1:size(v.gs1,2)
              v.gs2(j)=inp(j);
              eval(['gsoptions.' v.gs1{j} '=' inp{j} ';']);
            end
            v.gsoptions=gsoptions;
            
            % Multistart sub options setup
          case 'ms_setup'
            try
              a=v.ms2;
            catch
              v.ms1={'MaxFunEvals' 'MaxIter' 'TolFun' 'TolX'};
              v.ms2_default={'1000' '500' '1e-6' '1e-6'};
              v.ms2=v.ms2_default;
            end
            prompt=v.ms1;  def=v.ms2;
            title='Multi-search options -- enter 0 to reset to default';
            inp=inputdlg(prompt,title,1,def);
            if strcmp(inp{1},'0')
              inp=v.ms2_default;
            end
            for j=1:size(v.ms1,2)
              v.ms2(j)=inp(j);
              eval(['msoptions.' v.ms1{j} '=' inp{j} ';']);
            end
            v.msoptions=msoptions;
            
            % genetic algorithm multiobjective setup
          case 'gamo_setup'
            % this uses ga_setup
            
            %global search/multistart shared options
          case 'gsms_setup'
            try a=v.gsms1;
            catch
              v.gsms1={'NumTrialPoints'; 'BasinRadiusFactor';
                'DistanceThresholdFactor'; 'MaxWaitCycle';
                'NumStageOnePoints'; 'PenaltyThresholdFactor';
                'TolFun'; 'TolX'; 'MaxTime';};
              v.gsms2={'1000'; '0.2'; '0.75'; '20'; '200'; '0.2';...
                '1e-6'; '1e-6'; 'Inf'};
            end
            prompt=v.gsms1; title='Global Search'; lineno=1; def=v.gsms2;
            inp=inputdlg(prompt,title,lineno,def);
            if isempty(inp); GlobalSearch; return; end % reset default
            v.gsms2=inp; gsms={[]};
            a=[];
            for j=1:9;
              a(j)=str2num(inp{j});
            end
            gsms=GlobalSearch(v.gsms1{1},a(1),v.gsms1{2},a(2),...
              v.gsms1{3},a(3),v.gsms1{4},a(4),v.gsms1{5},a(5),...
              v.gsms1{6},a(6),v.gsms1{7},a(7),v.gsms1{8},a(8),v.gsms1{9},a(9));
            v.gsms=gsms;
        end % switch optimmethod
        
        %   case 'saveit'
        %   [fname,pname]=uiputfile;
        %  save([pname fname],'v');
        
    end % switch varargin
    
end % switch nargin

function fval=optz(x);
global v vh
if v.optim
  v.rrpsize=round(x(1)); v.p0=x(2); v.rrpstd=x(3); v.rrpskew=x(4);
  v.rtau=x(5); v.rskew=x(6); v.deadtime=x(7); v.rthresh=x(8);
  v.rrpslow=x(9); v.recycslow=x(10);
end

%    case 'setup_rrp4'
v.ctr=0; v.dt=[]; v.minp=0.001;
v.n=zeros(round(v.rrpsize),4);
v.mnow=[];
v.noise1=~v.optim*v.noisefac*randn(size(v.n,1),1);
x=[0:v.npts-1]';
v.df=1-exp(-x/(v.rtau*v.freq));
if v.rskew~=1;
  v.df=v.df.^v.rskew;
end

v.xlimit=[0 v.npts/v.freq];
v.ylimit=[0 100];
v.edges=[0:0.02:1]';
v.xstep=1/v.freq;
v.colors={ 'c' 'b'  'm' 'y' 'b' 'g' 'r'}; %{'r' 'g' 'b' 'y' 'm' 'c'};
axes(vh.axes1)
delete(findobj(gca,'type','line'))

% c1=time of last exocytosis; c2=# exo events; c3=p0; c4= p now
v.n(:,2)=0;  % # exo events

% random or gaussian or expl
a1=v.rrpavg*rand(size(v.n,1),1); % this will be used to replace negative p values
switch v.rrpmode
  case 0 % random
    a0=rand(size(v.n,1),1); a=a0;
  case 1 % gaussian
    a0=randn(size(v.n,1),1);  % make p0 distribution
    a=a0*v.rrpstd;
    a=a+v.rrpavg;
    %       aa=v.rrpavg*rand(size(v.n,1),1); % random, not gaussian
    a(a<v.minp)=a1(a<v.minp); % spread negative values randomly over the lower half
  case 2 % expl
    tau=v.rrpavg;
    dx=1/size(v.n,1);
    x=[0:dx:1-dx]';
    a0=min(1,max(v.minp,exp(-x/tau)+v.noise1)); %-v.noise2));
    a=a0;
end
b=a.^v.rrpskew; % skew p0 towards higher values by raising to a power
a=b*mean(a)/mean(b);
a(a>1)=a1(a>1);
a(a<v.minp)=a1(a<v.minp);
v.n(:,3)=max(v.minp,min(1,a)); % p0
%   v.n(:,3)=v.n(:,3)+v.noise1; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v.n(:,4)=v.n(:,3);

v.esites=ones(size(v.n,1),1); % ready for exo
v.xstep=1/v.freq;
if ~v.optim; eval([mfilename ' histogram']); end

if ~v.calc; return; end
% case 'calc'
rtau=v.rtau*v.freq;
v.deadpts=round(v.deadtime*v.freq);
for j=1:v.npts %%%%%%%%%%%%%%%%%%%%%%%%
  v.ctr=j;
  mx=v.n(:,3); % set max p value
  switch v.rrpgrow
    case 1
      mx(v.n(:,2)==0)=v.mx0;
    case 2
      mx(v.n(:,2)>0)=v.mx0;
    case 3
      mx=mx*0+v.mx0;
  end
  mn=v.n(:,3); % set min p value
  mn(v.n(:,2)>0)=0;
  y0=max(0,mx-mn);
  
  dt=max(1,j-v.deadpts-v.n(:,1)); % growth of p begins only after deadtime
  df=v.df(dt);
  a0=v.n(:,2)+1; a=a0; % slow recycle rate with multiple exocytoses and slow rrp growth
  a(a0==1)=a(a0==1)*v.rrpslow;
  a(a0>1)=a(a0>1)*v.recycslow;
  df=df./a;
  
  p=y0.*df;
  p=p+mn;
  v.n(:,4)=min(1,max(0,p+v.noise1)); % -v.noise2)); % current p
  v.esites=ones(size(v.n,1),1); % find eligible release sites
  v.esites(v.n(:,4)<v.rthresh & v.n(:,2)>0)=0;
  dt=j-v.n(:,1); % current time minus time of last exo
  v.esites(dt<v.deadpts & v.n(:,2)>0)=0;
  %   v.esites(v.n(:,2)>1)=0; % only 2 release per site
  neligible=sum(v.esites);
  
  c5=v.n(:,4); % current p
  rsites=v.esites*0;  % find sites of release
  pavg=mean(c5(v.esites>0)); % avg p of all eligible sites
  rnd=rand(size(v.n,1),1); % rand -> randn
  %     rnd(rnd<v.rthresh)=v.rthresh;
  rsites(v.n(:,4)>=rnd & v.esites>0)=1; % sites of release
  
  v.mnow(j,1)=sum(rsites(v.n(:,2)>0));  % mrecycled
  v.mnow(j,2)=sum(rsites(v.n(:,2)==0));  % mrrp
  v.mnow(j,3)=sum(rsites); % m
  v.mnow(j,4)=sum(v.n(:,2)==0)-v.mnow(j,2); % RRP remaining
  v.mnow(j,5)=neligible; % eligibles=n
  v.mnow(j,6)=pavg;
  v.mnow(j,7)=neligible*pavg; % predicted m
  if j>v.deadpts; % time of last exo
    a=j-v.n(rsites>0 ,1);
    v.dt=[v.dt; a]; % list of all recycle times
  end
  v.n(rsites>0,1)=j;
  
  if v.histo; eval([mfilename ' histogram']); end
  
  c2=v.n(:,2); % update release site exocytic count and reset p to zero
  c2(rsites>0)=c2(rsites>0)+1; % increment exocytic counter
  v.n(:,2)=c2;
  v.n(rsites>0,4)=v.minp; % p goes to zero after release
  
end % for j=.. %%%%%%%%%%%%%%%%%%%%%%%
switch v.optim
  case 0
    v.kk=round(size(v.mnow,1)/2)+1;
    v.varmin=var(v.mnow(v.kk:end,3));
    v.meanm=mean(v.mnow(v.kk:end,3)); v.meanm=round(v.meanm*10)/10;
    v.meanm_predict=round(mean(v.mnow(v.kk:end,7))*10)/10;
    v.varmin=round(v.varmin*10)/10;
    v.p=1-v.varmin/v.meanm; v.p=round(v.p*100)/100;
    v.p2=mean(v.mnow(v.kk:end,6)); v.p2=round(v.p2*100)/100;
    v.nplat=round(mean(v.mnow(end-10:end,5)));
    
    
  case 1
    p1=50; % omit these points in calculating v.fx
    %if v.optim
    obs=v.obs(p1:end,2); calc=v.mnow(p1:end,3);
    ddat=obs-calc;
    v.fx=sqrt(mean(ddat.^2)); % mean(obs)-mean(calc);
    %  v.fx=abs(mean(obs)-mean(calc));
    %p1=1-var(obs)/mean(obs); p2=1-var(calc)/mean(calc);
    %v.fx=abs(p1-p2);
    fval=v.fx;
    
    if v.multiobj
      fval2=abs(mean(obs)-mean(calc));
      fval=[fval; fval2];
      v.fx= (abs(fval(1))+abs(fval(2)))/2;
    end
    
    if v.fx<v.fxmin;
      v.rxmin=v.fx;
      %disp(v.fxmin);
      set(vh.results,'string',['fx min = ' num2str(v.fxmin)])
      axes(vh.axes5)
      set(vh.line6,'xdata',v.obs(:,1),'ydata',v.mnow(:,3))
      axes(vh.axes1)
      eval([mfilename ' setvals'])
    end
    % fval=v.fx;
    v.optimctr=v.optimctr+1;
    if ~mod(v.optimctr,50); disp(v.optimctr); end
    
    
end % switch v.optim








