function rrp4 (varargin)
% v.n has 4 columns: c1=time (pt)last exo; c2=# exo events; c3=p0; c4= p now
global v vh
more off
switch nargin
    case 0
        close all
        h=openfig(mfilename,'reuse');v.deadtime=0;
        vh=guihandles(h);
        v.rrpsize=1770; v.rrpstd=0.1; v.rrpavg=0.4;
        v.rtau=.2; v.rrpgrow=0; v.mx0=1;
        v.npts=100; v.freq=100;
        v.nbins=100; v.rrpskew=1; v.rskew=1;
        v.histo=1; v.ctr=1;
        v.rthresh=0;
        v.nruns=10; v.j10=0; v.rrpmode=2;
        v.noisefac=0.1; % fractional change (max) in p0
        v.rrpslow=1; v.recycslow=1;
        v.deadtime=0;
        %   try; load('rrpvars.mat'); catch; end
        setappdata(vh.hfig,'v',v)
        eval([mfilename ' setvals'])
        eval([mfilename ' setup_rrp4'])
        set (vh.axes1,'xlim',[0 v.npts/v.freq])

    case 1
        switch varargin{:}
            case 'vars'
                eval([mfilename ' getvals'])
                prompt={'RRP size'  'RRP p (mean)' 'RRP p (std dev)',...
                    'recruit tau (s)' 'rrp p0 skew factor' 'recruit time skew factor' 'recycle dead time',...
                    'recruit p thresh' 'factor to slow rate of growth of rrp p',...
                    'factor to slow p growth with multiple exo events' '# pts per run' '#runs for multiple runs',...
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
                    num2str(v.nruns),...
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
                v.nruns=str2num(inp{12});
                v.noisefac=str2num(inp{13});
                v.mx0=str2num(inp{14});
                eval([mfilename ' setvals'])
                eval([mfilename ' setup_rrp4'])

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
                eval([mfilename ' setup_rrp4'])

            case 'setvals'
                save('rrpvars.mat','v');
                set(vh.rrpsize_txt,'string',['RRP size= ' num2str(v.rrpsize)])
                set(vh.rrpavg_txt,'string',['RRP: p mean= ' num2str(v.rrpavg)])
                set(vh.rrpstd_txt,'string',['RRP: p std dev= ' num2str(v.rrpstd)])
                set(vh.skew_txt,'string',['p distribution skew= ' num2str(v.rrpskew)])

                set(vh.rtau_txt,'string',['recruit: tau= ' num2str(v.rtau)])
                set(vh.rskew_txt,'string',['recruit t skew= ' num2str(v.rskew)])
                set(vh.deadtime_txt,'string',['recycle deadtime=' num2str(v.deadtime)])
                set(vh.rthresh_txt,'string', ['recruit p thresh=' num2str(v.rthresh)])

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

                set(vh.tenruns,'string', [num2str(v.nruns) ' runs'])
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
                eval([mfilename ' setup_rrp4'])

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
                [fname,pname]=uigetfile;
                load([pname fname])
                eval([mfilename ' setvals'])
                eval([mfilename ' setup_rrp4'])

            case 'tenruns'
                turnon=0;
                if v.histo; eval([mfilename ' histoonoff']); turnon=1; end
                v.tenruns=zeros(v.nruns,3);
                v.j10=0;
                while v.j10<v.nruns
                    str0=[num2str(v.j10+1) ' / ' num2str(v.nruns)];
                    %     disp(str0)
                    set(vh.results,'string',str0)
                    v.j10=v.j10+1;
                    eval([mfilename ' setup_rrp4'])
                    eval([mfilename ' calc'])
                end
                msz=size(v.tenruns,1);
                mm=mean(v.tenruns);
                varp=round(100*mm(1,3))/100;
                varnc=round(100*mm(1,2))/100;
                varsd=round(100*std(v.tenruns(:,3)))/100;
                varsem=round(100*varsd/sqrt(v.nruns))/100;
                mtot=round(sum(v.tenruns(:,6))/v.nruns);
                str=['Avg ' num2str(msz) ' runs (plateau):' char(10),...
                    'mean m=' num2str(mm(1,1)) char(10),...
                    ' (tot m=' num2str(mtot) ') ' char(10),...
                    ' var(m (plateau))=' num2str(varnc) char(10),...
                    'p (var)= ' num2str(varp) '+/-' num2str(varsem) char(10),...
                    'p (mean sites)=' num2str(v.p2) char(10),...
                    'n=' num2str(round(mm(1,5))) char(10)];
                set(vh.results,'string',str)
                disp(str)
                v.j10=0;
                if turnon; eval([mfilename ' histoonoff']); end

            case 'go'
                eval([mfilename ' setup_rrp4'])
                eval([mfilename ' calc'])

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


            case 'setup_rrp4'
                v.ctr=0; v.dt=[]; v.minp=0.001;
                v.n=zeros(v.rrpsize,4);
                v.mnow=[];

                v.noise1=v.noisefac*randn(size(v.n,1),1);
                %   noisestd=0.1;
                %   a=randn(size(v.n,1),1)+noisestd;
                %   a=a-min(a); v.noise1=a*v.noisefac/mean(a);
                %   v.noise2=sort(v.noise1);
                %v.noise1=v.noisefac*rand(size(v.n,1),1);
                %v.noise2=v.noisefac*rand(size(v.n,1),1);

                x=[0:v.npts-1]';
                v.df=1-exp(-x/(v.rtau*v.freq));
                if v.rskew~=1;
                    v.df=v.df.^v.rskew;
                end
                %  v.df=[0; v.df(1:end-1)];
                %disp(mean(v.df))%%%%%%%%%%%%%%%%%%%%

                v.xlimit=[0 v.npts/v.freq];
                v.ylimit=[0 100];
                v.edges=[0:0.02:1]';
                v.xstep=1/v.freq;
                v.colors={ 'c' 'b'  'm' 'y' 'b' 'g' 'r'}; %{'r' 'g' 'b' 'y' 'm' 'c'};
                axes(vh.axes1)
                delete(findobj(vh.hfig,'type','line'))
                set(vh.results,'string','')

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
                if v.j10<2; eval([mfilename ' histogram']); end
            case 'drawlines'
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

            case 'calc'
                %
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
                    y0=mx-mn;

                    dt=max(1,j-v.deadpts-v.n(:,1)); % growth of p begins only after deadtime
                    df=v.df(dt);

                    a0=v.n(:,2)+1; a=a0; % slow recycle rate with multiple exocytoses and slow rrp growth
                    a(a0==1)=a(a0==1)*v.rrpslow;
                    a(a0>1)=a(a0>1)*v.recycslow;
                    df=df./a;

                    p=y0.*df;
                    p=p+mn;
                    %       if j==10; keyboard ;end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

                    setappdata(gcf,'v',v)
                    if v.histo; eval([mfilename ' histogram']); end

                    c2=v.n(:,2); % update release site exocytic count and reset p to zero
                    c2(rsites>0)=c2(rsites>0)+1; % increment exocytic counter
                    v.n(:,2)=c2;
                    v.n(rsites>0,4)=v.minp; % p goes to zero after release

                end % for j=...
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                kk=round(size(v.mnow,1)/2)+1;
                v.varmin=var(v.mnow(kk:end,3));
                v.meanm=mean(v.mnow(kk:end,3)); v.meanm=round(v.meanm*10)/10;
                v.meanm_predict=round(mean(v.mnow(kk:end,7))*10)/10;
                v.varmin=round(v.varmin*10)/10;
                v.p=1-v.varmin/v.meanm; v.p=round(v.p*100)/100;
                v.p2=mean(v.mnow(kk:end,6)); v.p2=round(v.p2*100)/100;
                v.nplat=round(mean(v.mnow(end-10:end,5)));

                if ~v.j10 | v.j10==v.nruns
                    str=['PLATEAU: ' char(10),...
                        'mean m= ' num2str(v.meanm) char(10),...
                        ' (tot= ' num2str(sum(v.mnow(:,3))) ')' char(10),...
                        'mean m (predicted)= ' num2str(v.meanm_predict) char(10),...
                        'p (var)= ' num2str(v.p) char(10),...
                        'p (mean sites)= ' num2str(v.p2) char(10),...
                        'n= ' num2str(v.nplat) char(10),...
                        '(Pts ' num2str(kk) '-' num2str(size(v.mnow,1)) ')' char(10)];
                    set(vh.results,'string',str)
                    setappdata(vh.hfig,'v',v)
                    if ~v.histo; eval([mfilename ' drawlines']); end
                    grid on

                    axes(vh.axes2) % # exocytic events vs p0
                    hist(v.n(:,2),100)
                    vv=get(gca); x=(vv.XLim(2)-vv.XLim(1))/3+vv.XLim(1);
                    y=(vv.YLim(2)-vv.YLim(1))/2+vv.YLim(1);
                    str=[num2str(sum(v.n(:,2)==0)) ' zeros'];
                    delete(findobj(gca,'type','text'))
                    text('position', [x,y], 'string',str)
                    drawnow

                    axes(vh.axes3) %
                    ninf=max(50,mean(v.mnow(end-10:end,3)));
                    set(vh.axes3,'ylim',[0 ninf*3]); grid on
                    vh.line5=line('xdata',v.xx,'ydata',v.mnow(:,5)/10,'color','black'); % n
                    vh.line3=line('xdata',v.xx,'ydata',v.mnow(:,3),'color','blue'); % m

                    axes(vh.axes4)
                    dt2=v.dt/v.freq;
                    hist(dt2,100)
                    %       x=[1:size(v.dt)]';
                    %     line(x,v.dt,'linestyle','none','marker','.')
                    axes(vh.axes1)

                else
                    v.tenruns(v.j10,1)=v.meanm;
                    v.tenruns(v.j10,2)=v.varmin;
                    v.tenruns(v.j10,3)=v.p;
                    v.tenruns(v.j10,4)=v.p2;
                    v.tenruns(v.j10,5)=v.nplat;
                    v.tenruns(v.j10,6)=sum(v.mnow(:,3)); % total m
                end




        end % switch varargin

end % switch nargin


