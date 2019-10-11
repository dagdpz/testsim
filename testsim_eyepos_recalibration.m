% function testsim_eyepos_recalibration
% recalibration of eye position data

% define targets

rng(120); % set random seed

% Tx = [0 0 10 0 -10];
% Ty = [0 10 0 -10 0];

Tx = [-30 -15 0 15 30 -30 -15 0 15 30 -30 -15 0 15 30];
Ty = [10 10 10 10 10 0 0 0 0 0 -10 -10 -10 -10 -10];

n_T = length(Tx); % number of targets

n_trials_per_T = 20;

x_offset_amp = 1;
x_offset_off = 0;
x_var = 1; % variability from trial to trial

y_offset_amp = 2;
y_offset_off = -1;
y_var = 0.5;

Tx_offset = x_offset_off + x_offset_amp*randn(size(Tx));
Ty_offset = y_offset_off + y_offset_amp*randn(size(Ty));

% raw gaze
gx = zeros(n_T,n_trials_per_T);
gy = zeros(n_T,n_trials_per_T);

for t=1:n_T,
    
    gx(t,:) = Tx(t) + Tx_offset(t) + x_var*randn(n_trials_per_T,1);
    gy(t,:) = Ty(t) + Ty_offset(t) + y_var*randn(n_trials_per_T,1);
    
end
    

% reshaping
Gx = reshape(gx',n_T*n_trials_per_T,1);
Gy = reshape(gy',n_T*n_trials_per_T,1);

TTx = reshape(repmat(Tx,n_trials_per_T,1),n_T*n_trials_per_T,1);
TTy = reshape(repmat(Ty,n_trials_per_T,1),n_T*n_trials_per_T,1);


    
% transformationType: 'NonreflectiveSimilarity' | 'Similarity' | 'Affine' | 'Projective' | 'pwl'
% or 'polynomial' 
transformationType = 'polynomial';
switch transformationType
    case 'polynomial'
        tform = fitgeotrans([TTx TTy], [Gx Gy], transformationType,2);
    otherwise
        tform = fitgeotrans([TTx TTy], [Gx Gy], transformationType);
end

recG = transformPointsInverse(tform, [Gx Gy]); 


% plotting
figure;
plot(Tx,Ty,'ko','MarkerSize',6); hold on
plot(Gx,Gy,'r.');
plot(recG(:,1),recG(:,2),'g.');

axis equal
