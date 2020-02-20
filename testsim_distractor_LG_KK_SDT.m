% function testsim_distractor_LG_KK_SDT
clear all, close all; 
plot_mainExpectations = 1;
SaveGraph = 1;
% predictions

% Legend
%       contra | ispi
% pre     1       2
% post    3       4

%%
IndependentCalculation = 0; % for double stimuli, using all three outcomes (dependent) or only two out of three (independent for contra/ipsi)
n_trials = 100; % for each stimulus condition

% Single STIMULI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  scenario = 'SingleStimuli_Post_ContraSpatialBias_NoPerceptualDeficit';
% scenario = 'SingleStimuli_Post_ContraPerceptualDeficit';
%  scenario = 'SingleStimuli_Post_NoGoBias_NoPerceptualDeficit';
% scenario = 'SingleStimuli_Post_NoSpatialBias_NoPerceptualDeficit';

% scenario = 'Single Stimuli: add contra spatial bias to contra and ipsi';
% scenario = 'Single Stimuli: contra perceptual problem';
% scenario = 'Single Stimuli: high hit rate, but ipsi spatial bias'; % like Curius early stim single targets, difficult distractor

% DOUBLE SAME STIMULI  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scenario = 'DoubleSameStimuli_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';
% scenario = 'DoubleSameStimuli_Post_IpsiSpatialBias_Vers2_NoPerceptualDeficit';
% scenario = 'DoubleSameStimuli_Post_ContraPerceptualDeficit';
% scenario = 'DoubleSameStimuli_Post_NoGOSpatialBias_NoPerceptualDeficit';

% scenario = 'DoubleSameStimuli_Pre_IpsiSelectionBias_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';
% scenario = 'DoubleSameStimuli_Post_ContraPerceptualDeficit_Ver2_decreaseContraHR';
% scenario = 'DoubleSameStimuli_Pre_IpsiSelectionBias_Cornelius_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';


% scenario = 'Double Stimuli - Pre: No spatial choice bias & Post: ipsi choice Bias';
% scenario = 'Double Stimuli - Curius inactivation session 7 20190913';

% DOUBLE D-T STIMULI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scenario = 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers1';
% scenario = 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers2';
% scenario = 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers3';
% scenario = 'DoubleD-Tstimuli_Post_ipsiSpatialBias_Vers1_LessSaccadesContra';
% scenario = 'DoubleD-Tstimuli_Post_ipsiSpatialBias_Vers2_LessFixation';
% scenario = 'DoubleD-Tstimuli_Post_NoGoBias';


% scenario = 'Double D-T Stimuli - Post: perceptual deficit';
% scenario = 'Double D-T Stimuli - For Curius.. Post: perceptual deficit';


