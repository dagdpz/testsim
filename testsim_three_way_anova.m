% testsim_three_way_anova

% DV: firing rate, factors: left/right, instr/choice, epoch (1:8), 10 trials each
% N  = 240 trials x 8 epochs
space = [zeros(1,60*8) ones(1,60*8) zeros(1,60*8) ones(1,60*8)]'
type = [zeros(1,120*8) ones(1,120*8)]';
epoch = repmat([1:8]',240,1);

% firing rate
FR = rand(1,240*8)';
[p,table,stats,terms] = anovan(FR,[space type epoch],'model','full','varnames',{'space' 'type' 'epoch'})

