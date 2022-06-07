Config =  get_processing_config_defaults_G1;
cd 'C:\Users\Didrik\Dropbox\Arbeid\OUS\Proc\Matlab\Visualize\Article2'
 
%% Boxplot, pooled

%close all
saveFig = false;

vars = {
  	'accA_xyz_NF_HP_b2_pow_norm', 'NHA_{norm(\itx,y,z\rm)} (dB)', [-.5,2.5]
% 	'P_LVAD_mean', '{\itP}_{LVAD} (W)', [-.5,2.5]
	'P_LVAD_change', '{\itP}_{LVAD} (W)', [-.5,2.5]
 	'Q_mean' '{\itQ} (L/min)', [-.5,2.5]
%	'Q_drop' '{\itQ} (L/min)', [-.5,2.5]
%	'pGraft_mean' '{\itp}_{graft} (mmHg)', []
	};

% TODO: Expand support for list of different groups and group labels in the
%       functions make_intervention_groups and make_level_sting_for_save_name
levs = {
	'2'
	'3'
	'4'
	};

bpAsdB = true;
intervention_boxplot_by_color_per_rpm(F, levs, vars, bpAsdB, saveFig, Config);
intervention_boxplot(F, levs, vars, bpAsdB, saveFig, Config);

%bpAsdB = false;
% intervention_boxplot_by_color_per_rpm(F_rel, levs, vars, bpAsdB, saveFig, Config);
% intervention_boxplot(F_rel, levs, vars, bpAsdB, saveFig, Config);


%% BL deviation bar chart

vars = {
	'Q_mean',                     'pump flow rate'
	'P_LVAD_mean',                'energy consumption'
	'accA_xyz_NF_HP_b2_pow_norm', 'vibrations, nonharmonic'
	};
cats = {
     'Clamp, 2400, 25%', '1'
     'Clamp, 2400, 50%', '2'
     'Clamp, 2400, 75%', '3'
     'Balloon, 2400, Lev1', '40%' 
     'Balloon, 2400, Lev2', '55%'
     'Balloon, 2400, Lev3', '70%'
     'Balloon, 2400, Lev4', '80%' 
     'Balloon, 2400, Lev5', '90%' 
     };

close all
saveFig = false;
% saveFig = true;
make_baseline_deviation_bar_chart_figure(G_rel, 'median', vars, cats, Config, saveFig);

%% Spectrograms
% [2x2] panels, controls to the left and balloon interventions to the right
% Based on ID-segments, not parts

var = 'accA_y_NF_HP';
tit = 'Spectromgram';
rpm = 2400;
IDs1 = {
	'2.0 #1'
	'2.1'
	'2.2'
	'2.3'
	'2.4'
	%'2.0 #2'
	};
IDs2 = {
	'3.0 #1'
	'3.1'
	'3.2'
	'3.3'
	'3.4'
	%'3.0 #2'
	};

close all
make_spectrogram_and_curve_figure_per_ids_G1(...
	Data.G1.Seq13.S, tit, var, rpm, Config.fs, IDs1, IDs2);

%% NHA, Q and P, per catheter type
% Pendulating Mass in Inlet Conduit
% 3 X [nLevels] panels
% Figure 5 in submission for ASAIO

nhaVars = {
	%'accA_best_NF_HP_b2_pow_per_speed', [0,15]
	'accA_best_NF_HP_b1_pow', [-1,5]
	%'accA_y_NF_HP_b2_pow',[-1, 10]
	%'accA_y_NF_stdev',[]
	%'p_eff_mean',[55,100]
	%'pGrad_mean',[]
	%'Q_LVAD_mean',[0 8]
	};
levelLabels = {
	'Balloon','balloon'
	};

xLims = [0,12.7];
xLims = [0,1];
legTit = 'Pendulating Mass in Inlet Conduit';
xLab = 'Areal inflow obstruction (%)';

%home; close all
% sequences = {
% 	'Seq3' % (pilot)
% 	'Seq6'
% 	'Seq7'
% 	'Seq8'
% 	'Seq11'
% 	'Seq12'
% 	'Seq13'
% 	'Seq14'
% 	};
% F2 = lookup_sequences(sequences, F_rel);
G_rel = Data.G1.Feature_Statistics.Descriptive_Relative.med;
plot_nha_power_and_flow(F_rel, G_rel, [], nhaVars, levelLabels, 'arealObstr_pst', xLims, xLab, legTit, 'effect');

