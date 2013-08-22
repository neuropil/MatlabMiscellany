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
    v.rrpgrow=0; v.recruitgrow=0; v.rrpmode=1;
    v.rrpmodestr={'random' 'gaussian' 'exponential'};
    % v.rrpsize=1770; v.rrpavg=0.5; v.rrpstd=0.2; v.rrpskew=0;
    %  v.rtau=.2; v.rskew=0; v.deadtime=0; v.rthresh=0;
    v.pthreshtau=5; v.fitstr={}; v.newrrp=0; v.slctall=0;
    
    % v.var has 4 columns: c1=var name; c2=default val; c3=lb; c4=ub
    v.var={'rrpsize' 1700 100 5000;,...
      'rrpavg' 1770 0 1;,...
      'rrpstd' 0.2 0 1;,...
      'rrpskew' 0 0 10;,...
      'rtau' 0.2 0.001 1;,...
      'rskew' 0.5 0 100;,...
      'deadtime' 0 0 .5;,...
      'rthresh' 0 0 1;,...
      'pthreshtau' 5 0 20;,...
      'noisefac' 0 0 2};
    
    v.varlist_txt={}; v.varlist_slider={};
    for j=1:size(v.var,1)
      varname=v.var{j,1}; % variable name (string)
      v.varlist_txt=[v.varlist_txt [varname '_txt']];
      v.varlist_slider=[v.varlist_slider [v.var{j,1} '_slider']];
      vslider=get(eval(['vh.' varname '_slider'])); h=['vh.' varname '_txt'];
      set(eval(h),'string',[varname '= ' num2str(vslider.Value)])
      eval(['v.' varname '= vslider.Value;'])
    end
    
    v.mx0=1; % max value to which p0 can grow
    v.npts=100; v.freq=100; v.repeat=1;
    v.bkg=get(vh.hfig,'color');
    v.nbins=100; v.histo=0; v.setup=0; v.ctr=1; v.pareto=[];
    v.fxname='rms'; v.fx2name='rms_plateau';
    v.fx=999999; v.fxmin=v.fx; v.optimctr=0; v.optim=0;
    try; a=v.obs;
    catch;
      a=[0:0.01:0.99]'; b=rand(size(a,1),1)/2.5;
      c=50+50*(exp(-a/0.2)+b);
      v.obs=[a c];
    end
    v.noisefac=0; % fractional change (max) in p0
    v.cd=[]; %  do we have a directory for saving?
    %   try; load('rrpvars.mat'); catch; end
    v.startup=1;
    eval([mfilename ' setvals'])
    eval([mfilename ' setup_rrp'])
    opt(v.optim);
    % v.obs(:,2)=v.mnow(:,3); % observed = calculated data
    eval([mfilename ' histogram'])
    eval([mfilename ' drawlines'])
    
  case 1
    switch varargin{:}
      case 'switchyard'
        vv=get(gco);
        if strcmp(vv.Style,'radiobutton'); eval([mfilename ' radiobutton'])
        else;
          eval([mfilename ' ' vv.Tag]); end
        
      case 'objfx'
        v.fxname=get(gco,'string');
        set(findobj('tag','objfx'),'BackgroundColor',v.bkg)
        set(gco,'BackgroundColor','red')
        v.fx=99999999; v.fxmin=v.fx;
        
      case v.varlist_txt % for changing current values of variables
        %  case 'vars'
        eval([mfilename ' ' v.varlist_slider{1}])
        prompt=v.var(:,1);
        def={};
        for j=1:size(v.var,1)
          def=[def num2str(eval(['v.' v.var{j,1}]))];
        end
        title='variables'; lineno=1;
        inp=inputdlg(prompt,title,lineno,def);
        for j=1:size(inp)
          eval(['v.' prompt{j} '=' inp{j}]);
        end
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_rrp'])
        v.optim=0;
        if v.repeat==1; opt(v.optim); end
        
      case v.varlist_slider % get values of all sliders
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        for j=1:size(v.var,1)
          a=eval(['get(vh.' v.var{j,1} '_slider);']);
          eval(['v.' v.var{j,1} '=round(a.Value*1000)/1000;']);
        end
        eval([mfilename ' setvals'])
        v.optim=0;
        if get(gco,'userdata') % non-rrp slider
          if ~v.setup; eval([mfilename ' setup_rrp']); end
          if v.repeat>1; return; end
          opt(v.optim);
          eval([mfilename ' histogram'])
          if v.histo;
            eval([mfilename ' drawlines']);
          end
        else  % rrp slider
          eval([mfilename ' setup_rrp'])
        end
        
      case 'setvals' % check sliders, set values
        for j=1:size(v.var(:,1))
          %checkslider(v.var{j,1}) % be sure Value is >=Min and <=Max
          hh=v.var{j,1};
          h1=['vh.' hh '_slider']; h2=['vh.' hh '_txt'];
          val=v.(hh);
          vv=get(eval(h1)); vv.Value=val;
          %if strcmp(vv.Visible,'off'),return; end
          if val>=vv.Max % || val<=vv.Min
            dv=vv.Max-vv.Min; % range doesn't change
            % vv.Min=max(0,val-0.5*dv);
            vv.Max=val+abs(vv.Max); % 0.5*dv;
            %   if vv.Min==0; vv.Max=dv; end
          end
          set((eval(h1)),'Min',vv.Min,'Max',vv.Max,'Value',vv.Value); %,'SliderStep',ss)
          set((eval(h2)),'string',[hh '= ' num2str(val)]);
        end
        drawnow
        str='no'; if v.rrpgrow; str='yes'; end
        set(vh.rrpgrow,'string',['RRP= ' str])
        str='no'; if v.recruitgrow; str='yes'; end
        set(vh.recruitgrow,'string',['Recruit= ' str])
        set(vh.rrpmode,'string',v.rrpmodestr{v.rrpmode})
        
      case 'axes_scale'
        a=get(gca,'ylimmode');
        %delete(findobj(gca,'type','line'))
        switch a
          case 'auto' % change to manual
            a=get(gca);
            prompt={'ymin' 'ymax'};
            title='Y Axes limits'; lineno=1;
            def={num2str(a.YLim(1)) num2str(a.YLim(2))};
            inp=inputdlg(prompt,title,lineno,def);
            axes(gca)
            set(gca,'ylim',[str2num(inp{1}) str2num(inp{2})])
            drawnow
          case 'manual' % change to auto
            set(gca,'ylimmode','auto')
        end
      case 'reset'
        eval(mfilename)
        
      case 'rrpgrow'
        str1='no'; str2='off';
        v.rrpgrow=~v.rrpgrow; if v.rrpgrow; str1='yes'; str2='on'; end
        set(vh.rrpgrow,'string',['RRP = ' str1])
        if ~v.setup; eval([mfilename ' setupf_rrp']); end
        if v.repeat>1; return; end
        opt(v.optim)
        eval([mfilename ' histogram'])
        eval([mfilename ' drawlines']);
        
      case 'recruitgrow'
        str1='no';
        v.recruitgrow=~v.recruitgrow; if v.recruitgrow; str1='yes'; end
        set(vh.recruitgrow,'string',['RRP = ' str1])
        if ~v.setup; eval([mfilename ' setup_rfrp']); end
        if v.repeat>1; return; end
        opt(v.optim)
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
        
      case 'repeat_slider'
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
        [fname,pname]=uigetfile('*');
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
        
      case 'go'
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        v.optim=0;
        if ~v.setup; eval([mfilename ' setup_rrp']); pause(0.1); end
        opt(v.optim);
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
        prompt={}; def={};
        for j=1:size(v.var,1)
          prompt=[prompt, v.var(j,1)];
          def=[def, [num2str(v.var{j,3}) '    ' num2str(v.var{j,4})]];
        end
        title='Lower & Upper bounds'; lineno=1;
        inp=inputdlg(prompt,title,lineno,def);
        for j=1: size(v.var,1)
          a=str2num(inp{j});
          v.var(j,3)={a(1)}; v.var(j,4)={a(2)};
        end
        drawnow
      case 'select_all'
        v.slctall=~v.slctall;
        a=findobj('style','radiobutton');
        val=0; if v.slctall; val=1; end
        set(a,'value',val)
        eval([mfilename ' radiobutton'])
        
      case 'radiobutton'
        if ~isempty(v.pareto);
          inp=questdlg('This will erase the pareto values. OK?','Erase Pareto values?');
          if ~strcmp(inp,'Yes'); return; end
        end
        v.pareto=[]; try; delete(vh.line11);
          set(vh.pareto_txt,'string','Pareto front')
        catch; end
        a=findobj('style','radiobutton');
        v.fitstr={}; nn=0; v.newrrp=0;
        for j=1:size(a,1)
          rad=get(a(j));
          if rad.Value; nn=nn+1;
            v.fitstr(nn)={['v.' rad.Tag]};
            if ~rad.UserData; v.newrrp=1; end
            % disp([rad.Tag rad.UserData])
          end
        end
        
      case 'pareto' % display pareto results
        if isempty(v.pareto); msgbox('First run Genetic Alg Multi Obj')
          return; end
        sz=size(v.pareto);
        str=['Pareto front has ' num2str(sz(1)) ' point(s)' char(10),...
          'Array contains ' num2str(sz(1)) ' row(s) and ' num2str(sz(2)) ' columns' char(10),...
          'Col 1 & 2 = pareto front values' char(10)];
        for j=1:size(v.fitstr,2)
          str=[str 'col ' num2str(j+2) '= ' v.fitstr{j} char(10)];
        end
        disp(v.pareto);
        prompt={[str ' Which row do you want to see? (0=all, negative number to display the array)']};
        title='Pareto front'; lineno=1; def={'0'};
        inp=inputdlg(prompt,title,lineno,def); if isempty(inp); return; end
        r0=str2num(inp{1});
        if r0<0
          dlmwrite(['junk.txt'],[v.pareto],'\t')
          edit ('junk.txt'); drawnow
        else
          r1=r0; r2=r1; if r1==0; r1=1; r2=size(v.pareto,1); end
          for looper=r1:r2
            xx=v.pareto(looper,3:end);
            for j=1:size(v.fitstr,2)
              eval([v.fitstr{j} '= xx(j);']) % fitstr members begin with 'v.'
            end
            eval([mfilename ' setvals'])
            eval([mfilename ' go'])
            if ~str2num(inp{1});
              str=['Row ' num2str(looper) '/' num2str(r2) ' in pareto'];
              h=msgbox(str,'replace');
              waitfor(h)
              try; delete(h); catch; end
            end
          end % for looper
        end % if r0<0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % case 'optim_setup'
      case {'ps_setup' 'ga_setup' 'sa_setup' 'gs_setup' 'ms_setup' 'gsms_setup' 'gamo_setup'}
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
            try a=v.gsms1;f
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
        
        %  case 'optim'
      case {'optim_ps' 'optim_ga' 'optim_sa' 'optim_gs' 'optim_ms' 'optim_gamo'}
        if isempty(v.fitstr); msgbox('No varibles selected for fitting - click radiobutton(s)');   return; end
        optimmethod=get(gco,'tag');
        set(vh.results,'string','')
        if isempty(v.obs); str='LOAD OBSERVED DATA';
          set(vh.results,'string',str); disp(str); return; end
        set(gco,'backgroundcolor',[1 0 0]); drawnow
        v.optimctr=0; v.fxmin=1e12;
        lb=[]; ub=[]; % set up variables, bounds
        for j=1:size(v.fitstr,2)
          eval(['x(j)=' v.fitstr{j}]);
          k=1;
          while ~strcmp(['v.' v.var{k,1}], v.fitstr(j)); k=k+1; end
          lb=[lb v.var{k,3}];  ub=[ub v.var{k,4}];
        end
        x0=x; %[v.rtau v.rskew v.deadtime v.rthresh];
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
            v.pareto=sortrows([fval X],1);
            
            str=['Col 1 & 2 = pareto front values' char(10)];
            for j=1:size(v.fitstr,2)
              str=[str 'col ' num2str(j+2) '= ' v.fitstr{j} char(10)];
            end
            axes(vh.axes11); try; delete(vh.line11); catch; end
            vh.line11=line('xdata',v.pareto(:,1),'ydata',v.pareto(:,2),'linestyle','-','marker','o');
            set(vh.pareto_txt,'string',['Pareto front' char(10) 'x=' v.fxname char(10) ' y=' v.fx2name])
            axes(vh.axes1)
            
            set(vh.results,'fontsize',8,'string',str)
            eval([mfilename ' setvals'])
            v.optim=0; v.histo=0;
            set(findobj('string',v.fx2name),'BackgroundColor',v.bkg)
            eval([mfilename ' pareto'])
        end % switch optimmethod
        
        disp('Done')
        beep
        set(findobj('userdata',999),'backgroundcolor',v.bkg) % no red buttons
        x=v.xmin;
        for j=1:size(x,2)
          eval([v.fitstr{j} '=x(j);'])
        end
        eval([mfilename ' setvals'])
        set(findobj('tag',optimmethod),'backgroundcolor',v.bkg)
        if v.histo; eval([mfilename ' histoonoff']); end
        v.optim=0;
        opt(v.optim);
        eval([mfilename ' histogram'])
        eval([mfilename ' drawlines'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
      case 'setup_lines'
        delete(findobj('type','line'))
        delete(findobj('type','patch'))
        set(vh.axes3,'ButtonDownFcn',[mfilename ' axes_scale'])
        set(vh.axes5,'ButtonDownFcn',[mfilename ' axes_scale'])
        set(vh.axes6,'ButtonDownFcn',[mfilename ' axes_scale'])
        axes(vh.axes1); vh.line01=line('xdata',[0 0],'ydata',[0 1],'color','red');
        set(vh.axes1,'xlim',[0 1]) %,'ylim',[0 150]) % 'ylimmode','auto')
        set(vh.axes2,'ylim',[0 1000])
        axes(vh.axes3)
        % set(vh.axes1,'ButtonDownFcn',[mfilename ' axes_scale'])
        vh.line3=line;
        vh.line3a=line;
        vh.line3b=line;
        
        axes(vh.axes5); grid on
        vh.line5a=line;
        vh.line5b=line;
        axes(vh.axes6)
        set(gca,'xlim',[0 max(v.obs(:,2))])
        vh.line6=line('marker','none','linestyle','-');
        vh.line6a=line;
        axes(vh.axes10)
        vh.line10=line;
        
        axes(vh.axes11)
        vh.line11=line;
        
      case 'setup_rrp'
        v.xlimit=1;
        if ~isempty(v.obs);
          v.xlimit=floor(v.obs(end,1)+1);
          v.npts=size(v.obs,1);
        end
        v.ylimit=[0 100];
        v.edges=[0:0.02:1]';
        v.xstep=1/v.freq;
        %  set(vh.axes3,'xlim',[0 v.xlimit],'ylim',[0 180])
        %       set(vh.axes4,'xlim',[0 v.xlimit])
        
        set(vh.axes1,'xlim',[0 1]); %,'ylimmode','auto'); % v.ylimit)
        axes(vh.axes1)
        v.ctr=1;
        v.dt=[0; diff(v.obs(:,2))]; v.minp=0.001;
        v.n=zeros(round(v.rrpsize),4);
        v.esites=ones(size(v.n,1),1); % ready for exo
        v.xstep=1/v.freq;
        v.mnow=[];
        v.colors={ 'c' 'b'  'm' 'y' 'b' 'g' 'r'};
        v.setup=1;
        % Calculate initial distribution of p values
        % c1=time of last exocytosis; c2=# exo events; c3=p0; c4= p now
        v.n(:,2)=0;  % # exo events
        
        % random or gaussian or expl
        a1=v.rrpavg*rand(size(v.n,1),1); % this will bfe used to replace negative p values
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
        %  if  ~v.optim
        %if v.startup;
        eval([mfilename ' setup_lines']);
        v.startup=0;
        %end
        eval([mfilename ' histogram'])
        %  end
        
      case 'histogram' % current distribution of p values
        axes(vh.axes1)
        vv=get(gca);
        sz=size(v.colors,2);
        %v.n2=v.n(v.esites>0,:); % eligibles only
        v.n2=v.n;
        p0=v.n2(v.n2(:,2)==0,4); % rrp
        p1=v.n2(v.n2(:,2)>0,4);  % recyc
        n1(:,1)=histc(p0,v.edges);
        n1(:,2)=histc(p1,v.edges);
        bar(v.edges,n1,'stacked')
        % color the bars
        zz=findobj(gca,'type','patch');
        for jj=size(zz,1):-1:1
          ncolor=mod(jj,sz)+4*~mod(jj,sz);
        end
        % the line must be recreated because 'bar' somehow deletes it!
        v.ylimit=vv.YLim; %get(vh.axes1,'ylim'); %v.ylimit=yy(2);
        vh.line01=line('xdata', [v.rthresh2(v.ctr) v.rthresh2(v.ctr)],'ydata',[0 max(sum(n1'))],'color','red');
        set(vh.axes1,'xlim',[0 1],'ylim',[vv.YLim(1) vv.YLim(2)])
         set(vh.axes1,'ButtonDownFcn',[mfilename ' axes_scale'])
        drawnow
        
      case 'drawlines'
        %     set(vh.line01,'xdata', [v.rthresh2(v.ctr) v.rthresh2(v.ctr)],'ydata',v.ylimit,'color','red');
        obs=v.obs(1:size(v.mnow,1),:);
        
        axes(vh.axes2)
        vv=get(gca);
        hist(v.n(:,2),100)
        % vv=get(gca);
        x=(vv.XLim(2)-vv.XLim(1))/3+vv.XLim(1);
        y=(vv.YLim(2)-vv.YLim(1))/2+vv.YLim(1);
        str=[num2str(sum(v.n(:,2)==0)) ' zeros'];
        delete(findobj(gca,'type','text'))
        text('position', [x,y], 'string',str)
        set(vh.axes2,'ylim',[vv.YLim(1) vv.YLim(2)],'ButtonDownFcn',[mfilename ' axes_scale'])
        set(vh.line3,'xdata',obs(:,1),'ydata',v.mnow(:,3),'color','blue'); % m
        set(vh.line3a,'xdata',obs(:,1),'ydata',v.mnow(:,2),'color','green'); % rrp
        set(vh.line3b,'xdata',obs(:,1),'ydata',v.mnow(:,1),'color',[1 0 0]); % m recyc
        drawnow
        
        axes(vh.axes4)
        hist(v.rectime,100)
        try; set(vh.axes4,'xlim',[0 max(v.rectime(:))]); catch; end
        set(vh.axes4,'ButtonDownFcn',[mfilename ' axes_scale'])
        
        drawnow
        set(vh.line5a,'xdata',obs(:,1),'ydata',obs(:,2),...
          'color','red','marker','.','linestyle','none');
        set(vh.line5b,'xdata',obs(:,1),'ydata',v.mnow(:,3),...
          'marker','.','linestyle','none','color','black');
        drawnow
        
        axes(vh.axes6)
        % set(gca,'xlim',[0 v.npts*1.1],'ylim',[0 max(max(v.obs(1:size(v.mnow,1),2), v.mnow(:,3)))])
        set(vh.line6,'xdata',v.obs(1:size(v.mnow,1),2),'ydata',v.mnow(:,3))
        set(vh.line6a,'xdata',[0 max(v.obs(1:size(v.mnow,1),2))],'ydata',[0 max(v.obs(:,2))]);
        
        axes(vh.axes10)
        % hist(v.rate,100)
        % set(vh.axes10,'ylim',[0 20],'xlimmode','auto')
        % tau=num2str(mean(v.rate));
        % disp(['Recruitment rate: mean= ' num2str(mean(v.rate)) '. max= ' num2str(max(v.rate))])
        % set(vh.line10,'xdata',v.n(:,3),'ydata',v.rate,'linestyle','none','marker','.');
        axes(vh.axes1)
        
      case 'newvals' % the quality of fit has improved
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
set(findobj('style','slider'),'visible','off')
if v.optim & v.newrrp
  a1=v.rrpsize+v.rrpavg+v.rrpstd+v.rrpskew;
  for j=1:size(x,2)
    eval([v.fitstr{j} '=x(j);'])
  end
  replot_rrp=0;
  if replot_rrp
    a2=v.rrpsize+v.rrpavg+v.rrpstd+v.rrpskew;
    if a1~=a2; eval([mfilename ' setup_rrp']); end
  end
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

set(findobj('style','slider'),'visible','on')
%if ~v.optim; eval([mfilename ' newvals']); end

function fval=opt2(x);
global v vh
if v.optim
  for j=1:size(x,2)
    eval([v.fitstr{j} '=x(j);'])
  end
end
% v.n has 4 columns: c1=time last exo; c2=# exo events; c3=p0; c4= p now
v.n(:,4)=v.n(:,3);  % initialize p values
v.n(:,1:2)=0; % initialize time of last exo, # exo events
v.mnow=[];
v.n=sortrows(v.n,-3);

rtau0=randn(size(v.n,1),1)+v.rtau;
rtau0(rtau0<0.001)=0.001+abs(rtau0(rtau0<0.001));
fac=v.rtau/mean(rtau0); rtau0=max(0.001,rtau0*fac);
v.rtau=mean(rtau0);
rtau0=sortrows(rtau0, 1);
set(findobj('tag','rtau_txt'),'string',['rtau= ' num2str(mean(rtau0))])
set(findobj('tag','rtau_slider'),'value',(mean(rtau0)))
if ~v.optim
  axes(vh.axes10)
  set(vh.line10,'xdata',v.n(:,3),'ydata',rtau0,'linestyle','none','marker','.');
  %hist(rtau0,100)
  axes(vh.axes1)
end
v.rectime=[];
% set m of first shock to ~match observed. Do this by setting p threshold
% to be same as that of the mth AZ. This effectively lowers p for first
% shock

dead0=0.04*randn(size(v.n,1),1)+v.deadtime; dead0=abs(dead0); %dead(dead0>1)=dead(dead>1)-1;
if v.deadtime==0; dead0=dead0*0; end
%disp(mean(dead0))
axes(vh.axes1)
%v.raw=zeros(v.npts,size(v.n,1));
if v.deadtime; fac=v.deadtime/mean(dead0); dead0=dead0*fac; end
v.deadtime=mean(dead0);
set(findobj('tag','deadtime_txt'),'string',['deadtime= ' num2str(mean(dead0))])
set(findobj('tag','deadtime_slider'),'value',(mean(dead0)))
%axes(vh.axes11)
%hist(dead0,100)

for j=1:v.npts %%%%%%%%%%%%%%%%%%%%%
  tnow=v.obs(j,1);
  v.ctr=j;
  % set max p value for each AZ
  mx=v.n(:,3);
  if v.rrpgrow; mx(v.n(:,2)==0)=v.mx0; end
  if v.recruitgrow; mx(v.n(:,2)>0)=v.mx0; end
  % determine new p values
  mn=v.n(:,3); % set start p value, = p0 for virgins, 0 for others
  mn(v.n(:,2)>0)=0;
  % driving force on expl recovery of p
  y0=max(0,mx-mn);
  % dtms=max(0,tnow-v.deadtime-v.n(:,1)); % length of time that p has been growing
  % length of time that p has been growing
  dead=dead0; dead(v.n(:,2)==0)=0;
  dtms=max(0,tnow-dead-v.n(:,1));
  % rise in p rate ccnstants
  %  rate=rate0;
  %fractional rise of p
  %df=(1-exp(-dtms.*rate));
  df=(1-exp(-dtms./rtau0));
  % new p value
  p=mn+y0.*df;
  % add noise
  noisey=2*(rand(size(v.n,1),1)-0.5)*v.noisefac;
  % if j==50; keyboard; end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %v.n(:,4)=min(1,max(0,p+p.*noisey)); % current p
  v.n(:,4)=min(1,max(0,p+noisey)); % current p
  
  if j==1
    z=sortrows(v.n(:,4),-1); % p values, highest first
m1=max(1,round(v.obs(1,2))); % first m
nn=1; 
while sum(z(1:nn))<m1
  nn=nn+1;
end
v.rthresh0=z(nn-1);
%v.rthresh0=z(min(size(z,1),round(m1/mean(z(1:min(size(z,1),m1)))))); % avg p value of first m1 responses
x=[0:v.npts-1]';
v.rthresh2=(v.rthresh0-v.rthresh)*exp(-x/v.pthreshtau)+v.rthresh; % vector of values
  end
  
 c5=v.n(:,4);
  % determine which sites are eligible for release (p> thresh)
  v.esites=zeros(size(c5,1),1);
    v.esites(c5>=v.rthresh2(j))=1; % only sites with p>=thresh are eligible
  % dt=tnow-v.n(:,1); % current time minus time of last exo
  % v.esites(101:end)=0; % only 2 releases allowed per site
  
  neligible=sum(v.esites);
  
  rsites=v.esites*0;
  rndmode=0 ;
  switch rndmode
    case 0
      rsites(v.esites>0)=1;  % find sites of release
     % pavg=mean(c5(v.esites>0)); % avg p of all eligible sites
      % rnd=rand(size(v.n,1),1); % rand -> randn
    case 1
      rnd=0.1*randn(size(c5,1),1)+v.rskew;
      rsites(c5>=rnd & v.esites>0)=1; % sites of release
      %v.raw(j,:)=v.n(:,4)';
     % a=c5(v.esites>0); b=rnd(v.esites>0); c=a>=b; d=sortrows([a b c],-3);
  end
  % if j==50; keyboard; end
   pavg=mean(c5(v.esites>0)); % avg p of all eligible sites
     
  v.mnow(j,1)=sum(rsites(v.n(:,2)>0));  % mrecycled
  v.mnow(j,2)=sum(rsites(v.n(:,2)==0));  % mrrp
  v.mnow(j,3)=sum(rsites); % m
  % if j<50; disp([neligible v.rthreshnow v.mnow(j,3) v.obs(j,2)]); end%%%%%%%%%%%%%%%%
  v.mnow(j,4)=sum(v.n(:,2)==0)-v.mnow(j,2); % RRP remaining
  v.mnow(j,5)=neligible; % eligibles=n
  v.mnow(j,6)=pavg;
  v.mnow(j,7)=neligible*pavg; % predicted m
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
  %  if j==50; keyboard; end
end % for j=.. %%%%%%%%%%%%%%%%%%%%%%%

if ~v.optim
  axes(vh.axes11)
  grid on
  nn=5;
  try; set(vh.line11,'xdata',[1:v.npts]','ydata',v.mnow(:,nn),'linestyle','none','marker','.');
  catch; end
end
%dlmwrite(['junk.txt'],[v.raw],'\t')
%edit ('junk.txt'); drawnow

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
%disp([v.fx v.fxmin]) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~v.optim
  eval([mfilename ' newvals'])
else % v.optim>0 (multi objectives)
  if v.optim>1
    switch v.fx2name
      case {'rms' 'rms_plateau' 'rmabs'}
        p1=1; if strcmp(v.fx2name,'rms_plateau'); p1=kk; end
        obs=v.obs(p1:end,2); calc=v.mnow(p1:end,3);
        pwr=2; if strcmp(v.fx2name,'rmabs'); pwr=1; end
        dd=abs((obs-calc).^pwr);
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





