function testsim_von_mises_fits
base_directory='Y:\Projects\Pulv_bodysignal\fitsims\';
n_rep        = 100; %% number of units simulated

activities=[2,10,100]; %% average firing rates
n_rpeaks     = 1000;  % number of cycles in which we collected spikes
pvalue       = 0.01;

%spikes_for_average=[20,50,100,10];
%N_averages=[10,20,50,100];
N_averages=[20];

modulation_indexes = [0.1 0.25 0.5 1]; %% modulation indexes for udnerlying simulated sinus/von mises distributions
modulation_phase=pi/4;

bin_list     = [32, 64, 128];



cos_mod      = fittype('a*cos(x-b)+c');% a - scaling factor, b - phase of the peak, c - intercept
%vonMises_mod = fittype('a1*( exp( k1*(cos(x-t1)) ) / (2*pi*besseli(0, k1)) )'); % a1 - scaling factor, k1 - kappa, t1 - peak phase, d1 - intercept



vonMises_mod = fittype('a1*(exp(k1*(cos(x-t1)-1)) - exp(-2*k1)) / (1 - exp(-2*k1)) + d1');

vonMises_fun = @(a,x) a(1)*(exp(a(3)*(cos(x-a(4))-1)) - exp(-2*a(3))) / (1 - exp(-2*a(3))) + a(2)';

vonMises_normalized = fittype('a1*exp(k1*(cos(x-t1)))/sum(exp(k1*cos(x))) + d1'); % a1 - scaling factor, k1 - kappa, t1 - peak phase, d1 - intercept
vonMises_unnormalized = fittype('a1*exp(k1*(cos(x-t1))) + d1'); % a1 - scaling factor, k1 - kappa, t1 - peak phase, d1 - intercept
for n_for_average=1:numel(N_averages);
for fr=1:numel(activities)
    AV_FR        = activities(fr); % Average firing rate in spikes/cycle
    
    dist_types   = {'R', 'RC', 'RvM'}; % random, noisy cosine, noisy von Mises
    dist_names   = {'cosine', 'vonMises'};
    orig_dist    = {'C', 'vM'};
    
    