% Enter the Proportion for Hits, Misses, FA, CR
switch scenario
    
    case 'SingleStimuli_Post_ContraSpatialBias_NoPerceptualDeficit';
        disp('Single Stimuli Post: Contra Spatial Bias & No PerceptualDeficit')
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7; %0.7
        M(1)   = 0.3; %0.3
        FA(1)  = 0.3;
        CR(1)  = 0.7;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.19;
        H(3)   = H(1)+sb;
        M(3)   = M(1)-sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)-sb;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
    case 'SingleStimuli_Post_ContraPerceptualDeficit';
        disp('Single Stimuli Post: No Spatial Bias & Contra PerceptualDeficit')
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7; %0.7
        M(1)   = 0.3; %0.3
        FA(1)  = 0.3;
        CR(1)  = 0.7;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.19;
        H(3)   = H(1)-sb;
        M(3)   = M(1)+sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)-sb;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
    case 'SingleStimuli_Post_NoGoBias_NoPerceptualDeficit';
        disp('Single Stimuli Post: NoGo-Bias & No PerceptualDeficit')
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7; %0.7
        M(1)   = 0.3; %0.3
        FA(1)  = 0.3;
        CR(1)  = 0.7;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.19;
        H(3)   = H(1)-sb;
        M(3)   = M(1)+sb;
        FA(3)  = FA(1)-sb;
        CR(3)  = CR(1)+sb;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
        
    case 'SingleStimuli_Post_NoSpatialBias_NoPerceptualDeficit';
        disp('Single Stimuli Post: No Spatial Bias & No PerceptualDeficit')
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7; %0.7
        M(1)   = 0.3; %0.3
        FA(1)  = 0.3;
        CR(1)  = 0.7;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.19;
        H(3)   = H(1);
        M(3)   = M(1);
        FA(3)  = FA(1);
        CR(3)  = CR(1);
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
    case 'Single Stimuli: add contra spatial bias to contra and ipsi';
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7;
        M(1)   = 0.3;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.2;
        H(3)   = H(1)+sb;
        M(3)   = M(1)-sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)-sb;
        
        H(4)   = H(2)-sb;
        M(4)   = M(2)+sb;
        FA(4)  = FA(2)-sb;
        CR(4)  = CR(2)+sb;
        
        
    case 'Single Stimuli: contra perceptual problem';
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.7;
        M(1)   = 0.3;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.6;
        M(2)   = 0.4;
        FA(2)  = 0.4;
        CR(2)  = 0.6;
        
        sb = 0.15; % here sb is not spatial bias, it is perceptual deficit
        
        %general increase in errors: reduce Hits, increase Miss, reduce CR, increase FA
        H(3)   = H(1) - sb; % 0.55;
        M(3)   = M(1) + sb; %0.45;
        FA(3)  = FA(1)+ sb; %0.45;
        CR(3)  = CR(1)- sb; %0.55;
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2);
        CR(4)  = CR(2);
        
    case 'Single Stimuli: high hit rate, but ipsi spatial bias';
        StimulusType = 'Sgl_Stimuli';
        IndependentCalculation = 1;
        
        H(1)   = 0.9;
        M(1)   = 0.1;
        FA(1)  = 0.25;
        CR(1)  = 0.75;
        
        H(2)   = 0.9;
        M(2)   = 0.1;
        FA(2)  = 0.7;
        CR(2)  = 0.3;
        
        sb = 0.1;
        H(3)   = H(1);
        M(3)   = M(1);
        FA(3)  = FA(1);
        CR(3)  = CR(1);
        
        H(4)   = H(2);
        M(4)   = M(2);
        FA(4)  = FA(2)+sb;
        CR(4)  = CR(2)-sb;
        
    case 'DoubleSameStimuli_Pre_IpsiSelectionBias_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';
        disp('DoubleStimuli - Pre: Ipsi selection bias, Post: ipsi selection Bias (less contra saccade), No perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % contra pre
        H(1)   = 0.35;%decreased ipsi T selection
        M(1)   = 0.1;
        FA(1)  = 0.4;%decreased ipsi D selection
        CR(1)  = 0.4;%decreased ipsi D selection
        
        % ipsi pre
        H(2)   = 0.55; %increased ipsi T selection
        M(2)   = M(1);
        FA(2)  = 0.2; 
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; %less saccades to contra
        M(3)   = M(1);
        FA(3)  = FA(1)- sb; %less saccades to contra
        CR(3)  = CR(1) ;
        
        % ispi post
        H(4)   = H(2)+ sb ; %more saccades to ipsi
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
      case 'DoubleSameStimuli_Pre_IpsiSelectionBias_Cornelius_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';
        disp('DoubleSameStimuli - Pre: IpsiSelectionBias (Cornelius) Post: ipsi spatial Bias (Vers1,saccade), NO perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % contra pre
        H(1)   = 0.50;
        M(1)   = 0.1;
        FA(1)  = 0.3;
        CR(1)  = 0.5;
        
        % ipsi pre
        H(2)   = 0.4;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; %less saccades to contra
        M(3)   = M(1);
        FA(3)  = FA(1)- sb; %less saccades to contra
        CR(3)  = CR(1) ;
        
        % ispi post
        H(4)   = H(2)+ sb ; %more saccades to ipsi
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        
    case 'DoubleSameStimuli_Post_IpsiSpatialBias_Vers1_NoPerceptualDeficit';
        disp('DoubleSameStimuli - Post: ipsi spatial Bias (Vers1,saccade), NO perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % A condition for double stimuli: Fixation is the same for contra vs ipsi M(1) = M(2)
        % spatial-saccade choice bias  (ipsi) without same discrimination performance
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations do not change for both hemifields
        % Post: ipsi targets are highly selected
        % H(1) + M(1) + H(2) should add to 1
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; %less saccades to contra
        M(3)   = M(1);
        FA(3)  = FA(1)- sb; %less saccades to contra
        CR(3)  = CR(1) ;
        
        % ispi post
        H(4)   = H(2)+ sb ; %more saccades to ipsi
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        
        
    case 'DoubleSameStimuli_Post_IpsiSpatialBias_Vers2_NoPerceptualDeficit';
        disp('DoubleSameStimuli - Post: ipsi spatial Bias (Vers2, fixation), NO perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % A condition for double stimuli: Fixation is the same for contra vs ipsi M(1) = M(2)
        % spatial-saccade choice bias  (ipsi) without same discrimination performance
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations do not change for both hemifields
        % Post: ipsi targets are highly selected
        % H(1) + M(1) + H(2) should add to 1
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.08;
        % contra post
        H(3)   = H(1) ; %less saccades to contra
        M(3)   = M(1)- sb;
        FA(3)  = FA(1); %less saccades to contra
        CR(3)  = CR(1)- sb ;
        
        % ispi post
        H(4)   = H(2)+ sb ; %more saccades to ipsi
        M(4)   = M(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = CR(3);
        
        
    case 'DoubleSameStimuli_Post_NoGOSpatialBias_NoPerceptualDeficit';
        disp('DoubleSameStimuli - Post: NoGo spatial Bias (less contra & ipsi saccades), NO perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % A condition for double stimuli: Fixation is the same for contra vs ipsi M(1) = M(2)
        % spatial-saccade choice bias  (ipsi) without same discrimination performance
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations do not change for both hemifields
        % Post: ipsi targets are highly selected
        % H(1) + M(1) + H(2) should add to 1
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- (sb/2) ; %less saccades to contra
        M(3)   = M(1)+ sb;
        FA(3)  = FA(1)-(sb/2) ; %less saccades to contra
        CR(3)  = CR(1)+ sb ;
        
        % ispi post
        H(4)   = H(2)- (sb/2); %more saccades to ipsi
        M(4)   = M(3);
        FA(4)  = FA(2)-(sb/2);
        CR(4)  = CR(3);
        
    case 'DoubleSameStimuli_Post_ContraPerceptualDeficit';
        disp('Double Stimuli - Post: contra perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        % perceptual deficit: increasing errors
        %
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1)+ sb; %contra fixation
        FA(3)  = FA(1)+ sb;%contra Saccade
        CR(3)  = CR(1)- sb;
        
        % ispi post
        H(4)   = H(2) ;
        M(4)   = M(3);
        FA(4)  = FA(2);
        CR(4)  = CR(3);
        
        
    case 'DoubleSameStimuli_Post_ContraPerceptualDeficit_Ver2_decreaseContraHR';
        disp('Double Stimuli - Post: contra perceptual deficit by selecting less targets & making more misses')
        StimulusType = 'DoubleSameStimuli';
        % contra pre
        H(1)   = 0.45;
        M(1)   = 0.1;
        FA(1)  = 0.2;
        CR(1)  = 0.6;
        
        % ipsi pre
        H(2)   = 0.45;
        M(2)   = M(1);
        FA(2)  = 0.2;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1)+ sb; %contra fixation
        FA(3)  = FA(1);%contra Saccade
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2) ;
        M(4)   = M(3);
        FA(4)  = FA(2);
        CR(4)  = CR(3);
        
    case 'Double Stimuli - Pre: No spatial choice bias & Post: perceptual deficit';
        disp('Double Stimuli - Pre: No spatial choice bias & Post: perceptual deficit')
        StimulusType = 'DoubleSameStimuli';
        
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.2;
        FA(1)  = 0.1; %0.1;
        CR(1)  = 0.5; %0.6;
        
        % ipsi pre
        H(2)   = 0.3;
        M(2)   = M(1);
        FA(2)  = 0.4;
        CR(2)  = CR(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ;
        M(3)   = M(1)+ sb;
        FA(3)  = FA(1)+sb;
        CR(3)  = CR(1)- sb;
        
        % ispi post
        H(4)   = H(2) ;
        M(4)   = M(3);
        FA(4)  = FA(2);
        CR(4)  = CR(3);
        
        
        
        
        
        
    case 'Double Stimuli - Curius inactivation session 7 20190913';
        StimulusType = 'DoubleSameStimuli';
        
        % spatial choice bias  (ipsi) with good discrimination performance
        % for distractors
        % Fixation is the same for contra vs ipsi M(1) = M(2)
        
        % Pre: no choice bias -> Post: ipsi choice bias -> fixations doesn't change for both hemifields
        % target are highly selected
        % H(1) + M(1) + H(2) should add to 1
        %pre 26/67 + 1/67  + 40/67
        %pst 11/61 + 0/61 +50/61
        % FA(1) + CR(1) + FA(2) should add to 1
        
        % contra pre
        H(1)   = 26/67;
        M(1)   = 1/67;
        FA(1)  = 21/65;
        CR(1)  = 23/65;
        
        % ipsi pre
        H(2)   = 40/67;
        M(2)   = M(1);
        FA(2)  = 21/65;
        CR(2)  = CR(1);
        
        % contra post
        H(3)   = 11/61 ;
        M(3)   = 0/61;
        FA(3)  = 19/62;
        CR(3)  = 19/62;
        
        % ispi post
        H(4)   = 50/61 ;
        M(4)   = M(3);
        FA(4)  = 24/62;
        CR(4)  = CR(3);
        
    case 'Double D-T Stimuli - Post: ipsi choice Bias & no perceptual deficit';
        StimulusType = 'Double D-T Stimuli';
        % Cornelius data looks like that
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)/CR(2)+ FA(2) == 1  &FA(1)+ CR(1)/M(2)+ H(2) == 1
        % ipsi selection bias - increase ipsilateral target selection, FA (contra) decreased
        % good perceptual discrimination on ipsilateral side - no change for ipsilateral distractor trials
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4;
        CR(1)  = 0.1;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1) - sb;
        M(3)   = M(1);
        FA(3)  = FA(1)- sb;
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)+ sb ;
        M(4)   = CR(3);
        FA(4)  = FA(2)+ sb;
        CR(4)  = M(3);
        
        
    case 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers1';
        disp('Double D-T Stimuli - Post: contra perceptual deficit (less ipsiTarget, more ipsi distractor)')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        % ipsi selection bias - increase ipsilateral target selection, FA (contra) decreased
        % ipsi perceptual deficit - increased selection of FA (ipsi)
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; % less saccades to contra T
        M(3)   = M(1);
        FA(3)  = FA(1)+ sb; %% more saccades to contra D
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)- sb ; % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2)+ sb ;
        CR(4)  = M(3);
        
    case 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers2';
        disp('Double D-T Stimuli - Post: contra perceptual deficit (more contra Miss, less contra CR)')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        % ipsi selection bias - increase ipsilateral target selection, FA (contra) decreased
        % ipsi perceptual deficit - increased selection of FA (ipsi)
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; % less saccades to contra T
        M(3)   = M(1) + sb;
        FA(3)  = FA(1)+ sb; %% more saccades to contra D
        CR(3)  = CR(1)- sb ;
        
        % ispi post
        H(4)   = H(2); % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2) ;
        CR(4)  = M(3);
        
    case 'DoubleD-Tstimuli_Post_contraPerceptualDeficit_Vers3';
        disp('Double D-T Stimuli - Post: contra perceptual deficit (more ipsi Miss, no influence on T-D)')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        % ipsi selection bias - increase ipsilateral target selection, FA (contra) decreased
        % ipsi perceptual deficit - increased selection of FA (ipsi)
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; % less saccades to contra T
        M(3)   = M(1) + sb;
        FA(3)  = FA(1); %% more saccades to contra D
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2); % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2) ;
        CR(4)  = M(3);
        
    case 'DoubleD-Tstimuli_Post_ipsiSpatialBias_Vers1_LessSaccadesContra';
        disp('DoubleD-Tstimuli Post: IpsiSpatialBias Vers1 (more saccades to ipsi, less saccades to contra))')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb ; % less saccades to contra T
        M(3)   = M(1) ;
        FA(3)  = FA(1)- sb; %% more saccades to contra D
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)+ sb; % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2)+ sb ;
        CR(4)  = M(3);
    case 'DoubleD-Tstimuli_Post_ipsiSpatialBias_Vers2_LessFixation';
        disp('DoubleD-Tstimuli Post: IpsiSpatialBias Vers2 (more saccades to ipsi, less fixation))')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1) ; % less saccades to contra T
        M(3)   = M(1)- sb ;
        FA(3)  = FA(1); %% more saccades to contra D
        CR(3)  = CR(1)- sb;
        
        % ispi post
        H(4)   = H(2)+ sb; % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2)+ sb ;
        CR(4)  = M(3);
        
    case 'DoubleD-Tstimuli_Post_NoGoBias';
        disp('DoubleD-Tstimuli_Post_NoGoBias (less contra saccades))')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- (sb/2) ; % less saccades to contra T
        M(3)   = M(1)+sb ;
        FA(3)  = FA(1)- (sb/2); %% more saccades to contra D
        CR(3)  = CR(1)+ sb;
        
        % ispi post
        H(4)   = H(2)- (sb/2); % less saccades to ipsi T
        M(4)   = CR(3);
        FA(4)  = FA(2)- (sb/2) ;
        CR(4)  = M(3);
        
    case 'Double D-T Stimuli - For Curius.. Post: perceptual deficit';
        disp('Double D-T Stimuli - For Curius.. Post: perceptual deficit')
        StimulusType = 'Double D-T Stimuli';
        %1.Target contra:  Miss contra == CR ipsi && 2.Target ipsi:  Miss ipsi == CR contra
        % H(1)+ M(1)+ FA(2) == 1  &FA(1)+ CR(1)+ H(2) == 1
        % ipsi selection bias - increase ipsilateral target selection, FA (contra) decreased
        % ipsi perceptual deficit - increased selection of FA (ipsi)
        
        % contra pre
        % contra pre
        H(1)   = 0.5;
        M(1)   = 0.1;
        FA(1)  = 0.4; %0.1;
        CR(1)  = 0.1; %0.6;
        
        % ipsi pre
        H(2)   = 0.5;
        M(2)   = CR(1);
        FA(2)  = 0.4;
        CR(2)  = M(1);
        
        sb = 0.1;
        % contra post
        H(3)   = H(1)- sb -sb;
        M(3)   = M(1)+ sb;
        FA(3)  = FA(1);
        CR(3)  = CR(1);
        
        % ispi post
        H(4)   = H(2)- sb  ;
        M(4)   = CR(3)+ sb;
        FA(4)  = FA(2)+ sb ;
        CR(4)  = M(3);
        
        
