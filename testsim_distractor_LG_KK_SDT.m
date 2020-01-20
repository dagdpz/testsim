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
scenario = 'contra perceptual problem';
scenario = 'high hit rate, but ipsi spatial bias'; % like Curius early stim single targets, difficult distractor
scenario = 'DoubleStimuli add ipsi choice bias';
scenario = 'Double Stimuli - Curius inactivation'; 

% Enter the Proportion for Hits, Misses, FA, CR
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
        sb = 0.15;
        %general increase in errors: reduce Hits, increase Miss, reduce CR, increase FA
        H(3)   = H(1) - sb; % 0.55;
        M(3)   = M(1) + sb; %0.45;
        FA(3)  = FA(1)+ sb; %0.45;
        CR(3)  = CR(1)- sb; %0.55;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
    case 'high hit rate, but ipsi spatial bias';
        H(1)   = 0.9;
        M(1)   = 0.1;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.9;
        M(2)   = 0.1;
        FA(2)  = 0.7;
        CR(2)  = 0.3;
        
        sb = 0.1;
        H(3)   = H(1);
        M(3)   = M(1);
        FA(3)  = FA(1);
        CR(3)  = CR(1);
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2)+sb;
        CR(4)  = CR(2)-sb;
    
   case 'DoubleStimuli add ipsi choice bias _';
       % Fixation is the same for contra vs ipsi M(1) = M(2)
       % Pre: no choice bias -> Post: ipsi choice bias -> fixations doesn't change for both hemifields
       % target are highly selected
        H(1)   = 0.8; 
        M(1)   = 0.2;
        FA(1)  = 0.2;
        CR(1)  = 0.8;
        
        H(2)   = 0.8;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
       
        sb = 0.19;
        H(3)   = H(1)- sb ;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        H(4)   = H(2)+ sb ;
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        
    case 'DoubleStimuli add ipsi choice bias';
        % Fixation is the same for contra vs ipsi M(1) = M(2)
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations doesn't change for both hemifields
        % target are highly selected
        % H(1) + M(1) + H(2) should add to 1
        % FA(1) + CR(1) + FA(2) should add to 1
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        H(3)   = H(1)- sb ;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        H(4)   = H(2)+ sb ;
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
  case 'Double Stimuli - Curius inactivation';
        % Fixation is the same for contra vs ipsi M(1) = M(2)
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations doesn't change for both hemifields
        % target are highly selected
        % H(1) + M(1) + H(2) should add to 1
        %pre 26/67 + 1/67  + 40/67 
        %pst 11/61 + 0/61 +50/61
        % FA(1) + CR(1) + FA(2) should add to 1
        H(1)   = 26/67;
        M(1)   = 1/67;
        FA(1)  = 21/65;
        CR(1)  = 23/65;
        
        H(2)   = 40/67;
        M(2)   = M(1);
        FA(2)  = 21/65;
        CR(2)  = CR(1);
        

        H(3)   = 11/61 ;
        M(3)   = 0/61;
        FA(3)  = 19/62;
        CR(3)  = 19/62;
        
        H(4)   = 50/61 ;
        M(4)   = M(3);
        FA(4)  = 24/62;
        CR(4)  = CR(3);  
        if H(1)+ M(1)+ H(2) == 1
            disp('target-trials: add up to 1')
        end
        if FA(1)+ CR(1)+ FA(2) == 1
            disp('distractor-trials: add up to 1')
        end
end


%% It should be before the dprime calculation because 0.5 is added to the Nb.of trials
c = 0;
for indPos = 1:2
Tar_IpsiSelection(1+c)    = H(1+indPos) ./ (H(1+indPos) + H(2+indPos) + M(1+indPos));
Tar_ContraSelection(1+c)  = H(2+indPos) ./ (H(1+indPos) + H(2+indPos) + M(1+indPos));
Tar_fixation(1+c)         = M(1+indPos) ./ (H(1+indPos) + H(2+indPos) + M(1+indPos));
c = 0+1; 
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
    [dprime(k),beta(k),criterion(k)] = testsim_dprime(pHit(k),pFA(k));
end

%% Graph
% Selection 
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name','Selection');
    subplot(1,3,1);
    plot([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Ipsilateral selection','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);

    subplot(1,3,2);
    plot([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Contralateral Selection','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);

    subplot(1,3,3);
    plot([1;2], [Tar_fixation(1),Tar_fixation(2)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [Tar_fixation(1),Tar_fixation(2)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Fixation','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);

%% Hitrate vs Falsealarm rate
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name','Hitrate and FalseAlarmRate');

    subplot(2,3,1);
    plot([1;2], [pHit(2),pHit(4)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [pHit(2),pHit(4)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    title('ipsi')

    subplot(2,3,4);
    plot([1;2], [pHit(1),pHit(1)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [pHit(1),pHit(1)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    title('contra')

    subplot(2,3,3);
    plot([1;2], [pFA(2),pFA(4)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [pFA(2),pFA(4)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    title('ipsi')
    
    subplot(2,3,6);
    plot([1;2], [pFA(1),pFA(3)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [pFA(1),pFA(3)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    title('contra')


% Dprime vs Criterion
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name','Dprime vs Criterion');
c = 0;
for indPos = 1:2
    subplot(1,2,indPos);
    plot(dprime(1+c),criterion(1+c), 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    plot(dprime(3+c),criterion(3+c), 'o','color',[0 0 1] ,'MarkerSize',15,'markerfacecolor',[0 0 1]);
    xlabel('sensitivity')
    ylabel('criterion')
    set(gca,'ylim',[-2 2])
    set(gca,'xlim',[0 4])
    if indPos == 1
        title('contra')
    else
        title('ipsi')
    end
    c = c+1;
   legend('pre', 'post')

end


%% OLD  graphs for criterion and dprime
figure
set(gcf,'Color',[1 1 1]);

subplot(2,1,1)

plot([1 3],[dprime(1) dprime(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[dprime(2) dprime(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'contra pre' 'ipsi pre' 'contra post' 'ipsi post'},'FontSize',12,'TickDir','out','box','off');
title([scenario sprintf('\n') 'dprime'])

subplot(2,1,2)
plot([1 3],[criterion(1) criterion(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[-criterion(2) -criterion(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on % reverse direction of criterion for ipsi
plot([0 5],[0 0],'k--');
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'contra pre' 'ipsi pre' 'contra post' 'ipsi post'},'FontSize',12,'TickDir','out','box','off');
title(['criterion'])





