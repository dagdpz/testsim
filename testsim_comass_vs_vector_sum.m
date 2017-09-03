% testsim_comass_vs_vector_sum
% for defining RF spatial tuning

% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4123790/
% (see also: http://www.jneurosci.org/content/32/10/3339 https://link.springer.com/content/pdf/10.1007%2Fs004220050411.pdf )


ScaleFactor = 50; % for plotting normalized length of the circular mean of the tuning curve

target_positions2D_a =  [10    5 0  -5 -10  -5  0   5]; 
target_positions2D_b =  [0.001 5 10 5 0.001 -5 -10 -5];
target_positions2D = complex(target_positions2D_a,target_positions2D_b); 

% Firing rate per target
% FR		=	5 + [5  10  5   2   2   2   2   2];
% FR		=	5 + [2  10  2   2   2   2   2   2];
FR		=	5 + [2  10  2   0   0   0   0   0];
FR = FR*2;

FRtarget =   FR.*target_positions2D./abs(target_positions2D);

FRtarget_norm = ScaleFactor*sum(FRtarget)/sum(FR); % this is same as Ldir below! But it is invariant to gain!

Ldir = ScaleFactor*abs(sum(FR.*exp(i*angle(target_positions2D)))/sum(FR)); % magnitude
Ldir_a = angle(sum(FR.*exp(i*angle(target_positions2D)))); % angle

figure
plot(FRtarget,'ko'); hold on; plot([FRtarget FRtarget(1)],'k-');
line([0 (real(FRtarget_norm))],[0 (imag(FRtarget_norm))],'Color',[0 1 0],'LineWidth',3);
line([0 mean(real(FRtarget))],[0 mean(imag(FRtarget))]);

polar(Ldir_a,Ldir,'mo');

[cx,cy] = comass(real(FRtarget),imag(FRtarget));
plot(cx,cy,'ro');
axis equal
title(sprintf('%s |mean(FRtarget)|=%.2f Ldir=%.2f Ldir/FRtarget=%.2f Ldir/comass=%.2f comass=%.2f',...
mat2str(FR),abs(mean(FRtarget)),Ldir,Ldir/sqrt(mean(real(FRtarget))^2+mean(imag(FRtarget))^2),Ldir/sqrt(cx^2+cy^2),sqrt(cx^2+cy^2)));
