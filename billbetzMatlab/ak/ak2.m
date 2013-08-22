function ak2 (varargin)
global v vh
more off
%clear all
switch nargin
  case 0
    close all
    h=openfig(mfilename,'reuse');
    vh=guihandles(h);
    
    % start value of the variables
    % nmax, p0, dpfac, taudep, taufac, mini -
    a=get(vh.nmax_slider); v.scanvars(1:3)=[a.Min a.Value a.Max]; v.nmax=a.Value;
    a=get(vh.p0_slider); v.scanvars(4:6)=[a.Min a.Value a.Max]; v.p0=a.Value;
    a=get(vh.mini_slider); v.scanvars(7:9)=[a.Min a.Value a.Max]; v.mini=a.Value;
    a=get(vh.dpfac_slider); v.scanvars(10:12)=[a.Min a.Value a.Max]; v.dpfac=a.Value;
    a=get(vh.taufac_slider); v.scanvars(13:15)=[a.Min a.Value a.Max]; v.taufac=a.Value;
    a=get(vh.depn1_slider); v.scanvars(16:18)=[a.Min a.Value a.Max]; v.depn1=a.Value;
    a=get(vh.tau1dep_slider); v.scanvars(19:21)=[a.Min a.Value a.Max]; v.tau1dep=a.Value;
    a=get(vh.tau2dep_slider); v.scanvars(22:24)=[a.Min a.Value a.Max]; v.tau2dep=a.Value;
    % housekeeping variables
    v.fx=99999999; % same as fval
    v.fxmin=v.fx; % minimum value
    v.fxname='RMS'; % objective fx output
    set(findobj('string',v.fxname),'BackgroundColor','red')
    v.replot=0; % replot (1) or not (0) during optimization
    v.bkg=get(vh.hfig,'color'); % color of buttons
    v.axes1zoom=0; v.axes3zoom=0;
    v.lastoptimmethod=[]; v.nn=1;
    
    % calculate dummy observed data
    v.t1=.001; % resolution (0.001= 1 ms)
    v.t2=120; % total duration (s)
    v.meanfreq=20; % mean frequency of events
    v.cutoff=v.meanfreq*v.t1; % fraction of timepts with response
 
    v.obs=[0:v.t1:v.t2-v.t1]'; % set up times of events
    v.dat=[];
    b=rand(size(v.obs,1),1);
    v.obs(b>v.cutoff)=[];
    v.obs(:,2)=0;
    v.optim=0; % optimization (0=no, 1=yes, 2=multiobj)
    % create observed y values given the times determined above
    v.dt=[0; diff(v.obs(:,1))];
    x(1)=v.nmax; x(2)=v.p0; x(3)=v.mini; x(4)=v.dpfac; x(5)=v.taufac;
    x(6)=v.depn1; x(7)=v.tau1dep; x(8)=v.tau2dep;
    fval=opt(x);
    v.obs(:,2)=v.dat(:,2);
    
    axes(vh.axes1)
    set(gca,'xlimmode','auto','ylimmode','auto')
    vh.line01obs=line('xdata',v.obs(:,1),'ydata',v.obs(:,2),'color',[1 0 0],...
      'linestyle','-','marker','o','MarkerSize',2); % was 1 0.6 0.6
    vh.line01dat=line('xdata',v.obs(:,1),'ydata',v.dat(:,2),'color',[0 1 0],...
      'linestyle','-','marker','o', 'MarkerSize',2);
    grid on
    set(vh.axes1,'ButtonDownFcn',[mfilename ' axes_scale']) %,'xlimmode','manual','ylimmode','manual')
    
    axes(vh.axes2)
    vh.line02obsdat=line('xdata',v.obs(:,2),'ydata',v.dat(:,2),...
      'linestyle','none','marker','.','MarkerSize',1,...
      'MarkerFaceColor','none','MarkerEdgeColor','red');
    vh.line02ident=line('xdata',[0 0],'ydata',[0 0]);
    vh.line02linreg=line('xdata',[0 0],'ydata',[0 0],'linestyle',':','color','blue');
    set(vh.axes2,'ButtonDownFcn',[mfilename ' axes_scale'])
    
    axes(vh.axes3)
    vh.line03dtobs=line('xdata',v.dt,'ydata',v.obs(:,2),...
      'linestyle','none','marker','o','MarkerSize',2,...
      'MarkerFaceColor','none','MarkerEdgeColor','red');
    vh.line03linreg=line('xdata',0,'ydata',0,...
      'linestyle',':','marker','none','color','blue');
    grid on
    set(vh.axes3,'ButtonDownFcn',[mfilename ' axes_scale'])
    
    axes(vh.axes4)
    vh.line04obs=line('xdata',0,'ydata',0,'color','red');
    vh.line04dat=line('xdata',0,'ydata',0,'color','green');
    vh.txt04obs=text(0,0,'+','color','red','FontSize',22);
    vh.txt04dat=text(0,0,'+','color','green','FontSize',22);
    vh.txt04rms=text(0,0,'');
    set(vh.axes4,'ButtonDownFcn',[mfilename ' axes_scale'])
    
    axes(vh.axes1)
    drawnow
    eval([mfilename ' setup_ak2'])
    eval([mfilename ' setvals'])
    
  case 1
    switch varargin{1}
      case 'axes_scale'
        a=get(gca,'xlimmode');
        switch a
          case 'auto' % change to manual
            a=get(gca);
            prompt={'xmin' 'xmax' 'ymin' 'ymax'};
            title='Axes limits'; lineno=1;
            def={num2str(a.XLim(1)) num2str(a.XLim(2)) num2str(a.YLim(1)) num2str(a.YLim(2))};
            inp=inputdlg(prompt,title,lineno,def);
            axes(gca)
            set(gca,'xlim',[str2num(inp{1}) str2num(inp{2})],'ylim',[str2num(inp{3}) str2num(inp{4})])
            drawnow
          case 'manual' % change to auto
            set(gca,'xlimmode','auto','ylimmode','auto')
        end
        
      case 'objfx'
        v.fxname=get(gco,'string');
        set(findobj('tag','objfx'),'BackgroundColor',v.bkg)
        set(gco,'BackgroundColor','red')
        v.fx=99999999; v.fxmin=v.fx; v.xmin=[];
        eval([mfilename ' setup_ak2'])
        
      case 'replot' % replot toggle button (for showing optimization results)
        v.replot=~v.replot;
        str='off'; if v.replot; str='on'; end
        set(vh.replot,'string',['Replot ' str])
        drawnow
        
      case 'saveit' % save obs data to text file
        if isempty(v.cd); cd([matlabroot '']); else; cd(v.cd); end
        [fname,pname]=uiputfile('*.txt');
        v.cd=pname;
        a=v.obs;
        dlmwrite([pname,fname],a,'\t')
        
      case 'loadit' % load data from text file
        % 2 columns: col 1= time (s); col 2= amplitude (any units)
        try
          if isempty(v.cd); cd([matlabroot '']); else; cd(v.cd); end
        catch; v.cd=[]; cd([matlabroot '']); end
        [fname,pname]=uigetfile('*.txt');
        v.cd=pname;
        try
          v.obs=dlmread([pname fname]); % for .txt files
        catch; msgbox('No joy!'); return; end
        if size(v.obs,2)~=2;
          disp(['File has ' num2str(size(v.obs,2)) ' columns. I need 2 columns - time and amplitude'])
          return
        end
        if max(v.obs(:,2))<1; v.obs(:,2)=v.obs(:,2)*1e12;
          disp('Amplitudes multiplied by 1e12'); end
        v.fx=99999999; v.fxmin=v.fx;
        v.t2=v.obs(end,1);
        v.dt=[0; diff(v.obs(:,1))];
        v.dat=v.obs*0;
        eval([mfilename ' setup_ak2'])
        
      case 'vars' % clicked on one of the 5 variable buttons (not sliders)
        eval([mfilename ' getvals'])
        prompt={'nmax' 'p0' 'mini amplitude (pA)',...
          'dp (facilitation)' 'tau (recovery from facilitation)',...
          'depn 1(%total)',...
          'tau1 (recovery from depression)' 'tau2 (recovery from depression)'};
        title='variables'; lineno=1;
        def={num2str(v.nmax) num2str(v.p0) num2str(v.mini),...
          num2str(v.dpfac) num2str(v.taufac),...
          num2str(v.depn1) num2str(v.tau1dep) num2str(v.tau2dep)};
        inp=inputdlg(prompt,title,lineno,def);
        v.nmax=str2num(inp{1});
        v.p0=str2num(inp{2});
        v.mini=str2num(inp{3});
        v.dpfac=str2num(inp{4});
        v.taufac=str2num(inp{5});
        v.depn1=str2num(inp{6});
        v.tau1dep=str2num(inp{7});
        v.tau2dep=str2num(inp{8});
        eval([mfilename ' checksliders'])
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak2'])
        
      case 'getvals' % clicked on one of 5 sliders
        set(findobj('userdata','optim_button'),'backgroundcolor',v.bkg)
        v.fxmin=99999999;
        v.optim=0;
        v.nmax=round((get(vh.nmax_slider,'value')));
        v.p0=round(1000*get(vh.p0_slider,'value'))/1000;
        v.mini=round(get(vh.mini_slider,'value'));
        v.taufac=round(1000*get(vh.taufac_slider,'value'))/1000;
        v.dpfac=round(1000*get(vh.dpfac_slider,'value'))/1000;
        v.depn1=round(1000*get(vh.depn1_slider,'value'))/1000;
        v.tau1dep=round(1000*get(vh.tau1dep_slider,'value'))/1000;
        v.tau2dep=round(1000*get(vh.tau2dep_slider,'value'))/1000;
        
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak2'])
        
      case 'setvals' % set text on buttons, values on sliders
        %  save('ak1vars.mat','v');
        set(vh.nmax_txt,'string',['nmax= ' num2str(v.nmax)])
        set(vh.p0_txt,'string',['p0= ' num2str(v.p0)])
        set(vh.mini_txt,'string',['mini (pA)= ' num2str(v.mini)])
        set(vh.dpfac_txt,'string',['dp= ' num2str(v.dpfac)])
        set(vh.taufac_txt,'string',['tau= ' num2str(v.taufac)])
        set(vh.depn1_txt,'string',['depn1 (% total)= ' num2str(v.depn1)])
        set(vh.tau1dep_txt,'string',['tau1= ' num2str(v.tau1dep)])
        set(vh.tau2dep_txt,'string',['tau2= ' num2str(v.tau2dep)])
        
        set(vh.nmax_slider,'value',v.nmax)
        set(vh.p0_slider,'value',v.p0)
        set(vh.mini_slider,'value',v.mini)
        set(vh.dpfac_slider,'value',v.dpfac)
        set(vh.taufac_slider,'value',v.taufac)
        set(vh.depn1_slider,'value',v.depn1)
        set(vh.tau1dep_slider,'value',v.tau1dep)
        set(vh.tau2dep_slider,'value',v.tau2dep)
        %   eval([mfilename ' checksliders'])
      case 'reset' % restart, but keep global variable values
        eval(mfilename)
      case 'kbd'
        keyboard
      case 'bounds'
        v.scanvars(2)=v.nmax; v.scanvars(5)=v.p0; v.scanvars(8)=v.mini;
        v.scanars(11)=v.dpfac; v.scanvars(14)=v.taufac; v.scanvars(17)=v.tau1dep;
        v.scanvars(20)=v.tau2dep;
        prompt={'nmax: min' 'nmax: Initial value' 'nmax: max',...
          'p0: min', 'p0: Initial vaue' 'p0: max',...
          'Mini size (pa): min' 'Mini size (pA): Initial value' 'Mini size (pA): max',...
          'dp (facilitation): min' 'dp (facilitation): Initial vaue' 'dp (facilitation): max'};
        
        title='scan variables page 1 of 2 '; lineno=1;
        def={}; % v.scanvars=v.scanvars';
        for j=1:12 % size(v.scanvars,1);
          def=[def {num2str(v.scanvars(j))}];
        end
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        drawnow
        for j=1:size(inp,1); x(j,1)=str2num(inp{j}); end
        
        prompt={'tau (facilitation decay): min' 'tau (facilitation decay) Initial vaue' 'tau (facilitation decay): max',...
          'depn1 (% total): min' 'depn1 (% total): Initial value' 'depn1 (% total): max',...
          'tau1 (depression recovery): min' 'tau1 (depression recovery): Initial vaue' 'tau1 (depression recovery): max',...
          'tau2 (depression recovery): min' 'tau2 (depression recovery): Initial vaue' 'tau2 (depression recovery): max',...
          };
        title='scan variables page 2 of 2'
        def={}; lineno=1;
        for j=13:size(v.scanvars,2);
          def=[def {num2str(v.scanvars(j))}];
        end
        inp=inputdlg(prompt,title,lineno,def);
        if isempty(inp); return; end
        drawnow
        for j=1:size(inp,1); x(j+12,1)=str2num(inp{j}); end
        v.scanvars=x';
        
      case 'optim' % optimization routines
        optimmethod=get(gco,'tag'); % which optimization button was clicked?
        if ~strcmp(optimmethod,v.lastoptimmethod); v.fxmin=999999;end
        v.lastoptimmethod=optimmethod;
        set(gco,'backgroundcolor',[1 0 0]) % color button red
        drawnow
        v.scanvars(2)=v.nmax; v.scanvars(5)=v.p0; v.scanvars(8)=v.mini;
        v.scanars(11)=v.dpfac; v.scanvars(14)=v.taufac;
        v.scanvars(17)=v.depn1; v.scanvars(20)=v.tau1dep;
        v.scanvars(23)=v.tau2dep;
        x=v.scanvars;
        lb=[x(1) x(4) x(7) x(10) x(13) x(16) x(19) x(22)]; % lower bounds
        ub=[x(3) x(6) x(9) x(12) x(15) x(18) x(21) x(24)]; % upper bounds
        x0=[x(2) x(5) x(8) x(11) x(14) x(17) x(20) x(23)]; % starting values
        nvars=size(x0,2); v.optim=1; v.nn=1;
        switch optimmethod
          case 'optim_ps' % PatternSearch'
            try; options=v.psoptions; catch; options=psoptimset; end
            disp('Using Pattern Search method...')
            disp(options)
            [x fval] = patternsearch(@opt, x0,[],[],[],[],lb,ub,[],options);
            
          case 'optim_ga' % GeneticAlgorithm'
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm method...')
            disp(options)
            [x fval] = ga(@opt,nvars,[],[],[],[],lb,ub,[],options);
            
          case 'optim_sa' % SimulatedAnnealing'
            try; options=v.saoptions; catch; options=saoptimset; end
            disp('Using Simulated Annealing method...')
            disp(options)
            [x fval] = simulannealbnd(@opt,x0,lb,ub,options);
            
          case 'optim_gs' % global search optimization
            try; options=v.gsoptions; gs=v.gs;
            catch; options=optimset; gs=GlobalSearch;
            end
            problem = createOptimProblem('fmincon','x0',x0,...
              'objective',@opt,'lb',lb,'ub',ub,'options',options);
            disp('Using Global Search method...')
            disp(options)
            [x fval]=run(gs,problem)
            
          case 'optim_ms'
            try; options=v.msoptions; catch; options=optimset; end
            problem = createOptimProblem('fmincon','objective', @opt,...
              'x0',x0,'lb',lb,'ub',ub,'options',options);
            ms = MultiStart; nruns=200;
            disp('Using MultiSearch method...')
            disp(options)
            [x,fval] = run(ms,problem,nruns);
            
          case 'optim_gamo' % genetic alogrithm multiple objectives
            v.optim=2; % multiobj
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm MultiObjectives method...')
            disp(options)
            [X fval]= gamultiobj(@opt,nvars,[],[],[],[],lb,ub,options);
            
            v.res=[fval X]; %; v.fval=fval;
            str='Col 1 & 2 = pareto front vals. Col 3-7 = variable values';
            dlmwrite(['junk.txt'],[v.res],'\t')
            edit ('junk.txt'); drawnow
            disp(str)
            
            eval([mfilename ' checksliders'])
            eval([mfilename ' setvals'])
            sz=size(v.res,1); v.optim=0;
            for gamores=1:size(v.res,1)
              pause
              x=v.res(gamores,3:end);
              v.nmax=x(1); v.p0=x(2); v.mini=x(3); v.dpfac=x(4);
              v.taufac=x(5); v.depn1=x(6); v.tau1dep=x(7);v.tau2dep=x(8);
              disp([num2str(gamores) ' / ' num2str(sz)])
              eval([mfilename ' setvals'])
              eval([mfilename ' setup_ak2'])
            end % for gamores...
            
            return
            
        end % switch optimmethod        disp('Done')
        set(findobj('userdata','optim_button'),'backgroundcolor',v.bkg)
        
        drawnow
        x=v.xmin; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        v.nmax=x(1); v.p0=x(2); v.mini=x(3); v.dpfac=x(4);
        v.taufac=x(5); v.depn1=x(6); v.tau1dep=x(7);v.tau2dep=x(8);
        v.optim=0;
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak2'])
        % v.optim=0;
        
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
                'InitialTemperature'}
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
        
      case 'setup_ak2'
        %    v.dat=zeros(size(v.obs,1),1); % times of events
        
        axes(vh.axes1)
        grid on
        if ~v.optim
          x(1)=v.nmax; x(2)=v.p0; x(3)=v.mini; x(4)=v.dpfac; x(5)=v.taufac;
          x(6)=v.depn1; x(7)=v.tau1dep; x(8)=v.tau2dep;
          fval=opt(x);
          str=[v.fxname '= ' num2str(v.fx) char(10),... % round(100*v.fx)/100) char(10),...
            'Min.' v.fxname '= ' num2str(v.fxmin)]; % round(100*v.fxmin)/100)];
          set(vh.results,'string',str)
        end
        
        axes(vh.axes1)
        set(vh.line01obs,'xdata',v.obs(:,1),'ydata',v.obs(:,2))%,'color',[1 0 0],...
        % 'linestyle','-','marker','o','MarkerSize',2); % was 1 0.6 0.6
        set(vh.line01dat,'xdata',v.obs(:,1),'ydata',v.dat(:,2)) %,'color',[0 1 0],...
        % 'linestyle','-','marker','o', 'MarkerSize',2);
        
        
        axes(vh.axes2)
        mx=max(max(v.obs(:,2)),max(v.dat(:,2)));
        set(gca,'xlim',[0 mx],'ylim', [0 mx]);
        p=polyfit(v.obs(:,2),v.dat(:,2),1);
        xlimit=get(gca,'xlim'); y1=p(1)*xlimit(1)+p(2); y2=p(1)*xlimit(2)+p(2);
        set(vh.line02obsdat,'xdata',v.obs(:,2),'ydata',v.dat(:,2))
        set(vh.line02linreg,'xdata',[xlimit],'ydata',[y1 y2])
        set(vh.line02ident,'xdata',[0 mx],'ydata',[0 mx])
        
        axes(vh.axes3) % x=interval y=diff(obs-calc)
        x=v.dt;
        y=v.obs(:,2)-v.dat(:,2);
        set(vh.line03dtobs,'xdata',x,'ydata',y)
        p=polyfit(x,y,1);
        xlimit=get(gca,'xlim'); y1=p(1)*xlimit(1)+p(2); y2=p(1)*xlimit(2)+p(2);
        set(vh.line03linreg,'xdata',[xlimit],'ydata',[y1 y2])
        
        grid on
        
        axes(vh.axes4) % amplitude histograms
        a=[v.obs(:,2) v.dat(:,2)];
        nbins=100;
        dx=max(a(:))/nbins;
        x=[0:dx:max(a(:))]';
        n=histc(a,x);
        set(vh.line04obs,'xdata',x,'ydata',n(:,1));
        set(vh.line04dat,'xdata',x,'ydata',n(:,2));
        set(vh.txt04obs,'position',[mean(a(:,1)),max(n(:,1))]) %,'+','color','red','FontSize',22);
        set(vh.txt04dat,'position',[mean(a(:,2)),max(n(:,1))]) %,'+','color','green','FontSize',22);
        rms_amphist=sum(sqrt((n(:,1)-n(:,2)).^2))/size(n,1);
        %rms_amphist=round(rms_amphist*1000)/1000;
        set(vh.txt04rms,'position',[dx*0.5*nbins,max(n(:))],'string',['rms diff= ' num2str(rms_amphist)])
        
        
        
        
      case 'checksliders'
        a=findobj(vh.hfig,'style','slider');
        for j=1: size(a,1)
          vv=get(a(j,1));
          val=vv.Value; mn=vv.Min; mx=vv.Max;
          if val<=mn; mn=mn-val; end
          if val>=mx; mx=mx+val; end
          set(a(j,1),'Min',mn,'Max',mx,'Value',val)
          eval([mfilename ' setvals'])
        end
        
    end % switch varargin
    
