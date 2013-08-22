function ak1 (varargin)
global v vh
more off
%clear all
switch nargin
  case 0
    close all
    h=openfig(mfilename,'reuse');
    vh=guihandles(h);
    
    % start value of the 5 variables
    v.imax=5000;
    v.p0=0.1;
    v.dpfac=0.02;
    v.taudep=1;
    v.taufac=0.2;
    
    % housekeeping variables
    v.rms=99999999; % same as fval
    v.rmsmin=v.rms; % minimum value
    v.replot=0; % replot (1) or not (0) during optimization
    v.cd=[]; % for loading text file of dat
    v.bkg=get(vh.hfig,'color'); % color of buttons
    v.makeaxes3=0; % for making the lower right graph
    v.multiobj=0; % genetic algorithm with multiple objectives (1) or not (0)
    
    % imax, p0, dpfac, taudep, taufac -
    % lower bound, start value, upper bound for each
    v.scanvars=[500 5000 10000 .02 .1 .8 0 .02 .2 .1 .1 5 .02 .05 .5 1]';
    
    % calculate dummy observed data
    v.t1=.001; % resolution (0.001= 1 ms)
    v.t2=120; % total duration (s)
    v.meanfreq=20; % mean frequency of events
    v.cutoff=v.meanfreq*v.t1; % fraction of timepts with response
    
    v.obs=[0:v.t1:v.t2-v.t1]'; % set up times of events
    b=rand(size(v.obs,1),1);
    v.obs(b>v.cutoff)=[];
    v.obs(:,2)=0;
    
    % create observed y values given the times determined above 
    v.dt=[0; diff(v.obs(:,1))];    
    x(5)=v.taufac; x(4)=v.taudep; x(3)=v.dpfac;
    x(2)=v.p0; x(1)=v.imax;
    fval=opt(x);
    v.obs(:,2)=v.dat(:,2);
        eval([mfilename ' setup_ak1'])
    eval([mfilename ' setvals'])
   
    
  case 1
    switch varargin{1}
      
      case 'replot' % replot toggle button (for showing optimization results)
        v.replot=~v.replot;
        str='off'; if v.replot; str='on'; end
        set(vh.replot,'string',['Replot ' str])
      case 'saveit' % save obs data to text file
         if isempty(v.cd); cd([matlabroot '']); end
        [fname,pname]=uiputfile('*.txt');
        a=v.obs;
        dlmwrite([pname,fname],a,'\t')               
        
      case 'loadit' % load data from text file
        % 2 columns: col 1= time (s); col 2= amplitude (any units)
        if isempty(v.cd); cd([matlabroot '']); end
        [fname,pname]=uigetfile('*.txt')
        v.obs=dlmread([pname fname]); % for .txt files
        if size(v.obs,2)~=2;
          disp(['File has ' num2str(size(v.obs,2)) ' columns. I need 2 columns - time and amplitude'])
          return
        end
        v.rmsmin=99999999;
        v.makeaxes3=0; v.t2=v.obs(end,1);
         v.dt=[0; diff(v.obs(:,1))]; 
        eval([mfilename ' setup_ak1'])
        
      case 'vars' % clicked on one of the 5 variable buttons (not sliders)
        eval([mfilename ' getvals'])
        prompt={'Imax' 'p0' 'dp (facilitation)' 'tau (recovery from depression)',...
          'tau (recovery from facilitation)'};
        title='variables'; lineno=1;
        def={num2str(v.imax) num2str(v.p0) num2str(v.dpfac),...
          num2str(v.taudep) num2str(v.taufac)};
        inp=inputdlg(prompt,title,lineno,def);
        v.imax=str2num(inp{1});
        v.p0=str2num(inp{2});
        v.dpfac=str2num(inp{3});
        v.taudep=str2num(inp{4});
        v.taufac=str2num(inp{5});
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak1'])
        
      case 'getvals' % clicked on one of 5 sliders
        v.imax=round(get(vh.imax_slider,'value'));
        v.p0=get(vh.p0_slider,'value');
        v.dpfac=get(vh.dpfac_slider,'value');
        v.taudep=get(vh.taudep_slider,'value');
        v.taufac=get(vh.taufac_slider,'value');
        
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak1'])
        
      case 'setvals' % set text on buttons, values on sliders
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
        
      case 'reset' % restart, but keep global variable values
        eval(mfilename)
        
      case 'kbd'
        keyboard
        
      case 'optim' % optimization routines
        optimmethod=get(gco,'tag'); % which optimization button was clicked?
        set(gco,'backgroundcolor',[1 0 0]) % color button red
        v.multiobj=0;
        
        % set up inputdlg
        v.scanvars(2)=v.imax; v.scanvars(5)=v.p0;
        v.scanvars(8)=v.dpfac; v.scanvars(11)=v.taudep; v.scanvars(14)=v.taufac;
        v.rmsmin=1e12;
        prompt={'Imax: min' 'Imax: Initial value' 'Imax: max',...
          'p0: min', 'p0: Initial vaue' 'p0: max',...
          'dp (facilitation): min' 'dp (facilitation): Initial vaue' 'dp (facilitation): max',...
          'tau (depression recovery): min' 'tau (depression recovery): Initial vaue' 'tau (depression recovery): max',...
          'tau (facilitation decay): min' 'tau (facilitation deay) Initial vaue',...
          'tau (facilitation decay): max'}; %
        title='scan variables'; lineno=1;
        def={};
        for j=1:size(v.scanvars,1);
          def=[def {num2str(v.scanvars(j,1))}];
        end
        inp=inputdlg(prompt,title,lineno,def);
        
        if isempty(inp); return; end
        drawnow
        eval([mfilename ' checksliders']) % in case value is <min or >max
        for j=1:size(inp,1); x(j,1)=str2num(inp{j}); end
        v.scanvars=x;
        
        lb=[x(1) x(4) x(7) x(10) x(13)]; % lower bounds
        ub=[x(3) x(6) x(9) x(12) x(15)]; % upper bounds
        x0=[x(2) x(5) x(8) x(11) x(14)]; % starting values
        nvars=size(x0,2);
        
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
            v.multiobj=1;
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm MultiObjectives method...')
            disp(options)
            [X fval]= gamultiobj(@opt,nvars,[],[],[],[],lb,ub,options);
            
            v.res=[fval X]; %; v.fval=fval;
            str='Col 1 & 2 = pareto front vals. Col 3-7 = variable values';
            dlmwrite(['junk.txt'],[v.res],'\t')
            edit ('junk.txt'); drawnow
            disp(str)
            set(findobj('tag',optimmethod),'backgroundcolor',v.bkg)
            v.imax=x(1); v.p0=x(2); v.dpfac=x(3); v.taudep=x(4); v.taufac=x(5);
            eval([mfilename ' checksliders'])
            eval([mfilename ' setvals'])
            return
            
        end % switch optimmethod        disp('Done')
        
        set(findobj('tag',optimmethod),'backgroundcolor',v.bkg)
        v.imax=x(1); v.p0=x(2); v.dpfac=x(3);
        v.taudep=x(4); v.taufac=x(5);
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_ak1'])
        
      case 'optim_setup'
        optimmethod=get(gco,'tag');
        switch optimmethod
          
          %Pattern search setup
          case 'ps_setup'
            try
              a=v.psoptions;
            catch
              v.ps1={'TolMesh' 'TolCon' 'TolX' 'TolFun',...
                'TolBind' 'MaxIter' 'MaxFunVals' 'TimeLimit',...
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
        
      case 'setup_ak1'
        
        if ~v.makeaxes3
          v.makeaxes3=1;
          axes(vh.axes3)
         
          
         % dobs=diff(v.obs(:,1)); dobs=[0; dobs];
          vh.line4=line('xdata',v.dt,'ydata',v.obs(:,2),'linestyle','none','marker','.');
          v.dat=zeros(size(v.obs,1),1); % times of events
          
          
        end
        axes(vh.axes1)
        delete(findobj(vh.axes1,'type','line'))
        set(gca,'ylimmode','auto','xlim',[0 v.t2]);
        grid on
        
        x(5)=v.taufac; x(4)=v.taudep; x(3)=v.dpfac;
        x(2)=v.p0; x(1)=v.imax;
        fval=opt(x);
        v.imax=x(1); v.p0=x(2); v.dpfac=x(3); v.taudep=x(4); v.taufac=x(5);
        
        str=['rms= ' num2str(round(100*v.rms)/100) char(10),...
          '. Min rms = ' num2str(round(100*v.rmsmin)/100)];
        set(vh.results,'string',str)
        
        axes(vh.axes2)
        delete(findobj(vh.axes2,'type','line'))
        mx=max(max(v.obs(:,2)),max(v.dat(:,2)));
        set(gca,'xlim',[0 mx],'ylim', [0 mx]);
        vh.line0=line('xdata',[0 mx],'ydata',[0 mx]);
        vh.line2=line('xdata',v.obs(:,2),'ydata',v.dat(:,2),'linestyle','none','marker','.');
        
        axes(vh.axes1)
        vh.line01=line('xdata',v.obs(:,1),'ydata',v.dat(:,2),'color',[0 0 0],...
          'linestyle','none','marker','.');
        vh.line0= line('xdata',v.obs(:,1),'ydata',v.obs(:,2),'color',[1 .6 .6],...
          'linestyle','none','marker','.');
        
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
v.taufac=x(5); v.taudep=x(4); v.dpfac=x(3);
v.p0=x(2); v.imax=x(1);
c=1-exp(-v.dt./v.taudep); % fractional recovery, depn
d=exp(-v.dt./v.taufac); % fractional recovery, facil
inow=x(1); pnow=x(2);
for j=1:size(v.obs,1)
  dfi=v.imax-inow;
  inow=round(inow+dfi*c(j));
  dfp=pnow-v.p0;
  pnow=v.p0+dfp*d(j);
  m=round(inow*pnow);
  inow=min(v.imax,max(0,inow-m));
  pnow=max(0,min(1,pnow+v.dpfac));
  v.dat(j,2)=m;
end
ddat=v.obs(:,2)-v.dat(:,2);
%ddat=ddat(400:600,1); % fit only the last points
v.rms=sqrt(mean(ddat.^2));
fval=v.rms;

if v.multiobj
  fval2=max(ddat);
  fval=[fval; fval2];
  v.rms=(abs(fval(1))+abs(fval(2)));
end

if v.rms<v.rmsmin; % is this a new minimum?
  v.rmsmin=v.rms;
  %  eval([mfilename ' calc'])
  str=['. Min rms = ' num2str(round(100*v.rmsmin)/100)];
  set(vh.results,'string',str)
  
  if v.replot
    eval([mfilename ' setvals'])
    eval([mfilename ' setup_ak1'])
  end
  drawnow
  
end % function fval=opt(x);