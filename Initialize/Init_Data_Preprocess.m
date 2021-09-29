%% Pre-process
% * Data fusion into given frequency
% * Make regularily sampled timetables of each recording segment parts
% * Add derived/filtered variables in the regular timetables

welcome(['Preprocess data',seq],'module')

US = merge_table_blocks(US);
US = aggregate_effQ_and_affQ(US);

PL = resample_signal(PL, fs_new);
PL = calculate_pressure_gradient(PL,'p_aff','p_eff');

S = fuse_data(Notes,PL,US,fs_new,'nearest','none');
S_parts = split_into_parts(S,fs_new);

S_parts = add_spatial_norms(S_parts,2,{'accA_x','accA_y','accA_z'},'accA_norm');
S_parts = add_spatial_norms(S_parts,2,{'accA_x','accA_y'},'accA_xynorm');
%S_parts = add_spatial_norms(S_parts,2,{'accB_x','accB_y','accB_z'},'accB_norm');

S_parts = add_harmonics_filtered_variables(S_parts,...
    {'accA_norm','accA_xynorm','accA_x','accA_y','accA_z'},fs_new);
%S_parts = add_moving_statistics(S_parts , varNames, statistics, newVarsNames)

S = merge_table_blocks(S_parts);
S = reduce_to_analysis_IV2(S,Notes,idSpecs);