function testsim_tuning_microstim

fig_size = [200 200 500 500];
N = 50; % ROIs
RA_noise_level = 0.25;

Stim_effect_l = 0.25; % %BOLD change % contraversive
Stim_effect_r = 0.2; % %BOLD change
Stim_effect_noise_level = 0.02;

hemi='right';
%hemi='left';

switch hemi
	
	case 'right' % RH, left space contraversive
		
		% control (baseline)
		ra_c_l = randn(N,1)*RA_noise_level+[0.4];
		ra_c_r = randn(N,1)*RA_noise_level+[0.15];
		
		% % stimulation additive
% 		ra_s_l = ra_c_l + Stim_effect_l + randn(N,1)*Stim_effect_noise_level;
% 		ra_s_r = ra_c_r + Stim_effect_r + randn(N,1)*Stim_effect_noise_level;
         
        % % stimulation additive proportional of spatial selectivity
        % ra_s_l = ra_c_l + Stim_effect_l*(1 - csi(ra_c_l,ra_c_r)) + randn(N,1)*Stim_effect_noise_level;
		% ra_s_r = ra_c_r + Stim_effect_r*(csi(ra_c_l,ra_c_r) + 1) + randn(N,1)*Stim_effect_noise_level;
        
        % % stimulation additive downscaled by response amplitude
        ra_s_l = ra_c_l + Stim_effect_l*(1 - 0.5*ra_c_l) + randn(N,1)*Stim_effect_noise_level;
		ra_s_r = ra_c_r + Stim_effect_r*(1 - 0.5*ra_c_r) + randn(N,1)*Stim_effect_noise_level;
		
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
[f_l_a,gf_l_a] = fit(ra_c_l,ra_s_l,fta);
[f_r_a,gf_r_a] = fit(ra_c_r,ra_s_r,fta);

% MULTIPLICATIVE: stim = control*a;
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [0],...    
               'Upper', [10],...     
               'Startpoint',[1]);
ftm = fittype('x*a','options',s);
[f_l_m,gf_l_m] = fit(ra_c_l,ra_s_l,ftm);
[f_r_m,gf_r_m] = fit(ra_c_r,ra_s_r,ftm);

% % ADDITIVE scaled by RA: stim = control + a*(1-control);
% s = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower', [-10],...    
%                'Upper', [10],...     
%                'Startpoint',[0]);
% fta = fittype('x+a*(1-x)','options',s);
% [f_l_as,gf_l_as] = fit(ra_c_l,ra_s_l,fta);
% [f_r_as,gf_r_as] = fit(ra_c_r,ra_s_r,fta);


% ADDITIVE scaled by RA: stim = control + a*(1-b*control);
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [-10],...    
               'Upper', [10],...     
               'Startpoint',[0 1]);
fta = fittype('x+a*(1-b*x)','options',s);
[f_l_as,gf_l_as] = fit(ra_c_l,ra_s_l,fta);
[f_r_as,gf_r_as] = fit(ra_c_r,ra_s_r,fta);


f_l_as
f_r_as
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
ig_add_equality_line;
ig_add_zero_lines;

% plot fits
h = plot(f_l_a); set(h,'Color','b');
h = plot(f_r_a); set(h,'Color','r');
h = plot(f_l_m); set(h,'Color','b','LineStyle',':');
h = plot(f_r_m); set(h,'Color','r','LineStyle',':');
h = plot(f_l_as); set(h,'Color','c','LineStyle','-');
h = plot(f_r_as); set(h,'Color','m','LineStyle','-');


title(sprintf('Adj. r-square add. %.2f %.2f mult. %.2f %.2f add.sc. %.2f %.2f',gf_l_a.adjrsquare,gf_r_a.adjrsquare,gf_l_m.adjrsquare,gf_r_m.adjrsquare,gf_l_as.adjrsquare,gf_r_as.adjrsquare));

ig_figure('Name','contraversive selectivity','Position',fig_size);
if strcmp(hemi,'right'),
	plot(csi(ra_c_l,ra_c_r),csi(ra_s_l,ra_s_r),'ko');
else
	% plot(csi(ra_c_r,ra_c_l),csi(ra_s_r,ra_s_l),'ko'); % contralateral selectivity
	plot(csi(ra_c_l,ra_c_r),csi(ra_s_l,ra_s_r),'ko'); % contraversive selectivity	
end
title(sprintf(' %s hemi, coef: %.2f contraversive, %.2f ipsi; CSI con %.2f CSI stim %.2f',hemi,f_l_a.a,f_r_a.a,mean(csi(ra_c_l,ra_c_r)),mean(csi(ra_s_l,ra_s_r))));
xlabel('control');
ylabel('stimulation');
axis square
axis equal
box off

%set_axes_equal_lim;
ig_add_equality_line;
ig_add_zero_lines;
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
ig_add_equality_line;
ig_add_zero_lines;
title(sprintf(' %s hemi stim effect: %.2f contraversive, %.2f ipsi',hemi,mean(ra_s_l - ra_c_l),mean(ra_s_r-ra_c_r)));	
xlabel('contraversive');
ylabel('ipsiversive');

