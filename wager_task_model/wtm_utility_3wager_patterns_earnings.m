% function wtm_utility_3wager_patterns_earnings

analyze_earnings = 1;
plot_all_patterns = 0;

if analyze_earnings,
	perf = 0.5;
	PayOff = round2(wtm_utility([0 2 5; 3 1 -45]),0.1); %
	N_trials = 100;
	E(5).earnings = [];
	E(5).k  = [];
end

step = 0.25;
wp  = ig_nchoosek_with_rep_perm([0:step:1],3);
wp = wp(sum(wp,2)==1,:);

n_wp = size(wp,1);

wp_c = wp;
wp_i = wp;

cwp = combvec(wp_c',wp_i')';

N_comb = size(cwp,1);

cwp = reshape(cwp,N_comb,3,2);


map_c = summer(N_comb);
map_i = cool(N_comb);

map_c = repmat([0 1 0],N_comb,1);
map_i = repmat([1 0 0],N_comb,1);



% figure('Name',sprintf('%d valid wagering patterns, %d permutations', n_wp, N_comb));
for k = 1:N_comb,
	% 	plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
	% 	plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;
	
	wc = cwp(k,:,1);
	wi = cwp(k,:,2);
	
	if all(wc == wi),
		pattern{k} = 'no metacognition';
	else
		pattern{k} = 'weird pattern';
		% define two slopes
		slope32_c = wc(3)-wc(2);
		slope32_i = wi(3)-wi(2);
		
		slope21_c = wc(2)-wc(1);
		slope21_i = wi(2)-wi(1);
		
		CertCor = 0;
		CertInc = 0;
		
		if wc(3)>wi(3) && slope32_c>slope32_i
			CertCor = 1;
			pattern{k} = 'certainty correct';
		end
		
		if wc(1)<wi(1) && slope21_c>slope21_i % negative means increase towards w1
			CertInc = 1;
			pattern{k} = 'certainty incorrect'; 
		end
		
		if CertCor && CertInc
			pattern{k} = 'bidirectional certainty';
		end
			
		
	end
	
	switch pattern{k}
		case 'bidirectional certainty'
			fignum = 1;
		case 'certainty correct'
			fignum = 2;
		case 'certainty incorrect'
			fignum = 3;
		case 'no metacognition'
			fignum = 4;
		case 'weird pattern'
			fignum = 5;	
	end
	
% 	figure(fignum);
% 	set(gcf,'Name',pattern{k});
% 	plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
% 	plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;
	
end

category_cmap = bone(length(unique(pattern))+2); category_cmap = category_cmap(2:end-1,:);

N(1) =  sum(strcmp(pattern,'bidirectional certainty'));
N(2) =  sum(strcmp(pattern,'certainty correct'));
N(3) =  sum(strcmp(pattern,'certainty incorrect'));
N(4) =  sum(strcmp(pattern,'no metacognition'));
N(5) =  sum(strcmp(pattern,'weird pattern'));


idx_patterns = zeros(1,5);


for k = 1:N_comb, % for each pattern
	
	switch pattern{k}
		case 'bidirectional certainty'
			fignum = 1;
		case 'certainty correct'
			fignum = 2;
		case 'certainty incorrect'
			fignum = 3;
		case 'no metacognition'
			fignum = 4;
		case 'weird pattern'
			fignum = 5;	
	end
	
	
	idx_patterns(fignum) = idx_patterns(fignum) + 1;
	
	if plot_all_patterns
	 	figure(fignum);
		set(gcf,'Name',[pattern{k} sprintf(' %d patterns',N(fignum))]);
		subplot(ceil(N(fignum)/5),5,idx_patterns(fignum));
		plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
		plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;
	end

	if analyze_earnings
		wager_proportions = squeeze(cwp(k,:,:))';
		EVw = perf*PayOff(1,:) + (1-perf)*PayOff(2,:); % EV per wager given the performance

		Outcomes = [
			N_trials*perf*wager_proportions(1,:).*PayOff(1,:);
			N_trials*(1-perf)*wager_proportions(2,:).*PayOff(2,:)];

		EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency

		E(fignum).earnings(idx_patterns(fignum)) = sum(EarningsPerWager);
		E(fignum).k(idx_patterns(fignum)) = k;
	end


end % of for each pattern

if analyze_earnings
	hf1 = figure('Name',sprintf('Best patterns, performance %.2f',perf),'Color',[1 1 1],'Position',[100 100 1400 260]);
	hf2 = figure('Name',sprintf('All patterns, performance %.2f',perf),'Color',[1 1 1],'Position',[100 100 1600 400]);
	pattern_counter = 0;
	for f = 1:5,
		figure(hf1);
		subplot(1,5,f)
		idx_max_within_category = find(E(f).earnings == max(E(f).earnings));
		[sortedEarnings,idx_sorted_within_category] = sort(E(f).earnings,'descend');
		
		k = E(f).k(idx_max_within_category);
		disp(pattern{k});
		squeeze(cwp ( k, :, :))'
		disp(' ');
		
		plot([1 2 3],squeeze(cwp(k,:,1)),'Color',map_c(k,:),'LineWidth',2); hold on;
		plot([1 2 3],squeeze(cwp(k,:,2)),'Color',map_i(k,:),'LineWidth',2); hold on;
		title(sprintf('%s earnings %d',pattern{k},round(E(f).earnings(idx_max_within_category))));
		set(gca,'xtick',[1 2 3]);
		
		figure(hf2);
		bar([pattern_counter + 1 : pattern_counter + length(idx_sorted_within_category)],sortedEarnings,'FaceColor',category_cmap(f,:)); hold on
		pattern_counter = pattern_counter + length(idx_sorted_within_category);
	end
	
end
	
	



	



