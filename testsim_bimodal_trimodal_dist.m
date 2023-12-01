% function testsim_bimodal_trimodal_dist
% Assuming 'data' is your vector of samples
% data = [0.2399 0.9041 0.0000 1.0000 0.0965 0.0000 0.9495 1.0000 0.3480 0.0000 0.0992 1.0000 0.1092 0.3083 1.0000 0.0179 0.3197 0.9694 0.2112 0.0814 0.2561 0.2994 0.0993 0.4026 0.3749 0.3406 0.0000 0.7783 0.0775 0.2098 1.0000 1.0000 1.0000 0.0509 0.3038 0.9054 1.0000 1.0000 0.9486 0.9747 0.9374 0.4245 0.3755 0.1577 0.3216 0.3971 0.1335 0.4093 0.9164 0.1453 0.1819 0.0104 0.3073 0.0657 0.4086 0.0000 0.8989 0.8369]; 
% data = [0.3 0.33 0.34 0.35 0.36 0.2399 0.9041 0.0000 1.0000 0.0965 0.0000 0.9495 1.0000 0.3480 0.0000 0.0992 1.0000 0.1092 0.3083 1.0000 0.0179 0.3197 0.9694 0.2112 0.0814 0.2561 0.2994 0.0993 0.4026 0.3749 0.3406 0.0000 0.7783 0.0775 0.2098 1.0000 1.0000 1.0000 0.0509 0.3038 0.9054 1.0000 1.0000 0.9486 0.9747 0.9374 0.4245 0.3755 0.1577 0.3216 0.3971 0.1335 0.4093 0.9164 0.1453 0.1819 0.0104 0.3073 0.0657 0.4086 0.0000 0.8989 0.8369]; 
data = [0.0430 0.0000 0.0000 0.0419 0.0233 0.3587 0.3050 0.0000 0.0000 0.9357 0.3344 0.2916 0.2694 0.3652 1.0000 0.2314 0.3126 1.0000 0.0505 0.3113 0.0223 0.3805 1.0000 1.0000 0.9488 0.9153 0.3672 1.0000 1.0000 0.3236 0.2557 1.0000 0.0000 0.0000 1.0000 0.9539 0.3111 0.0153 0.0081 0.3843 0.4314 0.0442 1.0000 0.0000 0.9921 0.3138 0.9196 0.1363 0.0000 0.0090 0.9665 0.3673 0.8813 0.0000 0.9642 1.0000 0.3295 0.9634];


hist(data);

% Reshape data for fitting
data = data';

% Fit bimodal distribution
gmModelBi = fitgmdist(data, 2,'RegularizationValue',0.01); % 2 components for bimodal

% Fit trimodal distribution
gmModelTri = fitgmdist(data, 3,'RegularizationValue',0.01); % 3 components for trimodal

% Compute AIC and BIC for model comparison
AIC_Bi = gmModelBi.AIC;
BIC_Bi = gmModelBi.BIC;
AIC_Tri = gmModelTri.AIC;
BIC_Tri = gmModelTri.BIC;

% Display the results
fprintf('Bimodal Fit: AIC = %.2f, BIC = %.2f\n', AIC_Bi, BIC_Bi);
fprintf('Trimodal Fit: AIC = %.2f, BIC = %.2f\n', AIC_Tri, BIC_Tri);

% Determine which model is better
if AIC_Bi < AIC_Tri
    fprintf('Bimodal fit is better based on AIC.\n');
else
    fprintf('Trimodal fit is better based on AIC.\n');
end

if BIC_Bi < BIC_Tri
    fprintf('Bimodal fit is better based on BIC.\n');
else
    fprintf('Trimodal fit is better based on BIC.\n');
end
