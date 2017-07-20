% test Chi-square
% http://sphweb.bumc.bu.edu/otlt/MPH-Modules/BS/BS704_HypothesisTesting-ChiSquare/BS704_HypothesisTesting-ChiSquare2.html
% http://www.socscistatistics.com/tests/goodnessoffit/Default2.aspx

% Example 1: 3 discrete outcomes (see links above)
[h,p,st] = chi2gof([1 2 3],'ctrs',[1 2 3],'frequency',[255 125 90],'expected',[282 117.5 70.5],'nparams',0)



