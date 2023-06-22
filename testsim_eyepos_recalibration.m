% function testsim_eyepos_recalibration
% recalibration of eye position data
% see also MPA_recalibrate_eye_data

% define targets

% rng(120); % set random seed

Tx = [0 0 10 0 -10];
Ty = [0 10 0 -10 0];

% Tx = [-30 -15 0 15 30 -30 -15 0 15 30 -30 -15 0 15 30];
% Ty = [10 10 10 10 10 0 0 0 0 0 -10 -10 -10 -10 -10];


TNx = [-5 5]; % new targets, on which calibration is not run
TNy = [-5 5];


n_T = length(Tx); % number of targets
n_TN = length(TNx);

n_trials_per_T = 20;

x_offset_amp = 0.1;
x_offset_off = 0.2;
x_var = 0.5; % variability from trial to trial

y_offset_amp = 0.1;
y_offset_off = 0.2;
y_var = 0.5;

if 0 % fixed offsets and some random offset per target
    Tx_offset = x_offset_off + x_offset_amp*randn(size(Tx));
    Ty_offset = y_offset_off + y_offset_amp*randn(size(Ty));
    TNx_offset = x_offset_off + x_offset_amp*randn(size(TNx));
    TNy_offset = y_offset_off + y_offset_amp*randn(size(TNy));
else % offset scaling with positive eccentricity
    Tx_offset = x_offset_off*(Tx - min(Tx) + 0.2) + x_offset_amp*randn(size(Tx));
    Ty_offset = y_offset_off*(Ty - min(Ty) + 0.2) + y_offset_amp*randn(size(Ty));
    TNx_offset = x_offset_off*(TNx - min(Tx) + 0.2) + x_offset_amp*randn(size(TNx));
    TNy_offset = y_offset_off*(TNy - min(Ty) + 0.2) + y_offset_amp*randn(size(TNy));
end

% raw gaze
gx = zeros(n_T,n_trials_per_T);
gy = zeros(n_T,n_trials_per_T);
gNx = zeros(n_TN,n_trials_per_T);
gNy = zeros(n_TN,n_trials_per_T);



for t=1:n_T,
    
    gx(t,:) = Tx(t) + Tx_offset(t) + x_var*randn(n_trials_per_T,1);
    gy(t,:) = Ty(t) + Ty_offset(t) + y_var*randn(n_trials_per_T,1);   
    
end
    
for t=1:n_TN,
    
    gNx(t,:) = TNx(t) + TNx_offset(t) + x_var*randn(n_trials_per_T,1);
    gNy(t,:) = TNy(t) + TNy_offset(t) + y_var*randn(n_trials_per_T,1);   
    
end

% reshaping
Gx = reshape(gx',n_T*n_trials_per_T,1);
Gy = reshape(gy',n_T*n_trials_per_T,1);

GNx = reshape(gNx',n_TN*n_trials_per_T,1);
GNy = reshape(gNy',n_TN*n_trials_per_T,1);

TTx = reshape(repmat(Tx,n_trials_per_T,1),n_T*n_trials_per_T,1);
TTy = reshape(repmat(Ty,n_trials_per_T,1),n_T*n_trials_per_T,1);


    
% transformationType: 'NonreflectiveSimilarity' | 'Similarity' | 'Affine' | 'Projective' | 'pwl'
% or 'polynomial' 
transformationType = 'Similarity';
switch transformationType
    case 'polynomial'
        tform = fitgeotrans([TTx TTy], [Gx Gy], transformationType,2);
    otherwise
        tform = fitgeotrans([TTx TTy], [Gx Gy], transformationType);
end

recG = transformPointsInverse(tform, [Gx Gy]); 
recGN = transformPointsInverse(tform, [GNx GNy]); 


% plotting
figure;
plot(Tx,Ty,'ko','MarkerSize',6); hold on
plot(TNx,TNy,'mo','MarkerSize',6); hold on

plot(Gx,Gy,'r.');
plot(recG(:,1),recG(:,2),'g.');

plot(GNx,GNy,'rx');
plot(recGN(:,1),recGN(:,2),'gx');

axis equal




if 1 % test timing of applying transform
    recGk = recG;
    
    t1 = zeros(size(Gx));
    t2 = t1;
    for k = 1:length(Gx)
        t1(k) = GetSecs;
        recG(k,:)=transformPointsInverse(tform, [Gx(k) Gy(k)]);
        t2(k) = GetSecs;
        
    end
    
    figure
    plot(t2-t1,'.');
end
