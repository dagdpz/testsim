% testsim_diff_sum_vs_mean 
s1 = rand(1,100) + 2;
s2 = rand(1,100) + 2.5;

s3 = rand(1,100) + 1;
s4 = rand(1,100) + 1.5;


diff_sum = (s1 + s2) - (s3 + s4);
diff_mean = (s1 + s2)/2 - (s3 + s4)/2;

diff_sum = (s1 + s1) - (s3 + s3);
diff_mean = (s1 + s1)/2 - (s3 + s3)/2;

subplot(2,1,1)
plot([s1' s2' s3' s4']);


subplot(2,1,2)
plot([diff_sum' diff_mean']);