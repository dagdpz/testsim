function testsim_tuning_microstim

fig_size = [200 200 500 500];
N = 50; % ROIs
RA_noise_level = 0.25;

Stim_effect_l = 0.3; % %BOLD change % contraversive
Stim_effect_r = 0.2; % %BOLD change
Stim_effect_noise_level = 0.1;

hemi='right';
%hemi='left';

switch hemi
	
	case 'right' % RH, left space contraversive
		
		% control (baseline)
		ra_c_l = randn(N,1)*RA_noise_level+[0.4];
		ra_c_r = randn(N,1)*RA_noise_level+[0.15];
		
		% % stimulation additive
		ra_s_l = ra_c_l + Stim_effect_l + randn(N,1)*Stim_effect_noise_level;
		ra_s_r = ra_c_r + Stim_effect_r + randn(N,1)*Stim_effect_noise_level;
		
		% % stimulation multiplicative
		% ra_s_l = ra_c_l*1.4+randn(N,1)/4;
		% ra_s_r = ra_c_r*1.2;
		
		% % stimulation additive and multiplicative => same as multiplicative! : ra_c_l+ra_c_l*0.5 = ra_c_l(1+0.5)
		% ra_s_l = ra_c_l+ra_c_l*0.5;
		% ra_s_r = ra_c_r+ra_c_r*0.5;
		
	case 'left' % LH, left space contraversive	
		
		% control (baseline)
		ra_c_l = randn(N,1)*RA_noise_level+[0.25];
		ra_c_r = randn(N,1)*RA_noise_level+[0.5];
		
		% % stimulation additive
		ra_s_l = ra_c_l + Stim_effect_l + randn(N,1)*Stim_effect_noise_level;
		ra_s_r = ra_c_r + Stim_effect_r + randn(N,1)*Stim_effect_noise_level;
		
		% % stimulation multiplicative
		% ra_s_l = ra_c_l*1.4+randn(N,1)/4;
		% ra_s_r = ra_c_r*1.2;
		
		% % stimulation additive and multiplicative => same as multiplicative! : ra_c_l+ra_c_l*0.5 = ra_c_l(1+0.5)
		% ra_s_l = ra_c_l+ra_c_l*0.5;
		% ra_s_r = ra_c_r+ra_c_r*0.5;
		
end

% FITTING

% ADDITIVE: stim = control + a;
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [-10],...    
               'Upper', [10],...     
               'Startpoint',[0]);
fta = fittype('x+a','options',s);
[f_l_a,gf_l_a] = fit(ra_c_l,ra_s_l,fta)
[f_r_a,gf_r_a] = fit(ra_c_r,ra_s_r,fta)

% MULTIPLICATIVE: stim = control*a;
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [0],...    
               'Upper', [10],...     
               'Startpoint',[1]);
ftm = fittype('x*a','options',s);
[f_l_m,gf_l_m] = fit(ra_c_l,ra_s_l,ftm)
[f_r_m,gf_r_m] = fit(ra_c_r,ra_s_r,ftm)

% PLOT

ig_figure('Name','Response amplitude','Position',fig_size);
plot(ra_c_l,ra_s_l,'bo'); hold on;
plot(ra_c_r,ra_s_r,'ro');
xlabel('control');
ylabel('stimulation');

axis square
axis equal
box off

%set_axes_equal_lim;
add_equality_line;
add_zero_lines;

% plot fits
h = plot(f_l_a); set(h,'Color','b');
h = plot(f_r_a); set(h,'Color','r');
h = plot(f_l_m); set(h,'Color','b','LineStyle',':');
h = plot(f_r_m); set(h,'Color','r','LineStyle',':');

ig_figure('Name','contraversive selectivity','Position',fig_size);
if strcmp(hemi,'right'),
	plot(csi(ra_c_l,ra_c_r),csi(ra_s_l,ra_s_r),'ko');
else
	% plot(csi(ra_c_r,ra_c_l),csi(ra_s_r,ra_s_l),'ko'); % contralateral selectivity
	plot(csi(ra_c_l,ra_c_r),csi(ra_s_l,ra_s_r),'ko'); % contraversive selectivity	
end
title(sprintf(' %s hemi, coef: %.2f contraversive, %.2f ipsi',hemi,f_l_a.a,f_r_a.a));

xlabel('control');
ylabel('stimulation');


axis square
axis equal
box off

%set_axes_equal_lim;
add_equality_line;
add_zero_lines;
if strcmp(hemi,'right'),
	[slope,intercept,STAT,CIR]=ig_myregr(csi(ra_c_l,ra_c_r) , csi(ra_s_l,ra_s_r) , 0);
else
	% [slope,intercept,STAT,CIR]=ig_myregr(csi(ra_c_r,ra_c_l) , csi(ra_s_r,ra_s_l) , 0); % contralateral selectivity
	[slope,intercept,STAT,CIR]=ig_myregr(csi(ra_c_l,ra_c_r) , csi(ra_s_l,ra_s_r) , 0); % contraversive selectivity
end

ig_add_linear_regression_line(slope.value,intercept.value,'Color','m');
hold on;
plot(CIR.xaxis,CIR.yaxis,'m:');



ig_figure('Name','Stimulation effect','Position',fig_size);
plot(ra_s_l - ra_c_l,ra_s_r-ra_c_r,'ko');

axis square
axis equal
box off

%set_axes_equal_lim;
add_equality_line;
add_zero_lines;

title(sprintf(' %s hemi stim effect: %.2f contraversive, %.2f ipsi',hemi,mean(ra_s_l - ra_c_l),mean(ra_s_r-ra_c_r)));
	
xlabel('contraversive');
ylabel('ipsiversive');




function CSI = csi(Contra,Ipsi)

% CSI = (Contra-Ipsi)./(Contra+Ipsi);
CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
% CSI = (Contra-Ipsi);