end % switch nargin
%%%%%%%%%%%%% SUBFUNCTIONS START HERE %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fval=opt(x);
global v vh

v.nmax=x(1); v.p0=x(2); v.mini=x(3); v.dpfac=x(4);
v.taufac=x(5); v.depn1=x(6); v.tau1dep=x(7); v.tau2dep=x(8);
df1=v.depn1/100;
c1=df1*(1-exp(-v.dt/v.tau1dep));
c2=(1-df1)*(1-exp(-v.dt/v.tau2dep));
c=c1+c2;
%c=1-exp(-v.dt./v.taudep); % fractional recovery, depn
d=exp(-v.dt./v.taufac); % fractional recovery, facil
nnow=v.nmax; pnow=v.p0;
for j=1:size(v.obs,1)
  dfn=v.nmax-nnow;
  nnow=(nnow+dfn*c(j));
  dfp=pnow-v.p0;
  pnow=v.p0+dfp*d(j);
  m=(nnow*pnow);
  nnow=min(v.nmax,max(0,nnow-m));
  pnow=max(0,min(1,pnow+v.dpfac));
  v.dat(j,2)=m*v.mini; % current
end

omitpts=11; % omit the first (omitpts-1) points from fitting
ddat=v.obs(omitpts:end,2)-v.dat(omitpts:end,2);

