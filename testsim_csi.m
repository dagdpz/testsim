function testsim_csi

if 1
C = [-1:0.02:1];
I = [-1:0.02:1];

for c=1:length(C)
	for i=1:length(I)
		CSI(c,i) = csi(C(c),I(i));
	end
end

surf(C,I,CSI);

else % test csi_rosen_et_al
	Contra = 0.5 + 0.5*randn(100,1);
	Ipsi = 0.25 + 0.5*randn(100,1);
	CSI = csi_rosen_et_al(Contra,Ipsi)
	
end

	
	

function CSI = csi(Contra,Ipsi)

% CSI = (Contra-Ipsi)./(Contra+Ipsi);
CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
% CSI = (Contra-Ipsi);

function CSI = csi_rosen_et_al (Contra,Ipsi)
% Rosen, M.L. et al., 2015. Influences of Long-Term Memory-Guided Attention and Stimulus-Guided Attention on Visuospatial Representations within Human Intraparietal Sulcus. The Journal of Neuroscience, 35(32), pp.11358ÿ11363.

C = mean(Contra);
I = mean(Ipsi);

C_var = var(Contra);
I_var = var(Ipsi);

CSI = (C-I)/sqrt(C_var+I_var);
