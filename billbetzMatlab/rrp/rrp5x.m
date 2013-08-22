function rrp5 (varargin)
% v.n has 4 columns: c1=time (pt)last exo; c2=# exo events; c3=p0; c4= p now
global v vh
more off
switch nargin
  case 0
    close all
    h=openfig(mfilename,'reuse');
    vh=guihandles(h);
    % main variables
    v.rrpgrow=0; v.recruitgrow=0; v.rrpmode=2;
    v.rrpmodestr={'random' 'gaussian' 'exponential'};
    v.rrpsize=1770; v.rrpavg=0.5; v.rrpstd=0.2; v.rrpskew=0;
    v.rtau=.2; v.rskew=0; v.deadtime=0; v.rthresh=0;
    v.pthreshtau=5;
    % bounds: v.rtau, rskew, deadtime, rthresh
    v.lb=[.01 0 0 0];
    v.ub=[.5 10 1 1];
    v.mx0=1; % max value to which p0 can grow
    v.npts=100; v.freq=100; v.repeat=1;
    v.bkg=get(vh.hfig,'color');
    v.nbins=100;
    v.histo=0;
    v.setup=0;
    v.ctr=1;
    v.fxname='rms'; v.fx2name='rms_plateau';
    v.fx=999999; v.fxmin=v.fx; v.optimctr=0;
    try; a=v.obs;
    catch;
      a=[0:0.01:0.99]'; b=rand(size(a,1),1);
      v.obs=[a b];
    end
    v.noisefac=0; % fractional change (max) in p0
    v.cd=[]; %  do we have a directory for saving?
    %   try; load('rrpvars.mat'); catch; end
    eval([mfilename ' setvals'])
    eval([mfilename ' setup_rrp'])
    opt
    v.obs(:,2)=v.mnow(:,3); % observed = calculated data
    eval([mfilename ' histogram'])
    eval([mfilename ' drawlines'])
    
  case 1
    switch varargin{:}
      case 'objfx'
        v.fxname=get(gco,'string');
        set(findobj('tag','objfx'),'BackgroundColor',v.bkg)
        set(gco,'BackgroundColor','red')
        v.fx=99999999; v.fxmin=v.fx;
        % eval([mfilename ' setup_ak2'])
        
      case 'vars'
        eval([mfilename ' getvals'])
        prompt={'RRP size',...
          'RRP p (mean)',...
          'RRP p (std dev)',...
          'recruit tau (s)',...
          'rrp p0 skew factor',...
          'recruit time skew factor',...
          'recycle dead time',...
          'recruit p thresh',...
          '# pts per run',...
          'noise factor?',...
          'max to which p0 can grow',...
          'pthreshtau'};
        title='variables'; lineno=1;
        def={num2str(v.rrpsize),...
          num2str(v.rrpavg),...
          num2str(v.rrpstd),...
          num2str(v.rtau),...
          num2str(v.rrpskew),...
          num2str(v.rskew),...
          num2str(v.deadtime),...
          num2str(v.rthresh),...
          num2str(v.npts),...
          num2str(v.noisefac),...
          num2str(v.mx0),...
          num2str(v.pthreshtau),...
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
        
        v.npts=str2num(inp{9});
        v.noisefac=str2num(inp{10});
        v.mx0=min(1,str2num(inp{11}));
        v.pthreshtau=str2num(inp{12});
        
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_rrp'])
        v.optim=0;
        if v.repeat==1; opt; end
        
      case 'getvals' % all sliders
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        v.rrpsize=round(get(vh.rrpsize_slider,'value'));
        v.rrpavg=get(vh.rrpavg_slider,'value');
        v.rrpstd=get(vh.rrpstd_slider,'value');
        v.rrpskew=get(vh.rrpskew_slider,'value');
        
        v.rtau=round(100*get(vh.rtau_slider,'value'))/100;
        v.rskew=get(vh.rskew_slider,'value');
        v.deadtime=get(vh.deadtime_slider,'value');
        v.rthresh=get(vh.rthresh_slider,'value');
        
        % v.rrptau=get(vh.rrptau_slider,'value');
        v.noisefac=get(vh.noise_slider,'value');
        v.pthreshtau=get(vh.pthreshtau_slider,'value');
        eval([mfilename ' setvals'])
        v.optim=0;
        if get(gco,'userdata') % non-rrp slider
          if ~v.setup; eval([mfilename ' setup_rrp']); end
          if v.repeat>1; return; end
          opt;
          eval([mfilename ' histogram'])
           if v.histo;
         eval([mfilename ' drawlines']);
          end
        else  % rrp slider
          eval([mfilename ' setup_rrp'])
        end
        
      case 'setvals'
     %   save('rrpvars.mat','v');
        set(vh.rrpsize_txt,'string',['RRP size= ' num2str(v.rrpsize)])
        set(vh.rrpavg_txt,'string',['RRP: p mean= ' num2str(v.rrpavg)])
        set(vh.rrpstd_txt,'string',['RRP: p std dev= ' num2str(v.rrpstd)])
        set(vh.rrpskew_txt,'string',['p dist skew= ' num2str(v.rrpskew)])
        
        set(vh.rtau_txt,'string',['recruit: tau= ' num2str(v.rtau)])
        set(vh.rskew_txt,'string',['recruit t skew= ' num2str(v.rskew)])
        set(vh.deadtime_txt,'string',['deadtime= ' num2str(v.deadtime)])
        set(vh.rthresh_txt,'string', ['p thresh=' num2str(v.rthresh)])
        
        set(vh.noise_txt,'string',['noise=' num2str(v.noisefac)]);
        set(vh.pthreshtau_txt,'string',['pthreshtau=' num2str(v.pthreshtau)])
        
         %A=checkslider(vh.plotfitA,'Slider A');
        checkslider(vh.rrpsize_slider,'RRP size= ',v.rrpsize)
        checkslider(vh.rrpavg_slider,'RRP: p mean= ',v.rrpavg)
        checkslider(vh.rrpstd_slider,'RRP: p std dev= ',v.rrpstd)
        checkslider(vh.rrpskew_slider,'p dist skew- ', v.rrpskew)
        checkslider(vh.rtau_slider,'recruite: tau= ',v.rtau)
        checkslider(vh.rskew_slider,'recruit: t skew= ',v.rskew)
        checkslider(vh.deadtime_slider,'deadtime= ',v.deadtime)
        checkslider(vh.rthresh_slider,'p thresh= ', v.rthresh)
        checkslider(vh.noise_slider,'noise= ', v.noisefac)
        checkslider(vh.pthreshtau_slider,'ptrheshtau= ',v.pthreshtau)
        
         set(vh.rrpsize_slider,'value',v.rrpsize)
        set(vh.rrpavg_slider,'value',v.rrpavg)
        set(vh.rrpstd_slider,'value',v.rrpstd)
        set(vh.rrpskew_slider,'value',v.rrpskew)
        
        set(vh.rtau_slider,'value',v.rtau)
        set(vh.rskew_slider,'value',v.rskew)
        set(vh.deadtime_slider,'value',v.deadtime)
        set(vh.rthresh_slider,'value',v.rthresh)
        
        set(vh.noise_slider,'value',v.noisefac)
        set(vh.pthreshtau_slider,'value',v.pthreshtau)
        
        str='no'; if v.rrpgrow; str='yes'; end
        set(vh.rrpgrow,'string',['RRP= ' str])
        str='no'; if v.recruitgrow; str='yes'; end
        set(vh.recruitgrow,'string',['Recruit= ' str])
        set(vh.rrpmode,'string',v.rrpmodestr{v.rrpmode})
        
      case 'reset'
        eval(mfilename)
        
      case 'rrpgrow'
        str1='no'; str2='off';
        v.rrpgrow=~v.rrpgrow; if v.rrpgrow; str1='yes'; str2='on'; end
        set(vh.rrpgrow,'string',['RRP = ' str1])
        %  set(vh.rrptau_txt,'visible',str2)
        %  set(vh.rrptau_slider,'visible',str2)
        if ~v.setup; eval([mfilename ' setup_rrp']); end
        if v.repeat>1; return; end
        opt
        eval([mfilename ' histogram'])
        eval([mfilename ' drawlines']);
        
      case 'recruitgrow'
        str1='no';
        v.recruitgrow=~v.recruitgrow; if v.recruitgrow; str1='yes'; end
        set(vh.recruitgrow,'string',['RRP = ' str1])
        if ~v.setup; eval([mfilename ' setup_rfrp']); end
        if v.repeat>1; return; end
        opt
        eval([mfilename ' histogram'])
        eval([mfilename ' drawlines']);
        
      case 'rrpmode'
        v.rrpmode=1+v.rrpmode; if v.rrpmode>3; v.rrpmode=1; end
        set(vh.rrpmode,'string',v.rrpmodestr{v.rrpmode})
        vis='on'; if v.rrpmode~=2; vis='off'; end
        set(vh.rrpstd_txt,'visible',vis)
        set(vh.rrpstd_slider,'visible',vis)
        eval([mfilename ' setup_rrp'])
        
      case 'histoonoff'
        v.histo=~v.histo;
        str='off'; if v.histo; str='on'; end
        set(vh.histoonoff,'string',['Plotall ' str])
        
      case 'repeat'
        v.repeat=round(get(vh.repeat_slider,'value'));
        set(vh.repeat_txt,'string',['repeat ' num2str(v.repeat)])
        set(vh.repeat_slider,'value',v.repeat)
        
      case 'kbd'
        keyboard
        
      case 'saveit'
        [fname,pname]=uiputfile;
        save([pname fname],'v');
        
      case 'loadit'
        try; if isempty(v.cd); cd([matlabroot '\work\data\']); end
        catch; v.cd=[]; end
        [fname,pname]=uigetfile('*')
        switch fname(end-2:end)
          case 'mat' % variables
            load([pname fname]); % for mat files
          case 'txt' % data
            v.obs=dlmread([pname fname]); % for .txt files
            if size(v.obs,2)~=2;
              disp(['File has ' num2str(size(v.obs,2)) ' columns. I need 2 columns - time and amplitude'])
              return
            end
            v.fxmin=99999999;
            v.xlimit=floor(v.obs(end,1)+1);
            axes(vh.axes5)
            delete(findobj(gca,'type','line'))
            set(vh.axes5,'xlim',[0 v.xlimit],'ylim',[0 max(v.obs(:,2))])
            %  vh.line5=line('xdata',v.obs(:,2),'ydata',v.mnow(:,3),...
            %    'color','red','marker','.','linestyle','none'); %
            %  axes(vh.axes1)
        end
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_rrp'])
        
      case 'axes5_yscale'
        yy=get(vh.axes5,'ylim');
        inp=inputdlg({'Ymax?'}, 'Ymax - graph 5', 1, {num2str(yy(2))});
        set(vh.axes5,'ylim',[yy(1) str2num(inp{1})])
        
      case 'go'
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        v.optim=0;
        if ~v.setup; eval([mfilename ' setup_rrp']); pause(0.1); end
        opt;
        eval([mfilename ' histogram'])
       % eval([mfilename ' drawlines'])
        
      case 'helpp'
        str=['p0 can grow?: ' char(10) char(10),...
          '{RRP= yes} means that initial p values can grow above ' char(10),...
          'their original (p0) values; growing to a maximum of 1, ' char(10),...
          'or to the value set by user (click on variable in green box).' char(10),...
          char(10) '{Recruit= yes} means that during rescruitment, ' char(10),...
          'p values can grow above p0.'];
        msgbox(str)
        
      case 'optim_bounds'
        prompt={'recruit tau lower bound' 'recruit tau UPPER bound',...
          'recruit tau skew lower bound' 'recruit tau skew UPPER bound',...
          'deadtime lower bound' 'deadtime UPPER bound',...
          'recruit thresh lower bound' 'recruit thresh UPPER bound'}';
        title='Lower and Upper bounds'; lineno=1;
        for j=1:2:size(v.lb,2)*2;
          def(j)={num2str(v.lb((j+1)/2))};
          def(j+1)={num2str(v.ub((j+1)/2))};
        end
        inp=inputdlg(prompt,title,lineno,def);
        for j=1:2:size(inp,1)
          v.lb((j+1)/2)=str2num(inp{j});
          v.ub((j+1)/2)=str2num(inp{j+1});
        end
        
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
      case 'optim'
        optimmethod=get(gco,'tag');
        set(vh.results,'string','')
        if isempty(v.obs); str='LOAD OBSERVED DATA';
          set(vh.results,'string',str); disp(str); return; end
        set(gco,'backgroundcolor',[1 0 0]); drawnow
        v.optimctr=0;
        v.replot=0; % replot each time new fxmin
        v.fxmin=1e12;
        x=[v.lb(1) v.rtau v.ub(1),...
          v.lb(2) v.rskew v.ub(2),...
          v.lb(3) v.deadtime v.ub(3),...
          v.lb(4) v.rthresh v.ub(4)]
       % if ~v.rrpgrow; x(13:15)=1; end % rrp slow
        v.scanvars=x; lb=[]; ub=[]; x0=[];
        for j=1:3:size(x,2)
          lb=[lb x(j)];
          ub=[ub x(j+2)];
          x0=[x0 x(j+1)];
        end
        nvars=size(x0,2);
        v.optim=1;
        
        switch optimmethod
          case 'optim_ps' % PatternSearch'
            try; options=v.psoptions; catch; options=psoptimset; end
            disp('Using Pattern Search method...')
            disp(options)
            [X fval] = patternsearch(@opt, x0,[],[],[],[],lb,ub,[],options);
            
          case 'optim_ga' % GeneticAlgorithm'
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm method...')
            disp(options)
            [X fval] = ga(@opt,nvars,[],[],[],[],lb,ub,[],options);
            
          case 'optim_sa' % SimulatedAnnealing'
            try; options=v.saoptions; catch; options=saoptimset; end
            disp('Using Simulated Annealing method...')
            disp(options)
            [X fval] = simulannealbnd(@opt,x0,lb,ub,options);
            
          case 'optim_gs' % global search optimization
            try; options=v.gsoptions; gs=v.gs;
            catch; options=optimset; gs=GlobalSearch;
            end
            problem = createOptimProblem('fmincon','x0',x0,...
              'objective',@opt,'lb',lb,'ub',ub,'options',options);
            disp('Using Global Search method...')
            disp(options)
            [X fval]=run(gs,problem)
            
          case 'optim_ms'
            try; options=v.msoptions; catch; options=optimset; end
            problem = createOptimProblem('fmincon','objective', @opt,...
              'x0',x0,'lb',lb,'ub',ub,'options',options);
            ms = MultiStart; nruns=200;
            disp('Using MultiSearch method...')
            disp(options)
            [X,fval] = run(ms,problem,nruns);
            
          case 'optim_gamo' % genetic alogrithm multiple objectives
            v.gamo={'rms' 'rms_plateau' 'rmabs' 'maxp'}
            prompt={'Choose 2 from these: 1=RMS, 2=RMS_plateau, 3=RMAbsolute, 4=Max_p'};
            title='Optim Genetic Algorithm Multiple Objectives'; lineno=1;
            def={'1  2'};
            inp=inputdlg(prompt,title,lineno,def);
            a=str2num(inp{:}); v.fxname=v.gamo{a(1)}; v.fx2name=v.gamo{a(2)};
            set(findobj('tag','objfx'),'BackgroundColor',v.bkg)
            set(findobj('string',v.fxname),'BackgroundColor','red')
            set(findobj('string',v.fx2name),'BackgroundColor','red')
        
            v.optim=2; nvars=size(x0,2);
            try; options=v.gaoptions; catch; options=gaoptimset; end
            disp('Using Genetic Algoritm MultiObjectives method...')
            disp(options)
            [X fval]= gamultiobj(@opt,nvars,[],[],[],[],lb,ub,options);
            set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
            v.res=sortrows([fval X],1);
            str=['Col 1 & 2 = pareto front vals.' char(10),...
              'c3=tau recruit' char(10),...
              'c4=recruit skew' char(10),...
              'c5=deadtime' char(10),...
              'c6=recruit thresh' char(10)];
            dlmwrite(['junk.txt'],[v.res],'\t')
            edit ('junk.txt'); drawnow
            disp(v.res)
            msgbox(str,'pareto','replace')
            set(vh.results,'fontsize',8,'string',str)
            eval([mfilename ' checksliders'])
            eval([mfilename ' setvals'])
            v.optim=0; v.histo=0;
            set(findobj('string',v.fx2name),'BackgroundColor',v.bkg)
            sz=size(v.res,1);
            for gamores=1:size(v.res,1)
              pause
              xx=v.res(gamores,3:end);
              v.rtau=xx(1);
              v.rskew=xx(2);
              v.deadtime=xx(3);
              v.rthresh=xx(4);
              opt
              disp([num2str(gamores) ' / ' num2str(sz)])
             % eval([mfilename ' go'])
            end % for gamores...
            return
        end % switch optimmethod
        
        disp('Done')
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        X=v.xmin;
        v.rtau=X(1);
        v.rskew=X(2);
        v.deadtime=X(3);
        v.rthresh=X(4);
        set(findobj('tag',optimmethod),'backgroundcolor',v.bkg)
        if v.histo; eval([mfilename ' histoonoff']); end
        v.optim=0;
        opt
        eval([mfilename ' histogram'])
        eval([mfilename ' drawlines'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %   case 'saveit'
        %   [fname,pname]=uiputfile;
        %  save([pname fname],'v');
        
      case 'setup_rrp'
        v.xlimit=1;
        if ~isempty(v.obs);
          v.xlimit=floor(v.obs(end,1)+1);
          v.npts=size(v.obs,1);
        end
        v.ylimit=[0 100];
        v.edges=[0:0.02:1]';
        v.xstep=1/v.freq;
        
        delete(findobj(vh.axes1,'type','line'))
        delete(findobj(vh.axes2,'type','patch'))
        delete(findobj(vh.axes3,'type','line'))
        delete(findobj(vh.axes4, 'type','patch'))
        delete(findobj(vh.axes6,'type','line'))
        delete(findobj(vh.axes10,'type','line'))
        set(vh.axes1,'xlim',[0 1],'ylim',v.ylimit)
        axes(vh.axes1)
        vh.line01=line('xdata', [0 0], 'ydata', [v.ylimit(1) v.ylimit(2)],'color','red');
        set(vh.axes2,'ylim',[0 1000])
        set(vh.axes3,'xlim',[0 v.xlimit],'ylim',[0 180])
        set(vh.axes4,'xlim',[0 v.xlimit])
        v.optim=0;
        v.ctr=1;
        v.dt=[0; diff(v.obs(:,2))]; v.minp=0.001;
        v.n=zeros(round(v.rrpsize),4);
        v.esites=ones(size(v.n,1),1); % ready for exo
        v.xstep=1/v.freq;
        v.mnow=[];
        % v.noise1=~v.optim*v.noisefac*randn(size(v.n,1),1);
        % noisey=(rand(size(v.n,1),1)-0.5)*2; % range is -1 to +1
        % v.noise1=~v.optim*v.noisefac*noisey; % range reduced by noisefac
        % v.res=0.001; % resolution (seconds)
        %  v.deadpts=v.deadtime*v.freq);
        v.colors={ 'c' 'b'  'm' 'y' 'b' 'g' 'r'};
        v.setup=1;
        % Calculate initial distribution of p values
        % c1=time of last exocytosis; c2=# exo events; c3=p0; c4= p now
        v.n(:,2)=0;  % # exo events
        
        % random or gaussian or expl
        a1=v.rrpavg*rand(size(v.n,1),1); % this will be used to replace negative p values
        switch v.rrpmode
          case 1 % random
            a0=rand(size(v.n,1),1);
            fac=v.rrpavg/mean(a0); a0=a0*fac;
            a=a0;
          case 2 % gaussian
            a0=randn(size(v.n,1),1);  % make p0 distribution
            a=a0*v.rrpstd;
            a=a+v.rrpavg;
            %       aa=v.rrpavg*rand(size(v.n,1),1); % random, not gaussian
            a(a<v.minp)=a1(a<v.minp); % spread negative values randomly over the lower half
          case 3 % expl
            tau=v.rrpavg;
            dx=1/size(v.n,1);
            x=[0:dx:1-dx]';
            %a0=min(1,max(v.minp,exp(-x/tau)+v.noise1)); %-v.noise2));
            a0=min(1,max(v.minp,exp(-x/tau)));
            a=a0;
        end
        b=a.^(v.rrpskew+1); % skew p0 towards higher values by raising to a power
        a=b*mean(a)/mean(b);
        a(a>1)=a1(a>1);
        a(a<v.minp)=a1(a<v.minp);
        v.n(:,3)=max(v.minp,min(1,a)); % p0
        setupnoise=0;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if setupnoise
          noisey=(rand(size(v.n,1),1)-0.5)*2; % range is -1 to +1
          v.noise1=~v.optim*v.noisefac*noisey; % range reduced by noisefac
          p=v.n(:,3);
          v.n(:,3)=min(1,max(0,p+p.*v.noise1)); % current p0
        end
        v.n(:,4)=v.n(:,3);
        
        z=sortrows(v.n(:,4),-1); % p values, highest first
        m1=max(1,round(v.obs(1,2))); % first m
        z2=min(size(z,1),round(m1/mean(z(1:min(m1,size(z,1))))));
        v.rthresh2=z(z2); % p value of mth AZ
        
        eval([mfilename ' histogram'])
        
      case 'histogram' % current distribution of p values
        sz=size(v.colors,2);
        %v.n2=v.n(v.esites>0,:); % eligibles only
        v.n2=v.n;
        p0=v.n2(v.n2(:,2)==0,4); % rrp
        p1=v.n2(v.n2(:,2)>0,4);  % recyc
        n1(:,1)=histc(p0,v.edges);
        n1(:,2)=histc(p1,v.edges);
        bar(v.edges,n1,'stacked');
        % color the bars
        zz=findobj(gca,'type','patch');
        for jj=size(zz,1):-1:1
          ncolor=mod(jj,sz)+4*~mod(jj,sz);
        end
        set(vh.axes1,'xlim',[0 1],'ylim',v.ylimit)
        
        axes(vh.axes1)
        vh.line01=line('xdata', [v.rthresh2(v.ctr) v.rthresh2(v.ctr)],'ydata',v.ylimit,'color','red');
        
        drawnow
        
      case 'drawlines'
        %   v.xx=v.obs(:,1); %[0:v.xstep:v.ctr/v.freq-v.xstep]';%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        axes(vh.axes1)
        vh.line01=line('xdata', [v.rthresh2(v.ctr) v.rthresh2(v.ctr)],'ydata',v.ylimit,'color','red');
        obs=v.obs(1:size(v.mnow,1),:);
        
        axes(vh.axes2)
        delete(findobj(vh.axes2,'type','patch'))
        hist(v.n(:,2),100)
        vv=get(gca);
        x=(vv.XLim(2)-vv.XLim(1))/3+vv.XLim(1);
        y=(vv.YLim(2)-vv.YLim(1))/2+vv.YLim(1);
        str=[num2str(sum(v.n(:,2)==0)) ' zeros'];
        delete(findobj(gca,'type','text'))
        text('position', [x,y], 'string',str)
        drawnow
        
        axes(vh.axes3)
        delete(findobj(vh.axes3,'type','line'))
        % vh.line5=line('xdata',v.xx,'ydata',v.mnow(:,5)/10,'color','black'); % n
        try
          vh.line3=line('xdata',obs(:,1),'ydata',v.mnow(:,3),'color','blue'); % m
          vh.line3=line('xdata',obs(:,1),'ydata',v.mnow(:,2),'color','green'); % rrp
          vh.line3a=line('xdata',obs(:,1),'ydata',v.mnow(:,1),'color',[0.5 0.5 0.5]); % m recyc
        catch; keyboard; end
        
        axes(vh.axes4)
        delete(findobj(gca,'type','patch'))
        hist(v.rectime,100)
        try; set(vh.axes4,'xlim',[0 max(v.rectime(:))]); catch; end
        
        axes(vh.axes5)
        delete(findobj(gca,'type','line'))
        drawnow
        grid on
        vh.line5a=line('xdata',obs(:,1),'ydata',obs(:,2),...
          'color','red','marker','.','linestyle','none');
        vh.line5b=line('xdata',obs(:,1),'ydata',v.mnow(:,3),...
          'marker','.','linestyle','none','color','black');
        drawnow
        
        axes(vh.axes6)
        try; set(gca,'xlim',[0 v.npts*1.1],'ylim',[0 max(max(v.obs(:,2), v.mnow(:,3)))])
        catch; end
        delete(findobj(gca,'type','line'))
        vh.line6=line('xdata',v.obs(1:size(v.mnow,1),2),'ydata',v.mnow(:,3),...
          'marker','none','linestyle','-');
        vh.line6a=line('xdata',[0 max(v.obs(:,2))],'ydata',[0 max(v.obs(:,2))]);
        
        
        axes(vh.axes10)
        delete(findobj(gca,'type','line'))
        % hist(v.rate,100)
        vh.line10=line('xdata',v.n(:,3),'ydata',v.rate,'linestyle','none','marker','.');
        axes(vh.axes1)
        drawnow
        
      case 'newvals'
        j=v.jctr;
        kk=round(size(v.mnow,1)/2)+1; % mid point
        x=v.obs(kk:end,1); x=x-x(1);
        y0calc=v.mnow(kk:end,3);
        a=polyfit(x,y0calc,1); % linear regression: a(1)=slope; a(2)=intercept
        yfit=a(1)*x+a(2); varcalc=var(y0calc-yfit);
        pcalc=1-varcalc/mean(y0calc);
        yobs=v.obs(kk:end,2);
        pobs=1-var(yobs)/mean(yobs); pobs=round(pobs*100)/100;
        mtot=sum(v.mnow(5:end,3));
        v.ff(j,2)=mtot;
        v.ff(j,3)=mean(y0calc);
        v.ff(j,4)=pcalc;
        y0calc=round(10*mean(v.ff(1:j,3)))/10;
        mtot=round(mean(v.ff(1:j,2)));
        pcalc=mean(v.ff(1:j,4));
        psd=round(100*std(v.ff(1:j,4)))/100;
        pcalc=round(pcalc*100)/100;
        
        str=['m(tot)= ' num2str(mtot) char(10),...
          'PLATEAU: ' char(10),...
          'm(avg)= ' num2str(y0calc) char(10),...
          'p(var_calc)= ' num2str(pcalc) ' (' num2str(psd) ' SD)' char(10),...
          'p(var_obs)= ' num2str(pobs)];
        set(vh.results,'string',str)
        axes(vh.axes1)
        eval([mfilename ' setvals'])
        eval([mfilename ' drawlines'])
        
    end % switch varargin
end % switch nargin

function fval=opt(x);
global v vh
if ~v.optim;
  x=[v.rtau v.rskew v.deadtime v.rthresh];
end
v.optimctr=v.optimctr+1;
v.ff=zeros(v.repeat,4); % fit, mean, variance
% no repeat for optim_gamo
if v.optim>1 % optim gamo
  fval=opt2(x);
  v.ff(1,1)=v.fx;
  nn=v.optimctr;
else % not optimgamo
  for j=1:v.repeat
    v.jctr=j;
    v.ff(j,1)=opt2(x);
    if ~v.optim; eval([mfilename ' newvals']); end
    drawnow
  end
  fval=mean(v.ff(:,1)); % v.ffsum/10;
  % v.optimctr=v.optimctr+1;
  nn=v.optimctr*v.repeat;
end
if ~mod(nn,50); disp([v.optimctr nn]); end
if v.fx<v.fxmin & v.optim
  % disp([mean(v.n(:,3)), std(v.n(:,3))])
  v.fxmin=v.fx;
  v.xmin=x;
  str=['fxmin= ' num2str(v.fxmin) char(10),...
    num2str(v.optimctr) ' ' num2str(nn)];
  set(vh.results,'string',str)
  eval([mfilename ' setvals'])
  eval([mfilename ' drawlines'])
end
%if ~v.optim; eval([mfilename ' newvals']); end


function fval=opt2(x);
global v vh
if v.optim
  v.rtau=x(1); v.rskew=x(2); v.deadtime=x(3); v.rthresh=x(4);
end
% v.n has 4 columns: c1=time last exo; c2=# exo events; c3=p0; c4= p now
v.n(:,4)=v.n(:,3);  % initialize p values
v.n(:,1:2)=0; % initialize time of last exo, # exo events
v.mnow=[];

%v.rate=v.n(:,3)*0 + v.rtau^-1;
v.rate=(v.n(:,3).^(v.rskew))/v.rtau; % rate of increase in p
%fac=mean(v.rate)*v.rtau;
%v.rate=v.rate/fac;

v.rectime=[];
% set m of first shock to ~match observed. Do this by setting p threshold
% to be same as that of the mth AZ. This effectively lowers p for first
% shock
z=sortrows(v.n(:,4),-1); % p values, highest first
m1=max(1,round(v.obs(1,2))); % first m
%v.rthresh0=z(m1); % p value of mth AZ
v.rthresh0=z(min(size(z,1),round(m1/mean(z(1:min(size(z,1),m1)))))); % avg p value of first m1 responses

x=[0:v.npts-1]';
v.rthresh2=(v.rthresh0-v.rthresh)*exp(-x/v.pthreshtau)+v.rthresh; % vector of values

for j=1:v.npts %%%%%%%%%%%%%%%%%%%%%
  tnow=v.obs(j,1);
  v.ctr=j;
  
  mx=v.n(:,3); % set max p value for each AZ
  if v.rrpgrow; mx(v.n(:,2)==0)=v.mx0; end
  if v.recruitgrow; mx(v.n(:,2)>0)=v.mx0; end
  % determine new p values
  mn=v.n(:,3); % set start p value, = p0 for virgins, 0 for others
  mn(v.n(:,2)>0)=0;
  y0=max(0,mx-mn); % driving force on expl recovery of p
  dtms=max(0,tnow-v.deadtime-v.n(:,1)); % length of time that p has been growing
  df=(1-exp(-dtms.*v.rate)).^v.rskew; % fractional rise of p
  %df=1-exp(-dtms.*v.rate); % fractional rise of p
  p=mn+y0.*df;
  noisey=(rand(size(v.n,1),1)-0.5)*2; % range is -1 to +1
  noisey(v.n(:,1)==0)=0; % virgins not noisy
  v.noise1=~v.optim*v.noisefac*noisey; % range reduced by noisefac
  v.n(:,4)=min(1,max(0,p+p.*v.noise1)); % current p
  
  % determine which sites are eligible for release (p> thresh)
  v.esites=ones(size(v.n,1),1);
  v.esites(v.n(:,4)<v.rthresh2(j))=0; % sites with p<thresh not eligible
  
  dt=tnow-v.n(:,1); % current time minus time of last exo
  v.esites(dt<v.deadtime & v.n(:,2)>0)=0; % sites inside deadtime not eligible
  % v.esites(v.n(:,2)>1)=0; % only 2 releases allowed per site
  
  neligible=sum(v.esites);
  
  c5=v.n(:,4);
  rsites=v.esites*0;  % find sites of release
  pavg=mean(c5(v.esites>0)); % avg p of all eligible sites
  rnd=rand(size(v.n,1),1); % rand -> randn
  rsites(v.n(:,4)>=rnd & v.esites>0)=1; % sites of release
  
  v.mnow(j,1)=sum(rsites(v.n(:,2)>0));  % mrecycled
  v.mnow(j,2)=sum(rsites(v.n(:,2)==0));  % mrrp
  v.mnow(j,3)=sum(rsites); % m
  % if j<50; disp([neligible v.rthreshnow v.mnow(j,3) v.obs(j,2)]); end%%%%%%%%%%%%%%%%
  v.mnow(j,4)=sum(v.n(:,2)==0)-v.mnow(j,2); % RRP remaining
  v.mnow(j,5)=neligible; % eligibles=n
  v.mnow(j,6)=pavg;
  v.mnow(j,7)=neligible*pavg; % predicted
  if tnow>v.deadtime; % time of last exo
    a=tnow-v.n(rsites>0 ,1);
    v.rectime=[v.rectime; a]; % list of all recycle times
  end
  
  % update time of exo
  v.n(rsites>0,1)=tnow; % col 1 of v.n updated for release sites
  
  if v.histo & ~v.optim;
    eval([mfilename ' histogram']);
    eval([mfilename ' drawlines'])
  end
  
  c2=v.n(:,2); % update release site exocytic count and reset p to zero
  c2(rsites>0)=c2(rsites>0)+1; % increment exocytic counter
  v.n(:,2)=c2;
  v.n(rsites>0,4)=v.minp; % p goes to zero after release
  
end % for j=.. %%%%%%%%%%%%%%%%%%%%%%%

kk=round(size(v.mnow,1)/2)+1; % mid point
switch v.fxname
  case 'rmabs'
    p1=kk; % include points startubg with p1 in calculating v.fx
    obs=v.obs(p1:end,2); calc=v.mnow(p1:end,3);
    v.fx=sum(abs(obs-calc))/size(obs,1);
  case {'rms' 'rms_plateau'}
    p1=kk; if strcmp(v.fxname,'rms'); p1=1; end
    obs=v.obs(p1:end,2); calc=v.mnow(p1:end,3);
    dd=(obs-calc).^2;
    v.fx=sqrt(sum(dd))/size(obs,1);
  case 'maxp'
    x=v.obs(kk:end,1); x=x-x(1);
    y0=v.mnow(kk:end,3);
    a=polyfit(x,y0,1); % linear regression: a(1)=slope; a(2)=intercept
    yfit=a(1)*x+a(2); varcalc=var(y0-yfit);
    p3=1-varcalc/mean(y0);
    p3=round(p3*100)/100;
    v.fx=-p3;
end
fval=v.fx;
if ~v.optim
  %  v.setup=0;
  eval([mfilename ' newvals'])
else % v.optim>0 (multi objectives)
  if v.optim>1
    switch v.fx2name
      case {'rms' 'rms_plateau'}
        p1=kk; if strcmp(v.fx2name,'rms'); p1=1; end
        obs=v.obs(p1:end,2); calc=v.mnow(p1:end,3);
        dd=(obs-calc).^2;
        fval2=sqrt(sum(dd))/size(obs,1);
      case 'maxp'
        x=v.obs(kk:end,1); x=x-x(1);
        y0=v.mnow(kk:end,3);
        a=polyfit(x,y0,1); % linear regression: a(1)=slope; a(2)=intercept
        yfit=a(1)*x+a(2); varcalc=var(y0-yfit);
        p3=1-varcalc/mean(y0);
        p3=round(p3*100)/100;
        fval2=-p3;
        if isnan(fval2); fval2=0; end
      case 'meandiff'
        p1=1; p2=kk;
        obsmean=mean(v.obs(p1:p2,2));
        calcmean=mean(v.mnow(p1:p2,3));
        fval2=abs(obsmean-calcmean);
    end
    fval=[fval; fval2];
    v.fx= (abs(fval(1))+abs(fval(2)))/2;
  end
end % switch v.optim
%******************************************************
function val=checkslider(hh,str,val);
h1=[hh '_slider']; h2=[hh '_txt'];
vv=get(h1); %vv.Value=val;
%if strcmp(vv.Visible,'off'),return; end
if val>=vv.Max || val<=vv.Min
  dv=vv.Max-vv.Min;
  mn=max(0,val-0.5*dv); mx=val+0.5*dv;
  set(h1,'Min',mn,'Max',mx,'Value',val) %,'SliderStep',ss)
  set(h2,'string',[str num2str(val)])
end







