function testsim_nhp_perturbation_summary 
% methods summary figure for the NHP perturbation paper

% Current list of methods:
% ------------------------
% Permanent Lesions
% Pharmacology/FDG
% Reversible pharmacological inactivation
% Genetic Manipulation
% DREADDs
% DBS (long-term effects)
% Electrical Stimulation
% Optogenetics
% Infrared
% Ultrasound
% Pathway-specific perturbations
% Anaesthesia

% TR - temporal resolution (in s, will be converted to log10 - e.g. log10(60*60) = 3.56 (1 hour))
% SR - 1D spatial resolution (in mm, will be converted to log10 of mm^3- e.g. log10(10^3) = 3 (1 cubic cm))
% SP - cell type specificity: from [0-1] - no specificity - to [2-3] - very high cell type sensitivity 

alpha = 1; % transparency of frames

k = 1;

T(k).name = 'Lesions';
T(k).tr = [60*60*24*7 60*60*24*180]; % 7 days - 180 days
T(k).sr = [4.5 50]; % 4.5 mm - 50 mm
T(k).sp = [0 1];
T(k).color = [1 0.84 0];

k = k + 1;
T(k).name = 'Pharmacology';
T(k).tr = [60*45 60*60*24*2];
T(k).sr = [1.5 80]; 
T(k).sp = [0 2];
T(k).color = [0.47 0.7 0.19];

k = k + 1;
T(k).name = 'Reversible inactivation';
T(k).tr = [60*60 60*60*4]; % 1 hour - 4 hours
T(k).sr = [1 9]; % the extent of inactivation typically 1 - 9 mm 
T(k).sp = [0 1]; % no cell specificity
T(k).color = [0.5 0 0.8];

k = k + 1;
T(k).name = 'Genetic manipulation';
T(k).tr = [60*60*24 60*60*24*180];
T(k).sr = [1.75 20];
T(k).sp = [1 3]; % cell-specificity, can match opto/dreadds. 
T(k).color = [0.31 0.40 0.58];

k = k + 1; 
T(k).name = 'DREADDs';
T(k).tr = [20*60 60*60*3]; % 20 min - 3 hours -- technically, it could be chronic.
T(k).sr = [.5 8]; % the extent of inactivation typically .5 - 8 mm, technically it could be systemic… 
T(k).sp = [1 3]; % from some to very cell-specific
T(k).color = [ 0 1 1]; % I will let someone else pick the colors… 

k = k + 1;
T(k).name = 'Deep Brain Stimulation';
T(k).tr = [5 15.5e6]; % seconds (e.g., tremor) to months (e.g., depression)
T(k).sr = [2 15]; % 2 - 15 mm >> even larger? Depends on electrode...
T(k).sp = [0 1]; % no cell specificity
T(k).color = [0.80 0.23 0.10]; % ????

k = k + 1;
T(k).name = 'Electrical stimulation';
T(k).tr = [0.15 15]; % 0.15 s - 15 s (but if we consider long-term effects, could be a couple of hours)
T(k).sr = [1 5]; % 1 - 5 mm
T(k).sp = [0 1]; % no cell specificity
T(k).color = [1 0.5 0.3];

k = k + 1;
T(k).name = 'Optogenetics';
T(k).tr = [0.1 10];
T(k).sr = [0.5 4];
T(k).sp = [2 3];
T(k).color = [0 0.45 0.74];

k = k + 1;
T(k).name = 'Infrared';
T(k).tr = [0.3 12];
T(k).sr = [1.75 3.5];
T(k).sp = [1 2];
T(k).color = [0.5 0 0];

k = k + 1;
T(k).name = 'Ultrasound';
T(k).tr = [1 60*60*5];
T(k).sr = [4.5 20];
T(k).sp = [0 1];
T(k).color = [0 0.5 0];

k = k + 1;
T(k).name = 'Anaesthesia';
T(k).tr = [60*60*1.5 60*60*5];
T(k).sr = [30 82]; 
T(k).sp = [0 1];
T(k).color = [1 0.2 0.4];

% k = k + 1;
% T(k).name = 'Pathway-specific perturbations';
% T(k).tr = [2 60*60*24*15];
% T(k).sr = [1.5 10];
% T(k).sp = [2 3];
% T(k).color = [0 1 0.2];

figure('Position',[200 200 800 600]);