%clear nhaVars levelLabels xLims xLab tit


%TODO
% - Continious segment instead?
% - Include thombus injection?
% - Include RPM variation?
% - Keep NHA in a separate panel?


%% NHA, Q and P, per catheter type
% Pendulating Mass in Inlet Conduit
% 3 X [nLevels] panels
% Figure 5 in submission for ASAIO

nhaVars = {
	%'accA_x_NF_b1_pow',[0,0.008]
	%'accA_y_NF_HP_b2_pow',[0, 0.008]
	'accA_y_NF_HP_b1_pow',[0, 0.008]
	%'accA_z_NF_HP_b2_pow',[0, 0.008]
	%'accA_norm_NF_HP_b2_pow',[0, 0.008]
	%'accA_z_NF_b1_pow',[0,0.008]
	%'accA_y_NF_stdev',[]
	%'p_eff_mean',[55,100]
	%'pGrad_mean',[]
	%'Q_LVAD_mean',[0 8]
	};
levelLabels = {
	'Clamp', 'Outflow clamp'
	};

xLims = [2,12.5];
xLims = [0,100];
legTit = 'Pendulating Mass in Inlet Conduit';
xLab = 'Areal inflow obstruction (%)';

%home; close all
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
F2 = lookup_sequences(sequences, F_rel);
plot_nha_power_and_flow_per_intervention_G1(...
	F2,...
	Data.G1.Feature_Statistics.Descriptive_Relative.med, ...
	...Data.G1.Feature_Statistics.Descriptive_Absolute_swap_yz.med, ...
	[], ...
	nhaVars, levelLabels, ...
	'QRedTarget_pst', ...
	...'arealObstr_xRay_pst_mean', ...
	xLims, xLab, legTit, 'control');

clear nhaVars levelLabels xLims xLab legTit


%% NHA, Q and P for afterload and prelod side by side
% Control intervention
% 3 X 2 panels
% Figure 4 in submission for ASAIO

close all

nhaVars = {
	%'accA_x_NF_b1_pow',[0,8]
	'accA_y_NF_b2_pow',[0 8]
	%'accA_z_NF_b1_pow',[0,8]
	};

% Level categories plotted together
levelLabels = {
	'Afterload', 'Outflow clamp'
	'Preload',   'Inflow clamp'
	};

% Levels in separate panels
%{
levelLabels = {
	'Preload Q red., 10%', 'Q reduced 10%'
	'Preload Q red., 20%', 'Q reduced 20%'
	'Preload Q red., 40%', 'Q reduced 40%'
	'Preload Q red., 60%', 'Q reduced 60%'
	'Preload Q red., 80%', 'Q reduced 80%'
};
%}

xLims = [0,100];
xLab = 'Flow rate reduction targets (%)';
legTit = 'Control intervensions';

plot_nha_power_and_flow_per_intervention(Data.G1.Features.Absolute,...
	Data.G1.Feature_Statistics.Descriptive_Absolute.med, ...
	Data.G1.Feature_Statistics.Results, ...
	nhaVars, levelLabels, 'QRedTarget_pst', xLims, xLab, legTit,'control');

clear nhaVars levelLabels xLims xLab legTit

%% ROC curves for each diameter states and each speed
% Overlaid component curves
% [no of states]x[no of speeds] panels
% Figure 6 in submission for ASAIO

classifiers_to_plot = {
	%'accA_xyz_NF_HP_b1_pow_sum', 'sum(NHA_{x,y,z})'
	'accA_xyz_NF_HP_b1_pow_norm', 'norm(NHA_{x,y,z})'
	%'accA_best_NF_HP_b1_pow_per_speed', 'NHA_{best, per speed}'
	%   'accA_best_NF_HP_b2_pow', 'NHA_{best, per interv.}';
% 	'accA_x_NF_HP_b2_pow', 'NHA_{\itx}';
% 	'accA_y_NF_HP_b2_pow', 'NHA_{\ity}';
% 	'accA_z_NF_HP_b2_pow', 'NHA_{\itz}';
	'P_LVAD_change',   '\itP\rm_{LVAD}';
	};

