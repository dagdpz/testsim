% testsim_plot_2Darray_colormap

s = 1:30; % samples
N = 500; % number of spikes

D = repmat([0:1/(N-1):1]',1,30) + repmat(cos(2*pi*0.03*s),N,1) + 0.1*randn(N,30);
D = D';

h = plot(D);

set(h,{'Color'},num2cell(jet(N),2));