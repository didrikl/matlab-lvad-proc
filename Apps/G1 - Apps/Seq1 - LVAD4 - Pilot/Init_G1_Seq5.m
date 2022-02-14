%% Initialze the processing environment and input file structure

% Which experiment
basePath = 'C:\Data\IVS\Didrik';
sequence = 'G1_Seq1';
pc.seq_subdir = [sequence,' - Simulated HVAD pre-pump thrombosis'];
% TODO: look up all subdirs that contains the sequence in the dirname. 

% Directory structure
powerlab_subdir = 'Recorded\PowerLab';
driveline_subdir = 'Recorded\Teguar';
ultrasound_subdir = 'Recorded\M3';
notes_subdir = 'Noted';

% Which files to input from input directory 
% NOTE: Could be implemented to be selected interactively using uigetfiles
pc.labChart_fileNames = {
    'G1_Seq1 - F1_Sel1_ch1-5.mat'
    'G1_Seq1 - F1_Sel2_ch1-5.mat'
    };
driveline_fileNames = {
    };
pc.notes_fileName = 'G1_Seq1 - Notes ver3.12 - Rev3.xlsm';
pc.ultrasound_fileNames = {
    'ECM_2020_05_14__13_27_19.wrf'
    };

% Add subdir specification to filename lists
[read_path, save_path] = init_io_paths(sequence,basePath);
ultrasound_filePaths  = fullfile(basePath,pc.seq_subdir,ultrasound_subdir,pc.ultrasound_fileNames);
powerlab_filePaths = fullfile(basePath,pc.seq_subdir,powerlab_subdir,pc.labChart_fileNames);
driveline_filePaths = fullfile(basePath,pc.seq_subdir,driveline_subdir,driveline_fileNames);
notes_filePath = fullfile(basePath, pc.seq_subdir,notes_subdir,pc.notes_fileName);

powerlab_variable_map = {
    % LabChart name  Matlab name  Max frequency  Type        Continuity
    'Trykk1'         'p_eff'       1000           'single'    'continuous'
    'Trykk2'         'p_aff'       1000           'single'    'continuous'
    'SensorAAccX'    'accA_x'     700            'numeric'   'continuous'
    'SensorAAccY'    'accA_y'     700            'numeric'   'continuous'
    'SensorAAccZ'    'accA_z'     700            'numeric'   'continuous'
    };

%% Read data into Matlab
% Initialize data into Matlab timetable format
% * Read PowerLab data (PL) and ultrasound (US) files stored as into cell arrays
% * Read notes from Excel file

init_matlab
welcome('Initializing data','module')
%if load_workspace({'S_parts','notes','feats'}); return; end

% Read PowerLab data in files exported from LabChart
PL = init_labchart_mat_files(powerlab_filePaths,'',powerlab_variable_map);

% Read meassured flow and emboli (volume and count) from M3 ultrasound
US = init_system_m_text_files(ultrasound_filePaths);

% Read sequence notes made with Excel file template
notes = init_notes_xlsfile_ver3_12(notes_filePath);


%% Pre-processing
% Transform and extract data for analysis
% * QC/pre-fixing data
% * Block-wise fusion of notes into PL, and then US into PL, followed by merging
%   of blocks into one table S
% * Splitting into parts, each resampling to regular sampling intervals of given frequency

notes = qc_notes(notes);

% Correct for unsync'ed clock on driveline monitor
% unsync_inds = DL.time + hours(1)+minutes(3)+seconds(29);

% Correct for clock drift in M3 monitor
secsAhead = 38; % TO BE UPDATED!!!
secsRecDur = height(US);
driftPerSec = secsRecDur/secsAhead;
driftCompensation = seconds(0:driftPerSec:secsAhead);
driftCompensation = driftCompensation(1:height(US));
US.time = US.time-driftCompensation;

feats = init_features_from_notes(notes);

%%

%S = fuse_data_parfor(notes,PL,US);
S = fuse_data(notes,PL,US);
%clear PL US
S_parts = split_into_parts(S);
%clear S

S_parts = add_spatial_norms(S_parts,2);

S_parts = add_moving_statistics(S_parts);
S_parts = add_moving_statistics(S_parts,{'accA_x'});
S_parts = add_moving_statistics(S_parts,{'accA_y'});
S_parts = add_moving_statistics(S_parts,{'accA_z'});
S_parts = add_moving_statistics(S_parts,{'p_aff'});

% Maybe not a pre-processing thing
%S_parts = add_harmonics_filtered_variables(S_parts);

% TODO:
% Add MPF, std, RMS and other statistics/indices into feats
% Revise categoric blocks, and put into feats

%ask_to_save({'S_parts','notes','feats'},sequence);

