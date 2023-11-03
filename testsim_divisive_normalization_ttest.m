function [p1, p2] = testsim_divisive_normalization_ttest

C1 = randn(1,30); % condition 1
C2 = randn(1,30) + 1; % condition 2
V = 5*rand(1,30); % variation in amplitude from channel to channel

C1 = C1+V;
C2 = C2+V;

[h1, p1] = ttest(C1,C2);

% normalized within each channel
C1n = C1./max([C1; C2]);
C2n = C2./max([C1; C2]);

[h2, p2] = ttest(C1n,C2n);


% for k=1:1000,  [p1(k), p2(k)] = testsim_divisive_normalization_ttest; end
% loglog(p1,p2,'.');
% hold on
% loglog(p1(p1<0.05),p2(p1<0.05),'r.');
% 
% axis equal
% hold on
% plot([0.0000000000000000001 1], [0.0000000000000000001 1], 'k--', 'LineWidth', 2); 
% set(gca,'Xlim',xlim,'Ylim',ylim);
% axis square
% xlabel('p-value without norm. (red dots < 0.05)');
% ylabel('p-value with norm.');