end % of scenario selection



H = single(H*n_trials);
M = single(M*n_trials);
FA = single(FA*n_trials);
CR = single(CR*n_trials);


switch StimulusType
    
    
    case 'Sgl_Stimuli'
        
        Accuracy(1) = (H(2)+H(1)+ CR(1)+ CR(2))/(H(1) + H(2) + M(1)+ M(2)+CR(2) +  FA(1)+ CR(1)+ FA(2));
        Accuracy(2) = (H(4)+H(3)+ CR(3)+ CR(4))/   (H(3) + H(4) + M(3)+ M(4)+ CR(4) +  FA(3)+ CR(3)+ FA(4));
        Accuracy_ipsi(1) = (H(2)+ CR(2))/(H(2) + M(2)+CR(2) + FA(2));
        Accuracy_ipsi(2) = (H(4)+ CR(4))/(H(4) + M(4)+ CR(4) + FA(4));
        Accuracy_contra(1) = (H(1)+ CR(1))/(H(1) + M(1)+CR(1) + FA(1));
        Accuracy_contra(2) = (H(3)+ CR(3))/(H(3) + M(3)+ CR(3) + FA(3));
        %TargetSelection
        Tar_IpsiSelection(1)    = H(2) ./ (H(2) + M(2)); %ipsi
        Tar_IpsiFixation(1)     = M(2) ./ (H(2) + M(2)); % fixation selection when tar is ipsi
        Tar_ContraSelection(1)  = H(1) ./ (H(1) + M(1));
        Tar_ContraFixation(1)   = M(1) ./ (H(1) + M(1)); % fixation selection when tar is contra
        Tar_IpsiSelection(2)    = H(4) ./ (H(4) + M(4));
        Tar_IpsiFixation(2)     = M(4) ./ (H(4) + M(4));
        Tar_ContraSelection(2)  = H(3) ./ (H(3) + M(3));
        Tar_ContraFixation(2)   = M(3) ./ (H(3) + M(3));
        %DistractorSelection
        Dis_IpsiSelection(1)    = FA(2)./ (FA(2) + CR(2)); %ipsi
        Dis_IpsiFixation(1)     = CR(2)./ (FA(2) + CR(2));
        Dis_ContraSelection(1)  = FA(1)./ (FA(1) + CR(1));
        Dis_ContraFixation(1)   = CR(1)./ (FA(1) + CR(1));
        Dis_IpsiSelection(2)    = FA(4)./ (FA(4) + CR(4));
        Dis_IpsiFixation(2)     = CR(4)./ (FA(4) + CR(4));
        Dis_ContraSelection(2)  = FA(3)./ (FA(3) + CR(3));
        Dis_ContraFixation(2)   = CR(3)./ (FA(3) + CR(3));
        
    case 'DoubleSameStimuli'
        if H(1)+ M(1)+ H(2) == 100 || H(1)+ M(2)+ H(2) == 100
            disp('Pre: target-trials: add up to 100')
        else
            disp('Pre: target-trials: DO NOT add up to 100')
            
        end
        if FA(1)+ CR(1)+ FA(2) == 100 || FA(1)+ CR(2)+ FA(2) == 100
            disp('Pre: distractor-trials: add up to 100')
        else
            disp('Pre: distractor-trials: DO NOT add up to 100')
            
        end
        if H(3)+ M(3)+ H(4) == 100 || H(3)+ M(4)+ H(4) == 100
            disp('Post: target-trials: add up to 100')
        else
            disp('Post: target-trials: DO NOT add up to 100')
            
        end
        if FA(3)+ CR(3)+ FA(4) == 100 || FA(3)+ CR(4)+ FA(4) == 100
            disp('Post: distractor-trials: add up to 100')
        else
            disp('Post: distractor-trials: DO NOT add up to 100')
            
        end
        
        Accuracy(1) = (H(2)+H(1)+ CR(1))/(H(1) + H(2) + M(1) + FA(1)+ CR(1)+ FA(2));
        Accuracy(2) = (H(4)+H(3)+ CR(3))/(H(3) + H(4) + M(3) + FA(3)+ CR(3)+ FA(4));
        
        Accuracy_ipsi(1) = (H(2)+ CR(2))/(H(1) + H(2) + M(1) + FA(1)+ CR(1)+ FA(2));
        Accuracy_ipsi(2) = (H(4)+ CR(4))/(H(3) + H(4) + M(3) + FA(3)+ CR(3)+ FA(4));
        
        Accuracy_contra(1) = (H(1)+ CR(1))/(H(1) + H(2) + M(1) + FA(1)+ CR(1)+ FA(2));
        Accuracy_contra(2) = (H(3)+ CR(3))/(H(3) + H(4) + M(3) + FA(3)+ CR(3)+ FA(4));
        %TargetSelection
        Tar_IpsiSelection(1)    = H(2) ./ (H(1) + H(2) + M(1)); %ipsi
        Tar_ContraSelection(1)  = H(1) ./ (H(1) + H(2) + M(1));
        Tar_IpsiFixation(1)     = M(1) ./ (H(1) + H(2) + M(1));
        Tar_ContraFixation(1)   = Tar_IpsiFixation(1);
        Tar_IpsiSelection(2)    = H(4) ./ (H(3) + H(4) + M(3));
        Tar_ContraSelection(2)  = H(3) ./ (H(3) + H(4) + M(3));
        Tar_IpsiFixation(2)     = M(3) ./ (H(3) + H(4) + M(3));
        Tar_ContraFixation(2)     = Tar_IpsiFixation(2);
        
        %DistractorSelection
        Dis_IpsiSelection(1)    = FA(2) ./ (FA(1) + FA(2) + CR(1)); %ipsi
        Dis_ContraSelection(1)  = FA(1) ./ (FA(1) + FA(2) + CR(1));
        Dis_IpsiFixation(1)     = CR(1) ./ (FA(1) + FA(2) + CR(1));
        Dis_ContraFixation(1)   = Dis_IpsiFixation(1);
        Dis_IpsiSelection(2)    = FA(4) ./ (FA(3) + FA(4) + CR(3));
        Dis_ContraSelection(2)  = FA(3) ./ (FA(3) + FA(4) + CR(3));
        Dis_IpsiFixation(2)     = CR(3) ./ (FA(3) + FA(4) + CR(3));
        Dis_ContraFixation(2)   = Dis_IpsiFixation(2);
        
        
        
    case 'Double D-T Stimuli'
        
        if H(1)+ M(1)+ FA(2) == 100 || H(2)+ M(2)+ FA(1) == 100
            disp('Pre: target-trials: add up to 100')
        else
            disp('Pre: target-trials: DO NOT add up to 100')
        end
        if FA(1)+ CR(1)+ H(2) == 100 || FA(2)+ CR(2)+ H(1) == 100
            disp('Pre: distractor-trials: add up to 100')
        else
            disp('Pre: distractor-trials: DO NOT add up to 100')
        end
        if H(3)+ M(3)+ FA(4) == 100 || H(4)+ M(4)+ FA(3) == 100
            disp('Post: target-trials: add up to 100')
        else
            disp('Post: target-trials: DO NOT add up to 100')
        end
        if FA(3)+ CR(3)+ H(4) == 100 || FA(4)+ CR(4)+ H(3) == 100
            disp('Post: distractor-trials: add up to 100')
        else
            disp('Post: distractor-trials: DO NOT add up to 100')
        end
        Accuracy(1) = (H(2)+H(1))/(H(1) + FA(2) + M(1) + FA(1) + CR(1) + H(2) );
        Accuracy(2) = (H(4)+H(3))/(H(3) + FA(4) + M(3) + FA(3) + CR(3) + H(4));
        
        Accuracy_ipsi(1) = (H(2))/(H(1) + H(2) + M(1) +  FA(1)+ CR(1)+ FA(2));
        Accuracy_ipsi(2) = (H(4))/(H(3) + H(4) + M(3) +  FA(3)+ CR(3)+ FA(4));
        
        Accuracy_contra(1) = (H(1))/(H(1) + H(2) + M(1) +  FA(1)+ CR(1)+ FA(2));
        Accuracy_contra(2) = (H(3))/(H(3) + H(4) + M(3) +  FA(3)+ CR(3)+ FA(4));
        %TargetSelection
        Tar_IpsiSelection(1)    = H(2) ./ (FA(1) + H(2) + M(1)); %ipsi
        Tar_ContraSelection(1)  = H(1) ./ (H(1) + FA(2) + M(1));
        Tar_IpsiFixation(1)     = M(2) ./ (FA(1) + H(2) + M(2)); %Dis_ContraFixation(1);
        Tar_ContraFixation(1)   = M(1) ./ (FA(2) + H(1) + M(1)); %Dis_IpsiFixation(1);
        Tar_IpsiSelection(2)    = H(4) ./ (FA(3) + H(4) + M(3));
        Tar_ContraSelection(2)  = H(3) ./ (H(3) + FA(4) + M(3));
        Tar_IpsiFixation(2)     = M(4) ./ (FA(3) + H(4) + M(4));
        Tar_ContraFixation(2)   = M(3) ./ (FA(4) + H(3) + M(3));
        %DistractorSelection
        Dis_IpsiSelection(1)    = FA(2) ./ (H(1) + FA(2) + CR(1)); %ipsi
        Dis_ContraSelection(1)  = FA(1) ./ (FA(1) + H(2) + CR(1));
        Dis_IpsiFixation(1)     = CR(2) ./ (H(1) + FA(2) + CR(2));
        Dis_ContraFixation(1)   = CR(1) ./ (H(2) + FA(1) + CR(1));
        %post
        Dis_IpsiSelection(2)    = FA(4) ./ (H(3) + FA(4) + CR(3));
        Dis_ContraSelection(2)  = FA(3) ./ (FA(3) + H(4) + CR(3));
        Dis_IpsiFixation(2)     = CR(4) ./ (H(3) + FA(4) + CR(4));
        Dis_ContraFixation(2)   = CR(3) ./ (H(4) + FA(3) + CR(3));
        
        
