clear all, close all

x = pi/128 : 2*pi/128 : 2*pi-pi/128; % define 128 equally spaced bins
kappa = [0, 0.25, 0.5, 1, 2, 4, 8, 16, 32, 64]; % define kappas

for kNum = 1:length(kappa)
    
%     vmdist(kNum,:) = 100*circ_vmpdf(x, pi, kappa(kNum));
    y(kNum,:) = vMDist(x, pi, kappa(kNum));
    
end

figure,
plot(x, y)
hold on
hline(0.1592, 'k', 'Mean') 
legend({'0', '0.25', '0.5', '1', '2', '4', '8', '16', '32', '64'})

% compute kappas to see how much those are different from the initial
% values
for kNum = 1:length(kappa)
    
    new_kappa(kNum) = circ_kappa(x,y(kNum,:));
    
end

function p = vMDist(alpha, thetahat, kappa)

% original von Mises function
% p = exp( kappa*(cos(alpha-thetahat)-1) ) / (2*pi*besseli(0,kappa,1));

% these von Mises distributions have the same peak
% p = exp( kappa*(cos(alpha-thetahat)-1) );

% these von Mises distributions have 0 baseline and peak amplitude at 1
p = ( exp( kappa*(cos(alpha-thetahat)-1) ) - exp( -2*kappa ) ) / (1 - exp( -2*kappa ));

end
