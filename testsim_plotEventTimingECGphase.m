function testsim_plotEventTimingECGphase(ecgRPeaks, eventTimes)
    % Calculate ECG cycle durations
    ecgCycleDurations = diff(ecgRPeaks);
    numCycles = length(ecgCycleDurations);
    
    % Normalize event times to the respective ECG cycle durations
    eventTimesNorm = zeros(size(eventTimes));
    for i = 1:numCycles
        cycleStart = ecgRPeaks(i);
        cycleEnd = ecgRPeaks(i+1);
        cycleDuration = cycleEnd - cycleStart;
        
        % Normalize event times within the current cycle
        eventTimesCycle = eventTimes((eventTimes >= cycleStart) & (eventTimes < cycleEnd));
        eventTimesNorm((eventTimes >= cycleStart) & (eventTimes < cycleEnd)) = ...
            (eventTimesCycle - cycleStart) / cycleDuration;
    end
    
    % Calculate the phase of each event
    eventPhase = 2*pi*eventTimesNorm;
    
    % Create polar plot
   
    % h = polar(eventPhase, ones(size(eventPhase)), 'ro');
    
    % MATLAB 2016 and later
    % polarplot(eventPhase, ones(size(eventPhase)), 'o', 'MarkerSize', 6,'MarkerEdgeColor', 'red'); 
    polarscatter(eventPhase, ones(size(eventPhase)),40,'red','filled','MarkerFaceAlpha',.5);
    thetaticks(0:30:330);  % Set theta axis tick positions
    thetaticklabels({'0', '30', '60', '90', '120', '150', '180', '210', '240', '270', '300', '330'});  % Set theta axis tick labels
      
    % Set the radial axis limit to 1
    rlim([0 1]);
    
    title('Event Timing as a Function of ECG Cycle Phase');