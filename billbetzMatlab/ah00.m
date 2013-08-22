function ah01(varargin)
global v vh
switch nargin
    case 0
        close all
        h=openfig(mfilename,'new');
        vh=guihandles(h);
        v.x=[1:1001]';%samples
        v.y=v.x;%voltages
        vh.line01=line('xdata',v.x,'ydata',v.y);
        try
            a=v.dat;
        catch
            eval('ah01 loadfile')
        end
    case 1
        switch varargin{:}
            case 'color'
                set(vh.figure1,'color',[rand rand rand])
            case 'randnumber'
                set(vh.randnumber,'string',num2str(rand))
            case 'plotit'
                dblevel=round(get(vh.dblevel,'value'));
                set(vh.dblevel_txt,'string',['dblevel= ' num2str(dblevel)])
                frequency=round(get(vh.frequency,'value'));
                set(vh.frequency_txt,'string',['frequency= ' num2str(round(v.mf(frequency)))])
                td= squeeze(v.dat(dblevel,frequency,:));%%x (dB levels); y (frequency)
                set(vh.line01,'ydata',td)
            case 'loadfile'
                [f fpath]=uigetfile('*','pickanyfile');
                load([fpath f])
                v.x=[1:1001]';
               % mem=memb;
                %%% intensity values
                dblevels = mem.GWF.Intensity.Min:mem.GWF.Intensity.Step:mem.GWF.Intensity.Max;
                %%% frequency values (250-13929 Hz)
                v.mf=1000*0.25*2.^((0:29)/5);
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
        end

end