%     N_spikes_per_average=spikes_for_average(n_for_average);    
%     subdir=['FR_' num2str(AV_FR) '_Nsp_per_average_' num2str(N_spikes_per_average) '_Nrpeaks_' num2str(n_rpeaks) '_pval_' num2str(pvalue)];
        
    AVGS=N_averages(n_for_average);    
    subdir=['FR_' num2str(AV_FR) '_N_averages' num2str(AVGS) '_Nrpeaks_' num2str(n_rpeaks) '_pval_' num2str(pvalue)];
    
    base_directory_to_save=[base_directory subdir '\'];
    if ~exist(base_directory_to_save,'dir')
        mkdir(base_directory,subdir);
    end
    
    % - 0.1592*a1
    clear out;
    for n_level = 1:length(modulation_indexes)
        
        % loop through bin numbers
        for n_bins = 1:length(bin_list)
            
            modulation_index = modulation_indexes(n_level); % ratio peak/mean fr
            disp(['MI: ' num2str(modulation_index), ' nbins: ' num2str(bin_list(n_bins))]);
            
            av_spikes_per_bin = AV_FR/bin_list(n_bins);
            amp               = av_spikes_per_bin*modulation_index; %% max-min
            phasebinedges     = 0 : 2*pi/bin_list(n_bins) : 2*pi;
            phasebincenters   = phasebinedges(1:end-1)+2*pi/bin_list(n_bins);
            phasebins_for_distributions   = 0 : 2*pi/100 : 2*pi; phasebins_for_distributions(1)=[];
            
            % some calculations for the simulated von mises to have same modulation index as respective cosine
            kappa=3;
            BL_VM=av_spikes_per_bin;
            
            FK=floor(n_rpeaks/AVGS);            
            mod_cycles=n_rpeaks-FK*AVGS;
            
            %FK=max(round(N_spikes_per_average/AV_FR),1);
            %mod_cycles=mod(n_rpeaks,FK);
            n_cycles=(n_rpeaks-mod_cycles)/FK;
            %FK=n_rpeaks/round(n_rpeaks/FKapprox);
            x = repmat(phasebincenters,1,n_cycles);
            
            
            R = reshape(randsample(phasebins_for_distributions,AV_FR*n_rep*n_cycles*FK,true),AV_FR*FK,n_cycles,n_rep);
            R=histc(R,phasebinedges);
            R(end,:,:)=[];
            R=shiftdim(R,2);
            R=reshape(R,n_rep,size(R,2)*n_cycles);            
            
%             U = reshape(randsample(phasebincenters,AV_FR*n_rep*n_cycles*FK,true),AV_FR*FK,n_cycles,n_rep);
%             U=histc(U,phasebinedges);
%             U(end,:,:)=[];
%             U=shiftdim(U,2);
%             U=reshape(U,n_rep,size(U,2)*n_cycles);
            
            VM = reshape(randsample(phasebins_for_distributions,AV_FR*n_rep*n_cycles*FK,true,vonMises_mod(amp, BL_VM,kappa, modulation_phase, phasebins_for_distributions)),AV_FR*FK,n_cycles,n_rep);
            VM=histc(VM,phasebinedges);
            VM(end,:,:)=[];
            VM=shiftdim(VM,2);
            VM=reshape(VM,n_rep,size(VM,2)*n_cycles);
            
            C = reshape(randsample(phasebins_for_distributions,AV_FR*n_rep*n_cycles*FK,true,cos_mod(amp/2,modulation_phase, av_spikes_per_bin, phasebins_for_distributions)),AV_FR*FK,n_cycles,n_rep);
            C=histc(C,phasebinedges);
            C(end,:,:)=[];
            C=shiftdim(C,2);
            C=reshape(C,n_rep,size(C,2)*n_cycles);
            
            %         data.R{n_bins,n_level}  = R(:)'; % use uniformly distributed random data
            %         data.C{n_bins,n_level}  = C(:)';              % simulate cosine
            %         data.vM{n_bins,n_level} = VM(:)';             % simulate von Mises distribution with theta-hat = pi, kappa = 4
            
%             data.R{n_bins,n_level}  = R; % use uniformly distributed random data
%             data.C{n_bins,n_level}  = C;              % simulate cosine
%             data.vM{n_bins,n_level} = VM;             % simulate von Mises distribution with theta-hat = pi, kappa = 4
%             
%             
            data.RC{n_bins,n_level}  = C; %bsxfun(@plus, R, C); % noisy cosine
            data.RvM{n_bins,n_level} = VM; %bsxfun(@plus, R,VM); % noisy von Mises distribution
            data.R{n_bins,n_level}   = R;%bsxfun(@plus, R,U); % noise + uniform firing rate
            
            
            
            % loop through distributions
            tM=0;tC=0;tV=0;tCp=0;tVp=0;
            for n_type = 1:length(dist_types)
                D = dist_types{n_type};
                % I. Check to circular uniformity: compute O-test for both cosine and noisy data
%                 for ii = 1:n_rep
%                     out.(D).p_otest(ii)  = circ_otest(x, [], data.(D){n_bins,n_level}(ii,:));
%                 end
%                 
%                 % figure out decisions of O-test at the population level
%                 out.(D).n_nonsig(n_bins,n_level)  = 100*sum(out.(D).p_otest > pvalue)/n_rep;  % percentage of noisy curves assigned as uniformly distributed
%                 out.(D).n_sig(n_bins,n_level)     = 100*sum(out.(D).p_otest < pvalue)/n_rep;  % percentage of noisy curves assigned as non-unifirmly distributed
%                 
                % II. Compute Mosher's procedure
%                 tic
%                 %[out.(D).modIndex{n_bins,n_level}, out.(D).removeNoise{n_bins,n_level}] = fitCardiacModulation(x, data.(D){n_bins,n_level}, {'PSTH'}, 0);
%                 av=reshape(data.(D){n_bins,n_level},size(data.(D){n_bins,n_level},1),numel(phasebinedges)-1,size(data.(D){n_bins,n_level},2)/(numel(phasebinedges)-1));
%                 av=squeeze(sum(av,3));
%                 out.(D).modIndex{n_bins,n_level} = fitCardiacModulation(phasebinedges,av, {'PSTH'}, 0);
%                 tM=tM+toc;
                
                % III. Compute fits with 'fit' function
                for ii = 1:n_rep
                    
                    % 1. Figure out starting parameters
                    % 1.1. figure out starting parameters for cosine fit
                    %                 currCurve = data.(D){n_bins,n_level}(ii,:)';
                    currCurve = data.(D){n_bins,n_level}(ii,:)';
                    a = (max(currCurve) - min(currCurve))/2;
                    b = circ_mean(x, currCurve');
                    c = mean(currCurve);
                    
                    startPoint_cos = [a b c];% a - scaling factor, b - phase of the peak, c - intercept
                    %                 options = optimoptions('lsqcurvefit', 'Display', 'off'); %, 'UseParallel', true
                    
                    % 1.2. figure out starting parameters for von Mises fit
                    a1 = max(currCurve)-min(currCurve);
                    k1 = exp(2); %circ_kappa(x, currCurve' - mean(currCurve) + 0.1592);
                    t1 = circ_mean(x, currCurve');
                    d1 = min(currCurve);
                    kmax=log(0.5)/(cos(phasebinedges(3))-1);
                    
                    
                    startPoint_vm = [a1 d1 k1 t1];% a1 - scaling factor, k1 - kappa, t1 - peak phase, d1 - intercept
                    
                    tic
                    [fittedmdl,gof] = fit(x',currCurve,cos_mod,'StartPoint',startPoint_cos, 'Lower', [-Inf -Inf -pi], 'Upper', [Inf Inf 3*pi]);
                    tC=tC+toc;
                    
                    coefs = coeffvalues(fittedmdl); % get model coefficients
                    
                    yfit = cos_mod(coefs(1),coefs(2),coefs(3),x);
                    
                    out.(D).cosine.coefs{n_bins,n_level}(ii,:)  = coefs;
                    out.(D).cosine.yfit{n_bins,n_level}(ii,:)   = yfit;
                    out.(D).cosine.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                    
                    % employ a linear fit to get a p-value vs. fitting with a
                    % constant model
                    tic
                    mdl = fitlm(currCurve, yfit);
                    tCp=tCp+toc;
                    
                    out.(D).cosine.pvalue{n_bins,n_level}(ii)   = mdl.Coefficients.pValue(2);
                    
                    clear fittedmdl gof coefs yfit mdl
                    
                    tic
                    [fittedmdl,gof,output] = fit(x',currCurve,vonMises_mod,'StartPoint',startPoint_vm, 'Lower', [0 0 0 -pi], 'Upper', [1000 1000 kmax 3*pi]);
                    tV=tV+toc;
                    
                    coefs = coeffvalues(fittedmdl); % get model coefficients
                    
                    yfit = vonMises_mod(coefs(1),coefs(2),coefs(3), coefs(4), x);
                    
                    out.(D).vonMises.coefs{n_bins,n_level}(ii,:)  = coefs;
                    out.(D).vonMises.yfit{n_bins,n_level}(ii,:)   = yfit;
                    out.(D).vonMises.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                    
                    % employ a linear fit to get a p-value vs. fitting with a
                    % constant model
                    
%                     AA=reshape(currCurve,32,10);
%                     tempmean=mean(mean(AA,2));                    
%                     [B,SE,PVAL,in] = stepwisefit([repmat(tempmean,size(yfit))' yfit' ],currCurve,'display','off');
                    
                    tic
                    mdl = fitlm(yfit, currCurve);
                    tVp=tVp+toc;
                    out.(D).vonMises.pvalue{n_bins,n_level}(ii)   = mdl.Coefficients.pValue(2);
                    
                    clear fittedmdl gof coefs yfit mdl
                end
            end
            
            %disp(['fitCardiacModulation took ' num2str(tM) ' seconds'])
            disp(['cosine fitting took ' num2str(tC) 'seconds'])
            disp(['cosine p-value estimation took ' num2str(tCp) 'seconds'])
            disp(['von mises fit took ' num2str(tV) 'seconds'])
            disp(['von mises p value estimation took ' num2str(tVp) 'seconds'])
        end
    end
    
    
    %% Plot the resulting curves
    for n_level = 1:length(modulation_indexes)
        
        % loop through bin numbers
        for n_bins = 1:length(bin_list)
            
            %xunique = pi/bin_list(n_bins) : 2*pi/bin_list(n_bins) : 2*pi-pi/bin_list(n_bins);
            %x = repmat(xunique,1,n_rpeaks);
             
            
            FK=floor(n_rpeaks/AVGS);            
            mod_cycles=n_rpeaks-FK*AVGS;
            
            %FK=max(round(N_spikes_per_average/AV_FR),1);
            %mod_cycles=mod(n_rpeaks,FK);
            n_cycles=(n_rpeaks-mod_cycles)/FK;
            
            phasebinedges = 0 : 2*pi/bin_list(n_bins) : 2*pi;
            phasebincenters = phasebinedges(1:end-1)+2*pi/bin_list(n_bins);
            x = repmat(phasebincenters,1,n_cycles);
            
            for n_type = 1:length(dist_types)
                % example fits - cosine + Luba's cosine fit
                figure(500+n_type)
                set(500+n_type, 'Position', [591 42 893 954])
                subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
                plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
                hold on
                plot(x, out.(dist_types{n_type}).cosine.yfit{n_bins,n_level}(1,:))
                title(['Rsq = ' num2str(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level}(1))])
                
                if n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                    print(500+n_type,[base_directory_to_save 'Example: ' dist_types{n_type} ' + cosine fit by Luba'],'-dpng');
                end
                %title(['Example fits: ' dist_types{n_type} ' + cosine fit by Luba'])
                
                % example fits - cosine + Luba's von Mises fit
                figure(510+n_type)
                set(510+n_type, 'Position', [591 42 893 954])
                subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
                plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
                hold on
                plot(x,out.(dist_types{n_type}).vonMises.yfit{n_bins,n_level}(1,:))
                title(['Rsq = ' num2str(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level}(1))])
                
                if n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                    print(510+n_type,[base_directory_to_save 'Example: ' dist_types{n_type} ' + von Mises fit by Luba'],'-dpng');
                end
                %title(['Example fits: ' dist_types{n_type} ' + von Mises fit by Luba'])
                
            end
            
%             % significance of the cosine fit by Mosher
%             figure(1000)
%             set(1000, 'Position', [591 42 893 954])
%             subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             for ii = 1:length(dist_types)
%                 h_sig(ii)    = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < pvalue);
%                 h_nonsig(ii) = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) > pvalue);
%             end
%             bar_data = [h_sig; h_nonsig];
%             bar(bar_data', 'stacked')
%             if n_level == 1 && n_bins == 1
%                 legend({'sig', 'nonsig'})
%                 xlabel('Distribution Type')
%                 ylabel('# Cases')
%                 set(gca, 'XTickLabel', dist_types)
%             elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
%                 print(1000,[base_directory_to_save 'Fit Significance of Mosher''s procedure'],'-dpng');
%             end
            
            % significance of the cosine fit by Luba
            figure(1001)
            set(1001, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                h_sig(ii)    = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} < pvalue);
                h_nonsig(ii) = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} > pvalue);
            end
            bar_data = [h_sig; h_nonsig];
            bar(bar_data', 'stacked')
            if n_level == 1 && n_bins == 1
                legend({'sig', 'nonsig'})
                xlabel('Distribution Type')
                ylabel('# Cases')
                set(gca, 'XTickLabel', dist_types)
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(1001,[base_directory_to_save 'Fit Significance of Cosine Fits by Luba'],'-dpng');
            end
            
            % significance of the von Mises fit by Luba
            figure(1002)
            set(1002, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                h_sig(ii)    = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} < pvalue);
                h_nonsig(ii) = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} > pvalue);
            end
            bar_data = [h_sig; h_nonsig];
            bar(bar_data', 'stacked')
            if n_level == 1 && n_bins == 1
                legend({'sig', 'nonsig'})
                xlabel('Distribution Type')
                ylabel('# Cases')
                set(gca, 'XTickLabel', dist_types)
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(1002,[base_directory_to_save 'Fit Significance of von Mises Fits by Luba'],'-dpng');
            end
            
            
%             % R-squred from Mosher's procedure for noise, cosine and von Mises
%             % distribution
%             figure(3000)
%             set(3000, 'Position', [591 42 893 954])
%             subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             for ii = 1:length(dist_types)
%                 Rsq(ii, :) = out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4);
%             end
%             hist(Rsq')
%             xlim([-0.1 1.1])
%             if n_level == 1 && n_bins == 1
%                 xlabel('R-squared')
%                 ylabel('Counts')
%                 legend(dist_types, 'Location', 'best')
%             elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
%                 print(3000,[base_directory_to_save 'R-squared for Mosher''s Cosine Fits'],'-dpng');
%             end
%             clear Rsq
            
            % R-squared for cosine fits by Luba
            figure(4000)
            set(4000, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                Rsq(ii, :) = histc(out.(dist_types{ii}).cosine.rsquared{n_bins,n_level}, 0:0.1:1);
            end
            bar(0:0.1:1, Rsq')
            xlim([-0.1 1.1])
            if n_level == 1 && n_bins == 1
                legend(dist_types, 'Location', 'best')
                xlabel('R-squared')
                ylabel('Counts')
                title(bin_list(n_bins))
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(4000,[base_directory_to_save 'R-squared for Cosine Fits by Luba'],'-dpng');
            end
            clear Rsq
            
            % R-squared for von Mises fits by Luba
            figure(4001)
            set(4001, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                Rsq(ii, :) = histc(out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level}, 0:0.1:1);
            end
            bar(0:0.1:1, Rsq')
            xlim([-0.1 1.1])
            if n_level == 1 && n_bins == 1
                legend(dist_types, 'Location', 'best')
                xlabel('R-squared')
                ylabel('Counts')
                title(bin_list(n_bins))
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(4001,[base_directory_to_save 'R-squared for von Mises Fits by Luba'],'-dpng');
            end
            clear Rsq
            
            %         % scaling factors coming from COSINE fits by Luba
            %         figure(5000)
            %         set(5000, 'Position', [591 42 893 954])
            %         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            %         for ii = 1:length(dist_types)
            %             coeff(ii, :) = out.(dist_types{ii}).cosine.coefs{n_bins,n_level}(:,1);
            %         end
            %         hist(coeff')
            %         if n_level == 1
            %             title(bin_list(n_bins))
            %         end
            %         if n_level == 1 && n_bins == 1
            %             xlabel('Scaling Factors: a')
            %             ylabel('Counts')
            %             legend(dist_types, 'Location', 'best')
            %         end
            %         title('Scaling Factors for Cosine Fits by Luba')
            
            % cosine phases coming from COSINE fits by Luba
            figure(6000)
            set(6000, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                cosPh(ii,:) = mod(out.(dist_types{ii}).cosine.coefs{n_bins,n_level}(:,2), 2*pi);
            end
            hist(cosPh')
            xlim([0 2*pi])
            if n_level == 1
                title(bin_list(n_bins))
            end
            if n_level == 1 && n_bins == 1
                legend(dist_types, 'Location', 'best')
                xlabel('Cosine Phases: b')
                ylabel('Counts')
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(6000,[base_directory_to_save 'Phases for Cosine Fits by Luba'],'-dpng');
            end
            clear cosPh
            
            %         % scaling factors coming from VON MISES fits by Luba
            %         figure(6500)
            %         set(6500, 'Position', [591 42 893 954])
            %         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            %         for ii = 1:length(dist_types)
            %             coeff(ii, :) = out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,1);
            %         end
            %         hist(coeff')
            %         if n_level == 1
            %             title(bin_list(n_bins))
            %         end
            %         if n_level == 1 && n_bins == 1
            %             xlabel('Scaling Factors: a')
            %             ylabel('Counts')
            %             legend(dist_types, 'Location', 'best')
            %         end
            %         title('Scaling Factors for von Mises Fits by Luba')
            
            % von Mises phases from fits by Luba
            figure(7000)
            set(7000, 'Position', [591 42 893 954])
            subplot(length(modulation_indexes),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            for ii = 1:length(dist_types)
                vmPh(ii,:) = out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,4);
            end
            hist(vmPh')
            xlim([0 2*pi])
            if n_level == 1
                title(bin_list(n_bins))
            end
            if n_level == 1 && n_bins == 1
                legend(dist_types, 'Location', 'best')
                xlabel('Phases')
                ylabel('Counts')
            elseif n_level == length(modulation_indexes) && n_bins ==length(bin_list)
                print(7000,[base_directory_to_save 'Phases for von Mises Fits by Luba'],'-dpng');
            end
            clear vmPh
        end
    end
    
    close all;
end
end
% %% Plot the resulting curves
% for n_level = 1:length(noise_levels)
%
%     % loop through bin numbers
%     for n_bins = 1:length(bin_list)
%
%         xunique = pi/bin_list(n_bins) : 2*pi/bin_list(n_bins) : 2*pi-pi/bin_list(n_bins);
%         x = repmat(xunique,1,n_rpeaks);
%
%         for n_type = 1:length(dist_types)
%
%             % R-squared for significant vs. non-significant (Mosher's fits)
%             figure(250+n_type)
%             set(250+n_type, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             sig_idx    = out.(dist_types{n_type}).modIndex{n_bins,n_level}(:,2) < pvalue;
%             nonsig_idx = out.(dist_types{n_type}).modIndex{n_bins,n_level}(:,2) > pvalue;
%             Rsq_sig    = histc(out.(dist_types{n_type}).modIndex{n_bins,n_level}(sig_idx,4), [0:0.1:1]);
%             Rsq_nonsig = histc(out.(dist_types{n_type}).modIndex{n_bins,n_level}(nonsig_idx,4), [0:0.1:1]);
%             if size(Rsq_sig,2) > size(Rsq_sig,1)
%                 Rsq_sig = Rsq_sig';
%             end
%             if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
%                 Rsq_nonsig = Rsq_nonsig';
%             end
%             bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
%             xlim([-0.1 1.1])
%             if n_level == 1 && n_bins == 1
%                 xlabel('R-squared')
%                 ylabel('Counts')
%                 legend({'sig', 'nonsig'}, 'Location', 'best')
%             end
%             title(['R-squared for Mosher''s Cosine Fits (' (dist_types{n_type}) ' Data)'])
%
%             % R-squared for significant vs. non-significant (Luba's cosine fits)
%             figure(255+n_type)
%             set(255+n_type, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             sig_idx    = out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level} < pvalue;
%             nonsig_idx = out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level} > pvalue;
%             Rsq_sig    = histc(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(sig_idx), [0:0.1:1]);
%             Rsq_nonsig = histc(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(nonsig_idx), [0:0.1:1]);
%             if size(Rsq_sig,2) > size(Rsq_sig,1)
%                 Rsq_sig = Rsq_sig';
%             end
%             if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
%                 Rsq_nonsig = Rsq_nonsig';
%             end
%             bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
%             xlim([-0.1 1.1])
%             if n_level == 1 && n_bins == 1
%                 xlabel('R-squared')
%                 ylabel('Counts')
%                 legend({'sig', 'nonsig'}, 'Location', 'best')
%             end
%             title(['R-squared for Luba''s Cosine Fits (' (dist_types{n_type}) ' Data)'])
%
%             % R-squared for significant vs. non-significant (Luba's von Mises fits)
%             figure(255+n_type)
%             set(255+n_type, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             sig_idx    = out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level} < pvalue;
%             nonsig_idx = out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level} > pvalue;
%             Rsq_sig    = histc(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(sig_idx), [0:0.1:1]);
%             Rsq_nonsig = histc(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(nonsig_idx), [0:0.1:1]);
%             if size(Rsq_sig,2) > size(Rsq_sig,1)
%                 Rsq_sig = Rsq_sig';
%             end
%             if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
%                 Rsq_nonsig = Rsq_nonsig';
%             end
%             bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
%             xlim([-0.1 1.1])
%             if n_level == 1 && n_bins == 1
%                 xlabel('R-squared')
%                 ylabel('Counts')
%                 legend({'sig', 'nonsig'}, 'Location', 'best')
%             end
%             title(['R-squared for Luba''s von Mises Fits (' (dist_types{n_type}) ' Data)'])
%
%
%             % example fits - cosine + Luba's cosine fit
%             figure(500+n_type)
%             set(500+n_type, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
%             hold on
%             plot(x, out.(dist_types{n_type}).cosine.yfit{n_bins,n_level}(1,:))
%             title(['Rsq = ' num2str(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level}(1))])
%
%             %title(['Example fits: ' dist_types{n_type} ' + cosine fit by Luba'])
%
%             % example fits - cosine + Luba's von Mises fit
%             figure(510+n_type)
%             set(510+n_type, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
%             hold on
%             plot(x,out.(dist_types{n_type}).vonMises.yfit{n_bins,n_level}(1,:))
%             title(['Rsq = ' num2str(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level}(1))])
%
%             %title(['Example fits: ' dist_types{n_type} ' + von Mises fit by Luba'])
%
%         end
%
%         for n_dist = 1:length(dist_names)
%
%             V = dist_names{n_dist};
%             D = dist_types{n_dist+1};
%
%             % plot the original data
%             figure(100*(n_dist-1)+1)
%             set(100*(n_dist-1)+1, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             plot1 = plot(x, data.(dist_types{n_dist+1}){n_bins,n_level}, 'k');         % noisy data from distribution
%             hold on
%             plot2 = plot(x, out.(D).removeNoise{n_bins,n_level}, 'Color', [255 120 0]/255); % smoothed data (Mosher's procedure)
%             plot3  = plot(x, data.(orig_dist{n_dist}){n_bins,n_level} + noise_levels(n_level), 'y', 'LineWidth', 2); % original curve
%             xlim([0 2*pi])
%             ylim([-2 8])
%             if n_level == 1
%                 title({['N bins ' num2str(bin_list(n_bins))]})
%                 if n_bins == 1
%                     legend([plot1(1) plot2(1) plot3], ...
%                         {['Noisy ' dist_types{n_dist+1}], ['Smoothed Noisy ' dist_types{n_dist+1}], ['Original ' dist_types{n_dist+1}]}, 'Location', 'Best')
%                 end
%             end
%
%             % scaling factors of Mosher's fit
%             figure(100*(n_dist-1)+2)
%             set(100*(n_dist-1)+2, 'Position', [591 42 893 954])
%             subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%             h_R   = out.R.modIndex{n_bins,n_level}(:,2) < pvalue;
%             r_scF = histc(out.R.modIndex{n_bins,n_level}(h_R,1), [-1:0.5:3]);
%
%             h_D   = out.(D).modIndex{n_bins,n_level}(:,2) < pvalue;
%             d_scF = histc(out.(D).modIndex{n_bins,n_level}(h_D,1), [-1:0.5:3]);
%
%             bar(-1:0.5:3, [r_scF(:) d_scF(:)])
%             if n_level == 1 && n_bins == 1
%                 legend({'R', D})
%             end
%             title('Significant Scaling Factors from Mosher''s Procedure')
%
%         end
%
%         % significance of the cosine fit by Mosher
%         figure(1000)
%         set(1000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < pvalue);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) > pvalue);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title('Fit Significance of Mosher''s procedure')
%
%         % significance of the cosine fit by Luba
%         figure(1001)
%         set(1001, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} < pvalue);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} > pvalue);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title('Fit Significance of Cosine Fits by Luba')
%
%         % significance of the von Mises fit by Luba
%         figure(1002)
%         set(1002, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} < pvalue);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} > pvalue);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title('Fit Significance of von Mises Fits by Luba')
%
%         % adjust significance by R-squared threshold - significance of the cosine fit by Mosher
%         figure(1003)
%         set(1003, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < pvalue & out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4) > 0.3);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) > pvalue | out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4) < 0.3);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title({'Fit Significance of Mosher''s procedure', 'After thresholding by R-squared'})
%
%         % adjust significance by R-squared threshold - significance of the cosine fit by Luba
%         figure(1004)
%         set(1004, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} < pvalue & out.(dist_types{ii}).cosine.rsquared{n_bins,n_level} > 0.3);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} > pvalue | out.(dist_types{ii}).cosine.rsquared{n_bins,n_level} < 0.3);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title({'Fit Significance of Cosine Fits by Luba', 'After thresholding by R-squared'})
%
%         % adjust significance by R-squared threshold - significance of the von Mises fit by Luba
%         figure(1005)
%         set(1005, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h_sig(ii)    = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} < pvalue & out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level} > 0.3);
%             h_nonsig(ii) = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} > pvalue | out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level} < 0.3);
%         end
%         bar_data = [h_sig; h_nonsig];
%         bar(bar_data', 'stacked')
%         if n_level == 1 && n_bins == 1
%             legend({'sig', 'nonsig'})
%             xlabel('Distribution Type')
%             ylabel('# Cases')
%             set(gca, 'XTickLabel', dist_types)
%         end
%         title({'Fit Significance of von Mises Fits by Luba', 'After thresholding by R-squared'})
%
%
%
%         % Significant Phases from the Mosher's procedure
%         figure(2000)
%         set(2000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             h = out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < pvalue;
%             sigPh(:,ii) = histc(out.(dist_types{ii}).modIndex{n_bins,n_level}(h,3), 0:0.4:2*pi);
%         end
%         bar([0:0.4:2*pi], sigPh)
%         if n_level == 1 && n_bins == 1
%             xlabel('Cycle Phase [0 2*pi]')
%             ylabel('# Cases')
%             legend(dist_types, 'Location', 'best')
%         end
%         title('Significant Phases from Mosher''s Procedure')
%
%         % R-squred from Mosher's procedure for noise, cosine and von Mises
%         % distribution
%         figure(3000)
%         set(3000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             Rsq(ii, :) = out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4);
%         end
%         hist(Rsq')
%         xlim([-0.1 1.1])
%         if n_level == 1 && n_bins == 1
%             xlabel('R-squared')
%             ylabel('Counts')
%             legend(dist_types, 'Location', 'best')
%         end
%         title('R-squared for Mosher''s Cosine Fits')
%         clear Rsq
%
%         % R-squared for cosine fits by Luba
%         figure(4000)
%         set(4000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             Rsq(ii, :) = histc(out.(dist_types{ii}).cosine.rsquared{n_bins,n_level}, 0:0.1:1);
%         end
%         bar(0:0.1:1, Rsq')
%         xlim([-0.1 1.1])
%         if n_level == 1 && n_bins == 1
%             legend(dist_types, 'Location', 'best')
%             xlabel('R-squared')
%             ylabel('Counts')
%         end
%         title(bin_list(n_bins))
%         title('R-squared for Cosine Fits by Luba')
%         clear Rsq
%
%         % R-squared for von Mises fits by Luba
%         figure(4001)
%         set(4001, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             Rsq(ii, :) = histc(out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level}, 0:0.1:1);
%         end
%         bar(0:0.1:1, Rsq')
%         xlim([-0.1 1.1])
%         if n_level == 1 && n_bins == 1
%             legend(dist_types, 'Location', 'best')
%             xlabel('R-squared')
%             ylabel('Counts')
%         end
%         title(bin_list(n_bins))
%         title('R-squared for von Mises Fits by Luba')
%         clear Rsq
%
%         % scaling factors coming from COSINE fits by Luba
%         figure(5000)
%         set(5000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             coeff(ii, :) = out.(dist_types{ii}).cosine.coefs{n_bins,n_level}(:,1);
%         end
%         hist(coeff')
%         if n_level == 1
%             title(bin_list(n_bins))
%         end
%         if n_level == 1 && n_bins == 1
%             xlabel('Scaling Factors: a')
%             ylabel('Counts')
%             legend(dist_types, 'Location', 'best')
%         end
%         title('Scaling Factors for Cosine Fits by Luba')
%
%         % cosine phases coming from COSINE fits by Luba
%         figure(6000)
%         set(6000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             cosPh(ii,:) = mod(out.(dist_types{ii}).cosine.coefs{n_bins,n_level}(:,2), 2*pi);
%         end
%         hist(cosPh')
%         xlim([0 2*pi])
%         if n_level == 1
%             title(bin_list(n_bins))
%         end
%         if n_level == 1 && n_bins == 1
%             legend(dist_types, 'Location', 'best')
%             xlabel('Cosine Phases: b')
%             ylabel('Counts')
%         end
%         title('Phases for Cosine Fits by Luba')
%         clear cosPh
%
%         %         % scaling factors coming from VON MISES fits by Luba
%         %         figure(6500)
%         %         set(6500, 'Position', [591 42 893 954])
%         %         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         %         for ii = 1:length(dist_types)
%         %             coeff(ii, :) = out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,1);
%         %         end
%         %         hist(coeff')
%         %         if n_level == 1
%         %             title(bin_list(n_bins))
%         %         end
%         %         if n_level == 1 && n_bins == 1
%         %             xlabel('Scaling Factors: a')
%         %             ylabel('Counts')
%         %             legend(dist_types, 'Location', 'best')
%         %         end
%         %         title('Scaling Factors for von Mises Fits by Luba')
%
%         % von Mises phases from fits by Luba
%         figure(7000)
%         set(7000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             vmPh(ii,:) = out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,4);
%         end
%         hist(vmPh')
%         xlim([0 2*pi])
%         if n_level == 1
%             title(bin_list(n_bins))
%         end
%         if n_level == 1 && n_bins == 1
%             legend(dist_types, 'Location', 'best')
%             xlabel('Phases')
%             ylabel('Counts')
%         end
%         title('Phases for von Mises Fits by Luba')
%         clear vmPh
%
%         % kappas from von Mises fits by Luba
%         figure(8000)
%         set(8000, 'Position', [591 42 893 954])
%         subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
%         for ii = 1:length(dist_types)
%             vmKappa(ii,:) = log(out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,3));
%         end
%         hist(vmKappa')
%         %         bar([0:0.5:10], vmKappa')
%         %         xlim([0 10])
%         %         set(gca, 'XScale', 'log')
%         if n_level == 1
%             title(bin_list(n_bins))
%         end
%         if n_level == 1 && n_bins == 1
%             legend(dist_types, 'Location', 'best')
%             xlabel('log(\kappa)')
%             ylabel('Counts')
%         end
%         title('Kappa for von Mises Fits by Luba')
%         clear vmKappa
%
%     end
% end

%             % figure out the number of units that will be included into the final
%             % analysis if I include only those that have significant cosine fits
%             % AND uniform distribution based on O-test
%             n_noisy_incorr(n_bins) = sum(p_R < pvalue & h_R); % units that will be assigned as fitted with Mosher's cosine significantly
%             n_cos_incorr(n_bins)   = sum(p_RC > pvalue & ~h_RC);
%
%         end
%
%         figure(100)
%         colororder([0 0 0; [255 120 0]/255; 1 1 0; 1 1 1])
%         bar([n_true_negatives n_false_positives n_true_positives n_false_negatives])
%         set(gca, 'XTickLabel', bin_list)
%         ylim([0 100])
%         xlabel('Number of Bins')
%         ylabel('Percentages, %')
%         legend({'True Negatives', 'False Positives', 'True Positives', 'False Negatives'}, 'Location', 'SouthOutside')
%         title('O-test: for circular uniformity')
%
%     end
%
% end
%
end

function y = cospdf(x, a, b, c)
y = abs(a)*cos(x-b)+c;
end

function y = vonMisesPDF(alpha, thetahat, kappa, d)
y = exp(kappa * cos(alpha - thetahat)) / (2*pi*besseli(0, kappa)) + d;
end


function out = circ_smooth2(input)

if size(input, 1) < size(input, 2)
    input = input';
end

A = repmat(input, 3, 1);
A_smoothed = smooth(A, 'rlowess');

out = A_smoothed(length(input)+1:end-length(input));

end