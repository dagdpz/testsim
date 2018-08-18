function testsim_QSR
% Fleming, S. M., Putten, E. J. van der and Daw, N. D. (2018) 
% ‘Neural mediators of changes of mind about perceptual decisions’, Nature Neuroscience, 21(4), pp. 617–624. 
% doi: 10.1038/s41593-018-0104-6.


correct = [ones(1,11) zeros(1,11)]; % correct 1, incorrect 0
conf	= [0:0.1:1 0:0.1:1];

p = qsr(correct, conf,1,1);

plot(conf(correct==1),p(correct==1),'go'); hold on
plot(conf(correct==0),p(correct==0),'ro'); hold on
xlabel('Confidence in being correct');
ylabel('Earnings');


function p = qsr(correct, conf, a, b)
if nargin < 4,
	a = 1;
	b = 1;
end
p = a - b*(correct - conf).^2;
% p = a - b*(1-conf.^2);
% p = a - b*(1-(1-conf.^2);



