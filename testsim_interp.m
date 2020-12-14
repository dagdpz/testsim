% testsim_interp
% test interpolation methods for vtc timecourses

duplicateLastSample = 1; % duplicate last sample, to get the interpolated samples after the last samples

% e.g. FRD project
TR = 0.9; % s
N = 100; % number of samples/volumes
TRi = 0.1; % s

% monkey fMRI
% TR = 2;
% N = 100; % number of samples/volumes
% TRi = 1; % s

time = 0:TR:TR*(N-1);

data = rand(1,N);
% data = sin(2*pi*0.05*time);




% standard interpolation, works only for interger of TR
idata = interp(data,TR/TRi);
itime = [0:TRi:TRi*(length(idata)-1)];

n = neuroelf;
if duplicateLastSample, 
    data_ = [data data(end)];
    time_ = time(end)+TR;
else
    data_= data;
    time_ = time(end);
end
fidata = n.flexinterpn(data_',[1:TRi/TR:length(data_)]');
fitime = time(1):time_/(length(fidata)-1):time_;

%       method      either of:
%                   'cubic', 'lanczos2' 'lanczos3', {'linear'},
%                   'nearest', 'poly3', 'spline2', 'spline3'

fimdata = n.flexinterpn_method(data_',[1:TRi/TR:length(data_)]','poly3');
fimtime = time(1):time_/(length(fimdata)-1):time_;

figure
plot(time,data,'k'); hold on
plot(time,data,'ko');
plot(itime,idata,'r.');
plot(fitime,fidata,'g.');
plot(fimtime,fimdata,'b');

xlabel('Time (s)');












	
