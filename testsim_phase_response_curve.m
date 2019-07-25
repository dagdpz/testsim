function testsim_phase_response_curve

I = 500+50*randn(1,100);
hist(I)
mean(I)
ans =
  506.1543
plot(I(1:99),I(2:100),'o')
C = I-mean(I);
[C_sort, ind_sort] = sort(C);
I_sort = I(ind_sort);
plot(I_sort(1:99),C_sort(2:100),'o')
set(gca,'xlim',[0 1000])