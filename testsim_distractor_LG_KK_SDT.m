% function testsim_distractor_LG_KK_SDT
clear all

% predictions

% Legend
%       contra | ispi
% pre     1       2
% post    3       4

%%

IndependentCalculation = 1; % for double stimuli, using all three outcomes (dependent) or only two out of three (independent for contra/ipsi)
n_trials = 100; % for each stimulus condition
%%
scenario = 'Single Stimuli: Pre: no spatial bias, add spatial bias to contra';
% scenario = 'add spatial bias to contra and ipsi';
% scenario = 'contra perceptual problem';
% scenario = 'high hit rate, but ipsi spatial bias'; % like Curius early stim single targets, difficult distractor
% scenario = 'DoubleStimuli add ipsi choice bias';
 scenario = 'Double Stimuli - Pre: No spatial choice bias & Post: ipsi choice Bias';
% scenario = 'Double Stimuli - contra perceptual problem';
% scenario = 'Double Stimuli - Curius inactivation session 7 20190913'; 

% Enter the Proportion for Hits, Misses, FA, CR
switch scenario
    
    case 'Single Stimuli: Pre: no spatial bias, add spatial bias to contra';
        IndependentCalculation = 1;
        H(1)   = 0.7; %0.7
        M(1)   = 0.3; %0.3
        FA(1)  = 0.3;
        CR(1)  = 0.7;
        
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
    
    case 'DoubleStimuli add ipsi choice bias';
        % spatial-saccade choice bias (ipsi) [without same discrimination performance]?
        % Fixation is the same for contra vs ipsi M(1) = M(2)
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations do not change for both hemifields
        % targets are highly selected (easy distractor)
        % for independent and dependent calculations
        % H(1) + M(1) + H(2) should add to 1
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)+ sb ;
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        

    
     case 'Double Stimuli - contra perceptual problem';
        
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post

        H(3)   = H(1)- sb ;
        M(3)   = M(1)+ sb;
        FA(3)  = FA(1)+ sb;
        CR(3)  = CR(1)- sb;
        
        % ispi post
        H(4)   = H(2) ;
        M(4)   = M(3);
        FA(4)  = FA(2);
        CR(4)  = CR(3);
        
        if H(1)+ M(1)+ H(2) == 1
            disp('Pre: target-trials: add up to 1')
        end
        if FA(1)+ CR(1)+ FA(2) == 1
            disp('Pre: distractor-trials: add up to 1')
        end
        if H(3)+ M(3)+ H(4) == 1
            disp('Post: target-trials: add up to 1')
        end
        if FA(3)+ CR(3)+ FA(4) == 1
            disp('Post: distractor-trials: add up to 1')
        end
        
        
        
    case 'Double Stimuli - Pre: No spatial choice bias & Post: ipsi choice Bias';
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.2;
        FA(1)  = 0.1; %0.1;
        CR(1)  = 0.5; %0.6;
        
        % ipsi pre
        H(2)   = 0.3;
        M(2)   = M(1);
        FA(2)  = 0.4;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)+ sb ;
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        

        if H(1)+ M(1)+ H(2) == 1 
            disp('Pre: target-trials: add up to 1')
        end
        if FA(1)+ CR(1)+ FA(2) == 1 
            disp('Pre: distractor-trials: add up to 1')
        end
        if H(3)+ M(3)+ H(4) == 1
            disp('Post: target-trials: add up to 1')
        end
        if FA(3)+ CR(3)+ FA(4) == 1
            disp('Post: distractor-trials: add up to 1')
        end
        
  case 'Double Stimuli - Curius inactivation session 7 20190913';
        % spatial choice bias  (ipsi) with good discrimination performance
        % for distractors
        % Fixation is the same for contra vs ipsi M(1) = M(2)

        % Pre: no choice bias -> Post: ipsi choice bias -> fixations doesn't change for both hemifields
        % target are highly selected
        % H(1) + M(1) + H(2) should add to 1
        %pre 26/67 + 1/67  + 40/67 
        %pst 11/61 + 0/61 +50/61
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 26/67;
        M(1)   = 1/67;
        FA(1)  = 21/65;
        CR(1)  = 23/65;
        
        % ipsi pre
        H(2)   = 40/67;
        M(2)   = M(1);
        FA(2)  = 21/65;
        CR(2)  = CR(1);
        
        % contra post
        H(3)   = 11/61 ;
        M(3)   = 0/61;
        FA(3)  = 19/62;
        CR(3)  = 19/62;
        
        % ispi post
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
     
    case 'Double D-T Stimuli - Pre: No spatial choice bias & Post: ipsi choice Bias';
        % contra pre
            % contra pre
        H(1)   = 0.5;
        M(1)   = 0.2;
        FA(1)  = 0.1; %0.1;
        CR(1)  = 0.5; %0.6;
        
        % ipsi pre
        H(2)   = 0.3;
        M(2)   = M(1);
        FA(2)  = 0.4;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)+ sb ;
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        
        if H(1)+ M(1)+ H(2) == 1 
            disp('Pre: target-trials: add up to 1')
        end
        if FA(1)+ CR(1)+ FA(2) == 1 
            disp('Pre: distractor-trials: add up to 1')
        end
        if H(3)+ M(3)+ H(4) == 1
            disp('Post: target-trials: add up to 1')
        end
        if FA(3)+ CR(3)+ FA(4) == 1
            disp('Post: distractor-trials: add up to 1')
        end
