function testsim_csi

if 0
C = [-1:0.02:1];
I = [-1:0.02:1];

for c=1:length(C)
	for i=1:length(I)
		CSI(c,i) = csi(C(c),I(i));
	end
end

surf(C,I,CSI);

elseif 0 % test csi_rosen_et_al
	Contra = 0.5 + 0.5*randn(100,1);
	Ipsi = 0.25 + 0.5*randn(100,1);
	CSI = csi_rosen_et_al(Contra,Ipsi)
	
else % simulate effects of inactivation on tuning
	base1 = 10; % [0:5:50];
	R1_c = 5:5:50;
	R1_i = 5;
	% R1_i = ones(size(R1_c))*5;
	
	base2 = base1 + 0;
	R2_c = R1_c-5;
	R2_i = R1_i;
	
	MI1 = csi(base1+R1_c,base1+R1_i);
	MI2 = csi(base2+R2_c,base2+R2_i);
	
	map = jet(length(MI1));
	for k=1:length(MI1),	
		plot(MI1(k),MI2(k),'o','Color',map(k,:)); hold on
	end
	add_equality_line;
	axis equal
	axis square
	xlabel('MI control');
	ylabel('MI inactivaton');
	
end

	
	

function CSI = csi(Contra,Ipsi)

CSI = (Contra-Ipsi)./(Contra+Ipsi);
% CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
% CSI = (Contra-Ipsi);

function CSI = csi_rosen_et_al (Contra,Ipsi)
% Rosen, M.L. et al., 2015. Influences of Long-Term Memory-Guided Attention and Stimulus-Guided Attention on Visuospatial Representations within Human Intraparietal Sulcus. The Journal of Neuroscience, 35(32), pp.11358ÿ11363.

C = mean(Contra);
I = mean(Ipsi);

C_var = var(Contra);
I_var = var(Ipsi);

CSI = (C-I)/sqrt(C_var+I_var);
