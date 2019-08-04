function feats = make_feature_windows(signal, feats)
    
    lead_expansion = 30;
    trail_expansion = 30;
    
    event_type = {'Thrombus injection'};
    
    sub1_y_varname =  'acc_length';
    sub2_y_varname = 'movrms';
    sub2_yy_varname = 'movstd';
    pivot_y_varnames = {'movstd','movrms'};
    
    
    % More specified window for the feature, to be adjusted in quality control.
    % Start with using the window to be equal to the precursor window
    feats.lead_win_startTime = feats.precursor_startTime-seconds(lead_expansion);
    feats.lead_win_endTime = feats.precursor_startTime;
    feats.trail_win_startTime = feats.precursor_startTime;
    feats.trail_win_endTime = feats.precursor_endTime+seconds(trail_expansion); 
    
    % Clip trail window if it goes into the next intervention window
    feats.trail_win_endTime(1:end-1) = min(feats.trail_win_endTime(1:end-1),feats.precursor_startTime(2:end));
    
    event_feats = feats(contains(string(feats.precursor),event_type),:);
    n_events = height(event_feats);
    
    %h_fig = gobjects(n_iv,1);
    close all
    for i=1:n_events
        
        plot_range = timerange(event_feats.lead_win_startTime(i),event_feats.trail_win_endTime(i));
        plot_data = signal(plot_range,:);
        t = seconds(plot_data.timestamp-plot_data.timestamp(1));%feats.precursor_startTime(1))
        t = t-lead_expansion;
        
        h_fig = figure; %clf
        
        % NOTE: 
        % * User MaxNumChanges=2 and take the first of these
        % * Check for all pivot_y_varnames (instead of binary search?)
        %   - Useful to check performance associated with the variable
        %   - Take the fist of these to window split marker
        % * Check if the detection goes outside the feature window
        % * Implement a check that the trail_window does not go into next
        %   intervention, or let the window go all the way to the next
        %   intervention.
        % * Store automatic detection findings
        % * Store the manual quality control detection
        max_no_changes = 2; % =2 take more time to run
        mid_time = t(1)+0.5*t(end);
        
        fprintf('\nSearching for abrupt signal changes\n\n');
        for j=1:numel(pivot_y_varnames)
            
            t0_ind = find(t==0,1,'first');
            iv_var = rmmissing(plot_data.(pivot_y_varnames{j})(t0_ind:end,:));
            pivot_ind = findchangepts(iv_var,...
                'MaxNumChanges',max_no_changes ); %'MinThreshold' );
            
            if isempty(pivot_ind)
                pivot_ind = search_refined_abrupt_changes(iv_var);
            end
            
            if not(isempty(pivot_ind))
                abrupt_change_time = t(t0_ind+pivot_ind(1));       
                fprintf('\nDetected for: %s\n\tWindow split time: %s\n',...
                    pivot_y_varnames{j},num2str(abrupt_change_time))
            else
                fprintf('\nNo detected for %s\n\tWindow split time: Midpoint\n',...
                    pivot_y_varnames{j})
                abrupt_change_time = mid_time;
            end
        end
        
        % Make plots
        h_sub(1) = plot_in_upper_panel(t,plot_data,sub1_y_varname);
        h_sub(2) = plot_in_lower_panel(t,plot_data,sub2_y_varname,sub2_yy_varname);        
        
        % Add title
        make_title(feats.precursor(i), event_feats, i, n_events)
        
        % Axis relation control
        h_sub(2).Position(4) = h_sub(1).Position(4)*1.18;
        linkaxes(h_sub,'x')
        h_zoom = make_zoom_panel(h_sub(2),abrupt_change_time,sub2_y_varname);
        
        % Adding time label/annotation after zoom tool (which would reposition it)
        xlabel(h_sub(2),'Time (sec)','Position',[0.5,-0.11,0]);
        add_timestamp_textbox(feats.timestamp(i))
    
        % [ampl, phase] = make_fft_plots(iv_signal, qc_varname);
        
        % TODO: Find harmonic max values (also before and after abrupt change)
        
        cursors.abrupt_change = add_window_split_cursorbar(h_sub, h_zoom, abrupt_change_time);
        cursors.cutoff = add_cutoff_cursorbars(h_sub, h_zoom, 0, t(end)-trail_expansion);
    
        %break
        pause
        %cursors.abrupt_change.panel_1.Position(1)
        
        close(h_fig)
    end
    
