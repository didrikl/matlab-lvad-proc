%% Calculate metrics of intervals tagged in the analysis_id column in Data

% This defines the relevant ids for analysis
Config = Data.G1.Config;
idSpecs = init_id_specifications(Config.idSpecs_path);
idSpecs = idSpecs(not(idSpecs.extra),:);
idSpecs = idSpecs(not(contains(string(idSpecs.analysis_id),{'E'})),:);
idSpecs = idSpecs(not(contains(string(idSpecs.categoryLabel),{'Injection'})),:);
% idSpecs = idSpecs((ismember(idSpecs.interventionType,{'Control','Effect'})),:);

sequences = {
	'Seq3' % (pilot)
 	'Seq6'
  	'Seq7'
  	'Seq8'
  	'Seq11'
  	'Seq12'
  	'Seq13'
  	'Seq14'
	};

% Make variable features of each intervention
% -----------------------------------------------------------

discrVars = {
	'Q_LVAD'
	'P_LVAD'
	'p_maxArt'
%     'p_minArt'
%     'MAP'             
%     'p_maxPulm'       
%     'p_minPulm'       
%     'HR'              
%     'CVP'             
    'SvO2'
	'graftEmboliVol'
	%'CO_cont'   % Must derive CO       
    %'CO_thermo' % Must derive CO        
    };

meanVars = {
% 	'accA_x' % to check direction
% 	'accA_y' % to check direction
% 	'accA_z' % to check direction
    'accA_x_nf_HP' % to get stddev
	'accA_y_nf_HP' % to get stddev
	'accA_z_nf_HP' % to get stddev
    'pGraft'          
    %'pGrad'    % Calculation to be revised      
    'pMillar'  % not working if not present as in Seq3
    'Q'               
    };

F = make_intervention_stats(Data.G1, sequences, discrVars, meanVars, {}, idSpecs);
F.P_LVAD_drop = -F.P_LVAD_mean;

% Add calculate band powers to the features
% -----------------------------------------------------------

accVars = {...'accA_x','accA_y','accA_z',...
	'accA_x_nf_HP','accA_y_nf_HP','accA_z_nf_HP'
	};
hBands =  [1.2,7];
isHarmBand = true;
Pxx = make_power_spectra(Data.G1, sequences, accVars, Config.fs, hBands, idSpecs, isHarmBand);
F = join(F, Pxx.bandMetrics, 'Keys',{'analysis_id','id'});

% Make relative and delta differences from baselines using id tags
% -----------------------------------------------------------

F_rel = calc_relative_feats(F);
F_del = calc_delta_diff_feats(F);

Data.G1.idSpecs = idSpecs;
Data.G1.Periodograms = Pxx;
Data.G1.Features.Absolute = F;
Data.G1.Features.Relative = F_rel;
Data.G1.Features.Delta = F_del;

%%

% Descriptive stastistics over group of experiments
% -----------------------------------------------------------

G = make_group_stats(F, idSpecs);
G_rel = make_group_stats(F_rel, idSpecs);
G_del = make_group_stats(F_del, idSpecs);

Data.G1.Feature_Statistics.Descriptive_Absolute = G;
Data.G1.Feature_Statistics.Descriptive_Relative = G_rel;
Data.G1.Feature_Statistics.Descriptive_Delta = G_del;


%% Hypothesis test
% -----------------------------------------------------------

% Do Wilcoxens pair test and make table of median and p-values
pVars = {
 	...'accA_x_b1_pow','accA_y_b1_pow','accA_z_b1_pow','accA_y_nf_stdev',...
	'accA_x_nf_HP_b1_pow','accA_y_nf_HP_b1_pow','accA_z_nf_HP_b1_pow',...
	...'accA_y_HP_nf_stdev',...
	'Q_mean','P_LVAD_mean',...Q_LVAD_mean,...
	...'pGrad_mean','pGrad_stdev','p_aff_mean','p_eff_stdev'...
	};
W = make_paired_features_for_signed_rank_test(F, pVars);
[P,R] = make_paired_signed_rank_test(W, G, pVars, 'G1');


%% Calculate ROC curves and corresponding confidence intervals
% -----------------------------------------------------------
classifiers = {
%   	'accA_y_b1_pow'
%  	'accA_x_b1_pow'
%  	'accA_z_b1_pow'
 	'accA_y_nf_HP_b2_pow'
 	'accA_x_nf_HP_b2_pow'
 	'accA_z_nf_HP_b2_pow'
	'P_LVAD_mean'
	'P_LVAD_drop'
	};

% Input for states of pooled occlusions above a threshold
%{
predStateVar = 'pooledDiam';
predStates = {
	%2, '>= 4.73mm'
	4, '>= 6.6mm'
	6, '>= 8.52mm'
	%7, '>= 9mm'
	%8, '>= 10mm'
	9, '>= 11mm'
	};
pooled = true;
%}
	
% Input for states of concrete occlusions 
predStateVar = 'levelLabel';
predStates = {
	'Inflated, Lev1', 'Level 1'
	'Inflated, Lev2', 'Level 2'
	'Inflated, Lev3', 'Level 3'
	'Inflated, Lev4', 'Level 4'
	};
pooled = false;

[ROC,AUC] = make_roc_curve_matrix_per_intervention_and_speed(...
	F, classifiers, predStateVar, predStates, pooled);

% Prepare feature table for ROC analysis in SPSS, and for pooled diameter states
F_ROC_SPSS = make_tables_for_ROC_analysis_in_SPSS(F);
F_ROC = make_table_for_pooled_ROC_analysis(F,F_del);


%% Save and roundup
% -----------------------------------------------------------

% Gather all analytical data
Data.G1.Features.Absolute_SPSS_ROC = F_ROC_SPSS;
Data.G1.Features.Absolute_Pooled_ROC = F_ROC;
Data.G1.Features.Absolute_Paired = W;
Data.G1.Feature_Statistics.Test_P_Values = P;
Data.G1.Feature_Statistics.Results = R;
Data.G1.Feature_Statistics.ROC = ROC;
Data.G1.Feature_Statistics.AUC = AUC;

%save_data('Periodograms', feats_path, Data.G1.Periodograms, {'matlab'});
save_data('Features', feats_path, Data.G1.Features, {'matlab'});
save_data('Statistics', stats_path, Data.G1.Feature_Statistics, {'matlab'});
save_features_as_separate_spreadsheets(Data.G1.Features, feats_path);
save_statistics_as_separate_spreadsheets(Data.G1.Feature_Statistics, stats_path);

multiWaitbar('CloseAll');
clear save_data
clear discrVars meanVars accVars hBands G G_rel G_del F F_rel F_del pVars ...
	pooled classifiers predStateVar predStates ROC F_ROC F_ROC_SPSS AUC idSpecs
