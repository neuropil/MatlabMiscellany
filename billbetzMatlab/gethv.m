function gethv (varargin)
more off
srchlist={'X Dimension' 'Excitation Wavelength' 'Transmissivity' 'PMT Voltage'};
repllist={'um/pix.' 'nmEx' '%' '=hV.'};
wdn=[9 3 4 3 ]; % word number in the line
flist=bbmakelist;
for j=1:length(flist)
  a=importdata(flist{j});
  s0=[flist{j} ': '];
  for k=1:length(srchlist)
    for kk=1:length(a)
      b=a{kk};
      if findstr(b,srchlist{k});
        wd=regexp(b,'\S+','match'); % parses to words
        c=[wd{wdn(k)} repllist{k}];
        s0=[s0  c ' '];
      end
    end
  end
  omitlist={'"'};
  for kk=1:length(omitlist); s0=regexprep(s0,omitlist{kk},''); end
  disp(s0)
end