end


% avoid 0 or Inf probabilities
if any(H==0) || any(M==0) || any(FA==0) || any(CR==0),
    % add 0.5 to both the number of hits and the number of false alarms,
    % add 1 to both the number of signal trials and the number of noise trials; dubbed the loglinear approach (Hautus, 1995)
    disp('correcting...');
    %n_trials = n_trials + 1;
    
    H = H + 0.5;
    M = M + 0.5;
    FA = FA + 0.5;
    CR = CR + 0.5;
    
end

if IndependentCalculation == 1
    pHit = H ./ (H + M);
    pFA = FA ./ (FA + CR);
    
else
    %different proprotions of trials for hitrate & falsealarm dependent on type of Stimuli
    if strcmp(StimulusType , 'DoubleSameStimuli')
        
        H_ = [H(2) H(1) H(4) H(3) ];
        FA_ = [FA(2) FA(1) FA(4) FA(3) ];
        pHit = H ./ (H + M +H_);
        pFA = FA ./ (FA + CR +FA_);
    elseif strcmp(StimulusType , 'Double D-T Stimuli')
        %change the order of the Hits because
        % example: H (contra) ./ (H(contra) + M(contra) +FA(ipsi));
        H_ = [H(2) H(1) H(4) H(3) ];
        FA_ = [FA(2) FA(1) FA(4) FA(3) ];
        pHit = H ./ (H + M +FA_);
        pFA = FA ./ (FA + CR +H_);
        
    end
