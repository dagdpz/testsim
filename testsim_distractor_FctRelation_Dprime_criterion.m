function testsim_distractor_FctRelation_Dprime_criterion


n_trials = 100; % for each stimulus condition

% create all combinations for hits and CR before inactivation
step = 0.1;
cmb  = ig_nchoosek_with_rep_perm([0:step:1],2); %combvec([0:step:1],[0:step:1]); %
% combine all possible
AllComb = combvec(cmb', cmb'); %
% delete identical cases H1 = H3 and another case H3 = H1
%%
AllComb(5,:) = repmat(nan, length(AllComb),1)';
AllComb(6,:) = repmat(nan, length(AllComb),1)';
AllComb = num2cell(AllComb);
figure
set(gcf,'Color',[1 1 1]);
IncreaseErrors_NoSigChange = 0;  IncreaseErrors_ChangeSensCrit = 0;  IncreaseErrors_ChangeCriterion = 0;  IncreaseErrors_ChangeSensitivtiy = 0;
IncreaseNoGo_NoSigChange = 0;  IncreaseNoGo_ChangeSensCrit = 0;  IncreaseNoGo_ChangeCriterion = 0;  IncreaseNoGo_ChangeSensitivtiy = 0;

d = []; beta = []; c = [];
for i_sample = 1: length(AllComb)
    Plot = 0;  H = [];  M = [];  CR = []; FA = [];
    H(1)   = AllComb{1,i_sample};
    M(1)   = 1 - H(1);
    CR(1)  = AllComb{2,i_sample};
    FA(1)  = 1 - CR(1);
    
    H(2)   = AllComb{3,i_sample};
    M(2)   = 1 - H(2);
    CR(2)  =AllComb{4,i_sample};
    FA(2)  = 1 - CR(2);
    %1. Rule: Hit is decreasing
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
    
    
    for k = 1:length(H),
        [d(i_sample,k),beta(i_sample,k),c(i_sample,k)] = testsim_dprime(pHit(k),pFA(k));
    end
    
    
    [p,h,stat] = ranksum(repmat(d(i_sample,1),7,1), repmat(d(i_sample,2),7,1));
    d(i_sample,3) = p;
    [p,h,stat] = ranksum(repmat(c(i_sample,1),7,1), repmat(c(i_sample,2),7,1));
    c(i_sample,3) = p;
    
    %% Rules -> color scheme
    if  H(1) > H(2) &&  CR(1) > CR(2) % decrease in H(2) and CR(2) 
        %Does is lead to a significant shift in dprime, criterion or both? 
        if d(i_sample,3)< 0.05 && c(i_sample,3)< 0.05 
            IncreaseErrors_ChangeSensCrit= IncreaseErrors_ChangeSensCrit +1;
            AllComb{5,i_sample} = 'IncreaseErrors_ChangeSensCrit';
            AllComb{6,i_sample} = IncreaseErrors_ChangeSensCrit;
            Plot  = 2;
        elseif c(i_sample,3) < 0.05
            IncreaseErrors_ChangeCriterion = IncreaseErrors_ChangeCriterion +1;
            AllComb{5,i_sample} = 'IncreaseErrors_ChangeCriterion';
            AllComb{6,i_sample} = IncreaseErrors_ChangeCriterion;
        elseif d(i_sample,3) < 0.05
            IncreaseErrors_ChangeSensitivtiy = IncreaseErrors_ChangeSensitivtiy +1 ;
            AllComb{5,i_sample} = 'IncreaseErrors_ChangeSensitivtiy';
            AllComb{6,i_sample} = IncreaseErrors_ChangeSensitivtiy; 
            Plot = 1;

        else
            IncreaseErrors_NoSigChange = IncreaseErrors_NoSigChange +1;
            AllComb{5,i_sample} = 'IncreaseErrors_NoSigChange';
            AllComb{6,i_sample} = IncreaseErrors_NoSigChange;
        end
        color = [1 0 0];
        %How many cases have a significant shift in dprime / Criterion?
        
        
        
    elseif H(1) > H(2) &&  CR(1) < CR(2)
        if d(i_sample,3)< 0.05 && c(i_sample,3)< 0.05 
            IncreaseNoGo_ChangeSensCrit= IncreaseNoGo_ChangeSensCrit +1;
            AllComb{5,i_sample} = 'IncreaseNoGo_ChangeSensCrit';
            AllComb{6,i_sample} = IncreaseNoGo_ChangeSensCrit;
        elseif c(i_sample,3) < 0.05
            IncreaseNoGo_ChangeCriterion = IncreaseNoGo_ChangeCriterion +1;
            AllComb{5,i_sample} = 'IncreaseNoGo_ChangeCriterion';
            AllComb{6,i_sample} = IncreaseNoGo_ChangeCriterion;
        elseif d(i_sample,3) < 0.05
            IncreaseNoGo_ChangeSensitivtiy = IncreaseNoGo_ChangeSensitivtiy +1 ;
            AllComb{5,i_sample} = 'IncreaseNoGo_ChangeSensitivtiy';
            AllComb{6,i_sample} = IncreaseNoGo_ChangeSensitivtiy; 

        else
            IncreaseNoGo_NoSigChange = IncreaseNoGo_NoSigChange +1;
            AllComb{5,i_sample} = 'IncreaseNoGo_NoSigChange';
            AllComb{6,i_sample} = IncreaseNoGo_NoSigChange;
        end
        
    else
        color = [1 1 1];
    end
    

    
    %% Graph
    if     Plot  == 1
              subplot(2,1,1)
        plot(d(i_sample,1), c(i_sample,1), 'o','color','k' ,'MarkerSize',7,'markerfacecolor','k'); hold on
        plot(d(i_sample,2), c(i_sample,2), 'o','color','b' ,'MarkerSize',7,'markerfacecolor','b'); hold on
        line([d(i_sample,1), d(i_sample,2)], [c(i_sample,1), c(i_sample,2)],'color','k')
        
    elseif Plot == 2
       subplot(2,1,2)

        plot(d(i_sample,1), c(i_sample,1), 'o','color','k' ,'MarkerSize',7,'markerfacecolor','k'); hold on
        plot(d(i_sample,2), c(i_sample,2), 'o','color','b' ,'MarkerSize',7,'markerfacecolor','b'); hold on
        line([d(i_sample,1), d(i_sample,2)], [c(i_sample,1), c(i_sample,2)],'color','k')
%         
%     
%         %PreInjection
%         plot(d(i_sample,1), c(i_sample,1), 'o','color','k' ,'MarkerSize',3,'markerfacecolor',color); hold on
%         
%         subplot(3,1,3)
%         %Post-Injection
%         plot(d(i_sample,2), c(i_sample,2), 'o','color','b' ,'MarkerSize',3,'markerfacecolor',color); hold on
        
    end
end

ylabel(['criterion'])
xlabel(['drpime'])


%% Which cases have an increase in dprime? 

Idx = find(isnan([AllComb{6,:}]) == 0); 
Idx = find(isnan([AllComb{6,:}]) == 0); 
Case = AllComb(:,Idx);
find([AllComb{5,:}] == 0); 
d( Idx, :); 
c( Idx, :); 



