% testsim_anova_gaze_ret

% relationship between two-way anova on initial gaze and retinocentric tuning and one-way anova on final gaze position

% initial gaze and final gaze : saccade paper
n = 10; % n trials per condition, 16 conditions
noise    = 0.01;

% initial gaze
% 1 12 123 23 3
% 1 2  13  2  3
% 1 12 123 23 3

% retinocentric one gaze position
% 1 2 3
% 4   5
% 6 7 8

% retinocentric
% 1 21 321 32 3
% 4 4  54  5  5
% 6 76 876 87 8

% final
% 1   23   456   78   9
% 10  11   1213  14   15
% 16 1718 192021 2223 24

ini_gaze = [1*ones(n,1); 1*ones(n,1); 2*ones(n,1); 1*ones(n,1); 2*ones(n,1); 3*ones(n,1); 2*ones(n,1); 3*ones(n,1); 3*ones(n,1);...
            1*ones(n,1); 2*ones(n,1); 1*ones(n,1); 3*ones(n,1); 2*ones(n,1); 3*ones(n,1);...
	    1*ones(n,1); 1*ones(n,1); 2*ones(n,1); 1*ones(n,1); 2*ones(n,1); 3*ones(n,1); 2*ones(n,1); 3*ones(n,1); 3*ones(n,1);];

ret =	   [1*ones(n,1); 2*ones(n,1); 1*ones(n,1); 3*ones(n,1); 2*ones(n,1); 1*ones(n,1); 3*ones(n,1); 2*ones(n,1); 3*ones(n,1);...
            4*ones(n,1); 4*ones(n,1); 5*ones(n,1); 4*ones(n,1); 5*ones(n,1); 5*ones(n,1);...
	    6*ones(n,1); 7*ones(n,1); 6*ones(n,1); 8*ones(n,1); 7*ones(n,1); 6*ones(n,1); 8*ones(n,1); 7*ones(n,1); 8*ones(n,1);];

% only ret, tuning according to ret target 1->8
FR = 	    [1*ones(n,1); 2*ones(n,1); 1*ones(n,1); 3*ones(n,1); 2*ones(n,1); 1*ones(n,1); 3*ones(n,1); 2*ones(n,1); 3*ones(n,1);...
            4*ones(n,1); 4*ones(n,1); 5*ones(n,1); 4*ones(n,1); 5*ones(n,1); 5*ones(n,1);...
	    6*ones(n,1); 7*ones(n,1); 6*ones(n,1); 8*ones(n,1); 7*ones(n,1); 6*ones(n,1); 8*ones(n,1); 7*ones(n,1); 8*ones(n,1);];

% only ret, upper ret targets (10 20 10)
f(1) = 10;
f(2) = 20;
f(3) = 10;
f(4) = 0;
f(5) = 0;
f(6) = 0;
f(7) = 0;
f(8) = 0;

% only ret, right ret targets (15 20 15)
f(1) = 0;
f(2) = 0;
f(3) = 15;
f(4) = 0;
f(5) = 20;
f(6) = 0;
f(7) = 0;
f(8) = 15;

% only ret, upper corner
f(1) = 0;
f(2) = 15;
f(3) = 20;
f(4) = 0;
f(5) = 15;
f(6) = 0;
f(7) = 0;
f(8) = 0;

% only ret, hemifield + center
f(1) = 0;
f(2) = 15;
f(3) = 15;
f(4) = 0;
f(5) = 20;
f(6) = 0;
f(7) = 15;
f(8) = 15;

FR = 	    [f(1)*ones(n,1); f(2)*ones(n,1); f(1)*ones(n,1); f(3)*ones(n,1); f(2)*ones(n,1); f(1)*ones(n,1); f(3)*ones(n,1); f(2)*ones(n,1); f(3)*ones(n,1);...
            f(4)*ones(n,1); f(4)*ones(n,1); f(5)*ones(n,1); f(4)*ones(n,1); f(5)*ones(n,1); f(5)*ones(n,1);...
	    f(6)*ones(n,1); f(7)*ones(n,1); f(6)*ones(n,1); f(8)*ones(n,1); f(7)*ones(n,1); f(6)*ones(n,1); f(8)*ones(n,1); f(7)*ones(n,1); f(8)*ones(n,1);];

    
% FR = rand(240,1); % random FR

FR = 10*FR + noise*randn(length(FR),1);


figure('Position',[100 100 1200 300]);
subplot(1,3,1)
t=[1 2 4 10 12 16 17 19];
for k=1:8,
	FR_1(k) = mean( FR((t(k)-1)*n+1:(t(k)-1)*n+n) );
end
FR_1 = [FR_1(1:4) NaN FR_1(5:8)]; FR_1 = reshape(FR_1,3,3)'; imagesc(FR_1);

subplot(1,3,2)
t=[3 5 7 11 14 18 20 22];
for k=1:8,
	FR_2(k) = mean( FR((t(k)-1)*n+1:(t(k)-1)*n+n) );
end
FR_2 = [FR_2(1:4) NaN FR_2(5:8)]; FR_2 = reshape(FR_2,3,3)'; imagesc(FR_2);

subplot(1,3,3)
t=[6 8 9 13 15 21 23 24];
for k=1:8,
	FR_3(k) = mean( FR((t(k)-1)*n+1:(t(k)-1)*n+n) );
end
FR_3 = [FR_3(1:4) NaN FR_3(5:8)]; FR_3 = reshape(FR_3,3,3)'; imagesc(FR_3);
	



[p,table,stats,terms] = anovan(FR,[ini_gaze ret],'model','full','varnames',{'ini gaze' 'ret'})

final_gaze =[1*ones(n,1); 2*ones(n,1); 2*ones(n,1); 3*ones(n,1); 3*ones(n,1); 3*ones(n,1); 4*ones(n,1); 4*ones(n,1); 5*ones(n,1);...
            6*ones(n,1); 7*ones(n,1); 8*ones(n,1); 8*ones(n,1); 9*ones(n,1); 10*ones(n,1);...
	    11*ones(n,1); 12*ones(n,1); 12*ones(n,1); 13*ones(n,1); 13*ones(n,1); 13*ones(n,1); 14*ones(n,1); 14*ones(n,1); 15*ones(n,1);];

% [p,table,stats,terms] = anovan(FR,[final_gaze],'model','full','varnames',{'final gaze'})
[p,table,stats] = anova1(FR,[final_gaze])

for fg = 1:15,
	FR_fg(fg) = mean(FR((final_gaze == fg)));
end

FR_fg = reshape(FR_fg,5,3)';

figure
imagesc(FR_fg)

