function makehtm(varargin)
global v
more off
rfac=0.7 ; % reduce images by this
joffset=0; % add this to pic num (for concatenating)
prompt={'Mult image by what factor (recommend <0.85)' 'Add this offset for numbering'};
title=''; lineno=1; def={num2str(rfac) num2str(joffset)};
inp=inputdlg(prompt,title,lineno,def);
rfac=str2num(inp{1});
joffset=str2num(inp{2});
bbmakelist
list=v.list;
resizeit=1;
currdir=pwd;
if strcmp(currdir(length(currdir)-1:length(currdir)),'\z') % in z dir
  resizeit=0;
else
  if exist('z')==7 % z directory exists
    inp=questdlg('Directory z exists! Delete?');
    if strcmp(inp,'Yes');
      cd 'z'; delete *; cd ..;
    elseif strcmp(inp,'No');
      return
    end
  else
    inp=questdlg('Make z directory or not (work in this without resizing)?');
    if strcmp(inp,'Yes');
      mkdir 'z'
    else
      resizeit=0;
    end
  end
end
addcomment=1;
scrnsz=get(0,'screensize');
maxwd=scrnsz(3); maxht=scrnsz(4);
len=length(list);
method='nearest'; % nearest; bilinear; bicubic
destprefix='z'; % new image name prefix
resizemethod='nearest'; % bilinear, bicubic

%if addcomment;
close all
vh.fig=figure; set(vh.fig,'units','pixels',...
  'position',[10 10 round(maxwd/2) round(maxht/2)])
vh.ax=axes;
set(vh.ax,'units','normalized',...
  'position',[0 0 1 1])
vh.img=image;
axis off; axis image
%end
% This will make the html file
wdtable=1024; % width of table (pixels)
newwindow=0; % Open images in SAME (0) or NEW (1) window?
prompt={'Title',...
  'Intro text',...
  'background color',...
  'text color',...
  'table background color',...
  'table text color',...
  'width'}';
lineno=1; title='';
%try; load ('makehtmdefaults')
%catch;
def={' ' ' ' '#ccccff' 'blue' '#aaaaff' 'navy' '150'};
%save makehtmdefaults def; end
inp=inputdlg(prompt,title,lineno,def);
if isempty(inp); return; end
def=inp;
% save makehtmdefaults def
title0=inp(1); txt=inp(2); bgcolor=inp{3}; textcolor=inp{4};
tablebgcolor=inp{5}; tabletextcolor=inp{6}; wd=str2num(inp{7});

newwinstr=''; if newwindow; newwinstr=' target="_blank"'; end
% Use next line for thumbnails
%a0={['<a href="img/**"  ' newwinstr '><img src="img/**" width=' num2str(wd) '></a>']};
% or this line for all images in one file
a0={['###<br clear=all> <img src="**"><hr>']};

ai(1)={'<html>'};
ai(2)={'<title>'};
ai(3)=title0;
ai(4)={'</title>'};
ai(5)={['<body bgcolor=' bgcolor ' text=' textcolor '>']};
ai(6)={'<center>'};
ai(7)={'<font size=6>'};
ai(8)=title0;
ai(9)={'<hr><table cellpadding=12>'};
ai(10)={['<td width=' num2str(wdtable) ' bgcolor=' tablebgcolor ' >']};
ai(11)={['<font size=5 color=' tabletextcolor ' >']};
ai(12)={''};
ai(13)=txt;
ai(14)={['<br><br>' num2str(length(v.list)) ' images <center>']};
ai=ai';

