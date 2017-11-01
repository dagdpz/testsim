% test Fisher's exact test

%% Fisher's exact test on proportions of two outcomes

% example 1 
% https://dag-wiki.dpz.eu/doku.php?id=analysis:stat:fisherexacttest
% http://www.socscistatistics.com/tests/fisher/Default2.aspx
if 0
disp('Example 1')
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

elseif 0
	
disp('Example 2')
Ns1 = 4; % preceding L
Ns2 = 8; % preceding R
 
p_suc1 = 0.5; % probability preceding in status 1
p_suc2 = 0.7; % probability success in status 2
 
y1 = zeros(1,Ns1);	
y2 = ones(1,Ns2);	
 
x1 = [zeros(1,round(  (1-p_suc1)*Ns1 )) ones( 1, round(p_suc1*Ns1) )];	% status 1 outcome 
x2 = [zeros(1,round(  (1-p_suc2)*Ns2 )) ones( 1, round(p_suc2*Ns2) )];	% status 2 outcome 
 
p = fexact( [x1 x2]' , [y1 y2]' )

elseif 1
disp('Example 3: MATLAB fishertest')
% https://de.mathworks.com/help/stats/fishertest.html
load hospital

sex = double(hospital.Sex=='Male');
smoker = double(hospital.Smoker); 
p = fexact( smoker , sex ) % matrix way, same as MATLAB help (p=0.0375)

[tbl,chi2,p,labels] = crosstab(hospital.Sex,hospital.Smoker);
% 40 13
% 26 21
p = fexact( 40, 100, 53, 66 ); % fexact( a,M,K,N): same as MATLAB help (p=0.0375)

end