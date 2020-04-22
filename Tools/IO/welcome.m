function welcome(str, type)
    
    if nargin<2, type = 'function'; end
    
    switch type
        case 'iteration'
            fprintf('\n<strong>%s</strong>\n',str)
        
        case 'function'
            line = repmat('-',1,numel(str)+2);
            fprintf('\n<strong> %s</strong>\n%s\n',str,line)
            
        case 'module'
            line = repmat('*',1,numel(str)+4);
            fprintf('\n%s\n* <strong>%s</strong> *\n%s\n',line,str,line)
            
        case 'program'
            line = repmat('*',1,80);
            fprintf('\n%s\n<strong> %s</strong>\n%s\n',line,str,line)
            % NOTE: Could also display info about start of execution, 
            % program version, etc.
            
        otherwise
            error('type is not supported')
    end