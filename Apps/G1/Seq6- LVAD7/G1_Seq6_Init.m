%% Initialze the processing environment and input file structure

% Which experiment
basePath = 'D:\Data\IVS\Didrik';
sequence = 'Seq6 - LVAD7';
experiment_subdir = 'G1 - In vivo pre-pump thrombosis simulation\Seq6 - LVAD7';

% Directory structure
powerlab_subdir = 'Recorded\PowerLab';
ultrasound_subdir = 'Recorded\SystemM';
notes_subdir = 'Noted';

% Which files to input from input directory 
% NOTE: Could be implemented to be selected interactively using uigetfiles
powerlab_fileNames = {
      'G1_Seq6 - F1_Sel1 [accA].mat'
      'G1_Seq6 - F1_Sel1 [accB].mat'
      'G1_Seq6 - F1_Sel1 [pGraft,pLV,ECG].mat'
      'G1_Seq6 - F1_Sel2 [accA].mat'
      'G1_Seq6 - F1_Sel2 [accB].mat'
      'G1_Seq6 - F1_Sel2 [pGraft,pLV,ECG].mat'
     'G1_Seq6 - F2_Sel1 [accA].mat'
     'G1_Seq6 - F2_Sel1 [accB].mat'
     'G1_Seq6 - F2_Sel1 [pGraft,pLV,ECG].mat'
     'G1_Seq6 - F2_Sel2 [accA].mat'
     'G1_Seq6 - F2_Sel2 [accB].mat'
     'G1_Seq6 - F2_Sel2 [pGraft,pLV,ECG].mat'
     };
notes_fileName = 'G1_Seq6 - Notes ver4.16 - Rev8.xlsm';
notes_spec_file = 'VarMap_G1_Notes_Ver4p16';
ultrasound_fileNames = {
    'ECM_2020_10_22__11_02_46.wrf'
};

% Add subdir specification to filename lists
%[read_path, save_path] = init_io_paths(sequence,basePath);
ultrasound_filePaths  = fullfile(basePath,experiment_subdir,ultrasound_subdir,ultrasound_fileNames);
powerlab_filePaths = fullfile(basePath,experiment_subdir,powerlab_subdir,powerlab_fileNames);
notes_filePath = fullfile(basePath, experiment_subdir,notes_subdir,notes_fileName);
proc_path = fullfile(basePath,experiment_subdir,'Processed');

powerlab_variable_map = {
    % LabChart name  Matlab name  Target fs  Type        Continuity
    'pGraft'         'p_graft'      'single'    'continuous'
    'SensorAAccX'    'accA_x'      'single'    'continuous'
    'SensorAAccY'    'accA_y'      'single'    'continuous'
    'SensorAAccZ'    'accA_z'      'single'    'continuous'
    'SensorBAccX'    'accB_x'      'single'    'continuous'
    'SensorBAccY'    'accB_y'      'single'    'continuous'
    'SensorBAccZ'    'accB_z'      'single'    'continuous'
    'ECG'            'ecg'         'single'    'continuous'
    'pMillarLV'      'pLV'         'single'    'continuous'
    };

systemM_varMap = {
    % Name in Spectrum   Name in Matlab     SampleRate Type     Continuity   Units
    'VenflowLmin'        'Q_graft'          1          'single' 'continuous' 'L/min'
    };

notes_varMapFile = 'VarMap_G1_Notes_Ver4p16';

%% Read data into Matlab
% Initialize data into Matlab timetable format
% * Read PowerLab data (PL) and ultrasound (US) files stored as into cell arrays
% * Read notes from Excel file

welcome('Reading data','module')

if load_workspace({'S_parts','notes','feats'},proc_path); return; end

% Read PowerLab data in files exported from LabChart
PL = init_labchart_mat_files(powerlab_filePaths,'',powerlab_variable_map);

% Read meassured flow and emboli (volume and count) from M3 ultrasound
US = init_system_m_text_files(ultrasound_filePaths,'',systemM_varMap);

% Read sequence notes made with Excel file template
notes = init_notes_xlsfile_ver4(notes_filePath,'',notes_varMapFile);
notes = qc_notes_ver4(notes);


%% Pre-processing
% * QC/pre-fixing data
% * Block-wise fusion of notes into PL, and then US into PL, followed by merging
%   of blocks into one table S
% * Splitting into parts
% * resampling to regular sampling intervals of given frequency

welcome('Preprocessing data','module')

fs_new = 500;
interNoteInclSpec = 'nearest';
outsideNoteInclSpec = 'nearest';

secsAhead = 47.5;

US = adjust_for_linear_time_drift(US,secsAhead);

%PL = resample_signal(PL, fs_new);

% S = fuse_data_parfor(notes,PL,US);
S = fuse_data(notes,PL,US,fs_new,interNoteInclSpec,outsideNoteInclSpec);

S_parts = split_into_parts(S,fs_new);


%% Process derived variables

welcome('Processing derived variable','module')

S_parts = add_spatial_norms(S_parts,2,{'accA_x','accA_y','accA_z'},'accA_norm');
S_parts = add_spatial_norms(S_parts,2,{'accB_x','accB_y','accB_z'},'accB_norm');
% S_parts = add_spatial_norms(S_parts,2,{'i1','i2_shifted','i3_shifted'},'i_norm_shifted');
% S_parts = add_spatial_norms(S_parts,2,{'v1','v2_shifted','v3_shifted'},'v_norm_shifted');
%S_parts = remove_variables(S_parts,{'accB_x','accB_y','accB_z'});

% Add highpass-filtered moving acc statistics
S_parts = add_highpass_RPM_filter_variables(S_parts,{'accA_norm'},'accA_norm_HP',1,1);
%S_parts = add_highpass_RPM_filter_variables(S_parts,{'accA_norm'},'accA_norm_1.5HP',1.5,0);
S_parts = add_highpass_RPM_filter_variables(S_parts,{'accA_x','accA_y','accA_z'},{'accA_x_HP','accA_y_HP','accA_z_HP'},1,1);
%S_parts = add_highpass_RPM_filter_variables(S_parts,{'accA_x','accA_y','accA_z'},{'accA_x_1.5HP','accA_y_1.5HP','accA_z_1.5HP'},1.5,0);

% S_parts = add_moving_statistics(S_parts,{'accA_norm','accA_x','accA_y','accA_z'},{'std'});
% S_parts = add_moving_statistics(S_parts,{'i1','v1','i_norm','v_norm'},{'std'});
% S_parts = add_moving_statistics(S_parts,{'p_graft'},{'avg','max','min'});
% S_parts = add_moving_statistics(S_parts,{'accB_norm'},{'std'});

%feats = init_features_from_notes(notes);
