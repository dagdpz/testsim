% function testsim_pca_clustering
clear all

Noise = 1;
class1 = ones(10,50) + Noise*randn(10,50);
class2 = repmat(linspace(0,1,50),10,1) + Noise*randn(10,50);
class3 = repmat(linspace(1,0,50),10,1) + Noise*randn(10,50);

cl1idx = 1:10;
cl2idx = 11:20;
cl3idx = 21:30;

X = [class1; class2; class3];

[coeff,score,latent,tsquared,explained,mu] = pca(X,'VariableWeights','variance');

n_clusters = 3;
% cluster first 3 PCs
T1 = clusterdata(score(:,1:3),n_clusters);

Z = linkage(score(:,1:3),'ward');



ig_figure('Position',[100 100 1200 700]);
subplot(2,3,1)
plot(class1','r'); hold on
plot(class2','g');
plot(class3','b');

subplot(2,3,2)
plot3(score(cl1idx,1),score(cl1idx,2),score(cl1idx,3),'r+'); hold on
plot3(score(cl2idx,1),score(cl2idx,2),score(cl2idx,3),'g+');
plot3(score(cl3idx,1),score(cl3idx,2),score(cl3idx,3),'b+');
xlabel('1st PC');
ylabel('2nd PC');
zlabel('3rd PC');

subplot(2,3,3)
pareto(explained)
xlabel('Principal Component');
ylabel('Variance Explained (%)');


subplot(2,3,4)
scatter3(score(:,1),score(:,2),score(:,3),100,T1,'filled');

subplot(2,3,5)
dendrogram(Z);


