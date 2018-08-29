% testsim_M2S_orientations
%M2S_orientations, in deg

PTBconvention = 1; % if 1, then vertical is 0 and increase is cw (PTB convention); if 0, then horizontal is 0 and increase is ccw (MATLAB convention)

switch PTBconvention
	case 0 % MATLAB convention 
		sample_start = 18;
		sample_end   = 54;
		sample_step  = 4;
		
		% arbitrary deviation per difficulty (deg)
		d = [4 8 12 16 20];
		% d = [3 6 9 12 15];
		
	case 1 % PTB convention (Kristin's convention)
		
		% negative: ccw from 0 (vertical) in PTB (for bars)
		
		sample_start = 30;
		sample_end   = 57;
		sample_step  = 3;
		
		d = 20;
				
end
		
visOffset__cw = -0.5; % visualization offset for overlapping line (deg)
visOffset_ccw = - visOffset__cw;

% END OF SETTINGS

samples = [sample_start:sample_step:sample_end];
N_samples = length(samples);
N_diff = length(d);

if PTBconvention, % convert from PTB to MATLAB
	samples = mod(90 - samples,360);
end

% clockwise (cw) are warm colors
diff_colormap__cw = cool(2*length(d));
diff_colormap__cw = diff_colormap__cw(N_diff+1:end,:);

% counterclockwise (ccw) are cool colors
diff_colormap_ccw = cool(2*length(d));
diff_colormap_ccw = diff_colormap_ccw(1:N_diff,:);

figure;
for k = 1:N_samples
	h_sample = polar([samples(k)*pi/180+pi samples(k)*pi/180],[0 1],'k'); hold on
	set(h_sample,'LineWidth',1.5);
	
	for dd = 1:N_diff,
		h_nonmatch__cw = polar([(samples(k)+visOffset__cw*dd -d(dd))*pi/180+pi  (samples(k)+visOffset__cw*dd -d(dd))*pi/180],[0 1],'r'); hold on
		h_nonmatch_ccw = polar([(samples(k)+visOffset_ccw*dd +d(dd))*pi/180+pi  (samples(k)+visOffset_ccw*dd +d(dd))*pi/180],[0 1],'r'); hold on
		set(h_nonmatch__cw,'Color',diff_colormap__cw(dd,:),'LineWidth',1);
		set(h_nonmatch_ccw,'Color',diff_colormap_ccw(dd,:),'LineWidth',1);
	end
	% pause;
	
end


delete(findall(gcf,'type','text'));