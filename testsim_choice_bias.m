function testsim_choice_bias

N = 20; % trials

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
colorbar;


subplot(2,1,2)
surf(C,I,f);
ylabel('contra');
xlabel('ipsi');
title('number of fixations');
colorbar;

figure(2)
subplot(2,1,1)
plot(f,CB, 'o');
ylabel('choice bias');
xlabel('fixazion');
title('number of fixations');
colorbar;