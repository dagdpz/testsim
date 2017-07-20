% testsim_poffenberger_anova

% example of LH

LL_A = 1;
LR_A = 1.2; % crossed
RL_A = 1.2; % crossed
RR_A = 1;

LL = normrnd(LL_A,0.3,[100,1]);
LR = normrnd(LR_A,0.3,[100,1]);
RL = normrnd(RL_A,0.3,[100,1]);
RR = normrnd(RR_A,0.3,[100,1]);

hand = [zeros(200,1) ; ones(200,1)];
space = [zeros(100,1) ; ones(100,1) ; zeros(100,1) ; ones(100,1)];
cu    = [zeros(100,1) ; ones(100,1) ; ones(100,1) ; zeros(100,1)];

[p,table,stats,terms] = anovan([LL ; LR ; RL ; RR],[hand space],'model',[1 0; 0 1; 1 1],'varnames',{'hand' 'space'});
[p,table,stats,terms] = anovan([LL ; LR ; RL ; RR],[hand cu],'model',[1 0; 0 1; 1 1],'varnames',{'hand' 'cu'});

