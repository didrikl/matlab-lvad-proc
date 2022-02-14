%% Pre-process
% * Data fusion into given frequency
% * Make regularily sampled timetables of each recording segment parts
% * Add derived/filtered variables in the regular timetables
% * Reduce data to rows with given analysis_id
% * Remove columns that can be regenerated as needed

welcome(['Preprocess data ',pc.seq],'module')

Notes = derive_cardiac_output(Notes);
Notes = calc_obstruction(pc, Notes);
Notes = adjust_balloon_levels(Notes);

levLims = [5,9,10.10,11,11.70,12.7];



US = merge_Q_blocks(US);

PL = resample_signal(PL, pc.fs);
PL = calculate_pressure_gradient(PL, pc.pGradVars);

S = fuse_data(Notes, PL, US, pc.fs, pc.interNoteInclSpec, pc.outsideNoteInclSpec);
S_parts = split_into_parts(S, pc.fs);

S_parts = add_spatial_norms(S_parts, 2, {'accA_x','accA_y','accA_z'}, 'accA_norm');
S_parts = add_spatial_norms(S_parts, 2, {'accA_x','accA_y'}, 'accA_xynorm');
S_parts = add_spatial_norms(S_parts, 2, {'accA_y','accA_z'}, 'accA_yznorm');
%S_parts = add_spatial_norms(S_parts, 2, {'accB_x','accB_y','accB_z'}, 'accB_norm');

S_parts = add_harmonics_filtered_variables(S_parts,...
    {'accA_norm',   'accA_x',   'accA_y',   'accA_z',    'accA_xynorm',    'accA_yznorm'},...
	{'accA_norm_NF','accA_x_NF','accA_y_NF','accA_z_NF', 'accA_xynorm_NF', 'accA_yznorm_NF'});
S_parts = add_highpass_RPM_filter_variables(S_parts,...
	{'accA_x_NF',   'accA_y_NF',   'accA_z_NF',   'accA_norm_NF',    'accA_xynorm_NF',    'accA_yznorm_NF'},...
	{'accA_x_NF_HP','accA_y_NF_HP','accA_z_NF_HP','accA_norm_NF_HP', 'accA_xynorm_NF_HP', 'accA_yznorm_NF_HP'},...
	pc.harmCut, 'harm', pc.harmCutFreqShift);
% S_parts = add_highpass_RPM_filter_variables(S_parts,...
% 	{'accA_x_NF','accA_y_NF','accA_z_NF','accA_norm'},...
% 	{'accA_x_NF_HP','accA_y_NF_HP','accA_z_NF_HP','accA_norm_NF_HP'},...
% 	pc.cutFreq, 'freq');

S = merge_table_blocks(S_parts);
S = reduce_to_analysis_G1(S, Notes, pc.idSpecs);
S_parts = remove_unneeded_variables_in_parts(S_parts);