% testsim_RT_variability

RT1 = 200 + 50*randn(1,100);
RT2 = 300 + 60*randn(1,100);

CVRT1 = std(RT1)/mean(RT1);
CVRT2 = std(RT2)/mean(RT2);

