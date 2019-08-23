function [path, filename, overwrite_all, ignore_all] = ...
        save_destination_check(path, filename, overwrite_all, ignore_all)
    % SAVE_DESTINATION_CHECK
    %   Checks and initialize destination for saving, with user interaction and
    %   printed information the command line window.
    % 
    %   Check if directory exsists
    %   If saving directory does not exist: Create the directory
    %
    %   If saving directory  exist: 
    %   - Check if file already exists in the directory
    %   - If filename exist, then the user is given the following options:
    %
    %       Overwrite
    %       Overwrite all
    %       Save to ...
    %       Ignore
    %       Ignore all
    %       Abort
    %
    %   For the 'Overwrite all' and 'Ignore all' options to work in practice,
    %   the output variables overwrite_all and ignore_all must persist in
    %   memory, e.g. declared as a persistent variables in the calling code.
    %
    % See also uiputfile, save_table, save_figure

    
    % Check existence of saving directory and create new if not existing
    if not(exist(path,'dir'))
        fprintf(['\nDirectory for saving does not exist:\n',...
            strrep(path,'\','\\')])
        warning('Directory will be created.')
        mkdir(path);
    end
    
    % Check if file exists in given directory
    if exist(fullfile(path,filename),'file')
             
        % Start with using overwrite_all and ignore_all. If they both are false,
        % then we enter the user interaction part below, allowing the user to
        % change these parameters
        overwrite=overwrite_all;
        ignore=ignore_all;
        
        % New filename or path is not yet given
        new_filename_selected = false;
        new_path_selected = false;
        
        % First, check with user about what to do, if not previously done 
        if not(overwrite) && not(ignore)
            
            overwrite_all=false;
            ignore_all=false;
            
            % Display warning and open user interaction menu
            user_opts = {
                'Overwrite'
                'Overwrite all'
                'Save to ...'
                'Ignore'
                'Ignore all'
                'Abort'
                };
            
            message = display_filename(filename,path,'\nOutput file already exist:','\t');
            response = ask_list_ui(user_opts, message);
        
            if response==1
                overwrite=true;
            end
            
            % Ask no more about for the above options with option 2 or 4
            if response==2 
                overwrite_all = true; 
                overwrite = true;
            elseif response==4
                filename = 0;
            elseif response==5
                ignore_all = true; 
                filename = 0;
            elseif response==6
                error('Aborted')
            end
            
            % Open build-in browser for saving, giving full flexibility for filepath
            if response==3
                [new_filename,new_path] = uiputfile(...
                    fullfile(path,filename),'Save as');
                
                new_filename_selected = strcmp(new_filename, filename);
                new_path_selected = strcmp(new_path, path);
        
                % If new filename and/or new path was not given
                if not(new_filename_selected) && not(new_path_selected)
                    overwrite = true;                   
                elseif not(isnumeric(new_filename)) && not(isnumeric(new_path))
                    filename = new_filename;
                    path = new_path;
                    overwrite = false;
                end
                
            end
            
            % Interperate user-closed window or 'Cancel' as ignore=true
            if isempty(response)
                filename = 0;
            end
            
        end
        
        % Display info after user interaction
        if new_filename_selected || new_path_selected
            display_filename(new_filename,new_path,...
                '\nSaving to new destination');
        elseif isnumeric(filename)
            fprintf('\nSaving will not be done.\n');   
        end
        
    end
    
   