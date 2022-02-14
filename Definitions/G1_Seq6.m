%% Sequence definitions and correction inputs

% Experiment sequence ID
pc.seq = 'G1_Seq6';

% Folder in base path
pc.seq_subdir = 'Seq6 - LVAD7';

% Which files to input from input directory 
pc.labChart_fileNames = {
	'G1_Seq6 - F1_Sel1 [accA].mat'
	%'G1_Seq6 - F1_Sel1 [accB].mat'
	'G1_Seq6 - F1_Sel1 [pGraft,pLV,ECG].mat'
	'G1_Seq6 - F1_Sel2 [accA].mat'
	%'G1_Seq6 - F1_Sel2 [accB].mat'
	'G1_Seq6 - F1_Sel2 [pGraft,pLV,ECG].mat'
	'G1_Seq6 - F2_Sel1 [accA].mat'
	%'G1_Seq6 - F2_Sel1 [accB].mat'
	'G1_Seq6 - F2_Sel1 [pGraft,pLV,ECG].mat'
	'G1_Seq6 - F2_Sel2 [accA].mat'
	%'G1_Seq6 - F2_Sel2 [accB].mat'
	'G1_Seq6 - F2_Sel2 [pGraft,pLV,ECG].mat'
	};
pc.notes_fileName = 'G1_Seq6 - Notes G1 v1.0.0 - Rev9.xlsm';
pc.ultrasound_fileNames = {
    'ECM_2020_10_22__11_02_46.wrf'
};

% Correction input
pc.US_offsets = {};
pc.US_drifts = {47.5}; % Just an estimate based on previous drifts
pc.accChannelToSwap = {};
pc.blocksForAccChannelSwap = [];
pc.pChannelToSwap = {};
pc.pChannelSwapBlocks = [];
pc.PL_offset = [];
pc.PL_offset_files = {};