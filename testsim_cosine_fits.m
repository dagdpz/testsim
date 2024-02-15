% function testsim_cosine_fits

noise_levels = [1 1.5 2 2.5 3];
bin_list     = [32, 64, 128];
dist_types   = {'R', 'RC', 'RvM'}; % random, nosiy cosine, noisy von Mises
dist_names   = {'cosine', 'vonMises'};
orig_dist    = {'C', 'vM'};

n_rep        = 15;

cos_mod      = fittype('a*cos(x-b)+c');% a - scaling factor, b - phase of the peak, c - intercept
% mdl_vonMises = fittype('a1*exp( k1*(cos(x-t1)-1) ) / (2*pi*besseli(0, k1, 1)) + d1');
vonMises_mod = fittype('a1*( exp( k1*(cos(x-t1)) ) / (2*pi*besseli(0, k1)) ) + d1');

% y = a*exp(kappa * cos(alpha - thetahat)) / (2*pi*besseli(0, kappa)) + d;

% for fitnlm
% cos_mod      = @(b,x) b(1).*cos(x - b(2)) + b(3);
% vonMises_mod = @(b,x) b(1).*exp( b(2)*(cos(x-b(3))) ) / (2*pi*besseli(0, b(2))) + b(4);% b(1) - scaling factor, b(2) - kappa, b(3) - peak phase, b(4) - intercept

