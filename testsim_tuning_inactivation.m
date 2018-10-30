function testsim_tuning_inactivation

% variant 1: one task, two conditions (e.g. pre- and post-injection), two epochs: "baseline" and "response", 
% four trial types (contralesional and ipsilesional hand and space)

% close all;

% 1 - control
%base1 = 10*ones(1,10); % [0:5:50]; % baseline firing
% base1 = 2:11;
% R1_csch = 5:5:50;
% R1_csih = 5:5:50;
% R1_isch = 5*ones(1,10);
% R1_isih = 5*ones(1,10);

base1 = 5;
R1_csch = 30;
R1_csih = 20;
R1_isch = 15;
R1_isih = 10;

A1_csch = base1 + R1_csch;
A1_csih = base1 + R1_csih;
A1_isch = base1 + R1_isch;
A1_isih = base1 + R1_isih;

% 2 - inactivation
base2 = base1;
R2_csch = R1_csch+100;
R2_csih = R1_csih;
R2_isch = R1_isch;
R2_isih = R1_isih;

baseline_multiplication_factor = 1; % typically is 1
A2_csch = baseline_multiplication_factor*(base2 + R2_csch);
A2_csih = baseline_multiplication_factor*(base2 + R2_csih);
A2_isch = baseline_multiplication_factor*(base2 + R2_isch);
A2_isih = baseline_multiplication_factor*(base2 + R2_isih);

if 1 % for specific unit debug
temp1 = num2cell([ 7.6667   11.1111    6.3333    4.1111]); % Lin_20170707_07
temp2 = num2cell([32.4000   38.0000   24.6667   22.3333]); % Lin_20170707_07

[A1_isch A1_csch A1_csih A1_isih] = deal(temp1{:});
[A2_isch A2_csch A2_csih A2_isih] = deal(temp2{:});
end


map = jet(length(R1_csch));

if 1 % normalize by max rate in condition 1 in each cell
	max_per_cell_1 = max([A1_isch; A1_csch; A1_csih; A1_isih]);
	% max_per_cell_1 = max([(A1_isch+A2_isch)/2; (A1_csch+A2_csch)/2; (A1_csih+A2_csih)/2; (A1_isih+A2_isih)/2]);
	
	A1_isch = A1_isch./max_per_cell_1;
	A1_csch = A1_csch./max_per_cell_1;
	A1_csih = A1_csih./max_per_cell_1;
	A1_isih = A1_isih./max_per_cell_1;
	
	A2_isch = A2_isch./max_per_cell_1;
	A2_csch = A2_csch./max_per_cell_1;
	A2_csih = A2_csih./max_per_cell_1;
	A2_isih = A2_isih./max_per_cell_1;
	
end

figure;
for k=1 % 1:length(A1_isch),
	plot_diag_two_conditions([1 2 3 4],[A1_isch(k) A1_csch(k) A1_csih(k) A1_isih(k)],...
				 [1 2 3 4],[A2_isch(k) A2_csch(k) A2_csih(k) A2_isih(k)],'Marker','.','Color',map(k,:)); hold on
			 
			 % tuning indices
			 TI1_space(k) = csi(mean([A1_csch A1_csih]),mean([A1_isch A1_isih]));
			 TI2_space(k) = csi(mean([A2_csch A2_csih]),mean([A2_isch A2_isih]));
			 TI1_hand(k) = csi(mean([A1_csch A1_isch]),mean([A1_isih A1_csih]));
			 TI2_hand(k) = csi(mean([A2_csch A2_isch]),mean([A2_isih A2_csih]));
			 
end

max1 = max(max([A1_isch; A1_csch; A1_csih; A1_isih]));
max2 = max(max([A2_isch; A2_csch; A2_csih; A2_isih]));
maxv = max([max1 max2]);

set(gca,'xlim',[-maxv maxv]);
set(gca,'ylim',[-maxv maxv]);
axis square
ig_add_diagonal_line;
ig_add_zero_lines;
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
line([xlim(1) xlim(2)],[ylim(2) ylim(1)],'Color','k','LineStyle',':');
colorbar;

if length(A1_csch) == 1, % only one cell
	figure;
	plot(TI1_space,TI2_space,'ro'); hold on;
	plot(TI1_hand,TI2_hand,'go'); hold on;
	set(gca,'xlim',[-1 1], 'ylim', [-1 1]);
	ig_add_diagonal_line;
	ig_add_zero_lines;
	axis square
	xlabel('TI1');
	ylabel('TI2');
end

function h = plot_diag_two_conditions(diag1, mag1, diag2, mag2, varargin)
% diag 1 -> 2 -> 3 - 4 counterclockwise
% IS-CH CS-CH CS-IH IS-IH

% if ~all(size(diag) == size(mag)),	
% end

