% testsim_stat_power
% example script
% http://www.mathworks.com/help/stats/examples/selecting-a-sample-size.html
% https://dag-wiki.dpz.eu/doku.php?id=analysis:stat:statpower

%% difference between two normal distributions
mean_1 = 200;
std_1 = 30;
n1 = 200;

mean_2 = 205;
std_2 = 30;
n2 = 200;

% method 1: MATLAB sampsizepwr
% how many samples we need to detect difference between mean_1 and mean_2?
n_sampsizepwr = sampsizepwr('t',[mean_1 std_1],mean_2,0.95,[],'alpha',0.05,'tail','both')

% given n1 samples, which difference in mean can we detect?
mu2 = sampsizepwr('t',[mean_1 std_1],[],0.95,n1)

% method 2: 
% to confirm method 1, use n1 and n2 from n_sampsizepwr
n1 = n_sampsizepwr;
n2 = n_sampsizepwr;

% or set it here, e.g. from G*Power program 
n1 = 937;
n2 = 937;

for i = 1:100,
	RT1 = normrnd(mean_1,std_1,[n1,1]);
	RT2 = normrnd(mean_2,std_2,[n2,1]);
	[h(i),p(i)] = ttest2(RT1,RT2);
end

hist(h);


%% Fisher's exact test on proportions of two outcomes
Ns1 = 10; % condition, or status 1 (e.g. control)
Ns2 = 10; % condition, or status 2 (e.g. stimulation)

% Let's assign arbitrary outcome 2 ("1") as "success"
p_suc1 = 0.2; % probability success in status 1
p_suc2 = 0.9; % probability success in status 2

y1 = zeros(1,Ns1);	
y2 = ones(1,Ns2);	

x1 = [zeros(1,round(  (1-p_suc1)*Ns1 )) ones( 1, round(p_suc1*Ns1) )];	% status 1 outcome 
x2 = [zeros(1,round(  (1-p_suc2)*Ns2 )) ones( 1, round(p_suc2*Ns2) )];	% status 2 outcome 
	
p = fexact( [x1 x2]' , [y1 y2]' )


% approximating by Binomial distribution, 100 times
% http://www.stat.yale.edu/Courses/1997-98/101/binom.htm

count_success1 = binornd(Ns1,p_suc1,1,100); % this draws a count of success
count_success2 = binornd(Ns2,p_suc2,1,100);

y1 = zeros(1,Ns1);	
y2 = ones(1,Ns2);

for i = 1:100,
	x1 = [zeros(1,Ns1-count_success1(i)) ones( 1, count_success1(i) )];	% status 1 outcome 
	x2 = [zeros(1,Ns1-count_success2(i)) ones( 1, count_success2(i) )];	% status 1 outcome 

	p(i) = fexact( [x1 x2]' , [y1 y2]' );
end

hist(p<0.05);