for k = 1:length(T),
    T(k).sr = T(k).sr.^3; % convert 1D mm to cubic mm3
    
    if 0 % 3D 
        T(k).sp = [T(k).sp(1)+0.1 T(k).sp(2)-0.1];
        plotcube([log10(T(k).tr(2)-T(k).tr(1)) log10(T(k).sr(2)-T(k).sr(1)) T(k).sp(2)-T(k).sp(1)],[log10(T(k).tr(1)) log10(T(k).sr(1)) T(k).sp(1)],alpha,T(k).color); 
        text(log10(T(k).tr(1)), log10(T(k).sr(1)), T(k).sp(1),T(k).name,'Color',T(k).color*0.7);
    else % 2D
        % h = rectangle('Position', [log10(T(k).tr(1)) log10(T(k).sr(1)) log10(T(k).tr(2)-T(k).tr(1)) log10(T(k).sr(2)-T(k).sr(1))]);
        h = patch([log10(T(k).tr(1)) log10(T(k).tr(1)) log10(T(k).tr(2)) log10(T(k).tr(2)) log10(T(k).tr(1))],...
                  [log10(T(k).sr(1)) log10(T(k).sr(2)) log10(T(k).sr(2)) log10(T(k).sr(1)) log10(T(k).sr(1))],T(k).color);  
        switch T(k).sp(2), % maximal cell specificity
            case 1  
                ls = '-';
            case 2
                ls = '--';
            case 3
                ls = ':';
        end
                
        % set(h,'FaceColor',T(k).color,'EdgeColor',T(k).color*0.8,'LineWidth',2,'LineStyle',ls,'FaceAlpha',alpha); % filled
        set(h,'FaceColor','none','EdgeColor',T(k).color*0.8,'LineWidth',2,'LineStyle',ls,'FaceAlpha',alpha); % filled
        
        text(log10(T(k).tr(1)), log10(T(k).sr(1)),T(k).name,'Color',T(k).color*0.7);

    end
end

% set(gca,'Ztick',[0 1 2 3]); % for 3D

set(gca,'Xlim',[-1.2 7.5],'Xtick',round2([log10(0.1) log10(1) log10(60) log10(60*60) log10(60*60*24) log10(60*60*24*30)],0.01),'YLim',[-1.2 5.8],'TickDir','out');

% set(gca, 'XScale', 'log');
% set(gca, 'YScale', 'log');

xlabel('Temporal resolution (log s)');
ylabel('Spatial resolution (log mm^3)');
zlabel('Cell specificity');


function plotcube(varargin)
% modified by IK from https://www.mathworks.com/matlabcentral/fileexchange/15161-plotcube
%
% PLOTCUBE - Display a 3D-cube in the current axes
%
%   PLOTCUBE(EDGES,ORIGIN,ALPHA,COLOR) displays a 3D-cube in the current axes
%   with the following properties:
%   * EDGES : 3-elements vector that defines the length of cube edges
%   * ORIGIN: 3-elements vector that defines the start point of the cube
%   * ALPHA : scalar that defines the transparency of the cube faces (from 0
%             to 1)
%   * COLOR : 3-elements vector that defines the faces color of the cube
%
% Example:
%   >> plotcube([5 5 5],[ 2  2  2],.8,[1 0 0]);
%   >> plotcube([5 5 5],[10 10 10],.8,[0 1 0]);
%   >> plotcube([5 5 5],[20 20 20],.8,[0 0 1]);
% Default input arguments
inArgs = { ...
  [10 56 100] , ... % Default edge sizes (x,y and z)
  [10 10  10] , ... % Default coordinates of the origin point of the cube
  .7          , ... % Default alpha value for the cube's faces
  [1 0 0]       ... % Default Color for the cube
  };
% Replace default input arguments by input values
inArgs(1:nargin) = varargin;
% Create all variables
[edges,origin,alpha,clr] = deal(inArgs{:});
XYZ = { ...
  [0 0 0 0]  [0 0 1 1]  [0 1 1 0] ; ...
  [1 1 1 1]  [0 0 1 1]  [0 1 1 0] ; ...
  [0 1 1 0]  [0 0 0 0]  [0 0 1 1] ; ...
  [0 1 1 0]  [1 1 1 1]  [0 0 1 1] ; ...
  [0 1 1 0]  [0 0 1 1]  [0 0 0 0] ; ...
  [0 1 1 0]  [0 0 1 1]  [1 1 1 1]   ...
  };
XYZ = mat2cell(...
  cellfun( @(x,y,z) x*y+z , ...
    XYZ , ...
    repmat(mat2cell(edges,1,[1 1 1]),6,1) , ...
    repmat(mat2cell(origin,1,[1 1 1]),6,1) , ...
    'UniformOutput',false), ...
  6,[1 1 1]);
cellfun(@patch,XYZ{1},XYZ{2},XYZ{3},...
  repmat({clr},6,1),...
  repmat({'EdgeColor'},6,1),...
  repmat({clr*0.9},6,1),...
  repmat({'FaceAlpha'},6,1),...
  repmat({alpha},6,1)...
  );
view(3);
