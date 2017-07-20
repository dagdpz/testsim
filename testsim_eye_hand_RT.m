function testsim_eye_hand_RT
% eye hand coordination
% http://stats.stackexchange.com/questions/32464/how-does-the-correlation-coefficient-differ-from-regression-slope

N = 200;
t = [1:N]'; % time, or trial

% all values in s

% eye
e_mean	= 0.2;
e_sd	= 0.050;

h2e_delay	= 0.100; % average hand-to-eye delay, should be ~equal to intercept of regression
h2e_sd		= 0.05; % 0.050;
h2e_slope	= 0; % should be ~equal to slope of regression

% general trend
gt = [1:N]/N*0.0; % *0 for no trend

e = e_mean + e_sd.*randn(N,1)+gt';
h = h2e_delay + h2e_slope.*e + h2e_sd*randn(N,1)+gt';

bins = [0.05:0.025:0.5];
figure('Position',[100 100 600 800]);



subplot(2,1,1);
eh = hist(e,bins);
hh = hist(h,bins);
plot(bins,eh,'r'); hold on
plot(bins,hh,'g'); hold on
title(sprintf('mean eye RT %.2f, mean hand RT %.2f',mean(e),mean(h))); 



subplot(2,1,2)
plot(e,h,'o');
xlabel('RT eye')
ylabel('RT hand')
[r,sig] = corrcoef_eval(e,h);
[slope,intercept,STAT]=ig_myregr(e,h,0,0);
axis equal
title(sprintf('r = %.2f, sig = %.2f, slope = %.2f, intercept = %.2f',r,sig,slope.value,intercept.value)); 


% analyzing residuals

figure('Position',[100 100 600 1000]);
subplot(3,1,1);
plot(t,e,'o'); hold on
[slope_e,intercept_e]=ig_myregr(t,e,0,0);
e_reg = intercept_e.value + slope_e.value*t;
plot(t,e_reg,'r-');

subplot(3,1,2);
plot(t,h,'o'); hold on
[slope_h,intercept_h]=ig_myregr(t,h,0,0);
h_reg = intercept_h.value + slope_h.value*t;
plot(t,h_reg,'r-');

% residuals

e_res = e - e_reg;
h_res = h - h_reg;

subplot(3,1,3)
plot(e_res,h_res,'o');
xlabel('RT eye res')
ylabel('RT hand res')
[r,sig] = corrcoef_eval(e_res,h_res);
[slope,intercept,STAT]=ig_myregr(e_res,h_res,0,0);
axis equal
title(sprintf('r = %.2f, sig = %.2f, slope = %.2f, intercept = %.2f',r,sig,slope.value,intercept.value)); 





