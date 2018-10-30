% testsim_comass_vs_vector_sum
% for defining RF spatial tuning

% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4123790/
% (see also: http://www.jneurosci.org/content/32/10/3339 https://link.springer.com/content/pdf/10.1007%2Fs004220050411.pdf )


if 0 % variant 1: 8 targets
ScaleFactor = 10; % for plotting normalized length of the circular mean of the tuning curve

target_positions2D_a =  [10    5 0  -5 -10  -5  0   5]; 
target_positions2D_b =  [0.001 5 10 5 0.001 -5 -10 -5];
target_positions2D = complex(target_positions2D_a,target_positions2D_b); 

% Firing rate per target
% FR		=	5 + [5  10  5   2   2   2   2   2];
% FR		=	5 + [2  10  2   2   2   2   2   2];
FR		=	5 + [2  10  2   0   0   0   0   0];
FR = FR*2;

elseif 1 % variant 2: 4 targets
	ScaleFactor = 1; % for plotting normalized length of the circular mean of the tuning curve

	target_positions2D_a =  [1  -1  -1  1]; 
	target_positions2D_b =  [1   1	 -1  -1];
	target_positions2D = complex(target_positions2D_a,target_positions2D_b); 
	FR		=	1 * [1   0.1 0.1 0.1];
	
	
elseif 0 % variant 3: 8 targets but same tuning as variant 2
	ScaleFactor = 1; % for plotting normalized length of the circular mean of the tuning curve

	target_positions2D_a =  [1  0 -1 -1 -1  0  1 1]; 
	target_positions2D_b =  [1  1  1  0 -1 -1 -1 0];
	target_positions2D = complex(target_positions2D_a,target_positions2D_b); 
	FR		=	1 * [1 0.1285  0.1 0.0707 0.1 0.0707 0.1 0.1285];
	
end



FRtarget =   FR.*target_positions2D./abs(target_positions2D);

FRtarget_norm = ScaleFactor*sum(FRtarget)/sum(FR); % this is same as Ldir below! But it is invariant to gain!

Ldir = ScaleFactor*abs(sum(FR.*exp(i*angle(target_positions2D)))/sum(FR)); % magnitude
Ldir_a = angle(sum(FR.*exp(i*angle(target_positions2D)))); % angle

figure
plot(FRtarget,'ko'); hold on; plot([FRtarget FRtarget(1)],'k-');
line([0 (real(FRtarget_norm))],[0 (imag(FRtarget_norm))],'Color',[0 1 0],'LineWidth',3); % it is not vector sum! it is normalized by sum(FR)
line([0 mean(real(FRtarget))],[0 mean(imag(FRtarget))],'Color',[0 0 0],'LineWidth',1);

polar(Ldir_a,Ldir,'mo'); % it is not vector sum! it is normalized by sum(FR)

[cx,cy] = ig_comass(real(FRtarget),imag(FRtarget));
plot(cx,cy,'ro');
axis equal
title(sprintf('%s |mean(FRtarget)|=%.2f Ldir=%.2f Ldir/FRtarget=%.2f Ldir/comass=%.2f comass=%.2f',...
mat2str(FR),abs(mean(FRtarget)),Ldir,Ldir/sqrt(mean(real(FRtarget))^2+mean(imag(FRtarget))^2),Ldir/sqrt(cx^2+cy^2),sqrt(cx^2+cy^2)));
