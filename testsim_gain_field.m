function testsim_gain_field(modulation_type)

if nargin < 1,
	modulation_type = 'linear_gain';
end
	
% see also testsim_lip_activity_profile

Noise		= 50;	% Firing rate noise
n_trials_per_cond = 10;

% retinotopic Gaussian RF

Center		= 0;	% deg
Amplitude	= 20;	%spikes/s
Sigma		= 10;	% tuning width 
retpos		= [-40:40]; % retinotopic position
R		= 1/(sqrt(2*pi)*Sigma)*exp(-(retpos - Center).^2/(2*Sigma^2)); % Gaussian RF profile
% R		= ones(size(retpos)); % no target position modulation
R		= R/max(R)*Amplitude;

target_positions = retpos(1):10:retpos(end);

gaze_positions = [-15 0 15];
gazepos		= -20:20; % gaze position
		
switch modulation_type % eye position modulation type
	
	case 'linear_gain' % 

		% E = interp1([gazepos(1) gazepos(end)],[-10 10],gazepos); % Gaze effect: leads to "loss" of main target effect
		% E = interp1([gazepos(1) 0 gazepos(end)],[10 0 10],gazepos); % Gaze effect: bidirectinal increase from center
		E = interp1([gazepos(1) gazepos(end)],[1.5 0],gazepos); % Gaze effect: standard monotonic unidirectional 
		
		
		for k = 1:n_trials_per_cond
			FR(:,:,k) = E'*R + Noise*randn(length(gazepos),length(retpos)); % one trial
		end

		
	case 'linear_addition'
		
		E = interp1([gazepos(1) gazepos(end)],[10 0],gazepos); % Gaze effect
		
		for k = 1:n_trials_per_cond
			FR(:,:,k) = 1*ones(size(gazepos))'*R + 1*E'*ones(size(retpos)) + Noise*randn(length(gazepos),length(retpos)); % one trial
		end
end


FRmean = mean(FR,3);

% Plotting
figure;
surface(retpos,gazepos,FRmean); shading flat; hold on;
plot3(retpos,gaze_positions(1)*ones(size(retpos)),FRmean(gazepos == gaze_positions(1),:),'Color',[1 1 1]);
plot3(retpos,gaze_positions(2)*ones(size(retpos)),FRmean(gazepos == gaze_positions(2),:),'Color',[1 1 1]);
plot3(retpos,gaze_positions(3)*ones(size(retpos)),FRmean(gazepos == gaze_positions(3),:),'Color',[1 1 1]);
xlabel('retinotopic pos');
ylabel('gaze pos');
FRtarget4ANOVA = [];
target_pos = [];
gaze_pos = [];

for k = 1:1:n_trials_per_cond,
	for t=1:length(target_positions),
		retpos_idx = find(retpos == target_positions(t));
		for g = 1:length(gaze_positions)
			gazepos_idx = find(gazepos == gaze_positions(g));
			FRtarget(t,g,k) = FR(gazepos_idx,retpos_idx,k);
			plot3(retpos(retpos_idx),gazepos(gazepos_idx),FRtarget(t,g,k),'o','Color',[0 0 0]);
			
			% FOR ANOVA
			FRtarget4ANOVA	= [FRtarget4ANOVA; FRtarget(t,g,k)];
			target_pos	= [target_pos; t];
			gaze_pos	= [gaze_pos; g];
			
		end
	end
end

% ANOVA

[p,table,stats,terms] = anovan(FRtarget4ANOVA,[target_pos gaze_pos],'model','full','varnames',{'target' 'gaze'});
% c = multcompare(stats)

if 1 % one-way vs two-way ANOVA on gaze
	% the question here if presence of another factor (target position) affects the first factor, e.g. in the initial fixation period
	% for this, we should remove the the effect of target position from the simulation, set "no target position modulation" above
	[p,table,stats,terms] = anovan(FRtarget4ANOVA,[gaze_pos],'model','full','varnames',{'gaze'});
	
	
end % of 


if 0 % Test different ANOVA variants
% 3 gaze positions, 2 or 3 targets, 10 trials

Noise			= 1;	% Firing rate noise
n_trials_per_cond	= 10;

% variant 1: no main effects, only interaction
FRtarget4ANOVA = repmat(reshape([	10 0
					0 10
					5 5],6,1),n_trials_per_cond,1) + Noise*randn(3*2*10,1);			
target_pos	= repmat([1;1;1;2;2;2],n_trials_per_cond,1);
gaze_pos	= repmat([1;2;3;1;2;3],n_trials_per_cond,1);
[p,table,stats,terms] = anovan(FRtarget4ANOVA,[target_pos gaze_pos],'model','full','varnames',{'target' 'gaze'});

% variant 2: no main effects, only interaction
FRtarget4ANOVA = repmat(reshape([	0 10
					5 5
					10 0],6,1),n_trials_per_cond,1) + Noise*randn(3*2*10,1);			
target_pos	= repmat([1;1;1;2;2;2],n_trials_per_cond,1);
gaze_pos	= repmat([1;2;3;1;2;3],n_trials_per_cond,1);
[p,table,stats,terms] = anovan(FRtarget4ANOVA,[target_pos gaze_pos],'model','full','varnames',{'target' 'gaze'});

% variant 3: target effect and interaction
FRtarget4ANOVA = repmat(reshape([	0 10 40
					5 15 30
					10 20 20],9,1),n_trials_per_cond,1) + Noise*randn(3*3*10,1);			
target_pos	= repmat([1;1;1;2;2;2;3;3;3],n_trials_per_cond,1);
gaze_pos	= repmat([1;2;3;1;2;3;1;2;3],n_trials_per_cond,1);
[p,table,stats,terms] = anovan(FRtarget4ANOVA,[target_pos gaze_pos],'model','full','varnames',{'target' 'gaze'});

end % of Test different ANOVA variants

