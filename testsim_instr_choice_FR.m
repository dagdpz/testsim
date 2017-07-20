function testsim_instr_choice_FR
% response amplitudes for instr and choice trials
% null hypothesis: just noise (no tuning)
noise_level = 1; % [0.5:0.5:20];
N_rep = 1;

for n = 1:length(noise_level),
	for r = 1:N_rep,
		[p(n,r) CII(n,r)] = testsim_instr_choice_FR_one_noise_level(noise_level(n), 1);
	end
end	

if N_rep > 1,
figure;
subplot(2,1,1)
ig_errorbar(noise_level,p,2);
xlabel('noise level');
ylabel('p value');
subplot(2,1,2)
ig_errorbar(noise_level,CII,2);
xlabel('noise level');
ylabel('CII');
end


function [p meanCII meanCCI] = testsim_instr_choice_FR_one_noise_level(noise_level, TOPLOT)
n_trials = 30; % per hemifield
%noise_level = 5;

for k = 1:50, % units
	unit_FR_level = 30;
	FR_i_l = unit_FR_level + noise_level*randn(1,n_trials);
	FR_i_r = unit_FR_level + noise_level*randn(1,n_trials);
	FR_c_l = unit_FR_level + noise_level*randn(1,n_trials);
	FR_c_r = unit_FR_level + noise_level*randn(1,n_trials);
	
	if mean(FR_i_l) > mean(FR_i_r),
		RA_i(k) = mean(FR_i_l);
		RA_c(k) = mean(FR_c_l);
		RA_cu(k) = mean(FR_c_r);
	else
		RA_i(k) = mean(FR_i_r);
		RA_c(k) = mean(FR_c_r);
		RA_cu(k) = mean(FR_c_l);
	end
	CII(k) = 100*(RA_c(k) - RA_i(k))./max([RA_i(k) RA_c(k)]); 
	CCI(k) = 100*(RA_c(k) - RA_cu(k))./max([RA_c(k) RA_cu(k)]);
	
	
	
end
[h,p] = ttest(RA_i,RA_c);
meanCII = mean(CII);

if TOPLOT,
	figure('Position',[300 300 500 900]);
	subplot(2,1,1)
	plot(RA_i,RA_c,'o');
	xlabel('instr FR');
	ylabel('choice FR');
	title(sprintf('instr FR %.2f, choice FR %.2f, p=%.2f, CII=%.1f% ',mean(RA_i),mean(RA_c),p,meanCII));

	axis equal
	axis square
	add_equality_line;
	
	subplot(2,1,2)
	plot(CII,CCI,'o');
	xlabel('CII');
	ylabel('CCI');
	% title(sprintf('instr FR %.2f, choice FR %.2f, p=%.2f, CII=%.1f% ',mean(RA_i),mean(RA_c),p,meanCII));

	axis equal
	axis square
	add_equality_line;
	
	corrcoef_eval(CII,CCI);
	
end





	
