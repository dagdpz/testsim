function testsim_choice_bias

N = 100; % trials

C = [0:N];
I = [0:N];
f = NaN(length(C),length(I));
CB = f;
for c = 1:length(C)
    for i = 1:length(I) 
        if (C(c) + I(i)) <= N
            f(c,i) = N - C(c) - I(i);
            CB(c,i) = (C(c) - I(i))/N;
        end
    end
end


subplot(2,1,1)
surf(C,I,CB);
ylabel('contra');
xlabel('ipsi');
title('Choice bias');

subplot(2,1,2)
surf(C,I,f);
ylabel('contra');
xlabel('ipsi');
title('fixation');