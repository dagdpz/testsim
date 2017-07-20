% test inter-hemispheric correlations
clear all
close all

cd = 0.5; % contralateral difference

% independent
choice_left_RH = cd + rand(1,50);
choice_right_RH = rand(1,50);
choice_left_LH = rand(1,50);
choice_right_LH = cd + rand(1,50);

figure
subplot(2,1,1)
hold on;
plot(choice_left_RH, choice_left_LH,'bo');
plot(choice_right_RH, choice_right_LH,'ro');
disp('independent');
corrcoef([choice_left_RH choice_right_RH],[choice_left_LH choice_right_LH]) 
corrcoef([choice_left_RH],[choice_left_LH])
corrcoef([choice_right_RH],[choice_right_LH])
axis equal
axis square
title('independent');


subplot(2,1,2), hold on
hist(choice_right_RH - choice_right_LH);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
hist(choice_left_RH - choice_left_LH);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w')


% covariation due to common input
common_input_left = (rand(1,50)-1)*0.5;
common_input_right = (rand(1,50)-1)*0.5;

choice_left_RH = cd + rand(1,50) + common_input_left;
choice_right_RH = rand(1,50) + common_input_right;
choice_left_LH = rand(1,50) + common_input_left;
choice_right_LH = cd + rand(1,50) + common_input_right;

figure
subplot(2,1,1)
hold on;
plot(choice_left_RH, choice_left_LH,'bo');
plot(choice_right_RH, choice_right_LH,'ro');
disp('covariation due to common input');
corrcoef([choice_left_RH choice_right_RH],[choice_left_LH choice_right_LH]) 
corrcoef([choice_left_RH],[choice_left_LH])
corrcoef([choice_right_RH],[choice_right_LH])
axis equal
axis square
title('% covariation due to common input');

subplot(2,1,2), hold on
hist(choice_right_RH - choice_right_LH);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
hist(choice_left_RH - choice_left_LH);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w')

% relative difference constant and commont input
common_input_left = (rand(1,50)-1)*0.25;
common_input_right = (rand(1,50)-1)*0.25;

choice_left_RH = cd + rand(1,50) + common_input_left;
choice_right_RH = rand(1,50) + common_input_right;
choice_left_LH = choice_left_RH - 0.2;
choice_right_LH = choice_right_RH + 0.2;

figure
subplot(2,1,1)
hold on;
plot(choice_left_RH, choice_left_LH,'bo');
plot(choice_right_RH, choice_right_LH,'ro');
disp('relative difference constant and commont input');
corrcoef([choice_left_RH choice_right_RH],[choice_left_LH choice_right_LH]) 
corrcoef([choice_left_RH],[choice_left_LH])
corrcoef([choice_right_RH],[choice_right_LH])
axis equal
axis square
title('% relative difference constant and commont input');


subplot(2,1,2), hold on
hist(choice_right_RH - choice_right_LH);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
hist(choice_left_RH - choice_left_LH);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w')


% push-pull 
common_input_left = (rand(1,50)-1)*0;
common_input_right = (rand(1,50)-1)*0;

choice_left_RH = cd + rand(1,50) + common_input_left;
choice_right_RH = rand(1,50) + common_input_right;
choice_left_LH = rand(1,50) + common_input_left;
choice_right_LH = cd + rand(1,50) + common_input_right;

choice_right_RH = choice_right_RH - 0.3*choice_right_LH;
choice_left_LH = choice_left_LH - 0.3*choice_left_RH;



figure
subplot(2,1,1)
hold on;
plot(choice_left_RH, choice_left_LH,'bo');
plot(choice_right_RH, choice_right_LH,'ro');
disp('push-pull');
corrcoef([choice_left_RH choice_right_RH],[choice_left_LH choice_right_LH]) 
corrcoef([choice_left_RH],[choice_left_LH])
corrcoef([choice_right_RH],[choice_right_LH])
axis equal
axis square
title('% push-pull');


subplot(2,1,2), hold on
hist(choice_right_RH - choice_right_LH);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
hist(choice_left_RH - choice_left_LH);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w')


% push-pull and covariation due to common input
common_input_left = (rand(1,50)-1)*0.25;
common_input_right = (rand(1,50)-1)*0.25;

choice_left_RH = cd + rand(1,50) + common_input_left;
choice_right_RH = rand(1,50) + common_input_right;
choice_left_LH = rand(1,50) + common_input_left;
choice_right_LH = cd + rand(1,50) + common_input_right;

choice_right_RH = choice_right_RH - 0.3*choice_right_LH;
choice_left_LH = choice_left_LH - 0.3*choice_left_RH;



figure
subplot(2,1,1)
hold on;
plot(choice_left_RH, choice_left_LH,'bo');
plot(choice_right_RH, choice_right_LH,'ro');
disp('push-pull and covariation due to common input');
corrcoef([choice_left_RH choice_right_RH],[choice_left_LH choice_right_LH]) 
corrcoef([choice_left_RH],[choice_left_LH])
corrcoef([choice_right_RH],[choice_right_LH])
axis equal
axis square
title('% push-pull and covariation due to common input');


subplot(2,1,2), hold on
hist(choice_right_RH - choice_right_LH);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
hist(choice_left_RH - choice_left_LH);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w')