ig_figure('Name','Average stimulation effect','Position',fig_size);
SE_r = ra_s_r - ra_c_r;
SE_l = ra_s_l - ra_c_l;
bar(1, mean(SE_l),'b'); hold on; % contraversive responses
errorbar(1, mean(SE_l), sterr(SE_l),'k');
bar(2, mean(SE_r),'r'); hold on; % ipsiversive responses
errorbar(2, mean(SE_r), sterr(SE_r),'k');



ig_figure('Name','Stim. effect vs spatial selectivity','Position',fig_size);
plot(csi(ra_c_l,ra_c_r),ra_s_l - ra_c_l,'bo'); hold on;
plot(csi(ra_c_l,ra_c_r),ra_s_r - ra_c_r,'ro');

[slope_l,intercept_l,STAT_l,CIR_l]=ig_myregr(csi(ra_c_l,ra_c_r), ra_s_l - ra_c_l, 0);
[slope_r,intercept_r,STAT_r,CIR_r]=ig_myregr(csi(ra_c_l,ra_c_r), ra_s_r - ra_c_r, 0);

ig_add_linear_regression_line(slope_l.value,intercept_l.value,'Color','b');
ig_add_linear_regression_line(slope_r.value,intercept_r.value,'Color','r');

box off
xlabel('CSI');
ylabel('stim. effect');


ig_figure('Name','Stim. effect vs response amplitude','Position',fig_size);
plot(ra_c_l,ra_s_l - ra_c_l,'bo'); hold on;
plot(ra_c_r,ra_s_r - ra_c_r,'ro');

[slope_l,intercept_l,STAT_l,CIR_l]=ig_myregr(ra_c_l, ra_s_l - ra_c_l, 0);
[slope_r,intercept_r,STAT_r,CIR_r]=ig_myregr(ra_c_r, ra_s_r - ra_c_r, 0);

ig_add_linear_regression_line(slope_l.value,intercept_l.value,'Color','b');
ig_add_linear_regression_line(slope_r.value,intercept_r.value,'Color','r');

box off
xlabel('response amplitude');
ylabel('stim. effect');



if 0
% Another question: how additive or multiplicative effects translate into ANOVA task-dependence, within each ROI
N_trials = [100 100 100 100 100 100];
task_ra = [1.3 1.6 1.9];
task_ra_noise_level = [1.5 1.5 1.5];
Stim_effect_noise_level = [0.1 0.1 0.1];

task = [ones(N_trials(1),1) ; 2*ones(N_trials(2),1) ; 3*ones(N_trials(3),1) ; ones(N_trials(4),1) ; 2*ones(N_trials(5),1) ; 3*ones(N_trials(6),1)];
stim = [ones(sum(N_trials(1:3)),1) ; 2*ones(sum(N_trials(4:6)),1)];

% additive model, same or different addition for all tasks
% stim_effect = [0.2 0.2 0.2];
stim_effect = [0.2 0.4 0.6];
ra1 = task_ra(1) + task_ra_noise_level(1)*randn(N_trials(1),1); ra4 = task_ra(1)+task_ra_noise_level(1)*randn(N_trials(4),1)+stim_effect(1)+randn(N_trials(4),1)*Stim_effect_noise_level(1);
ra2 = task_ra(2) + task_ra_noise_level(2)*randn(N_trials(2),1); ra5 = task_ra(2)+task_ra_noise_level(2)*randn(N_trials(5),1)+stim_effect(2)+randn(N_trials(5),1)*Stim_effect_noise_level(2);
ra3 = task_ra(3) + task_ra_noise_level(3)*randn(N_trials(3),1); ra6 = task_ra(3)+task_ra_noise_level(3)*randn(N_trials(6),1)+stim_effect(3)+randn(N_trials(6),1)*Stim_effect_noise_level(3);

if 0
% multiplicative model, same or different multiplication for all tasks
stim_effect = [1.5 1.5 1.5];
% stim_effect = [1.2 1.5 1.8];
ra1 = task_ra(1) + task_ra_noise_level(1)*randn(N_trials(1),1); ra4 = (task_ra(1)+task_ra_noise_level(1)*randn(N_trials(4),1))*stim_effect(1)+randn(N_trials(4),1)*Stim_effect_noise_level(1);
ra2 = task_ra(2) + task_ra_noise_level(2)*randn(N_trials(2),1); ra5 = (task_ra(2)+task_ra_noise_level(2)*randn(N_trials(5),1))*stim_effect(2)+randn(N_trials(5),1)*Stim_effect_noise_level(2);
ra3 = task_ra(3) + task_ra_noise_level(3)*randn(N_trials(3),1); ra6 = (task_ra(3)+task_ra_noise_level(3)*randn(N_trials(6),1))*stim_effect(3)+randn(N_trials(6),1)*Stim_effect_noise_level(3);
end

[p,table,stats,terms] = anovan([ra1; ra2; ra3; ra4; ra5; ra6],[task stim],'model','full','varnames',{'task' 'stim'});
% c = multcompare(stats);
ig_figure('Name','ANOVA','Position',fig_size);

ig_errorbar([1 2 3 4 5 6],[ra1 ra2 ra3 ra4 ra5 ra6],1);

end



function CSI = csi(Contra,Ipsi)

% CSI = (Contra-Ipsi)./(Contra+Ipsi);
% CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
CSI = (Contra-Ipsi);
