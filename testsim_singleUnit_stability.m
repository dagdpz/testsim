function testsim_singleUnit_stability
% This script illustrates if Fano factor is affected by heart modulations
%
% in this example, two groups of units with the same firing rate are 
% simulated. One spikes randomly and another one has heart-related 
% modulations.
%

stability1 = nan(1000, 1);
stability2 = nan(1000, 1);

heartBeatStarts = [0:9];

for simNum = 1:1000

    t1 = sort(rand(100, 1) * 10); % random timestamps, 10s @ 10 Hz
    
    % drop half of the t1 times imitation hart-beat modulation at 2 Hz
    t1_to_drop = arrayfun(@(x) t1 > x & t1 < x + 0.5, heartBeatStarts, 'UniformOutput', false);
    t1_to_drop = any([t1_to_drop{:}]');
    t1 = t1(~t1_to_drop);
    
    t2 = sort(rand(1, 50) * 10); % random timestamps, 10s @ 5 Hz (as I dropped half of the time stamps of t1)
    
    if simNum == 1
        figure, stem(t1, ones(length(t1),1)), hold on, stem(t2,(-1)*ones(length(t2),1))
        arrayfun(@(x) fill([x+0.5 x x x+0.5], [-1 -1 1 1], 'b', 'LineStyle', 'none', 'FaceAlpha', 0.3), heartBeatStarts, 'UniformOutput', false)
        text(1, -0.8, 'Randomly Spiking Unit', 'BackgroundColor', 'w')
        text(1, 0.8, 'Heart-Responsive Unit', 'BackgroundColor', 'w')
        xlabel('Time, s')
        hold off
    end
    
    FR1 = smooth(diff(t1),10); % the same type of smoothing we have in spike analysis
    FR2 = smooth(diff(t2),10);
    
    stability1(simNum)=nanstd(FR1)/nanmean(FR1); % compute Fano-factor
    stability2(simNum)=nanstd(FR2)/nanmean(FR2);

end

figure,
boxplot([stability1 stability2])
ylabel('Stability: std/mean')
set(gca, 'XTickLabel', {'Heart-Responsive Unit', 'Randomly Spiking Unit'})

end

