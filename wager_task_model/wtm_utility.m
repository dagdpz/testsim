function [u] = wtm_utility(value,params)

if nargin < 2
    R = 0.9;	% power function for gain
    T = 0.91;	% power function for loss
    S = 1.1;	% risk aversion coefficient
elseif length(params)==3,
    R = params(1);
    T = params(2);
    S = params(3);
else
    error('provide 3 parameters');
end

u = ( 0.5*(sign(value)-1)*S  + 0.5*(sign(value)+1) ) .*  abs(value).^( 0.5*(1 - sign(value))*T + 0.5*(sign(value)+1)*R );

% previous approach with the loop, does not work with value matrix
% for k = 1:length(value)
%     if value(k)<0, % cost, convert time/loss to utility
%         u(k) = -S*abs(value(k)).^T;
%     else
%         u(k) = value(k).^R;
%     end
% end