end


%% It should be before the dprime calculation because 0.5 is added to the Nb.of trials

Tar_IpsiSelection(1)    = H(2) ./ (H(1) + H(2) + M(1)); %ipsi
Tar_ContraSelection(1)  = H(1) ./ (H(1) + H(2) + M(1));
Tar_fixation(1)         = M(1) ./ (H(1) + H(2) + M(1));
Tar_IpsiSelection(2)    = H(4) ./ (H(3) + H(4) + M(3));
Tar_ContraSelection(2)  = H(3) ./ (H(3) + H(4) + M(3));
Tar_fixation(2)         = M(3) ./ (H(3) + H(4) + M(3));
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


if IndependentCalculation == 1
    pHit = H ./ (H + M);
    pFA = FA ./ (FA + CR);
else
    H_ = [H(2) H(1) H(4) H(3) ];
    FA_ = [FA(2) FA(1) FA(4) FA(3) ];
    pHit = H ./ (H + M +H_);
    pFA = FA ./ (FA + CR +FA_);
end

for k = 1:4,
    [dprime(k),beta(k),criterion(k)] = testsim_dprime(pHit(k),pFA(k));
end

%% Graph
% Selection 
Plot_Rows = 3; 
Plot_Colums = 3; 
MarkSize = 10; 
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
if IndependentCalculation == 1
    Title = 'pHit/FA independent Calculation: '; 
    mult = -1; 
else
    Title = 'pHit/FA dependent Calculation'; 
    mult = -1;