end


% Functions to populate panels with plots
% ---------------------------------------

function h_sub = plot_in_upper_panel(t,iv_signal,sub1_y_varname)
    
    sub1_ylim = [0.8,1.2];
    
    h_sub = subplot(2,1,1);
    h_plt = plot(t,iv_signal.(sub1_y_varname));
    common_adjust_panel(h_sub(1),t)
    h_sub(1).Position(4) = h_sub(1).Position(4)*1.18;
    h_sub(1).YLim = sub1_ylim;
    h_sub(1).XAxisLocation = 'top';
    set(h_sub(1),'YTick',h_sub(1).YTick(2:end));        
    legend(h_plt,strrep({sub1_y_varname},'_','\_'),...
            'Orientation','horizontal',...
            'AutoUpdate','off')       
end

function h_sub2 = plot_in_lower_panel(t,iv_signal,sub2_y_varname,sub2_yy_varname)
    h_sub2 = subplot(2,1,2);
    h_plt_y = plot(t,iv_signal.(sub2_y_varname),'Clipping','on');
    common_adjust_panel(h_sub2,t)
    
    axes(h_sub2)
    %subplot(2,1,2);
    
    % Lower panel: Add ekstra plot with separate axis-scale on the right
    yyaxis right
    h_plt_yy = plot(t,iv_signal.(sub2_yy_varname));
    h_sub_yy = gca;
    h_sub_yy.YLim = h_sub_yy.YLim+0.15*abs((h_sub_yy.YLim(2)-h_sub_yy.YLim(1)));
    h_sub_yy.YLim(1) = min(h_sub_yy.YLim(1),min(iv_signal.(sub2_yy_varname)));
    h_sub_yy.Box = 'off';
    
    legend([h_plt_y,h_plt_yy],strrep({sub2_y_varname,sub2_yy_varname},'_','\_'),...
            'Orientation','horizontal',...
            'AutoUpdate','off')       
end

function make_title(event_type, feat, event_no, n_event)
    
    vol = feat.thrombusVolume(event_no);
    rpm = string(feat.pumpSpeed(event_no));
    suptitle(sprintf('Intervention: %s %d/%d - %s ml - %s RPM',...
        event_type,event_no,n_event,vol,rpm))
    
end 

function add_timestamp_textbox(t0_timestamp)
    
    disp_t = datestr(t0_timestamp);
    text(gca,0,-0.33,{'Time = 0';disp_t},'Units','normalized','FontSize',9);
    
end

function common_adjust_panel(ax,t)
    
    ax.XAxis.TickDirection = 'both';
    ax.XAxis.TickLength = [0.003,0];
    ax.YAxis.TickLength = [0.005,0];
    ax.XGrid = 'on';
    ax.XMinorGrid = 'on';
    ax.Box = 'off';   

    % Stretch in y-dir
    %ax.Position(4) = ax.Position(4)*1.18;
    
    xtick_step = 10; %round(t(end)-t(1)/10,-2)/20;
    ax.XTick = t(1):xtick_step:t(end);
    ax.XLim(2) = t(end);
    
    % Fix start and width in x-position
    ax.Position(1) = 0.043;
    ax.Position(3) = 0.915625;
    
end

function h_zoom = make_zoom_panel(h_sub,mid_pos,varname)
    % Add zoom functionality, using data from the given axis
    
    yyaxis_selection = 'left';
    initial_zoom = 90;    
    
    if size(h_sub.YAxis,1)>1
        yyaxis(h_sub,yyaxis_selection)
    end
    
    h_zoom = scrollplot(h_sub,...
        'WindowSizeX',initial_zoom,...
        'MinX',mid_pos-0.5*initial_zoom);
    adjust_zoom_panel(h_zoom,h_sub,varname)
end