for n_level = 1:length(noise_levels)
    
    % loop through bin numbers
    for n_bins = 1:length(bin_list)
        
        x = pi/bin_list(n_bins) : 2*pi/bin_list(n_bins) : 2*pi-pi/bin_list(n_bins);
        
        data.R{n_bins,n_level} = noise_levels(n_level) * rand(n_rep,bin_list(n_bins)); % use uniformly distributed random data
        data.C{n_bins,n_level} = cos(x-pi);                                              % simulate cosine
        data.vM{n_bins,n_level} = vonMises_mod(1, 0, 4, pi/4, x);                                 % simulate von Mises distribution with theta-hat = pi, kappa = 4
        %         data.vM{n_bins,n_level} = data.vM{n_bins,n_level}/max(data.vM{n_bins,n_level})*2;  % adjust von Mises amplitude to match the cosine amp
        data.vM{n_bins,n_level} = data.vM{n_bins,n_level};
        
        % adjust noise levels by the function amplitude
        data.RC{n_bins,n_level}  = (max(data.C{n_bins,n_level}) - min(data.C{n_bins,n_level})) * data.R{n_bins,n_level} + data.C{n_bins,n_level}+2; % noisy cosine
        data.RvM{n_bins,n_level} = (max(data.vM{n_bins,n_level}) - min(data.vM{n_bins,n_level})) * data.R{n_bins,n_level} + data.vM{n_bins,n_level};% noisy von Mises distribution
        
        % loop through distributions
        for n_type = 1:length(dist_types)
            
            % I. Check to circular uniformity: compute O-test for both cosine and noisy data
            for ii = 1:n_rep
                D = dist_types{n_type};
                out.(D).p_otest(ii)  = circ_otest(x, [], data.(D){n_bins,n_level}(ii,:));
            end
            
            % figure out decisions of O-test at the population level
            out.(D).n_nonsig(n_bins,n_level)  = 100*sum(out.(D).p_otest > 0.05)/n_rep;  % percentage of noisy curves assigned as uniformly distributed
            out.(D).n_sig(n_bins,n_level)     = 100*sum(out.(D).p_otest < 0.05)/n_rep;  % percentage of noisy curves assigned as non-unifirmly distributed
            
            % II. Compute Mosher's procedure
            tic
            [out.(D).modIndex{n_bins,n_level}, out.(D).removeNoise{n_bins,n_level}] = fitCardiacModulation(x, data.(D){n_bins,n_level}, {'PSTH'}, 0, [221]);
            toc
            
            % III. Compute fits with 'fit' function
            tic
            for ii = 1:n_rep
                
                % 1. Figure out starting parameters
                % 1.1. figure out starting parameters for cosine fit
                %                 currCurve = data.(D){n_bins,n_level}(ii,:)';
                currCurve = out.(D).removeNoise{n_bins,n_level}(ii,:)';
                a = (max(currCurve) - min(currCurve))/2;
                b = circ_mean(x, currCurve');
                c = mean(currCurve);
                
                startPoint_cos = [a b c];% a - scaling factor, b - phase of the peak, c - intercept
                %                 options = optimoptions('lsqcurvefit', 'Display', 'off'); %, 'UseParallel', true
                
                % 1.2. figure out starting parameters for von Mises fit
                a1 = max(currCurve) - min(currCurve);
                k1 = circ_kappa(x, currCurve' - mean(currCurve) + 0.1592);
                t1 = circ_mean(x, currCurve');
                d1 = mean(currCurve);
                
                startPoint_vm = [a1 d1 k1 t1];% a1 - scaling factor, k1 - kappa, t1 - peak phase, d1 - intercept
                %                 options = optimoptions('lsqcurvefit', 'Display', 'off'); %, 'UseParallel', true
                
                % 2. fit with a cosine from the starting point
                %                 [xx,resnorm,residual,exitflag,output] = ...
                %                     lsqcurvefit(@(params, theta) cospdf(theta, params(1), params(2), params(3)), startPoint_cos, x, currCurve', [0 0 -Inf], [Inf 2*pi Inf], options);
                %
                %                 yfit = cospdf(x, xx(1), xx(2), xx(3));
                %
                %                 out.(D).cosine.yfit{n_bins,n_level}(ii,:)   = yfit;
                %                 out.(D).cosine.coefs{n_bins,n_level}(ii,:)  = xx;
                %                 out.(D).cosine.rsquared{n_bins,n_level}(ii) = Rsq;
                %                 clear Rsq
                
                [fittedmdl,gof] = fit(x',currCurve,cos_mod,'StartPoint',startPoint_cos, 'Lower', [-Inf 0 -Inf], 'Upper', [Inf 2*pi Inf]);
                
                coefs = coeffvalues(fittedmdl); % get model coefficients
                
                yfit = cos_mod(coefs(1),coefs(2),coefs(3),x);
                
                out.(D).cosine.coefs{n_bins,n_level}(ii,:)  = coefs;
                out.(D).cosine.yfit{n_bins,n_level}(ii,:)   = yfit;
                out.(D).cosine.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                
                % employ a linear fit to get a p-value vs. fitting with a
                % constant model
                mdl = fitlm(currCurve, yfit);
                out.(D).cosine.pvalue{n_bins,n_level}(ii)   = mdl.Coefficients.pValue(2);
                
                clear fittedmdl gof coefs yfit mdl
                
                %                 out.(D).cosine.mdl{n_bins,n_level}{ii}      = fittedmdl;
                %                 out.(D).cosine.coefs{n_bins,n_level}(ii,:)  = coeffvalues(fittedmdl);
                %                 out.(D).cosine.n_iter{n_bins,n_level}(ii)   = output.iterations;
                %                 out.(D).cosine.sse{n_bins,n_level}(ii)      = gof.sse;
                %                 out.(D).cosine.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                %                 clear fittedmdl gof output
                
                % 3. Employ the von Mises fit
                % 3.1. figure out the starting phase and shift the distribution to it
                %                 M = circ_mean(x, data.(D){n_bins,n_level}(ii,:));
                %                 C_shifted = circshift(data.(D){n_bins,n_level}(ii,:), round((pi - M)/2/pi*bin_list(n_bins)));
                % 3.1. prepare data for von Mises fit - figure out min and
                % normalize by the area under the curve
                %                 currCurve = (currCurve - min(currCurve))/sum((currCurve - min(currCurve)));
                
                % 3.2. fit with the von Mises distribution
                %                 [xx,resnorm,residual,exitflag,output] = ...
                %                     lsqcurvefit(@(params, theta) vonMisesPDF(theta, params(1), params(2), params(3), params(4)), startPoint_vm, x, currCurve', [0 0 -Inf 0], [2*pi Inf Inf Inf], options);
                %
                %                 yfit = vonMisesPDF(x, xx(1), xx(2), xx(3), xx(4));
                %
                %                 % compute R-squared
                %                 SStot = sum((currCurve-mean(currCurve)).^2);                            % Total Sum-Of-Squares
                %                 SSres = sum((currCurve(:)-yfit(:)).^2);                         % Residual Sum-Of-Squares
                %                 Rsq = 1-SSres/SStot;
                %
                %                 out.(D).vonMises.yfit{n_bins,n_level}(ii,:)   = yfit;
                %                 out.(D).vonMises.coefs{n_bins,n_level}(ii,:)  = xx;
                %                 out.(D).vonMises.rsquared{n_bins,n_level}(ii) = Rsq;
                %                 clear Rsq
                
                [fittedmdl,gof,output] = fit(x',currCurve,vonMises_mod,'StartPoint',startPoint_vm, 'Lower', [-1000 -1000 exp(-4) 0], 'Upper', [1000 1000 exp(4) 2*pi]);
                
                coefs = coeffvalues(fittedmdl); % get model coefficients
                
                yfit = vonMises_mod(coefs(1),coefs(2),coefs(3), coefs(4), x);
                
                out.(D).vonMises.coefs{n_bins,n_level}(ii,:)  = coefs;
                out.(D).vonMises.yfit{n_bins,n_level}(ii,:)   = yfit;
                out.(D).vonMises.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                
                % employ a linear fit to get a p-value vs. fitting with a
                % constant model
                mdl = fitlm(yfit, currCurve);
                out.(D).vonMises.pvalue{n_bins,n_level}(ii)   = mdl.Coefficients.pValue(2);
                
                clear fittedmdl gof coefs yfit mdl
                
                %                 [fittedmdl, gof, output] = fit(x', currCurve, mdl_vonMises, 'StartPoint', startPoint_vm, 'TolFun', 10e-7);
                %                 out.(D).vonMises.mdl{n_bins,n_level}{ii}      = fittedmdl;
                %                 out.(D).vonMises.coefs{n_bins,n_level}(ii,:)  = coeffvalues(fittedmdl);
                %                 out.(D).vonMises.n_iter{n_bins,n_level}(ii)   = output.iterations;
                %                 out.(D).vonMises.sse{n_bins,n_level}(ii)      = gof.sse;
                %                 out.(D).vonMises.rsquared{n_bins,n_level}(ii) = gof.rsquare;
                %                 clear fittedmdl gof output
                
            end
            toc
        end
    end
end

%% Plot the resulting curves
for n_level = 1:length(noise_levels)
    
    % loop through bin numbers
    for n_bins = 1:length(bin_list)
        
        x = pi/bin_list(n_bins) : 2*pi/bin_list(n_bins) : 2*pi-pi/bin_list(n_bins);
        
        for n_type = 1:length(dist_types)
            
            % R-squared for significant vs. non-significant (Mosher's fits)
            figure(250+n_type)
            set(250+n_type, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            sig_idx    = out.(dist_types{n_type}).modIndex{n_bins,n_level}(:,2) < 0.05;
            nonsig_idx = out.(dist_types{n_type}).modIndex{n_bins,n_level}(:,2) > 0.05;
            Rsq_sig    = histc(out.(dist_types{n_type}).modIndex{n_bins,n_level}(sig_idx,4), [0:0.1:1]);
            Rsq_nonsig = histc(out.(dist_types{n_type}).modIndex{n_bins,n_level}(nonsig_idx,4), [0:0.1:1]);
            if size(Rsq_sig,2) > size(Rsq_sig,1)
                Rsq_sig = Rsq_sig';
            end
            if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
                Rsq_nonsig = Rsq_nonsig';
            end
            bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
            xlim([-0.1 1.1])
            if n_level == 1 && n_bins == 1
                xlabel('R-squared')
                ylabel('Counts')
                legend({'sig', 'nonsig'}, 'Location', 'best')
            end
            sgtitle(['R-squared for Mosher''s Cosine Fits (' (dist_types{n_type}) ' Data)'])
            
            % R-squared for significant vs. non-significant (Luba's cosine fits)
            figure(255+n_type)
            set(255+n_type, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            sig_idx    = out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level} < 0.05;
            nonsig_idx = out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level} > 0.05;
            Rsq_sig    = histc(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(sig_idx), [0:0.1:1]);
            Rsq_nonsig = histc(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(nonsig_idx), [0:0.1:1]);
            if size(Rsq_sig,2) > size(Rsq_sig,1)
                Rsq_sig = Rsq_sig';
            end
            if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
                Rsq_nonsig = Rsq_nonsig';
            end
            bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
            xlim([-0.1 1.1])
            if n_level == 1 && n_bins == 1
                xlabel('R-squared')
                ylabel('Counts')
                legend({'sig', 'nonsig'}, 'Location', 'best')
            end
            sgtitle(['R-squared for Luba''s Cosine Fits (' (dist_types{n_type}) ' Data)'])
            
            % R-squared for significant vs. non-significant (Luba's von Mises fits)
            figure(255+n_type)
            set(255+n_type, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            sig_idx    = out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level} < 0.05;
            nonsig_idx = out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level} > 0.05;
            Rsq_sig    = histc(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(sig_idx), [0:0.1:1]);
            Rsq_nonsig = histc(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(nonsig_idx), [0:0.1:1]);
            if size(Rsq_sig,2) > size(Rsq_sig,1)
                Rsq_sig = Rsq_sig';
            end
            if size(Rsq_nonsig,2) > size(Rsq_nonsig,1)
                Rsq_nonsig = Rsq_nonsig';
            end
            bar([0:0.1:1], [Rsq_sig Rsq_nonsig])
            xlim([-0.1 1.1])
            if n_level == 1 && n_bins == 1
                xlabel('R-squared')
                ylabel('Counts')
                legend({'sig', 'nonsig'}, 'Location', 'best')
            end
            sgtitle(['R-squared for Luba''s von Mises Fits (' (dist_types{n_type}) ' Data)'])
            
            
            % example fits - cosine + Luba's cosine fit
            figure(500+n_type)
            set(500+n_type, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
            hold on
            plot(x, out.(dist_types{n_type}).cosine.yfit{n_bins,n_level}(1,:))
            title(['Rsq = ' num2str(out.(dist_types{n_type}).cosine.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).cosine.pvalue{n_bins,n_level}(1))])
            
            sgtitle(['Example fits: ' dist_types{n_type} ' + cosine fit by Luba'])
            
            % example fits - cosine + Luba's von Mises fit
            figure(510+n_type)
            set(510+n_type, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            plot(x,data.(dist_types{n_type}){n_bins,n_level}(1,:),'.')
            hold on
            plot(x, out.(dist_types{n_type}).vonMises.yfit{n_bins,n_level}(1,:))
            title(['Rsq = ' num2str(out.(dist_types{n_type}).vonMises.rsquared{n_bins,n_level}(1)) '; p = ' num2str(out.(dist_types{n_type}).vonMises.pvalue{n_bins,n_level}(1))])
            
            sgtitle(['Example fits: ' dist_types{n_type} ' + von Mises fit by Luba'])
            
        end
        
        for n_dist = 1:length(dist_names)
            
            V = dist_names{n_dist};
            D = dist_types{n_dist+1};
            
            % plot the original data
            figure(100*(n_dist-1)+1)
            set(100*(n_dist-1)+1, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            plot1 = plot(x, data.(dist_types{n_dist+1}){n_bins,n_level}, 'k');         % noisy data from distribution
            hold on
            plot2 = plot(x, out.(D).removeNoise{n_bins,n_level}, 'Color', [255 120 0]/255); % smoothed data (Mosher's procedure)
            plot3  = plot(x, data.(orig_dist{n_dist}){n_bins,n_level} + noise_levels(n_level), 'y', 'LineWidth', 2); % original curve
            xlim([0 2*pi])
            ylim([-2 8])
            if n_level == 1
                title({['N bins ' num2str(bin_list(n_bins))]})
                if n_bins == 1
                    legend([plot1(1) plot2(1) plot3], ...
                        {['Noisy ' dist_types{n_dist+1}], ['Smoothed Noisy ' dist_types{n_dist+1}], ['Original ' dist_types{n_dist+1}]}, 'Location', 'Best')
                end
            end
            
            % scaling factors of Mosher's fit
            figure(100*(n_dist-1)+2)
            set(100*(n_dist-1)+2, 'Position', [591 42 893 954])
            subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
            h_R   = out.R.modIndex{n_bins,n_level}(:,2) < 0.05;
            r_scF = histc(out.R.modIndex{n_bins,n_level}(h_R,1), [-1:0.5:3]);
            
            h_D   = out.(D).modIndex{n_bins,n_level}(:,2) < 0.05;
            d_scF = histc(out.(D).modIndex{n_bins,n_level}(h_D,1), [-1:0.5:3]);
            
            bar(-1:0.5:3, [r_scF d_scF]')
            if n_level == 1 && n_bins == 1
                legend({'R', D})
            end
            sgtitle('Significant Scaling Factors from Mosher''s Procedure')
            
        end
        
        % significance of the cosine fit by Mosher
        figure(1000)
        set(1000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < 0.05);
            h_nonsig(ii) = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) > 0.05);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle('Fit Significance of Mosher''s procedure')
        
        % significance of the cosine fit by Luba
        figure(1001)
        set(1001, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} < 0.05);
            h_nonsig(ii) = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} > 0.05);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle('Fit Significance of Cosine Fits by Luba')
        
        % significance of the von Mises fit by Luba
        figure(1002)
        set(1002, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} < 0.05);
            h_nonsig(ii) = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} > 0.05);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle('Fit Significance of von Mises Fits by Luba')
        
        % adjust significance by R-squared threshold - significance of the cosine fit by Mosher
        figure(1003)
        set(1003, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < 0.05 & out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4) > 0.3);
            h_nonsig(ii) = sum(out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) > 0.05 | out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4) < 0.3);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle({'Fit Significance of Mosher''s procedure', 'After thresholding by R-squared'})
        
        % adjust significance by R-squared threshold - significance of the cosine fit by Luba
        figure(1004)
        set(1004, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} < 0.05 & out.(dist_types{ii}).cosine.rsquared{n_bins,n_level} > 0.3);
            h_nonsig(ii) = sum(out.(dist_types{ii}).cosine.pvalue{n_bins,n_level} > 0.05 | out.(dist_types{ii}).cosine.rsquared{n_bins,n_level} < 0.3);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle({'Fit Significance of Cosine Fits by Luba', 'After thresholding by R-squared'})
        
        % adjust significance by R-squared threshold - significance of the von Mises fit by Luba
        figure(1005)
        set(1005, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h_sig(ii)    = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} < 0.05 & out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level} > 0.3);
            h_nonsig(ii) = sum(out.(dist_types{ii}).vonMises.pvalue{n_bins,n_level} > 0.05 | out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level} < 0.3);
        end
        bar_data = [h_sig; h_nonsig];
        bar(bar_data', 'stacked')
        if n_level == 1 && n_bins == 1
            legend({'sig', 'nonsig'})
            xlabel('Distribution Type')
            ylabel('# Cases')
            set(gca, 'XTickLabel', dist_types)
        end
        sgtitle({'Fit Significance of von Mises Fits by Luba', 'After thresholding by R-squared'})
        
        
        
        % Significant Phases from the Mosher's procedure
        figure(2000)
        set(2000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            h = out.(dist_types{ii}).modIndex{n_bins,n_level}(:,2) < 0.05;
            sigPh(:,ii) = histc(out.(dist_types{ii}).modIndex{n_bins,n_level}(h,3), 0:0.4:2*pi);
        end
        bar([0:0.4:2*pi], sigPh')
        if n_level == 1 && n_bins == 1
            xlabel('Cycle Phase [0 2*pi]')
            ylabel('# Cases')
            legend(dist_types, 'Location', 'best')
        end
        sgtitle('Significant Phases from Mosher''s Procedure')
        
        % R-squred from Mosher's procedure for noise, cosine and von Mises
        % distribution
        figure(3000)
        set(3000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            Rsq(ii, :) = out.(dist_types{ii}).modIndex{n_bins,n_level}(:,4);
        end
        hist(Rsq')
        xlim([-0.1 1.1])
        if n_level == 1 && n_bins == 1
            xlabel('R-squared')
            ylabel('Counts')
            legend(dist_types, 'Location', 'best')
        end
        sgtitle('R-squared for Mosher''s Cosine Fits')
        clear Rsq
        
        % R-squared for cosine fits by Luba
        figure(4000)
        set(4000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            Rsq(ii, :) = histc(out.(dist_types{ii}).cosine.rsquared{n_bins,n_level}, 0:0.1:1);
        end
        bar(0:0.1:1, Rsq')
        xlim([-0.1 1.1])
        if n_level == 1 && n_bins == 1
            legend(dist_types, 'Location', 'best')
            xlabel('R-squared')
            ylabel('Counts')
        end
        title(bin_list(n_bins))
        sgtitle('R-squared for Cosine Fits by Luba')
        clear Rsq
        
        % R-squared for von Mises fits by Luba
        figure(4001)
        set(4001, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            Rsq(ii, :) = histc(out.(dist_types{ii}).vonMises.rsquared{n_bins,n_level}, 0:0.1:1);
        end
        bar(0:0.1:1, Rsq')
        xlim([-0.1 1.1])
        if n_level == 1 && n_bins == 1
            legend(dist_types, 'Location', 'best')
            xlabel('R-squared')
            ylabel('Counts')
        end
        title(bin_list(n_bins))
        sgtitle('R-squared for von Mises Fits by Luba')
        clear Rsq
        
        % scaling factors coming from COSINE fits by Luba
        figure(5000)
        set(5000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            coeff(ii, :) = out.(dist_types{ii}).cosine.coefs{n_bins,n_level}(:,1);
        end
        hist(coeff')
        if n_level == 1
            title(bin_list(n_bins))
        end
        if n_level == 1 && n_bins == 1
            xlabel('Scaling Factors: a')
            ylabel('Counts')
            legend(dist_types, 'Location', 'best')
        end
        sgtitle('Scaling Factors for Cosine Fits by Luba')
        
        % cosine phases coming from COSINE fits by Luba
        figure(6000)
        set(6000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
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
        end
        sgtitle('Phases for Cosine Fits by Luba')
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
        %         sgtitle('Scaling Factors for von Mises Fits by Luba')
        
        % von Mises phases from fits by Luba
        figure(7000)
        set(7000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
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
        end
        sgtitle('Phases for von Mises Fits by Luba')
        clear vmPh
        
        % kappas from von Mises fits by Luba
        figure(8000)
        set(8000, 'Position', [591 42 893 954])
        subplot(length(noise_levels),length(bin_list), length(bin_list)*(n_level-1) + n_bins)
        for ii = 1:length(dist_types)
            vmKappa(ii,:) = log(out.(dist_types{ii}).vonMises.coefs{n_bins,n_level}(:,3));
        end
        hist(vmKappa')
        %         bar([0:0.5:10], vmKappa')
        %         xlim([0 10])
        %         set(gca, 'XScale', 'log')
        if n_level == 1
            title(bin_list(n_bins))
        end
        if n_level == 1 && n_bins == 1
            legend(dist_types, 'Location', 'best')
            xlabel('log(\kappa)')
            ylabel('Counts')
        end
        sgtitle('Kappa for von Mises Fits by Luba')
        clear vmKappa
        
    end
end

%             % figure out the number of units that will be included into the final
%             % analysis if I include only those that have significant cosine fits
%             % AND uniform distribution based on O-test
%             n_noisy_incorr(n_bins) = sum(p_R < 0.05 & h_R); % units that will be assigned as fitted with Mosher's cosine significantly
%             n_cos_incorr(n_bins)   = sum(p_RC > 0.05 & ~h_RC);
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
% end
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