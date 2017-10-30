function testsim_gain_field_dPulv2017(modulation_type)
% simulations of gain field effects and significance, including von Mises fitting
% see also testsim_gain_field for more generic version
% see also testsim_lip_activity_profile

if nargin < 1,
    modulation_type = 'linear_gain';
end


Noise		= 5;	% Firing rate noise
n_trials_per_cond = 10;

%
bootstrap_method='hierarchical';

% retinotopic Gaussian RF

Center              = 0;	% deg
Amplitude           = 50;	% spikes/s, RF response peak
UnmodulatedFR       = 5;	% spikes/s, ongoing/unmodulated firing
Sigma               = pi/4;	% tuning width
target_positions    = [-pi -pi*3/4 -pi/2 -pi/4 0 pi/4 pi/2 pi*3/4]; % retinotopic position
gaze_positions      = [-15 0 15];
retpos_continous	= -pi:pi/20:pi; % retinotopic position
gazepos_continous	= -20:20;       % gaze position

R		= 1/(sqrt(2*pi)*Sigma)*exp(-(retpos_continous - Center).^2/(2*Sigma^2)); % Gaussian RF profile
% R		= ones(size(retpos)); % no target position modulation
R		= UnmodulatedFR + R/max(R)*Amplitude;

n_trials_per_gaze=numel(target_positions)*n_trials_per_cond;

% target_positions2D_a =  [10    5 0  -5 -10  -5  0   5];
% target_positions2D_b =  [0.001 5 10 5 0.001 -5 -10 -5];
% target_positions2D = complex(target_positions2D_a,target_positions2D_b); % for MANOVA1 analysis


gaze_col = {'r' 'g' 'b'};

gaze_col_rgb = [227 6 19; 54 169 225; 243 146 0]/255;

% some additional comments to be detected in GitHub

switch modulation_type % eye position modulation type
    
    case 'linear_gain' %
        
        % E = interp1([gazepos(1) gazepos(end)],[-10 10],gazepos); % Gaze effect: leads to "loss" of main target effect
        % E = interp1([gazepos(1) 0 gazepos(end)],[10 0 10],gazepos); % Gaze effect: bidirectinal increase from center
        E = interp1([gazepos_continous(1) gazepos_continous(end)],[0.7 0],gazepos_continous); % Gaze effect: standard monotonic unidirectional
        % E = interp1([gazepos(1) gazepos(end)],[1 0.3],gazepos); % For CNL evaluatiom poster
        for k = 1:n_trials_per_cond
            FR(:,:,k) = E'*R + Noise*randn(length(gazepos_continous),length(retpos_continous)); % one trial
        end
        
    case 'linear_addition'
        E = interp1([gazepos_continous(1) gazepos_continous(end)],[10 0],gazepos_continous); % Gaze effect
        for k = 1:n_trials_per_cond
            FR(:,:,k) = 1*ones(size(gazepos_continous))'*R + 1*E'*ones(size(retpos_continous)) + Noise*randn(length(gazepos_continous),length(retpos_continous)); % one trial
        end
end

for g = 1:length(gaze_positions)
    col=gaze_col_rgb(g,:);
    gazepos_idx = find(gazepos_continous == gaze_positions(g));
    for t=1:length(target_positions)
        retpos_idx = find(retpos_continous == target_positions(t));
        for k = 1:1:n_trials_per_cond
            FRtarget(t,g,k) = FR(gazepos_idx,retpos_idx,k);
        end
    end
end

