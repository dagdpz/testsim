% function testsim_distractor_LG_KK_SDT
clear all

% predictions

% Legend
%       contra | ispi
% pre     1       2
% post    3       4

n_trials = 100; % for each stimulus condition

scenario = 'add spatial bias to contra';
scenario = 'add spatial bias to contra and ipsi';
% scenario = 'contra perceptual problem';

% Hits, Misses, FA, CR
switch scenario
    
    case 'add spatial bias to contra';
        H(1)   = 0.7;
        M(1)   = 0.3;
        FA(1)  = 0.2;
        CR(1)  = 0.8;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.19;
        H(3)   = H(1)+sb;
        M(3)   = M(1)-sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)-sb;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
    case 'add spatial bias to contra and ipsi';
        H(1)   = 0.7;
        M(1)   = 0.3;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.2;
        H(3)   = H(1)+sb;
        M(3)   = M(1)-sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)-sb;
        
        H(4)   = H(2)-sb;
        M(4)   = M(2)+sb;
        FA(4)  = FA(2)-sb;
        CR(4)  = CR(2)+sb;
        
        
    case 'contra perceptual problem';
        H(1)   = 0.7;
        M(1)   = 0.3;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        H(3)   = 0.55;
        M(3)   = 0.45;
        FA(3)  = 0.45;
        CR(3)  = 0.55;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
        
end


% avoid 0 or Inf probabilities
if any(H==0) || any(M==0) || any(FA==0) || any(CR==0),
    % add 0.5 to both the number of hits and the number of false alarms,
    % add 1 to both the number of signal trials and the number of noise trials; dubbed the loglinear approach (Hautus, 1995)
    
    disp('correcting...');
    
    n_trials = n_trials + 1;
    
    H = single(H*n_trials);
    M = single(M*n_trials);
    FA = single(FA*n_trials);
    CR = single(CR*n_trials);
    
    H = H + 0.5;
    M = M + 0.5;
    FA = FA + 0.5;
    CR = CR + 0.5;
    
else
    
    
    H = single(H*n_trials);
    M = single(M*n_trials);
    FA = single(FA*n_trials);
    CR = single(CR*n_trials);
    
end



pHit = H ./ (H + M);
pFA = FA ./ (FA + CR);


for k = 1:4,
    [d(k),beta(k),c(k)] = testsim_dprime(pHit(k),pFA(k));
end

figure
set(gcf,'Color',[1 1 1]);

subplot(2,1,1)

plot([1 3],[d(1) d(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[d(2) d(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'contra pre' 'ipsi pre' 'contra post' 'ipsi post'},'FontSize',12,'TickDir','out','box','off');
title([scenario sprintf('\n') 'dprime'])

subplot(2,1,2)
plot([1 3],[c(1) c(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[-c(2) -c(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on % reverse direction of criterion for ipsi
plot([0 5],[0 0],'k--');
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'contra pre' 'ipsi pre' 'contra post' 'ipsi post'},'FontSize',12,'TickDir','out','box','off');
title(['criterion'])





