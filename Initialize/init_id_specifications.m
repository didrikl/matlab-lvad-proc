function id_specs = init_id_specifications(workbookFile)
        
    % Set up the Import Options and import the data
    opts = spreadsheetImportOptions("NumVariables", 12);
    
    % Specify sheet and range
    opts.Sheet = "ID_Definitions_IV2";
    opts.DataRange = "A2:L139";
    
    % Specify column names and types
    opts.VariableNames = ["categoryLabel", "levelLabel",  "idLabel",     "analysis_id", "analysisDuration", "effectInterv", "contingency", "QRedTarget_pst", "pumpSpeed", "catheter",    "balloonDiam", "balloonVolume"];
    opts.VariableTypes = ["categorical",   "categorical", "categorical", "categorical", "single",           "categorical",  "categorical", "categorical",    "int16",     "categorical", "categorical", "categorical"];
    
    % Specify variable properties
    opts = setvaropts(opts, ["categoryLabel", "levelLabel", "idLabel", "effectInterv", "contingency", "QRedTarget_pst", "catheter"], "EmptyFieldRule", "auto");
    
    % Import the data
    id_specs = readtable(workbookFile, opts, "UseExcel", false);
    
    % Parse column info
    id_specs.analysisDuration = seconds(id_specs.analysisDuration);
    cont_col = false(height(id_specs),1);
    cont_col(ismember(id_specs.contingency,{'x','X'})) = true;
    id_specs.contingency = cont_col;
    effect_col = false(height(id_specs),1);
    effect_col(ismember(id_specs.effectInterv,{'x','X'})) = true;
    id_specs.effectInterv = effect_col;