function adjust_zoom_panel(h_zoom,h_sub2,sub2_y_varname)
    
    legend(h_zoom,sub2_y_varname,...
        'AutoUpdate','off',...
        'EdgeColor','none',...
        'FontSize',9,...
        'Color','none',...
        'Location','eastoutside');
    %h_zoom_leg.Title.String = 'Zoom tool';   
    h_zoom.XTick = h_sub2.XTick;
    h_zoom_plt = findall(h_zoom,'Tag','scrollDataLine');
    h_zoom_plt.Color = [.67 .79 .87];
    h_zoom_hlp = findall(h_zoom,'Tag','scrollHelp');
    h_zoom_hlp.Color = [.5 .5 .5];
    h_zoom.Position(1) = 0.2;
    h_zoom.Position(2) = h_zoom.Position(2)-0.055;
    h_zoom.Position(3) = 0.6;    
    
end

% Functions to define feature windows
% -----------------------------------

% function [abrupt_change_time, pivot_ind] = search_abrupt_changes(data, t, pivot_varnames)
%     
%     for j=1:numel(pivot_varnames)
%         varname = pivot_varnames{j};
%         var = rmmissing(data.(varname));
%         pivot_ind = findchangepts(var,...
%             'MaxNumChanges',1 ... 'MinThreshold',2 ...
%             );
%         if isempty(pivot_ind)
%             pivot_ind = search_refined_abrupt_changes(var);
%         end
%         
%         if pivot_ind
%             abrupt_change_time = t(pivot_ind);
%             fprintf('\nAbrupt change detected\n\tVariable: %s\n\tTime: %s\n',...
%                 varname,num2str(abrupt_change_time))
%             break
%         else
%             abrupt_change_time = t(1)+0.5*t(end);
%         end        
%     end
% 
% end

function pivot_ind = search_refined_abrupt_changes(var, recur_no)
    
    % Recur is used for keeping track of number of refinements, for which the 
    % function is called recursively
    if nargin<2
        recur_no = 0; 
    end
    
    % We are happy if we can find just one change when using this function 
    refined_max_no_changes = 1;
    
    % Give up if no detection after 2 refinements
    if recur_no > 2
        pivot_ind = [];
        return
    end
    
    mid_ind = floor(numel(var)/2);
    
    % Check first the first half
    pivot_ind = findchangepts(var(1:mid_ind,:),'MaxNumChanges',refined_max_no_changes);
    
    % Check the second half if not success with the first half
    if isempty(pivot_ind)
        pivot_ind = findchangepts(var(mid_ind:end,:),'MaxNumChanges',1);
        if not(isempty(pivot_ind))
            pivot_ind = mid_ind+pivot_ind;
        end
        
    end

    % If no success, try again recursively (a new search with refining into 
    % 1st half, followed by 2nd half if no finding in first half)
    if isempty(pivot_ind)
        pivot_ind = search_refined_abrupt_changes(var(1:mid_ind,:), recur_no+1);
    end
    if isempty(pivot_ind)
        pivot_ind = search_refined_abrupt_changes(var(mid_ind:end,:), recur_no+1);
    end
    
end

function plot_init_pos(h_ax,flag_time,label,color)
    
    for k=1:numel(flag_time)
        xline(h_ax,flag_time(k),...
            'LineStyle',':',...
            'Alpha',0.6,...
            'LineWidth',1.3,...
            'Label',label,...
            'LabelHorizontalAlignment','left',...
            'LabelVerticalAlignment','bottom',...
            'FontSize', 7,...
            'FontWeight','bold',...
            'Color',color );
    end
    
end

function cursors = add_window_split_cursorbar(h_sub, h_zoom, pos)
    
    color = [0.80,0.00,0.40];%[0.67,0.15,0.31];%[0.9 0.1 0.9];
    width = 2;
    label = ' Signal change ';
    init_label = ' Automatic detection ';
    [h_cur1,h_cur2,h_curzoom,h_curlab] = add_panel_linked_cursors(...
        h_sub,h_zoom,pos,label,width,color);
    callback_fun = @(~,~)move_from_init_pos_callback(...
        h_cur1, h_curlab, pos, init_label, h_sub, h_zoom);
    addlistener(h_cur2,'UpdateCursorBar', callback_fun);
    addlistener(h_cur1,'UpdateCursorBar', callback_fun);
    addlistener(h_curzoom,'UpdateCursorBar', callback_fun);
