% visual_detection_predictions

N_targets = 6;	
% contraversive | ipsiversive
%	1	|	4
%	2	|	5
%	3	|	6

%		1	2	3	4	5	6
PercRate_b =	[0.5	0.5	0.5	0.5	0.5	0.5];	% Perceptual hit rate
SpatPref_b =	[0.0	0.0	0.6	0.0	0.0	0.4];	% should add to one
Perc_change =	[0.1	0.1	0.1	0.0	0.0	0.0];
Pref_change =	[0.1	0.1	0.1	-0.1	-0.1	-0.1];	% should add to zero for additive

perc_effect = 'multiplicative'; % additive /multiplicative
pref_effect = 'multiplicative'; % additive /multiplicative

if strcmp(perc_effect,'multiplicative'), % set multiplier below for each target
	Perc_change = [1.3 1.2 1 0.9 1 1];
	
end

if strcmp(pref_effect,'multiplicative'), % set multiplier_contraversive below
	multiplier_contraversive = 1.3;
	multiplier_ipsiversive = (1-multiplier_contraversive*sum(SpatPref_b(1:3)))/sum(SpatPref_b(4:6));
	Pref_change = [repmat(multiplier_contraversive,1,3) repmat(multiplier_ipsiversive,1,3)];
end




f = figure('Position',[200 200 600 800]);


if sum(SpatPref_b)~=1, error('sum of SpatPref_b is not equal to 1!'); end
if abs(sum(Pref_change))>eps && strcmp(pref_effect,'additive'), error('sum of Pref_change is not equal to 1!'); end

HitRate_b = PercRate_b + [1-PercRate_b].*SpatPref_b; 


colnames = {'Left', 'Right'};
rownames = {'upper', 'middle', 'down'};
t1 = uitable(f, 'Data', (reshape(HitRate_b,3,2)), 'ColumnName', colnames, 'RowName',rownames,...
	'Position', [175 520 250 100],'Units','Normalized');
uicontrol('Style','text','String','HitRate baseline','Position',[175 620 100 20]);

% MICROSTIMULATION
% Perceptual effect: increase of detection in contraversive (left) hemifield, motivation same
if strcmp(perc_effect,'additive'),
	PercRate_s = PercRate_b + Perc_change;
else
	PercRate_s = PercRate_b.*Perc_change;
end
HitRate_s = PercRate_s + [1-PercRate_s].*SpatPref_b;


t2 = uitable(f, 'Data', (reshape(HitRate_s,3,2)), 'ColumnName', colnames, 'RowName',rownames,...
	'Position', [5 380 250 100],'Units','Normalized');
uicontrol('Style','text','String','HitRate stimulation, perceptual effect','Position',[5 480 200 20]);

% Motivational effect: increase of motivation in contraversive (left) hemifield, perception same
if strcmp(pref_effect,'additive'),
	SpatPref_s = max((SpatPref_b+Pref_change),zeros(1,N_targets));
	SpatPref_s = SpatPref_s./sum(SpatPref_s); % normalize so that sum is one
else
	SpatPref_s = SpatPref_b.*Pref_change;
end
	

HitRate_s = PercRate_b + [1-PercRate_b].*SpatPref_s;


t3 = uitable(f, 'Data', (reshape(HitRate_s,3,2)), 'ColumnName', colnames, 'RowName',rownames,...
	'Position', [350 380 250 100],'Units','Normalized');
uicontrol('Style','text','String','HitRate stimulation, motivational effect','Position',[350 480 200 20]);


% upper table
colnames = {'1', '2', '3', '4', '5', '6'};
rownames = {'PercRate_b','SpatPref_b','Perc_change','Pref_change','SpatPref_s',}; 
t0 = uitable(f, 'Data', [PercRate_b; SpatPref_b; Perc_change; Pref_change; SpatPref_s],'ColumnName',colnames,'RowName',rownames,...
	'Position', [10 650 580 120],'Units','Normalized');
uicontrol('Style','text','String',['Perc.: ' perc_effect ' Motiv.: ' pref_effect],'Position',[10 770 200 20]);

