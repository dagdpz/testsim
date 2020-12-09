function r = testsim_p_2_Effectsize_r(p, N)
%p .. p-value
%N.. number of oberservation

 r = norminv(p)/sqrt(N);           