%      h_curlab.Position(2) = h_cur1.THandle.YData-0.05*abs(...
%          h_cur1.TopHandle.YData-h_cur1.BottomHandle.YData);
    
    % Save handles to struct container of cursor handles (can be object-oriented)
    cursors.panel_1 = h_cur1;
    cursors.panel_2= h_cur2;
    cursors.panel_zoom = h_curzoom;
    
end

function cursors = add_cutoff_cursorbars(h_sub, h_zoom,win_start,win_end)
    % NOTE: Object orientation is perhaps better structure of this code, which
    % may then be included in the add_panel_linked_cursor function
    
    color = [0.3 0.3 0.3];
    width = 2;
    left_label = 'window start';
    end_label = 'window end';
    
    [h_cur1,h_cur2,h_curzoom,h_curlab] = add_panel_linked_cursors(h_sub,h_zoom,...
        win_start,left_label,width,color);
    
    addlistener([h_cur1,h_cur2,h_curzoom],...
        'UpdateCursorBar',@(~,~)left_cutoff_callback(h_cur1,h_curlab,h_sub,h_zoom));
    left_cutoff_callback(h_cur1,h_curlab,h_sub,h_zoom)
    
    cursors.left_cutoff.panel_1 = h_cur1;
    cursors.left_cutoff.panel_2= h_cur2;
    cursors.left_cutoff.panel_zoom = h_curzoom;
    
    [h_cur1,h_cur2,h_curzoom,h_curlab] = add_panel_linked_cursors(h_sub,h_zoom,...
        win_end,end_label,width,color);
    
    addlistener([h_cur1,h_cur2,h_curzoom],...
        'UpdateCursorBar',@(~,~)right_cutoff_callback(h_cur1,h_curlab,h_sub,h_zoom));
    right_cutoff_callback(h_cur1,h_curlab,h_sub,h_zoom)

    cursors.right_cutoff.panel_1 = h_cur1;
    cursors.right_cutoff.panel_2= h_cur2;
    cursors.right_cutoff.panel_zoom = h_curzoom;
    
    callback_fun = @(~,~)move_from_init_pos_callback(...
        h_cur1, h_curlab, win_end, 'end of win', h_sub, h_zoom);
    addlistener(h_cur2,'UpdateCursorBar', callback_fun);
    addlistener(h_cur1,'UpdateCursorBar', callback_fun);
    addlistener(h_curzoom,'UpdateCursorBar', callback_fun);
    
end

function [h_cur1,h_cur2,h_curzoom,h_curlab] = add_panel_linked_cursors(...
        h_sub,h_zoom,pos,label,width,color)
    
    h_cur1 = cursorbar(h_sub(1),...
        'Location',pos,...
        'CursorLineWidth',width,...
        ...'BottomMarker','.',...
        ...'TopMarker','+',...
        'CursorLineColor',color);
    
    % hack/fix in case multiple y axis are in use
    if size(h_sub(2).YAxis,1)>1
        yyaxis(h_sub(2),'right')
    end
    h_cur2 = cursorbar(gca,...
        'Location',pos,...
        'CursorLineWidth',width,...
        ...'BottomMarker','+',...
        ...'TopMarker','.',...
        'CursorLineColor',color);
   
    h_curzoom = cursorbar(h_zoom,...
        'Location',pos,...
        'CursorLineWidth',width,...
        ...'BottomMarker','.',...
        ...'TopMarker','.',...
        'CursorLineColor',color);
    
    % Add a label next to the upper panel cursorbar
    lab_ypos = h_cur1.TopHandle.YData-0.1*abs(...
        h_cur1.TopHandle.YData-h_cur1.BottomHandle.YData);
    h_curlab=text(h_sub(1), pos, lab_ypos, label,...
        'FontWeight','bold',...
        'FontSize',8.5,...
        'HorizontalAlignment','center',...
        'BackgroundColor',[1 1 1]);...'right',...
     
    
    % When moving cursor on panel 1, other corresponding cursor positions
    addlistener ( h_cur1,'Location','PostSet', ...
        @(~,~)set([h_cur2,h_curzoom],'Location',h_cur1.Location) );
    
    % When moving cursor on panel 2, other corresponding cursor positions
    addlistener ( h_cur2,'Location','PostSet', ...
        @(~,~)set([h_cur1,h_curzoom],'Location',h_cur2.Location) );
    
    % When moving cursor on zoom panel, other corresponding cursor positions
    addlistener ( h_curzoom,'Location','PostSet', ...
        @(~,~)set([h_cur1,h_cur2],'Location',h_curzoom.Location) );
    
