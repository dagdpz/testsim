% function testsim_gain_field

% see also testsim_lip_activity_profile

Noise		= 5;	% Firing rate noise
n_trials_per_cond = 10;

%
modulation_type		= 'linear_gain';
bootstrap_method	= 'regular'; % 'hierarchical' or 'regular'

if 1 % re-create data
	
% retinotopic Gaussian RF
Center		= 0;	% deg
Amplitude	= 20;	% spikes/s, RF response peak
UnmodulatedFR	= 5;	% spikes/s, ongoing/unmodulated firing
Sigma		= 10;	% tuning width
retpos		= [-40:40]; % retinotopic position
R		= 1/(sqrt(2*pi)*Sigma)*exp(-(retpos - Center).^2/(2*Sigma^2)); % Gaussian RF profile
% R		= ones(size(retpos)); % no target position modulation
R		= UnmodulatedFR + R/max(R)*Amplitude;

target_positions = retpos(1):10:retpos(end);
target_positions2D_a =  [10    5 0  -5 -10  -5  0   5];
target_positions2D_b =  [0.001 5 10 5 0.001 -5 -10 -5];
target_positions2D = complex(target_positions2D_a,target_positions2D_b); % for MANOVA1 analysis
gaze_positions = [-15 0 15];
gazepos		= -20:20; % gaze position


gaze_col = {'r' 'g' 'b'};

gaze_col_rgb = [227 6 19; 54 169 225; 243 146 0]/255;

switch modulation_type % eye position modulation type
	
	case 'linear_gain' %
		
		% E = interp1([gazepos(1) gazepos(end)],[-10 10],gazepos); % Gaze effect: leads to "loss" of main target effect
		% E = interp1([gazepos(1) 0 gazepos(end)],[10 0 10],gazepos); % Gaze effect: bidirectinal increase from center
		E = interp1([gazepos(1) gazepos(end)],[2 1],gazepos); % Gaze effect: standard monotonic unidirectional
		
		
		for k = 1:n_trials_per_cond
			FR(:,:,k) = E'*R + Noise*randn(length(gazepos),length(retpos)); % one trial
		end
		
		
	case 'linear_addition'
		
		E = interp1([gazepos(1) gazepos(end)],[10 0],gazepos); % Gaze effect
		
		for k = 1:n_trials_per_cond
			FR(:,:,k) = 1*ones(size(gazepos))'*R + 1*E'*ones(size(retpos)) + Noise*randn(length(gazepos),length(retpos)); % one trial
		end
end

end % if re-create data


FRmean = mean(FR,3);

% Plotting
figure;
surface(retpos,gazepos,FRmean); shading flat; hold on;
plot3(retpos,gaze_positions(1)*ones(size(retpos)),FRmean(gazepos == gaze_positions(1),:),'Color',[1 1 1],'LineWidth',2);
plot3(retpos,gaze_positions(2)*ones(size(retpos)),FRmean(gazepos == gaze_positions(2),:),'Color',[1 1 1],'LineWidth',2);
plot3(retpos,gaze_positions(3)*ones(size(retpos)),FRmean(gazepos == gaze_positions(3),:),'Color',[1 1 1],'LineWidth',2);
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

if 0 % one-way vs two-way ANOVA on gaze
	% the question here if presence of another factor (target position) affects the first factor, e.g. in the initial fixation period
	% for this, we should remove the the effect of target position from the simulation, set "no target position modulation" above
	[p,table,stats,terms] = anovan(FRtarget4ANOVA,[gaze_pos],'model','full','varnames',{'gaze'});
	
	
end % of one-way vs two-way ANOVA on gaze


if 1 % MANOVA1, I do not think it is an appropriate test to detect gain field or a shift in a RF, due to huge variance
	% (but we use some of the code for the bootstrp (see next case))
	
	FRtarget4MANOVA1 = [];
	FRtarget4BOOTCI  = [];
	FRpositions4MANOVA1=[];
	FR4BOOTCI	 = [];
	
	gaze_pos4MANOVA1 = [];
	figure;
	
	
	for g = 1:length(gaze_positions)
		for t=1:length(target_positions)-1,
			
			FRtarget4MANOVA1_ = squeeze(FRtarget(t,g,:))*target_positions2D(t)/abs(target_positions2D(t)); % original Lukas formulation
			FRpositions4MANOVA1_ = repmat([target_positions2D(t) gaze_positions(g)],numel(FRtarget4MANOVA1_),1); % original Lukas formulation
			
			plot(FRtarget4MANOVA1_,'.','Color',gaze_col_rgb(g,:)); hold on;
			
			% FOR ANOVA
			FRtarget4MANOVA1	= [FRtarget4MANOVA1; [real(FRtarget4MANOVA1_) imag(FRtarget4MANOVA1_)]];
			gaze_pos4MANOVA1	= [gaze_pos4MANOVA1; g*ones(n_trials_per_cond,1)];
			% FOR BOOTCI
			FRpositions4MANOVA1     = [FRpositions4MANOVA1; FRpositions4MANOVA1_];
			FRtarget4BOOTCI         = [FRtarget4BOOTCI; FRtarget4MANOVA1_];
			
			% here we define the indexes that later are used to do hierarchical bootstraping
			indexes_per_position{g,t}=find(FRpositions4MANOVA1(:,1)==target_positions2D(t) & FRpositions4MANOVA1(:,2)==gaze_positions(g));
		end
		plot(mean(FRtarget4MANOVA1(gaze_pos4MANOVA1==g,1)), mean(FRtarget4MANOVA1(gaze_pos4MANOVA1==g,2)),'*','Color',gaze_col_rgb(g,:)); % vector mean
		
	end
	axis equal
	% plot(FRtarget4MANOVA1(:,1), FRtarget4MANOVA1(:,2),'.');
	
	% [D, p] = manova1(FRtarget4MANOVA1,gaze_pos4MANOVA1) % see testsim_manova1.m
	
