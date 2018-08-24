function testsim_interoception_score

n_subjects		= 15;
n_trials		= 15;
PLOT_IND_SUBJ		= 1;

obj_count(1:n_subjects,1:n_trials) = 30*ones(n_subjects,n_trials); % objective heart rate 

% Initialization
sub_count	= NaN(n_subjects,n_trials);
conf_rating	= NaN(n_subjects,n_trials);
hps		= NaN(n_subjects,n_trials);

if PLOT_IND_SUBJ,
	hf1 = figure('Position',[100 100 1000 1000]);
	n_cols = ceil(sqrt(n_subjects));
	n_rows = n_cols;
end


	
for s = 1:n_subjects,
	
	% set the desired levels of average performance per subject
	
	% type 1 performance, set as average signed difference between objective and subjective count and SD of difference
	% larger absolute mean and larger SD mean worse performance
	D(s).mean1	= round(randn*10);
	D(s).sd1	= round(randn*5);
	
	% type 2 performance, set as average level of correspondence between abs(objective - subjective) counts and confidence rating
	
% 	D(s).mean2	= round(randn*10) + s;
% 	D(s).sd2	= round(randn*5);
	
	for t = 1:n_trials,
		sub_count(s,t)		= obj_count(s,t) + (D(s).mean1 + D(s).sd1*randn(1));
		hps(s,t)		= get_hps(sub_count(s,t), obj_count(s,t)); 
		
		conf_rating(s,t)	= get_conf_rating(D,sub_count(s,t),obj_count(s,t),hps(s,t)); 
		
	end
	
	INCongruency(s) = sum ( (hps(s,:) * 100 - conf_rating(s,:)) ) / n_trials;
	% INCongruency(s) = sum ( (hps(s,:) * 100 - conf_rating(s,:)).^2 ) / n_trials;
	% INCongruency = sum ((HPS * 100 - confidence [0 - 100])^2) / n_trials

	if 1,
		figure(hf1);
		subplot(n_rows,n_cols,s)
		plot(hps(s,:),conf_rating(s,:),'ko');
		title(sprintf('mean hbs %.2f mean conf %.2f',mean(hps(s,:)), mean(conf_rating(s,:))));
		
	end
	
end
ig_set_axes_equal_lim;
ig_mlabel('HBS','conf rating');

figure('Position',[100 100 600 1000]);
subplot(2,1,1)
plot(mean(hps,2),mean(conf_rating,2),'go');
xlabel('HPS');
ylabel('mean confidence rating');

subplot(2,1,2)
plot(mean(hps,2),INCongruency,'ro');
xlabel('HPS');
ylabel('INCongruency');

% round2(continuous_data_vector + bin/2,bin)
% sum ( 0 * 100 -   abs[-2.5-rs]*20  ) ^2 / n_trials



if 0 % illustrate HBS?
	
sub = 5:70; % subjective report
obj = 20; % objective report

for k = 1:length(sub),
    hps(k) = 1 - abs(obj-sub(k))/obj;
end

plot(sub,hps); hold on
plot(obj,1,'r*');
xlabel('subjectve report');
ylabel('HPS');

end % of if illustrate hbs

function hbs = get_hps(sub,obj)
hbs = 1 - abs(obj-sub)/obj;

function conf = get_conf_rating(D,sub,obj,hps)

% conf = 50;
% 
% conf_rs = -2.5:1:2.5; % response scale
% conf = 20*abs(-2.5 - conf_rs(floor(rand(1)*length(conf_rs))+1)); % from 0 to 100

conf = ig_limit_range_min_max(100-abs(sub-obj),0,100); % difference in count directly related to confidence