end


% Callback functions
% ------------------

function right_cutoff_callback(h_cur,h_curlab,h_sub,h_zoom)

    % Let shade handles be persistent, so so they can be delete before creating 
    % new ones (preventing a stack up of old shades)
    persistent h_right_shade_sub1
    persistent h_right_shade_sub2
    persistent h_right_shade_zoom
    delete([h_right_shade_sub1,h_right_shade_sub2,h_right_shade_zoom])
    
    % Move cursor label
    h_curlab.Position(1) = h_cur.TopHandle.XData;
    
    % NOTE: Searching for objects may be sub-optimal (less efficient and less
    % robust)
    h_plot_line = findobj(h_sub(1),'Type','line');
    
    % Defining shade area. NB: For x axis, the shade can not overlay the
    % cursorbar due to technical difficulties with uistack, hence the addition.
    shade_xmax = h_plot_line.XData(end);
    shade_xmin = h_cur.TopHandle.XData(1)+0.4;
   
    h_right_shade_sub1 = patch(h_sub(1),...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_sub(1).YLim fliplr(h_sub(1).YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
    h_right_shade_sub2 = patch(h_sub(2),...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_sub(2).YLim fliplr(h_sub(2).YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
    h_right_shade_zoom = patch(h_zoom,...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_zoom.YLim fliplr(h_zoom.YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
    
end

function left_cutoff_callback(h_cur1,h_curlab,h_sub,h_zoom)
    % Very similar function to right cutoff_callback. It needs to be a separate
    % function to handles separate persistent variables.
    
    persistent h_left_shade_sub1
    persistent h_left_shade_sub2
    persistent h_left_shade_zoom
    delete([h_left_shade_sub1, h_left_shade_sub2, h_left_shade_zoom])
    
    % Move cursor label
    h_curlab.Position(1) = h_cur1.TopHandle.XData;
    
    h_plot_line = findobj(h_sub(1),'Type','line');
    shade_xmin = h_plot_line.XData(1);
    shade_xmax = h_cur1.TopHandle.XData(1)-0.4;
   
    h_left_shade_sub1 = patch(h_sub(1),...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_sub(1).YLim fliplr(h_sub(1).YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
     
    h_left_shade_sub2 = patch(h_sub(2),...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_sub(2).YLim fliplr(h_sub(2).YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
     
    h_left_shade_zoom = patch(h_zoom,...
        [repmat( shade_xmin,1,2) repmat( shade_xmax,1,2)], ...
        [h_zoom.YLim fliplr(h_zoom.YLim)], [0 0 0 0], [.5 .5 .5],...
        'FaceAlpha',0.2,...
        'EdgeColor','None');
    
end

function move_from_init_pos_callback(h_cur, h_curlab, pos, line_id, h_sub, h_zoom)
    
    persistent plotted_lines
    
    % Move cursor label
    h_curlab.Position(1) = h_cur.TopHandle.XData;
    
    % Plot original line (as before moving)
    if isempty(plotted_lines) || not(strcmp(plotted_lines{end},line_id))
        
        color = h_cur.CursorLineColor;%[.5 .5 .5];
        plot_init_pos(h_sub(1), pos, line_id, color)
        plot_init_pos(h_sub(2), pos, '', color)
        plot_init_pos(h_zoom, pos, '', color)
        
        plotted_lines{end+1} = line_id;
        
    end
    
end