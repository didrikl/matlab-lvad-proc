%#ok<*NASGU> 

run('C:\Users\Didrik\Dropbox\Arbeid\OUS\Proc\Matlab\Initialize\Environment.m')

% Initialize from raw data, preprocess and store (in memory and to disc)
inputs = {
	%'IV2B_Seq6'
   	'IV2B_Seq7'
% 	'IV2B_Seq9'
% 	'IV2B_Seq10'
% 	'IV2B_Seq11'
% 	'IV2B_Seq12'
% 	'IV2B_Seq13'
% 	'IV2B_Seq14'
% 	'IV2B_Seq18'
% 	'IV2B_Seq19'
	};

% Do separate initialization parts
for i=1:numel(inputs)

	% Initialize
	Config =  get_processing_config_defaults_IV2B;
	eval(inputs{i});
	init_multiwaitbar_preproc(i, numel(inputs), Config.seq);
	
	% Init Data if not present in memory, otherwise update  
	Data.IV2B.(get_seq_id(Config.seq)).Config = Config;

	% Init individual data source with adjustment input
	Init_Data_Raw_IV2
	
	% Data fusion, derive signals, clip into segments and continous parts
 	Preprocess_Sequence_IV2_accB
	
% 	% Store on disc
% 	save_s_parts(S_parts, Config.proc_path, Config.seq)
% 	save_s(S, Config.proc_path, Config.seq)
% 	save_notes(Notes, Config.proc_path, Config.seq)
% 	save_config(Config)
	
	% Store in Data struct and cleanup memory
	Data = save_in_memory_struct(Data, Config, S, S_parts, Notes);
	S.Properties.UserData.Notes = Notes;
	Preprocess_Roundup

end

clear inputs i