end % of MANOVA1

if 1 % test gain field via bootstrap - on trial-by-trial FR vectors per target in a complex 2D space, abs and angle, NEEDS FRtarget4BOOTCI
	figure
	n_boot = 1000;
	for g = 1:length(gaze_positions)
		
		FRtarget4BOOTCI_ = FRtarget4BOOTCI(gaze_pos4MANOVA1==g);
		
		% THIS IS USING bootci, BUT WE CANNOT USE bootci for angle (because of phase wrapping)
		% THEREFORE USE bootstrp and calculate CI as percentiles
		% 		fun1 = @(x)abs(mean(x));
		%
		% 		[ci1,bootstat1] = bootci(500, {fun1, FRtarget4BOOTCI_},'type','bca'); % amplitude
		% 		CI1(:,g) = ci1;
		% 		meanBS1(g) = mean(bootstat1);
		
		%regular bootstrap
		if strcmp(bootstrap_method,'regular')
			fun = @(x)[abs(mean(x)) angle(mean(x))];
			bootstat = bootstrp(n_boot, fun, FRtarget4BOOTCI_);
		elseif strcmp(bootstrap_method,'hierarchical') % 'balanced across target positions' bootstrap		
			for k=1:n_boot
				boots_idx=cellfun(@(x) x(randsample(numel(x),10,true)),indexes_per_position(g,:),'Uniformoutput',false);
				boots_idx=[boots_idx{:}];
				bootstat(k,:)=[abs(nanmean(FRtarget4BOOTCI(boots_idx(:)))) angle(nanmean(FRtarget4BOOTCI(boots_idx(:))))];
			end
		end
		bootstat1 = bootstat(:,1);
		bootstat2 = bootstat(:,2);
		% bootstat2 = unwrap(bootstat2); % not working well in real life examples, according to Lukas
		mean_FR_angle = angle(mean(FRtarget4BOOTCI_));
		bootstat2 =  mod(bootstat(:,2)-mean_FR_angle+5*pi,2*pi)-pi+mean_FR_angle; % Lukas
		
		pct1 = 100*0.05/2; % alpha 0.05
		pct2 = 100-pct1;
		
		lower = prctile(bootstat1,pct1,1);
		upper = prctile(bootstat1,pct2,1);
		ci1 =[lower;upper];
		CI1(:,g) = ci1;
		meanBS1(g) = mean(bootstat1);
		BOOTSTAT1(:,g) = bootstat1;
		
		lower = prctile(bootstat2,pct1,1);
		upper = prctile(bootstat2,pct2,1);
		ci2 =[lower;upper];
		CI2(:,g) = ci2;
		meanBS2(g) = mean(bootstat2);
		
		subplot(1,2,1)
		
		hp = polar([meanBS2(g) meanBS2(g)],[ci1(1) ci1(2)]); set(hp,'Color',gaze_col_rgb(g,:),'LineWidth',2); hold on;
		
		th = linspace( ci2(1), ci2(2), 10);
		hp = polar(th,meanBS1(g)*ones(size(th)),[gaze_col{g}]); set(hp,'Color',gaze_col_rgb(g,:),'LineWidth',2);
		polar(angle(mean(FRtarget4BOOTCI_)),abs(mean(FRtarget4BOOTCI_)),'ko'); hold on
		polar(meanBS2(g),meanBS1(g),'kx');
		
		subplot(1,2,2);
		hp = polar(bootstat2,bootstat1,[gaze_col{g} '.']); hold on
		set(hp,'Color',gaze_col_rgb(g,:));
		
		
	end
	
	% test significance
	
	BOOTSTAT_DIFF(:,1) = BOOTSTAT1(:,1) - BOOTSTAT1(:,2);
	BOOTSTAT_DIFF(:,2) = BOOTSTAT1(:,1) - BOOTSTAT1(:,3);
	BOOTSTAT_DIFF(:,3) = BOOTSTAT1(:,2) - BOOTSTAT1(:,3);
	
	H = 0;
	
	for k = 1:3, % 3 pair combinations
		
		ci_l = prctile(BOOTSTAT_DIFF(:,k),pct1,1);
		ci_u = prctile(BOOTSTAT_DIFF(:,k),pct2,1);
		ci_diff =[ci_l;ci_u];
		
		if ci_diff(1)>0 || ci_diff(2)<0;
			H = 1;
		end
		
	end
	decision = {'not significant','significant'};
	title(decision(H+1));
	
	
	
end % of if test gain field via bootstrap - on trial-by-trial FR vectors in 2D space

if 0 % test gain field via bootstrap - simple example on mean FR in each gaze position
	figure
	for g = 1:length(gaze_positions)
		FR = reshape(squeeze(FRtarget(:,g,:)),n_trials_per_cond*length(target_positions),1);
		meanFR = mean(FR);
		fun = @(x)mean(x);
		
		[ci,bootstat] = bootci(500, fun, FR);
		
		CI(:,g) = ci;
		meanBS(g) = mean(bootstat);
		plot(g,meanFR,'ko'); hold on
		plot(g,meanBS(g),'r.');
		plot(g,ci,'rs');
	end
	
end % of if test gain field via bootstrap - simple example on mean FR in each gaze position

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