jmax=length(v.list)
for j=1:jmax
  jj=v.list{j};
  inp='';
  if addcomment
    v.img=imread(jj);
    vh.img=image(v.img); axis off; axis image
    prompt={[jj ' (' num2str(j) '/' num2str(jmax) '): Comment?']};
    title='Comment'; lineno=1; def={''};
    inp=inputdlg(prompt,title,lineno,def);
    if isempty(inp); inp={''}; addcomment=0; end
    inp=inp{:};
  end % addcomment
  % aa=strrep(a0,'###',[num2str(j) '<font size=2> (of ' num2str(len) ')</font> ' inp]);
  aa=strrep(a0,'###',[num2str(j+joffset) '. ' inp]);
  str=''; if resizeit; str='z'; end
  aa=strrep(aa,'**',[str jj]); % z directory
  if j==1; a=aa;
  else
    a=[a; aa];
  end
  inp='';
end % for j=1:jmax

aend={'</table></body></html>'};
a=[ai; a; aend];
a=char(a);
currdir=pwd;
if resizeit; cd z; end
[fname,pname]=uiputfile('*.htm','File name?',100,500);
if fname==0; return; end
if length(fname)<5; fname=[fname '.htm']; end
if ~strcmp(fname(end-3:end),'.htm'); fname=[fname '.htm']; end
cd (pname)
dlmwrite(fname,a,'')
%edit (fname)
cd (currdir)

if resizeit
  disp('Resizing images. This may take a while.')
  figure(vh.fig)
  % rfac=0.85; % reduce images by this
  for j=1:jmax
    jj=v.list{j};
    v.img=imread(jj);
    vh.img=image(v.img); axis off; axis image
    drawnow
    yfac=rfac*maxht/size(v.img,1); xfac=rfac*maxwd/size(v.img,2);
    resizefac=min(yfac,xfac);
    if resizefac<1
      disp(['resizing #' num2str(j) '/' num2str(jmax) ' x ' num2str(resizefac)])
      v.img=imresize(v.img,resizefac,method);
      pause(0.2)
      imwrite(v.img,['z/z' jj])
    else
      copyfile(jj, ['z/z' jj])
    end
  end