end
set(gcf,'Name',[Title, '  Selection, Dprime, Criterion' ,scenario]);
set(gcf,'Color',[1 1 1]);
title([scenario sprintf('\n')])


    subplot(Plot_Colums,Plot_Rows,1);
    plot([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1 ]); hold on;
    plot([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ]); hold on;
    line([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'Color',[1 0 0],'LineWidth', 2); hold on; 
    line([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'Color',[0 0 1],'LineWidth', 2); hold on;

    set(gca,'ylim',[0 1])
    ylabel( 'Selection','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    legend('ipsi', 'con')


    subplot(Plot_Colums,Plot_Rows,2);
    plot([1;2], [Tar_fixation(1),Tar_fixation(2)], 'o','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [Tar_fixation(1),Tar_fixation(2)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Fixation','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);

%% Hitrate vs Falsealarm rate
% figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% set(gcf,'Name','Hitrate and FalseAlarmRate');

    subplot(Plot_Colums,Plot_Rows,4);
    plot([1;2], [pHit(2),pHit(4)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1 ]); hold on;
    plot([1;2], [pHit(1),pHit(3)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ]); hold on;
    line([1;2], [pHit(2),pHit(4)], 'Color',[0 0 1],'LineWidth', 2); hold on;
    line([1;2], [pHit(1),pHit(3)], 'Color',[1 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    legend('ipsi', 'contra')


    subplot(2,3,4);
    plot([1;2], [pHit(1),pHit(3)], 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
    line([1;2], [pHit(1),pHit(3)], 'Color',[0 0 0],'LineWidth', 2); hold on;
    set(gca,'ylim',[0 1])
    ylabel( 'Hitrate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    title('contra')

    subplot(Plot_Colums,Plot_Rows,5);
    plot([1;2], [pFA(2),pFA(4)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1 ]); hold on;
    line([1;2], [pFA(2),pFA(4)], 'Color',[0 0 1],'LineWidth', 2); hold on;
    plot([1;2], [pFA(1),pFA(3)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ]); hold on;
    line([1;2], [pFA(1),pFA(3)], 'Color',[1 0 0],'LineWidth', 2); hold on;
  
    set(gca,'ylim',[0 1])
    ylabel( 'False alarm rate','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',20);
    


%% Dprime vs Criterion
% figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% set(gcf,'Name','Dprime vs Criterion');

    subplot(Plot_Colums,Plot_Rows,6);
    plot(dprime(1),criterion(1), 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
    plot(dprime(2),mult*criterion(2), 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;% reverse direction of criterion for ipsi

    plot(dprime(3),criterion(3), 'o','color',[1 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[1 0 0]);
    plot(dprime(4),mult*criterion(4), 'o','color',[0 0 1] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 1]);% reverse direction of criterion for ipsi
   
    xlabel('sensitivity')
    ylabel('criterion')
    set(gca,'ylim',[-2 2])
    set(gca,'xlim',[0 4])
    %legend('Black: pre')
    %title('contra')
%     
%     subplot(Plot_Colums,Plot_Rows,3);
%     plot(dprime(2),criterion(2), 'o','color',[0 0 0] , 'MarkerSize',15,'markerfacecolor',[0 0 0 ]); hold on;
%     plot(dprime(4),criterion(4), 'o','color',[0 0 1] ,'MarkerSize',15,'markerfacecolor',[0 0 1]);
%     xlabel('sensitivity')
%     ylabel('criterion')
%     set(gca,'ylim',[-2 2])
%     set(gca,'xlim',[0 4])
%     legend('pre', 'post')   
%     title('ipsi')
% 

 
%% Graph - change in criterion or change in dprime
% figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% set(gcf,'Name','Change in Dprime and Criterion');
    subplot(Plot_Colums,Plot_Rows,9);

plot((dprime(1)-dprime(3)),(criterion(1)-criterion(3)), 'o','color',[1 0 0] , 'MarkerSize',15,'markerfacecolor',[1 0 0 ]); hold on;
%ipsi blue 
plot((dprime(2)-dprime(4)),((mult*criterion(2))-(mult*criterion(4))), 'o','color',[0 0 1] , 'MarkerSize',15,'markerfacecolor',[0 0 1 ]); hold on;
xlabel('deltaPrePost sensitivity')
ylabel('deltaPrePost criterion')
set(gca,'ylim',[-2 2])
set(gca,'xlim',[-2 2])
legend('contra', 'ipsi')

%% OLD  graphs for criterion and dprime
%figure

subplot(Plot_Colums,Plot_Rows,7);
title([scenario sprintf('\n') 'dprime'])
plot([1 3],[dprime(1) dprime(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[dprime(2) dprime(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'con pre' 'ipsi pre' 'con pst' 'ipsi pst'},'FontSize',12,'TickDir','out','box','off');
ylabel(['dprime'])
set(gca,'ylim',[-1 3])

subplot(Plot_Colums,Plot_Rows,8);
plot([1 3],[criterion(1) criterion(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[mult*criterion(2) mult*criterion(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on % reverse direction of criterion for ipsi
plot([0 5],[0 0],'k--');
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'con pre' 'ipsi pre' 'con pst' 'ipsi pst'},'FontSize',12,'TickDir','out','box','off');
ylabel(['criterion'])
set(gca,'ylim',[-2 2])






