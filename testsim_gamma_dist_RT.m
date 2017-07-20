% testsim_gamma_dist_RT
% Concerning reaction times
% The mean of the gamma distribution with parameters a (shape) and b (scale) is "ab". The variance is ab^2.
% http://en.wikipedia.org/wiki/Gamma_distribution

mu = 250; % mean RT ms
sd = 50; % ms
bins =  0:50:1000; % reaction time bins (ms)

% rt = normrnd(mu,sd,[500,1]); % normal
% rt =  gamrnd(30,8.33,[500,1]);
% rt =  gamrnd(8.33,30,[500,1]);
% rt =  gamrnd(5,50,[500,1]);
rt =  gamrnd(10,25,[500,1]);
% rt =  100 + gamrnd(4,250/4,[500,1]);

% http://www.neural-code.com/index.php/tutorials/action/reaction-time/83-reciprobit-distribution
% load('testsim_panda_reactiontime_for_testsim_gamma_dist_RT.mat'); % load the reaction time data into Matlab workspace
% rt = RT.easy; % let's take the reaction times (ms) for the "easy" task

[params,ci] = gamfit(rt);

figure(1)
[N,bins] = hist(rt,bins);
N       = 100*N./sum(N);
h       = bar(bins,N); hold on ; 
set(h,'FaceColor',[.7 .7 .7]);
box off; axis square;
xlabel('Reaction time (ms)'); % and setting labels is essential for anyone to understand graphs!
ylabel('Probability (%)');

% x    = linspace(min(rt),max(rt),length(bins));
x    = linspace(bins(1),bins(end),length(bins));
y = gampdf(x,params(1),params(2));
% y  = normpdf(x,mu,sd);
y       = y./sum(y)*100;

plot(x,y,'r','LineWidth',2);
title(sprintf('mean %.2f a %.1f b %.1f ',params(1)*params(2),params(1),params(2))); 
xlim([0 1000]);




% check if gamma distribution RTs are compatible with LATER model
% http://www.neural-code.com/index.php/tutorials/action/reaction-time/83-reciprobit-distribution

%% Inverse reaction time
rtinv   = 1./rt; % inverse reaction time / promptness (ms-1)

n_bins           = numel(bins); % number of bins in reaction time plot
xi               = linspace(1/2000,1/100,n_bins); % promptness bins
Ni               = hist(rtinv,xi);
Ni               = 100*Ni./sum(Ni);
figure(2)
h = bar(xi*1000,Ni); % in s
hold on
set(h,'FaceColor',[.7 .7 .7]);
box off; axis square;
xlabel('Promptness (s^{-1})');
ylabel('Probability (%)');
title('Reciprocal time axis');
set(gca,'YTick',0:5:100,'XTick',0:1:8);
xlim([0 8]);

% Does this look like a Gaussian?
% Let's plot a Gaussian curve with mean and standard deviation from the
% promptness data
mui      = mean(rtinv);
sdi      = std(rtinv);
yi       = normpdf(xi,mui,sdi);
yi       = yi./sum(yi)*100;
plot(xi*1000,yi,'ks-','LineWidth',2,'MarkerFaceColor','w');


% And test it with a one-sample kolmogorov-smirnov test
% Since this test compares with the normal distribution, we have to
% normalize the data, which we can do with zscore, which is the same as:
% z = (x-mean(x))/std(x)
[h,p]   = kstest(zscore(rt)); % for reaction time
if h
        str             = ['The null hypothesis that the reaction time distribution is Gaussian distributed is rejected, with P = ' num2str(p)];
else
        str             = ['The null hypothesis that the reaction time distribution is Gaussian distributed is NOT rejected, with P = ' num2str(p)];
end
disp(str); % display the results in command window
[h,p]   = kstest(zscore(rtinv)); % for inverse reaction time
if h
        str             = ['The null hypothesis that the inverse reaction time distribution is Gaussian distributed is rejected, with P = ' num2str(p)];
else
        str             = ['The null hypothesis that the inverse reaction time distribution is Gaussian distributed is NOT rejected, with P = ' num2str(p)];
end
disp(str); % display the results in command window