for d = 1:length(diag1),
	switch diag(d),
		case 1
			x1(d) = sqrt(mag1(d)^2/2);
			y1(d) = sqrt(mag1(d)^2/2);
			x2(d) = sqrt(mag2(d)^2/2);
			y2(d) = sqrt(mag2(d)^2/2);
		case 2
			x1(d) = -sqrt(mag1(d)^2/2);
			y1(d) = sqrt(mag1(d)^2/2);
			x2(d) = -sqrt(mag2(d)^2/2);
			y2(d) = sqrt(mag2(d)^2/2);
		case 3
			x1(d) = -sqrt(mag1(d)^2/2);
			y1(d) = -sqrt(mag1(d)^2/2);
			x2(d) = -sqrt(mag2(d)^2/2);
			y2(d) = -sqrt(mag2(d)^2/2);
		case 4
			x1(d) = sqrt(mag1(d)^2/2);
			y1(d) = -sqrt(mag1(d)^2/2);
			x2(d) = sqrt(mag2(d)^2/2);
			y2(d) = -sqrt(mag2(d)^2/2);
	end
end
[dummy,sort_idx] = sort(diag1);
x1 = x1(sort_idx);
y1 = y1(sort_idx);
x2 = x2(sort_idx);
y2 = y2(sort_idx);

h1 = plot([x1 x1(1)],[y1 y1(1)],'k-',varargin{:}); hold on;
h2 = plot([x2 x2(1)],[y2 y2(1)],'k-',varargin{:}); hold on;

set(h2,'Color',get(h1,'Color')*0.66);

% use center of mass
% [cx1,cy1] = ig_comass(x1,y1); 
% [cx2,cy2] = ig_comass(x2,y2); 

% use vector sum
cx1 = sum(x1);
cy1 = sum(y1);
cx2 = sum(x2);
cy2 = sum(y2);


if ~(cx1 == 0 && cy1 == 0),
	% hf1 = feather(cx1,cy1,'r');
	hf1 = plot(cx1,cy1,'o');
	set(hf1,varargin{end-1:end});
end

if ~(cx2 == 0 && cy2 == 0),
	% hf2 = feather(cx2,cy2,'r');
	hf2 = plot(cx2,cy2,'o');
	set(hf2,varargin{end-1:end});
	set(hf2,'Color',get(h1,'Color')*0.66);
end

drawArrow([cx1 cy1],[cx2 cy2],get(h1,'Color'));



function h = plot_diag(diag, mag, varargin)
% OBSOLETE
% diag 1 -> 2 -> 3 - 4 counterclockwise
% IS-CH CS-CH CS-IH IS-IH

% if ~all(size(diag) == size(mag)),	
% end

for d = 1:length(diag),
	switch diag(d),
		case 1
			x(d) = sqrt(mag(d)^2/2);
			y(d) = sqrt(mag(d)^2/2);
		case 2
			x(d) = -sqrt(mag(d)^2/2);
			y(d) = sqrt(mag(d)^2/2);
		case 3
			x(d) = -sqrt(mag(d)^2/2);
			y(d) = -sqrt(mag(d)^2/2);
		case 4
			x(d) = sqrt(mag(d)^2/2);
			y(d) = -sqrt(mag(d)^2/2);	
	end
end
[dummy,sort_idx] = sort(diag);
x = x(sort_idx);
y = y(sort_idx);

h = plot([x x(1)],[y y(1)],'k-',varargin{:}); hold on;
[cx,cy] = ig_comass(x,y); 

if ~(cx == 0 && cy == 0),
	h = feather(cx,cy,'r');
	set(h,varargin{end-1:end});
end






function CSI = csi(Contra,Ipsi)

CSI = (Contra-Ipsi)./(Contra+Ipsi);
% CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
% CSI = (Contra-Ipsi);




function hArrow = drawArrow(p0,p1,color)
% drawArrow(p0,p1)
% Draws a simple arrow in 2D, from p0 to p1.
% from: https://de.mathworks.com/matlabcentral/fileexchange/55181-drawarrow by Matthew Kelly
%
% INPUTS:
%   p0 = [x0; y0] = position of the tail
%   p1 = [x1; y1] = position of the tip
%   color = arrow color. Optional: default is black 
%       --> can be 'r','g','b','c','m','y','w', 'k' or a 1x3 color vector
%
% OUTPUTS:
%   hArrow = handle to the patch object representing the arrow
%
% Defaults:
if nargin == 2
   color = 'k'; 
end
% Parameters:
W1 = 0.08;   % half width of the arrow head, normalized by length of arrow
W2 = 0.014;  % half width of the arrow shaft
L1 = 0.18;   % Length of the arrow head, normalized by length of arrow
L2 = 0.13;  % Length of the arrow inset
% Unpack the tail and tip of the arrow
x0 = p0(1);
y0 = p0(2);
x1 = p1(1);
y1 = p1(2);
% Start by drawing an arrow from 0 to 1 on the x-axis
P = [...
    0, (1-L2), (1-L1), 1, (1-L1), (1-L2), 0;
    W2,    W2,     W1, 0,    -W1,    -W2, -W2];
% Scale,rotate, shift and plot:
dx = x1-x0;
dy = y1-y0;
Length = sqrt(dx*dx + dy*dy);
Angle = atan2(-dy,dx);
P = Length*P;   %Scale
P = [cos(Angle), sin(Angle); -sin(Angle), cos(Angle)]*P;  %Rotate
P = p0(:)*ones(1,7) + P;  %Shift
% Plot!
hArrow = patch(P(1,:), P(2,:),color);  axis equal;
set(hArrow,'EdgeColor',color);