end

for k = 1:4,
    [dprime(k),beta(k),criterion(k)] = testsim_dprime(pHit(k),pFA(k));
end

%% Plotting

% Selection
Plot_Rows = 3;
Plot_Colums = 3;
MarkSize = 10;
fs = 10; % font size

if IndependentCalculation == 1
    Title = 'pHit/FA independent Calculations: ';
    mult = -1;
else
    Title = 'pHit/FA dependent Calculation';
    mult = -1;
end
ig_figure('Position',[200 200 1200 900],'PaperPositionMode','auto','Name',[Title, ' - scenario - ',scenario]); % ,'PaperOrientation','landscape'


subplot(Plot_Colums,Plot_Rows,1);
plot([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ],'LineWidth', 2); hold on;
plot([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
plot([1;2], [Tar_ContraFixation(1),Tar_ContraFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0.5 0 0 ],'LineWidth', 2); hold on;
plot([1;2], [Tar_IpsiFixation(1),Tar_IpsiFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0.5 ],'LineWidth', 2); hold on;

%title([scenario sprintf('\n')])
set(gca,'ylim',[0 1])
ylabel( 'Target','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
legend('sac con', 'sac ipsi', 'fix con', 'fix ipsi','Location','BestOutside')


subplot(Plot_Colums,Plot_Rows,2);
plot([1;2], [Dis_ContraSelection(1),Dis_ContraSelection(2)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0],'LineWidth', 2); hold on;
plot([1;2], [Dis_IpsiSelection(1),Dis_IpsiSelection(2)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
plot([1;2], [Dis_ContraFixation(1),Dis_ContraFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0.5 0 0 ],'LineWidth', 2); hold on;
plot([1;2], [Dis_IpsiFixation(1),Dis_IpsiFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0.5 ],'LineWidth', 2); hold on;
set(gca,'ylim',[0 1])
ylabel( 'Distractor','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
legend('sac con', 'sac ipsi', 'fix con', 'fix ipsi','Location','BestOutside')

% Accuracy
subplot(Plot_Colums,Plot_Rows,3);
plot([1;2], [Accuracy(1),Accuracy(2)], 'o','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0 ]); hold on;
line([1;2], [Accuracy(1),Accuracy(2)], 'Color',[0 0 0],'LineWidth', 2); hold on;
set(gca,'ylim',[0 1])
ylabel( 'Accuracy','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);


subplot(Plot_Colums,Plot_Rows,4);
plot([1;2], [pHit(2),pHit(4)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
plot([1;2], [pHit(1),pHit(3)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ],'LineWidth', 2); hold on;
plot([1;2], [pFA(2),pFA(4)], '*--','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
plot([1;2], [pFA(1),pFA(3)], '*--','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ],'LineWidth', 2); hold on;

set(gca,'ylim',[0 1])
ylabel( 'Hitrate / FA rate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
legend('ipsi H', 'con H', 'ipsi FA', 'con FA','Location','BestOutside')

subplot(Plot_Colums,Plot_Rows,5);
plot([pFA(2),pFA(4)], [pHit(2),pHit(4)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1],'LineWidth', 2); hold on;
plot([pFA(1),pFA(3)], [pHit(1),pHit(3)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1],'LineWidth', 2); hold on;
plot([pFA(4)], [pHit(4)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize-1,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
plot([pFA(3)], [pHit(3)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize-1,'markerfacecolor',[1 0 0],'LineWidth', 2); hold on;
line([0 1],[1 0],'Color',[0 0 0],'LineStyle',':');
set(gca,'ylim',[0 1],'xlim',[0 1],'fontsize',fs)
xlabel( 'FA rate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
ylabel( 'Hitrate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
axis square

% subplot(Plot_Colums,Plot_Rows,5);
% plot([1;2], [pFA(2),pFA(4)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1 ]); hold on;
% line([1;2], [pFA(2),pFA(4)], 'Color',[0 0 1],'LineWidth', 2); hold on;
% plot([1;2], [pFA(1),pFA(3)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ]); hold on;
% line([1;2], [pFA(1),pFA(3)], 'Color',[1 0 0],'LineWidth', 2); hold on;
% set(gca,'ylim',[0 1])
% ylabel( 'False alarm rate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
% set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);


%% Dprime vs Criterion
% figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% set(gcf,'Name','Dprime vs Criterion');

subplot(Plot_Colums,Plot_Rows,6);

plot(dprime(1),criterion(1), 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0 ]); hold on;
plot(dprime(2),-criterion(2), 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0 ]); hold on;% reverse direction of criterion for ipsi

plot(dprime(3),criterion(3), 'o','color',[1 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[1 0 0]);
plot(dprime(4),-criterion(4), 'o','color',[0 0 1] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 1]);% reverse direction of criterion for ipsi

plot(dprime(1),criterion(1), 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
plot(dprime(2),-criterion(2), 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;% reverse direction of criterion for ipsi

plot(dprime(3),criterion(3), 'o','color',[1 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[1 0 0]);
plot(dprime(4),-criterion(4), 'o','color',[0 0 1] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 1]);% reverse direction of criterion for ipsi
axis square


xlabel('sensitivity','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
ylabel('criterion','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
set(gca,'ylim',[-2 2],'xlim',[-1 4] ,'fontsize',fs)


%% Graph - change in criterion or change in dprime
subplot(Plot_Colums,Plot_Rows,9);

plot((dprime(1)-dprime(3)),(criterion(1)-criterion(3)), 'o','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ]); hold on;
plot((dprime(2)-dprime(4)),((mult*criterion(2))-(mult*criterion(4))), 'o','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1 ]); hold on;
axis square
xlabel('Pre-Post sensitivity')
ylabel('Pre-Post criterion')
set(gca,'ylim',[-2 2])
set(gca,'xlim',[-2 2])
legend('contra', 'ipsi')
grid on

%% OLD  graphs for criterion and dprime

subplot(Plot_Colums,Plot_Rows,7);
title([scenario sprintf('\n') 'dprime'])
plot([1 3],[dprime(1) dprime(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[dprime(2) dprime(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'con pre' 'ipsi pre' 'con pst' 'ipsi pst'},'FontSize',12,'TickDir','out','box','off');
ylabel(['dprime'])
set(gca,'ylim',[-1 3])

subplot(Plot_Colums,Plot_Rows,8);
plot([1 3],[criterion(1) criterion(3)],'ro-','MarkerFaceColor',[1 0 0]); hold on
plot([2 4],[mult*criterion(2) mult*criterion(4)],'bo-','MarkerFaceColor',[0 0 1]); hold on % reverse direction of criterion for ipsi
plot([0 5],[0 0],'k--');
set(gca,'Xlim',[0 5],'Xtick',[1:4],'XtickLabel',{'con pre' 'ipsi pre' 'con pst' 'ipsi pst'},'FontSize',12,'TickDir','out','box','off');
ylabel(['criterion'])
set(gca,'ylim',[-2 2])


%% Main Expectations
MarkSize = 15;
fs = 20; % font size
if plot_mainExpectations
    
    if IndependentCalculation == 1
        Title = 'pHit/FA independent Calculations: ';
        mult = -1;
    else
        Title = 'pHit/FA dependent Calculation';
        mult = -1;
    end
    ig_figure('Position',[200 200 1200 900],'PaperPositionMode','auto','Name',[Title, ' - scenario - ',scenario]); % ,'PaperOrientation','landscape'
    
    Plot_Colums = 3;
    Plot_Rows = 1;
    
    
    % subplot(Plot_Rows,Plot_Colums,1);
    % plot([1;2], [Tar_ContraSelection(1),Tar_ContraSelection(2)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0 ],'LineWidth', 2); hold on;
    % plot([1;2], [Tar_IpsiSelection(1),Tar_IpsiSelection(2)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
    % plot([1;2], [Tar_ContraFixation(1),Tar_ContraFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0.5 0 0 ],'LineWidth', 2); hold on;
    % plot([1;2], [Tar_IpsiFixation(1),Tar_IpsiFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0.5 ],'LineWidth', 2); hold on;
    % axis square
    % set(gca,'ylim',[0 1])
    % ylabel( 'Target selection','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
    % set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
    %
    %
    % subplot(Plot_Rows,Plot_Colums,2);
    % plot([1;2], [Dis_ContraSelection(1),Dis_ContraSelection(2)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 0 0],'LineWidth', 2); hold on;
    % plot([1;2], [Dis_IpsiSelection(1),Dis_IpsiSelection(2)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
    % plot([1;2], [Dis_ContraFixation(1),Dis_ContraFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0.5 0 0 ],'LineWidth', 2); hold on;
    % plot([1;2], [Dis_IpsiFixation(1),Dis_IpsiFixation(2)], 'o:','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[0 0 0.5 ],'LineWidth', 2); hold on;
    %  axis square
    % set(gca,'ylim',[0 1])
    % ylabel( 'Distractor selection','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
    % set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
    % legend('con', 'ipsi', 'fix con', 'fix ipsi','Location','BestOutside')
    
    
    %Hit rate vs False alarm rate
    subplot(Plot_Rows,Plot_Colums,1);
    plot([pFA(2),pFA(4)], [pHit(2),pHit(4)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1],'LineWidth', 2); hold on;
    plot([pFA(1),pFA(3)], [pHit(1),pHit(3)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1],'LineWidth', 2); hold on;
    plot([pFA(4)], [pHit(4)], 'o','color',[0 0 1] , 'MarkerSize',MarkSize-1,'markerfacecolor',[0 0 1],'LineWidth', 2); hold on;
    plot([pFA(3)], [pHit(3)], 'o','color',[1 0 0] , 'MarkerSize',MarkSize-1,'markerfacecolor',[1 0 0],'LineWidth', 2); hold on;
    line([0 1],[1 0],'Color',[0 0 0],'LineStyle',':');
    set(gca,'ylim',[0 1],'xlim',[0 1],'fontsize',fs)
    xlabel( 'FA rate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
    ylabel( 'Hitrate','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
    axis square
    
    
    subplot(Plot_Rows,Plot_Colums,2);
    plot([dprime(1), dprime(3)],[criterion(1),criterion(3)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
    plot([dprime(2), dprime(4)],[-criterion(2),-criterion(4)] , 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;% reverse direction of criterion for ipsi
    
    plot(dprime(3),criterion(3), 'o','color',[1 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[1 0 0]);
    plot(dprime(4),-criterion(4), 'o','color',[0 0 1] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 1]);% reverse direction of criterion for ipsi
    axis square
    xlabel('sensitivity','fontsize',fs,'fontweight','b', 'Interpreter', 'none')
    ylabel('criterion','fontsize',fs,'fontweight','b', 'Interpreter', 'none')
    set(gca,'ylim',[-2 2],'xlim',[-1 4] ,'fontsize',fs)
    %legend('con pre', 'ipsi pre', 'con pst', 'ipsi pst','Location','NorthEast')
    text(-0.5,-1.8, 'more Contra & ipsi:NoGo /contra:Go', 'Color', 'k')
    text(-0.5,1.8, 'less Contra & ipsi:Go /contra:NoGo', 'Color', 'k')
    
    % Accuracy
    subplot(Plot_Rows,Plot_Colums,3);
    
 
    plot([0.9;1.9], [Accuracy_ipsi(1),Accuracy_ipsi(2)], 'o-','color',[0 0 1] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
    plot([1.1;2.1], [Accuracy_contra(1),Accuracy_contra(2)], 'o-','color',[1 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
    plot([1;2], [Accuracy(1),Accuracy(2)], 'o-','color',[0 0 0] , 'MarkerSize',MarkSize,'markerfacecolor',[1 1 1 ]); hold on;
    
    plot(2.1,Accuracy_contra(2), 'o','color',[1 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[1 0 0]);
    plot(1.9, Accuracy_ipsi(2), 'o','color',[0 0 1] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 1]);% reverse direction of criterion for ipsi
    plot(2,Accuracy(2), 'o','color',[0 0 0] ,'MarkerSize',MarkSize,'markerfacecolor',[0 0 0]);% reverse direction of criterion for ipsi

    set(gca,'ylim',[0 1])
    ylabel( 'Accuracy','fontsize',fs,'fontweight','b', 'Interpreter', 'none' );
    set(gca,'xlim',[0 3],'Xtick',1:2,'XTickLabel',{'pre' 'post'},'fontsize',fs);
    axis square
    
    
end

if SaveGraph
    h = figure(2);
    print(h,['Y:\Projects\Pulv_distractor_spatial_choice\SDT\SimulationsPredictions' ,filesep, scenario, '.png'], '-dpng')
    set(h,'PaperPositionMode','auto')
    %compl_filename =  ['Y:\Projects\Pulv_distractor_spatial_choice\SDT\SimulationsPredictions' ,filesep, scenario, '.ai'] ;
    %print(h,'-depsc',compl_filename);
    %close all;
end

