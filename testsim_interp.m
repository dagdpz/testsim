function testsim_interp
% test interpolation methods for vtc timecourses

TR = 0.9; % s
N = 100; % number of samples/volumes
TRi = 0.1; % s

time = 0:TR:TR*(N-1);

data = rand(1,N);
% data = sin(2*pi*0.05*time);



% standard interpolation, works only for interger of TR

idata = interp(data,TR/TRi);
itime = [0:TRi:TRi*(length(idata)-1)];

n = neuroelf;
fidata = n.flexinterpn(data',[1:TRi/TR:length(data)]');
fitime = time(1):time(end)/(length(fidata)-1):time(end);

%       method      either of:
%                   'cubic', 'lanczos2' 'lanczos3', {'linear'},
%                   'nearest', 'poly3', 'spline2', 'spline3'

fimdata = n.flexinterpn_method(data',[1:TRi/TR:length(data)]','poly3');
fimtime = time(1):time(end)/(length(fimdata)-1):time(end);

figure
plot(time,data,'k'); hold on
plot(time,data,'ko');
plot(itime,idata,'r.');
plot(fitime,fidata,'g.');
plot(fimtime,fimdata,'b');

xlabel('Time (s)');












	
