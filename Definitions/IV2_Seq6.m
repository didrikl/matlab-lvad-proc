% Experiment sequence ID
pc.seq = 'IV2_Seq6';
pc.seq_subdir = 'Seq6 - LVAD8';

% Input directory structure
powerlab_subdir = 'Recorded\PowerLab';
ultrasound_subdir = 'Recorded\SystemM';
notes_subdir = 'Noted';

% NOTE: Could be implemented to be selected interactively using uigetfiles
pc.labChart_fileNames = {
    'IV2_Seq6 - F1 [pEff,pAff].mat'
    'IV2_Seq6 - F1 [accA].mat'
    %     'IV2_Seq6 - F1 [accB].mat'
    'IV2_Seq6 - F2 [pEff,pAff].mat'
    'IV2_Seq6 - F2 [accA].mat'
    %     'IV2_Seq6 - F2 [accB].mat'
    'IV2_Seq6 - F3 [pEff,pAff].mat'
    'IV2_Seq6 - F3 [accA].mat'
    %     'IV2_Seq6 - F3 [accB].mat'
    'IV2_Seq6 - F4 [pEff,pAff].mat'
    'IV2_Seq6 - F4 [accA].mat'
    %     'IV2_Seq6 - F4 [accB].mat'
    'IV2_Seq6 - F5 [pEff,pAff].mat'
    'IV2_Seq6 - F5 [accA].mat'
    %     'IV2_Seq6 - F5 [accB].mat'
    'IV2_Seq6 - F6 [pEff,pAff].mat'
    'IV2_Seq6 - F6 [accA].mat'
    %     'IV2_Seq6 - F6 [accB].mat'
    'IV2_Seq6 - F7 [pEff,pAff].mat'
    'IV2_Seq6 - F7 [accA].mat'
    %     'IV2_Seq6 - F7 [accB].mat'
    'IV2_Seq6 - F8 [pEff,pAff].mat'
    'IV2_Seq6 - F8 [accA].mat'
    %     'IV2_Seq6 - F8 [accB].mat'
    'IV2_Seq6 - F9 [pEff,pAff].mat'
    'IV2_Seq6 - F9 [accA].mat'
    %     'IV2_Seq6 - F9 [accB].mat'
    'IV2_Seq6 - F10 [pEff,pAff].mat'
    'IV2_Seq6 - F10 [accA].mat'
    %'IV2_Seq6 - F10 [accB].mat'
    };
pc.notes_fileName = 'IV2_Seq6 - Notes IV2 v1.0.0 - Rev3.xlsm';
pc.ultrasound_fileNames = {
    'ECM_2020_09_02__12_23_38.wrf'
    'ECM_2020_09_03__11_52_50.wrf'
    };

% Correction input
pc.US_offsets = {};
pc.US_drifts = {[], 24.5};
pc.accChannelToSwap = {'accA_y','accA_z'};
pc.blocksForAccChannelSwap = [];
pc.pChannelToSwap = {};
pc.pChannelSwapBlocks = [];
pc.PL_offset = [];
pc.PL_offset_files = {};