end
close all
%%%%%%%%%%%%%%%%%%%%%%%%%% BBMAKELIST %%%%%%%%%%%%%%%%%%%%%%%%%
function bbmakelist(varargin)
global v
homedir='D:\bb\'; %getappdata(0,'homedir');
piclistdir=homedir; % [homedir 'img\']; % directory where piclist.txt and picdir.txt exist
picpath='./';
exit=0;
while (exit == 0)
  %%%%%%%%%%%%%%%      Directory
  try; picdir=char(textread([piclistdir 'picdir.txt'],'%s'));
  catch; picdir=piclistdir;
    dlmwrite([piclistdir 'picdir.txt'],char(piclistdir),'');end
  try
    cd (picdir)
  catch
    %disp('ERROR trying to change directory.')
    picdir=piclistdir;
    dlmwrite([piclistdir 'picdir.txt'], char(piclistdir),'')
    cd (picdir)
  end
  if (~exist([piclistdir 'piclist.txt']));
    list=[]; dlmwrite([piclistdir 'piclist.txt'],list,'');
  end
  wd=pwd;
  disp(['Current directory ' wd]);
  %%%%%%%%%%%% List of images (piclist.txt)
  list=textread([piclistdir 'piclist.txt'],'%s');
  sz=size(list,1);
  if (sz);
    disp(' '); disp(['CURRENT LIST: ' num2str(sz) ' entries: ' list{1} ' ... ' list{end}])
  else
    disp('List: 0 entries')
  end
  choices={'MENU:';...
    's=show list';...
    'i=Info about image';...
    'd(or ls)=dir';...
    'b=base names (unique first fields)';...
    'sk=skip';...
    'c=cut';...
    'cc=include';...
    'x=erase list & start over';...
    'cd=change directory';...
    'e=edit'};
  disp(char(choices))
  beep
  inp=input('Type base name (wild cards OK) (ENTER=use current list)\n\n','s');

  switch inp
    case 'i'
      prompt=['Which number? (1-' num2str(sz) '; ENTER=all)\n\n'];
      inp=input(prompt,'s');
      if isempty(inp);
        for j=1:sz
          try
            info=imfinfo([picdir list{j}])
          catch; disp (['Error reading ' list{j}])
          end;
        end
      else
        try
          %more on
          info=imfinfo([picdir list{str2num(inp)}])
        catch; disp (['Error reading ' list{inp}])
          info
          %more off
        end;
      end
    case 'cd'
      [f picpath]=uigetfile('*.*','Pick any file in Directory');
      cd (picpath)
      dlmwrite([piclistdir 'picdir.txt'],picpath,'')
      dlmwrite([piclistdir 'piclist.txt'],'','')
    case 's' % Show list
      clc
      %more on
      disp(char(list))
      input ('Press ENTER');
    case 'ls'
      ls
      disp('Press ENTER'); pause
    case ''
      clc;
      if ~(isempty(list)); exit=1; end % more off; disp(char(list)); more on;
    case 'd'
      % more on
      dir; disp('Press ENTER'); pause
    case 'c'
      nn=0;
      c=input('Omit if it contains string - type string (ENTER=abort)\n\n','s');
      if ~(isempty(c));
        nn=1; list2={};
        for j=1:length(list);
          if isempty(findstr(c,list{j}));nn=nn+1;list2(nn)=list(j);end
        end
        dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
      end
    case 'cc'
      c=input('Include if it contains string - type string (ENTER=abort)\n\n','s');
      if ~(isempty(c));
        nn=1;list2={};
        for j=1:length(list);
          if findstr(c,list{j}); list2(nn)=list(j); nn=nn+1; end
        end
        dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
      end
    case 'sk'
      inp=input('Take how many, skip how many? (ENTER= 1 1)\n\n','s');
      [n1 n2]=strtok(inp,' ');
      if (isempty (n1)); n1='1'; n2='1';end
      nn=0; n1=str2num(n1); n2=str2num(n2);list2={};
      for j=1:n1+n2:size(list,1)
        %list2(end+1:end+n1)=char(list(j:j+n1)); % Can't make this work!
        for k=1:n1
          nn=nn+1;
          try;list2(nn)=list(j+k-1);
          catch;nn=nn-1;end
        end
      end
      dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
    case 'x'
      list=[]; dlmwrite([piclistdir 'piclist.txt'],list,'')
    case 'e'
      edit ([piclistdir 'piclist.txt'])
      input ('Press ENTER when done','s')
    case 'b'
      a=dir; % ([picdir '*.tif']);
      %a=[a;dir([picdir '*.jpg'])];
      b={a.name};
      for j=1:size(b,2); % base name
        x=find(b{j}=='.');
        if (size(x,2)>1) % strip off last two fields
          place=x(size(x,2)-1)-1; % (e.g., 010612.001.tif -> 010612)
          p2=x(size(x,2)); % up to last field
          b{j}=b{j}(1:place); % c{j}=[ ' - ' b{j}(p2+1:end)]; % b{j}=(strtok(c(j,:),'.'));
        end
      end
      basenames=unique(b) ;  % CELL array, for CHAR use f=unique(b,'rows')
      disp('TIF & JPG base names: ');lst='';
      for j=1:size(basenames,2);
        lst=[lst ' ' char(basenames{j})];
        disp(['			' char(basenames{j})]);
      end
      input('Press ENTER')
    otherwise
      %if (isempty(findstr('*',inp))); inp=[inp '*'];end
      structlist=dir([picpath inp]); celllist={structlist.name};
      celllist=celllist'; % charlist2=zeros(size(structlist,1),1);
      list=[list; celllist];
      charlist=sortrows(char(list));
      dlmwrite([piclistdir 'piclist.txt'],charlist,''); list=charlist;
      % does directory (wd) end with '\'?
      a=find(wd=='\'); if ~isempty(a); if a(end) ~= size(wd,2); wd=[wd '\']; end; end
      dlmwrite([piclistdir 'picdir.txt'],wd,'');
  end % switch inp
end % while exit==0
v.list=list;
