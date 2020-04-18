function varName = check_var_output_to_table(signal, varName)
    
    persistent always_overwrite
    if isempty(always_overwrite), always_overwrite = false; end
    persistent always_skip
    if isempty(always_skip), always_skip = false; end
    
    if ismember(varName,signal.Properties.VariableNames)
        
        msg = sprintf('\tOutput variable: %s already exist',varName);
        
        if always_overwrite
            varName = '';
            return
        end
        if always_skip
            varName = '';
            return
        end
        
        opts = {
            'Keep'
            'Keep, always'
            'Overwrite'
            'Overwrite, always'
            'Abort'
            };
        response = ask_list_ui(opts,msg);
        
        if response==1
             varName = '';
             
        elseif response==2
            always_skip = true;
            varName = '';
            fprintf('\n\tExisting variable is kept');
            fprintf('\n\t(Type "clear check_var_output_to_table" to reset.)\n')
            
        elseif response==3
            
        elseif response==4
            always_skip = true;
            fprintf('\n\tExisting variable is always overwritten');
            fprintf('\n\t(Type "clear check_var_output_to_table" to reset.)\n')
            
        elseif response==5
            abort; 
        end
    
    end