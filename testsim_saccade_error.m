function testsim_saccade_error
% the relationship between saccade response field (RF) and potential coding of (absolute) saccadic error
FR_noise		= 1;	% Firing rate noise
n_trials_per_cond	= 150;
sr			= 0.1; % spatial resolution (deg)

% retinotopic Gaussian RF
cx		= 15;	% deg
cy		= 0;	% deg
Amplitude	= 15;	% spikes/s, RF response peak
UnmodulatedFR	= 5;	% spikes/s, ongoing/unmodulated firing
sigma_x		= 5;	% tuning width 
sigma_y		= 5;	% tuning width 
retpos		= [-30:sr:30]; % retinotopic position
Rx		= 1/(sqrt(2*pi)*sigma_x)*exp(-(retpos - cx).^2/(2*sigma_x^2)); % Gaussian RF profile
Ry		= 1/(sqrt(2*pi)*sigma_y)*exp(-(retpos - cy).^2/(2*sigma_y^2)); % Gaussian RF profile
R2D		= Ry'*Rx;
R2D		= UnmodulatedFR + R2D/max(max(R2D))*Amplitude + FR_noise*randn(length(retpos),length(retpos));

% degrees:
target_positions2D_x =  [10	10	0	-10	-10	-10	0	10]; 
target_positions2D_y =  [0	10	10	10	0	-10	-10	-10];
sac_error_x	     =	[3	3	2	2	2	2	2	3]; 
sac_error_y = sac_error_x;

n_targets	= length(target_positions2D_x);
target_colormap = jet(n_targets);


figure(1);
for t = 1:n_targets,
	idx_x(t) = find(abs(retpos-target_positions2D_x(t)) == min(abs(retpos-target_positions2D_x(t))));
	idx_y(t) = find(abs(retpos-target_positions2D_y(t)) == min(abs(retpos-target_positions2D_y(t))));
	
	for k = 1:n_trials_per_cond
		
		% saccadic error in deg
		sex_deg(t,k) = sac_error_x(t)*randn;
		sey_deg(t,k) = sac_error_y(t)*randn;
		
		% saccadic error in samples
		sex(t,k) = fix(sex_deg(t,k)/sr);
		sey(t,k) = fix(sey_deg(t,k)/sr);
		
		FR(t,k) = R2D(idx_y(t) + sey(t,k), idx_x(t) + sex(t,k)); % one trial (note - order of x and y should be reversed like that)
		
		% abs_error(t,k) = sex_deg(t,k); % signed error x
		abs_error(t,k) = sqrt(sex_deg(t,k)^2 + sey_deg(t,k)^2); % absolute error
	end
	[c,p] = corrcoef_eval(abs_error(t,:),FR(t,:),0);
	subplot(1,n_targets,t);
	plot(abs_error(t,:),FR(t,:),'ko');
	lsline;
	disp(sprintf('target %d, correlation %.2f p %.2f',t,c,p));
end
disp('overall correlation');
corrcoef_eval(reshape(abs_error,1,n_trials_per_cond*n_targets),reshape(FR,1,n_trials_per_cond*n_targets),1);
		
% Plotting
figure;
surface(retpos,retpos,R2D); shading flat; hold on;
colormap(gray);
xlabel('x');
ylabel('y');


for t = 1:n_targets,	
	for k = 1:n_trials_per_cond
		plot3(retpos(idx_x(t)+sex(t,k)),retpos(idx_y(t)+sey(t,k)),FR(t,k),'o','Color',target_colormap(t,:));	
	end
	text(retpos(idx_x(t)),retpos(idx_y(t)),mean(FR(t,:)+5),num2str(t),'Color',[1 1 1]);
end