close all
% legTit = 'ROC curves - Pooled balloon levels - Pooled RPM';
% h(1) = plot_roc_curve_matrix_G1(Data.G1.Feature_Statistics.ROC_Pooled_RPM, classifiers_to_plot, legTit);
% legTit = 'ROC curves - Pooled balloon levels';
% h(2) = plot_roc_curve_matrix_G1(Data.G1.Feature_Statistics.ROC_Pooled, classifiers_to_plot, legTit);
legTit = 'ROC curves - Concrete balloon levels';
h(3) = plot_roc_curve_matrix_G1(Data.G1.Feature_Statistics.ROC, classifiers_to_plot, legTit);

save_figure(h(1), fullfile(Config.fig_path,'ROC'), h(1).Name, 300)
save_figure(h(2), fullfile(Config.fig_path,'ROC'), h(2).Name, 300)
save_figure(h(3), fullfile(Config.fig_path,'ROC'), h(3).Name, 300)
%clear classfiers tit

%% ROC curves for each diameter states and each component
% % Overlaid speed curves
% % [no of states]x[3] panels
%
% classifiers = {
%  	'accA_x_NF_b1_pow', 'NHA_{\itx}';
%  	'accA_y_NF_b1_pow', 'NHA_{\ity}';
%  	'accA_z_NF_b1_pow', 'NHA_{\itz}';
% 	};
% tit = 'ROC Curves for Pendulating Mass States by Spatial Component';
%
% plot_roc_curve_matrix_per_intervention_and_xyz(...
% 	Data.IV2.Feature_Statistics.ROC, classifiers, tit);
%
% clear classfiers tit
%
% %% ROC curves for each pooled diameter states
% % Overlaid each speed
% % 1x[no of states] panels
%
% classifiers = {
%  	'accA_y_NF_b1_pow';
% 	};
% predStates = {
% 	%'diam_4.30mm_or_more', '>= 4.30mm'
% 	'diam_4.73mm_or_more', '>= 4.73mm'
% 	%'diam_6.00mm_or_more', '>= 6.0mm'
% 	'diam_6.60mm_or_more', '>= 6.6mm'
% 	%'diam_7.30mm_or_more', '>= 7.30mm'
% 	'diam_8.52mm_or_more', '>= 8.52mm'
% 	%'diam_9mm_or_more', '>= 9mm'
% 	%'diam_10mm_or_more', '>= 10mm'
% 	'diam_11mm_or_more', '>= 11mm'
% 	%'diam_12mm', '= 12mm'
% 	};
% tit = 'ROC Curves for Pool of Pendulating Mass States';
%
% close all
% plot_roc_curves_per_pooled_interventions(Data.IV2.Features.Absolute_Pooled_ROC, ...
% 	classifiers, predStates, tit);
%
% clear classfiers predStates tit
%
% %% Absolute NHA versus flow scatter
% % Intervention type grouping by color
% % 2x2 panels, one panel per speed
%
% vars = {
% %    'accA_y_NF_stdev',[0.01,0.19]
%     'accA_x_NF_b1_pow',[0,0.018]
%     'accA_y_NF_b1_pow',[0,0.018]
%    };
%
% close all
% plot_scatter_acc_against_Q(Data.IV2.Features.Absolute, vars);
% plot_scatter_relative_acc_and_Q_LVAD_against_Q(Data.IV2.Features.Absolute, ...
% 	Data.IV2.Features.Relative, vars);
%
% clear vars
%
% %% Individual effects aginst categories of Q red. and balloon occlusions
% % [no of speeds]x1panels
% % Includes all diameters (incl. intermediate levels)
% % D is numerical (unevenly distributed)
%
% vars = {
% 	'accA_y_NF_b1_pow', [0,0.011]
% 	%'accA_y_NF_b1_mpf', [90,210]
% 	};
%
% close all
% plot_individual_effects_against_interv_cats_per_speed(vars, ...
% 	{'Absolute','Medians'}, Data.IV2.Features.Absolute, ...
% 	'Absolute median effects');
%
% clear vars
%
% %% Aggregated effects aginst categories of Q red. and balloon occlusions
% %  [no of speeds]x1panels
% % Includes all diameters (incl. intermediate levels)
% % D is numerical (unevenly distributed)
%
% vars = {
% 	'accA_y_NF_b1_pow', [0,0.011]
% 	%'accA_y_NF_b1_mpf', [90,210]
% 	};
%
% close all
% G = Data.IV2.Feature_Statistics.Descriptive.Absolute;
% plot_aggregate_effects_against_interv_cats_per_speed(...
% 	G.med, vars,{'median','absolute'}, G.q1, G.q3);
%
% clear G vars
