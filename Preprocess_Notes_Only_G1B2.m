% NB: Use with caution! Note rows may be incorrect in fused data. 

% Read sequence notes made with Excel file template
inputs = {
  	'G1B2_Seq3' % (pilot)
	'G1B2_Seq6'
   	'G1B2_Seq7'
   	'G1B2_Seq8'
	'G1B2_Seq11'
   	'G1B2_Seq12'
   	'G1B2_Seq13'
   	'G1B2_Seq14'
	};

% Do separate initialization parts
for i=1:numel(inputs)
	Config =  get_processing_config_defaults_G1B2;
	eval(inputs{i});
	idSpecs = init_id_specifications(Config.idSpecs_path);	
	Config.notes_filePath = init_notes_filepath(Config);

	Notes = init_notes_xls(Config.notes_filePath, '', Config.notes_varMapFile);
	Notes = qc_notes_G1(Notes, idSpecs, Config.askToReInit);
 	Notes = pre_proc_notes_G1(Notes, Config);
 	
    Data = save_preprocessed_notes_only(Config, Notes, Data);
 	Preprocess_Roundup;
end

clear inputs i