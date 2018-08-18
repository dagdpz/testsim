function [u] = wtm_utility_farashahi2018(m,TOPLOT)
% Farashahi, S. et al. (2018) ‘On the Flexibility of Basic Risk Attitudes in Monkeys’, The Journal of Neuroscience, 38(18), pp. 4383–4398. doi: 10.1523/JNEUROSCI.2260-17.2018.

% m - magnitude

if nargin < 2,
	TOPLOT = 0;
end

gamma = 1; % loss aversion coefficient
rho_G = 1.5; % > 1: risk seeking
rho_L = 0.7; % < 1: risk seeking

model = 'EU';
switch model
	
	case 'EU'
		u = ( 0.5*(sign(m)-1)*gamma  + 0.5*(sign(m)+1) ) .*  abs(m/100).^( 0.5*(1 - sign(m))*rho_L + 0.5*(sign(m)+1)*rho_G );
		
end
		
	
if TOPLOT,
	plot(m/100,u); axis square; grid on;
	ig_add_equality_line;
	title(sprintf('model %s, gamma %.2f rho_G %.2f rho_L %.2f',model, gamma, rho_G, rho_L));
end