switch v.fxname
  case 'RMS'
    v.fx=sqrt(mean(ddat.^2));
  case '-CorrCoef'
    cc=-corr2(v.obs(omitpts:end,2),v.dat(omitpts:end,2));
    v.fx=cc(1,end);
    %  v.mini=v.mini*mean(v.obs(:,2))/mean(v.dat(:,2));
    %  x(6)=v.mini;
    %   disp(cc)
  case 'RMabs'
    v.fx=mean(abs(ddat));
  case '%_change' % sum(abs((obs-calc)/calc))/size(obs(:,1));
    v.fx=sum(abs(1-v.dat(:,2)./v.obs(:,2)))/size(v.obs,1);
  case 'amphist'
    a=[v.obs(omitpts:end,2) v.dat(omitpts:end,2)];
    nbins=100;
    dx=max(a(:))/nbins;
    xx=[0:dx:max(a(:))]';
    n=histc(a,xx);
    v.fx=sum(sqrt((n(:,1)-n(:,2)).^2))/size(n,1);
end

fval=v.fx;

if v.optim>1
  fval2=max(abs(v.obs(:,2)-v.dat(:,2)));
  fval=[fval; fval2];
  v.fx=(abs(fval(1))+abs(fval(2)))/2  ;
end

if v.fx<v.fxmin; % is this a new minimum?
  % disp(v.fxmin-v.fx)
  v.fxmin=v.fx;
  v.xmin=x;
  str=['Min.' v.fxname '= ' num2str(v.fxmin)]; % round(1000*v.fxmin)/1000)];
  set(vh.results,'string',str)
  if v.replot & v.optim
    eval([mfilename ' setvals'])
    eval([mfilename ' setup_ak2'])
  end
  drawnow
end % if v.fx<v.fxmin
v.nn=v.nn+1;
if ~mod(v.nn,1000); disp(v.nn); drawnow; end