t_anova	= repmat(target_positions',[1,size(FRtarget,2),size(FRtarget,3)]);
g_anova	= repmat(gaze_positions,[size(FRtarget,1),1,size(FRtarget,3)]);


FRmean = mean(FR,3);
%FRmean = 1*ones(size(gazepos))'*R + 1*E'*ones(size(retpos)); % For CNL evaluatiom poster

% Plotting
figure;
surface(retpos_continous,gazepos_continous,FRmean); shading flat; hold on;
for g=1:numel(gaze_positions)
    plot3(retpos_continous,gaze_positions(g)*ones(size(retpos_continous)),FRmean(gazepos_continous == gaze_positions(g),:),'Color',gaze_col_rgb(g,:),'LineWidth',2);
    plot3(reshape(t_anova(:,g,:),1,n_trials_per_gaze),reshape(g_anova(:,g,:),1,n_trials_per_gaze),reshape(FRtarget(:,g,:),1,n_trials_per_gaze),'o','Color',gaze_col_rgb(g,:));
end
xlabel('retinotopic pos');
ylabel('gaze pos');



% von Mises
F = @(a,x) a(3)+a(1)*exp(cos(x-a(2))*a(4))*exp(a(4)*-1);
opts = optimset('lsqcurvefit');
opts.Display='off';

% ANOVA
%FRtarget4ANOVA	= FRtarget(:);t_anova=t_anova(:); g_anova=g_anova(:);


pct1 = 100*0.05/2; % alpha 0.05
pct2 = 100-pct1;
Positions=t_anova(:);
angles=Positions;
Gazes=g_anova(:);
FR_vectors=FRtarget(:).*exp(1i*Positions);
unique_positions=unique(Positions);
unique_lines_effector=numel(unique(Gazes));
FRs=FRtarget(:);
[p,table,stats,terms] = anovan(FRs,[Positions Gazes],'model','full','varnames',{'target' 'gaze'});
% c = multcompare(stats)

if 0 % one-way vs two-way ANOVA on gaze
    % the question here if presence of another factor (target position) affects the first factor, e.g. in the initial fixation period
    % for this, we should remove the the effect of target position from the simulation, set "no target position modulation" above
    [p,table,stats,terms] = anovan(FRtarget(:),g_anova(:),'model','full','varnames',{'gaze'});
    
    
end % of one-way vs two-way ANOVA on gaze


if 0 % MANOVA1, I do not think it is an appropriate test to detect gain field or a shift in a RF, due to huge variance
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
            FRpositions4MANOVA1     = [	FRpositions4MANOVA1;FRpositions4MANOVA1_];
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
    n_iterations_bootstrap = 1000;
    
    LB=double([0                 -pi    min(FRs)        1/pi]); %% Amplitude Direction Baseline Width
    UB=double([max([FRs;1])*1.3  pi     max([FRs;1])    10000]);%% Amplitude Direction Baseline Width
    X0=double([max(FRs)          0      min(FRs)        4/pi]); %% Amplitude Direction Baseline Width
    for lin = 1:max(unique_lines_effector)
        tr=Gazes'==gaze_positions(lin);
        mean_FR_angle=angle(mean(FR_vectors(tr)));
        %FRtarget4BOOTCI_ = FRtarget4BOOTCI(gaze_pos4MANOVA1==lin);
        
        %% bootstrapping
        n_samples_per_bootstrap=NaN;
        for p=1:numel(unique_positions)
            idexes_per_position{p}=find(Positions==unique_positions(p) & tr');
            FR_vector_per_position(p)=nanmean(FR_vectors(idexes_per_position{p}));
            n_samples_per_bootstrap=min([n_samples_per_bootstrap, numel(idexes_per_position{p})]);
        end
        
        if n_samples_per_bootstrap>=1%here should actually be 5!?
            for k=1:n_iterations_bootstrap
                idx_idx=cellfun(@(x) x(randsample(numel(x),10,true)),idexes_per_position,'Uniformoutput',false);
                idx_idx=[idx_idx{:}];
                bootstat(k,:)=[abs(nansum(FR_vectors(idx_idx(:)))/size(idx_idx,1)) angle(nansum(FR_vectors(idx_idx(:))/size(idx_idx,1))) 0 pi/4];
                bootstat_fit(k,:)=lsqcurvefit(F,double(X0),double(angles(idx_idx(:))),double(FRs(idx_idx(:))),LB,UB,opts);
            end
        else
            bootstat=single(NaN(n_iterations_bootstrap,4));
        end
        
        bootstat(:,2) = mod(bootstat(:,2)-mean_FR_angle+5*pi,2*pi)-pi+mean_FR_angle; % shift so CIs are around the mean
        bootstraped(lin).CI_amp   = [prctile(bootstat(:,1),pct1,1) nanmean(bootstat(:,1)) prctile(bootstat(:,1),pct2,1)];
        bootstraped(lin).CI_angle = [prctile(bootstat(:,2),pct1,1) nanmean(bootstat(:,2)) prctile(bootstat(:,2),pct2,1)];
        bootstraped(lin).CI_base  = [prctile(bootstat_fit(:,3),pct1,1) nanmean(bootstat_fit(:,3)) prctile(bootstat_fit(:,3),pct2,1)];
        bootstraped(lin).CI_kappa = [prctile(bootstat_fit(:,4),pct1,1) nanmean(bootstat_fit(:,4)) prctile(bootstat_fit(:,4),pct2,1)];
        
        bootstraped(lin).FR_vectors                 = bootstat(:,1).*exp(1i*bootstat(:,2));
        bootstraped(lin).mean_FR_vector             = nanmean(bootstraped(lin).FR_vectors);
        bootstraped(lin).original_mean_FR_vector    = nansum(FR_vector_per_position);
        % for plotting
        bootstraped(lin).mean_amp   = nanmean(bootstat(:,1));
        bootstraped(lin).mean_angle = mean(bootstat(:,2));
        bootstraped(lin).mean_base  = mean(bootstat_fit(:,3));
        bootstraped(lin).mean_kappa = mean(bootstat_fit(:,4));
        % for CIs
        bootstraped(lin).raw_amp   = bootstat(:,1);
        bootstraped(lin).raw_angle = bootstat(:,2);
        bootstraped(lin).raw_base  = bootstat_fit(:,3);
        bootstraped(lin).raw_kappa = bootstat_fit(:,4);
        
        %
        %         bootstat1 = bootstat(:,1);
        %         bootstat2 = bootstat(:,2);
        %         % bootstat2 = unwrap(bootstat2); % not working well in real life examples, according to Lukas
        %         mean_FR_angle = angle(mean(FRtarget4BOOTCI_));
        %         bootstat2 =  mod(bootstat(:,2)-mean_FR_angle+5*pi,2*pi)-pi+mean_FR_angle; % Lukas
        %
        %         pct1 = 100*0.05/2; % alpha 0.05
        %         pct2 = 100-pct1;
        %
        %         lower = prctile(bootstat1,pct1,1);
        %         upper = prctile(bootstat1,pct2,1);
        %         ci1 =[lower;upper];
        %         CI1(:,g) = ci1;
        %         meanBS1(g) = mean(bootstat1);
        %         BOOTSTAT1(:,g) = bootstat1;
        %
        %         lower = prctile(bootstat2,pct1,1);
        %         upper = prctile(bootstat2,pct2,1);
        %         ci2 =[lower;upper];
        %         CI2(:,g) = ci2;
        %         meanBS2(g) = mean(bootstat2);
        %
        %         subplot(1,2,1)
        %
        %         hp = polar([meanBS2(g) meanBS2(g)],[ci1(1) ci1(2)]); set(hp,'Color',gaze_col_rgb(g,:),'LineWidth',2); hold on;
        %
        %         th = linspace( ci2(1), ci2(2), 10);
        %         hp = polar(th,meanBS1(g)*ones(size(th)),[gaze_col{g}]); set(hp,'Color',gaze_col_rgb(g,:),'LineWidth',2);
        %         polar(angle(mean(FRtarget4BOOTCI_)),abs(mean(FRtarget4BOOTCI_)),'ko'); hold on
        %         polar(meanBS2(g),meanBS1(g),'kx');
        %
        %         subplot(1,2,2);
        %         hp = polar(bootstat2,bootstat1,[gaze_col{g} '.']); hold on
        %         set(hp,'Color',gaze_col_rgb(g,:));
        %
        
    end
    
    %% significance with CI overlap
    CI1=vertcat(bootstraped.CI_amp);
    Lower_bound=CI1(:,1);
    Mean_values=CI1(:,2);
    Upper_bound=CI1(:,3);
    %sign_diff = ~(bsxfun( @le, Lower_bound, Mean_values' ) & bsxfun( @ge, Upper_bound, Mean_values' ));
    sign_diff = ~(bsxfun( @le, Lower_bound, Upper_bound' ) & bsxfun( @ge, Upper_bound, Lower_bound' ));
    significant_gain1=any(any(sign_diff));
    
    for c_s=1:numel(bootstraped)+1 %% shifting always one by 2 pi to find overlaps around 0
        CI1=vertcat(bootstraped.CI_angle);
        if c_s<numel(bootstraped)
            CI1(c_s,:)= CI1(c_s,:)+2*pi;
        end
        Lower_bound=CI1(:,1);
        Mean_values=CI1(:,2);
        Upper_bound=CI1(:,3);
        %sign_diff = ~(bsxfun( @le, Lower_bound, Mean_values' ) & bsxfun( @ge, Upper_bound, Mean_values' ));
        sign_diff = ~(bsxfun( @le, Lower_bound, Upper_bound' ) & bsxfun( @ge, Upper_bound, Lower_bound' ));
        %
        significant_shift(c_s)=any(any(sign_diff));
    end
    significant_shift1=all(significant_shift); % only true if CIs are not overlapping for any 2*pi shift
    
    %% significance with CIs of differences
    temp1=true(numel(bootstraped));
    [temp2 temp3]=ind2sub(size(temp1),find(temp1));
    comparison_matrix=[temp2(temp2<temp3) temp3(temp2<temp3)];
    for c_s=1:size(comparison_matrix,1) %% shifting always one by 2 pi to find overlaps around 0
        tt=bootstraped(comparison_matrix(c_s,1)).raw_amp-bootstraped(comparison_matrix(c_s,2)).raw_amp;
        CI1_diff(c_s,:)=[prctile(tt,pct1,1) prctile(tt,pct2,1)];
        
        tt=bootstraped(comparison_matrix(c_s,1)).raw_angle-bootstraped(comparison_matrix(c_s,2)).raw_angle;
        %tt=[tt tt+pi tt-pi tt+2*pi tt-2*pi tt*3+pi tt-3*pi tt+4*pi tt-4*pi];
        tt=[tt tt+2*pi tt-2*pi tt+4*pi tt-4*pi];% ti ti+2*pi ti-2+pi ti+4*pi ti-4*pi];
        [~,totest_for_CI_indexes]=min(abs(tt),[],2);
        tt=tt(sub2ind(size(tt),1:size(tt,1),totest_for_CI_indexes'))';
        CI2_diff(c_s,:)=[prctile(tt,pct1,1) prctile(tt,pct2,1)];
    end
    significant_gain2=any(CI1_diff(:,1)>0 | CI1_diff(:,2)<0);
    significant_shift2=any(CI2_diff(:,1)>0 | CI2_diff(:,2)<0);
    
    
    
    
    %
    %     % test significance
    %
    %     BOOTSTAT_DIFF(:,1) = BOOTSTAT1(:,1) - BOOTSTAT1(:,2);
    %     BOOTSTAT_DIFF(:,2) = BOOTSTAT1(:,1) - BOOTSTAT1(:,3);
    %     BOOTSTAT_DIFF(:,3) = BOOTSTAT1(:,2) - BOOTSTAT1(:,3);
    %
    %     H = 0;
    %
    %     for k = 1:3, % 3 pair combinations
    %
    %         ci_l = prctile(BOOTSTAT_DIFF(:,k),pct1,1);
    %         ci_u = prctile(BOOTSTAT_DIFF(:,k),pct2,1);
    %         ci_diff =[ci_l;ci_u];
    %
    %         if ci_diff(1)>0 || ci_diff(2)<0;
    %             H = 1;
    %         end
    %
    %     end
    %    decision = {'not significant','significant'};
    
    figure_handle=figure;
    linespec.visible='off';
    markersize=20;
    max_FR_vector=max(abs(vertcat(bootstraped.FR_vectors)));
    polar(0, max_FR_vector,linespec);
    hold on
    for lin=1:max(unique_lines_effector)
        scatter(real([bootstraped(lin).FR_vectors]),imag([bootstraped(lin).FR_vectors]),5,gaze_col_rgb(lin,:));
        FR_vector=bootstraped(lin).mean_FR_vector;
        original_FR_vector=bootstraped(lin).original_mean_FR_vector;
        FR_Amp_CI=bootstraped(lin).CI_amp([1,end])*FR_vector/abs(FR_vector);
        FR_Ang_CI=exp(1i*bootstraped(lin).CI_angle)*abs(FR_vector);
        FR_Ang_CI_rad=exp(1i*[bootstraped(lin).CI_angle(1):pi/100:bootstraped(lin).CI_angle(end) bootstraped(lin).CI_angle(end)])*abs(FR_vector);
        plot(real(original_FR_vector),imag(original_FR_vector),'h','markersize',markersize,'markeredgecolor','k','color',gaze_col_rgb(lin,:),'Markerfacecolor',gaze_col_rgb(lin,:));
        plot(real(FR_vector),imag(FR_vector),'s','markersize',markersize,'markeredgecolor','k','color',gaze_col_rgb(lin,:),'Markerfacecolor',gaze_col_rgb(lin,:));
        plot(real(FR_Amp_CI),imag(FR_Amp_CI),'d-','linewidth',3,'markersize',markersize,'markeredgecolor','k','color',gaze_col_rgb(lin,:));
        %plot(real(bootstraped(lin).CI_amp(2)*FR_vector),imag(bootstraped(lin).CI_amp(2)*FR_vector),'d','color',gaze_col_rgb(lin,:));
        plot(real(FR_Ang_CI(1)),imag(FR_Ang_CI(1)),'d','linewidth',3,'markersize',markersize,'markeredgecolor','k','color',gaze_col_rgb(lin,:));
        plot(real(FR_Ang_CI(end)),imag(FR_Ang_CI(end)),'d','linewidth',3,'markersize',markersize,'markeredgecolor','k','color',gaze_col_rgb(lin,:));
        line([real(FR_Ang_CI_rad)],[imag(FR_Ang_CI_rad)],'linewidth',3,'color',gaze_col_rgb(lin,:))
    end
    
    title(num2str([significant_gain1 significant_shift1 significant_gain2 significant_shift2]));
    
    
    
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



