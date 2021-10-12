%close all
clear check_table_var_input
seq_no = 19;
fig_subdir = 'Figures\Filter comparison';

% Calculation settings
sampleRate = fs_new;

mapSpec = {
    % Variable       Colorbar   y-lims
    'accA_norm',    [-80,-36], [0,5.2];
    'accA_norm_nf', [-80,-36], [0,5.2];
    'accA_x',       [-80,-36], [0,5.2];
    'accA_x_nf',    [-80,-36], [0,5.2];
    'accA_y',       [-80,-36], [0,5.2];
    'accA_y_nf',    [-80,-36], [0,5.2];
    'accA_z',       [-80,-36], [0,5.2];
    'accA_z_nf',    [-80,-36], [0,5.2];
    'accB_norm',    [-75,-45], [0,5.2];
    'accB_norm_nf', [-75,-45], [0,5.2];
    };

graphSpec = {
    % MovStd var     y-lims
    'accA_norm',    [-90,20]
    'accA_norm_nf', [-90,20];
    'accA_x',       [-90,20];
    'accA_x_nf',    [-90,20];
    'accA_y',       [-90,20];
    'accA_y_nf',    [-90,20];
    'accA_z',       [-90,20];
    'accA_z_nf',    [-90,20];
    'accB_norm',    [-90,20]
    'accB_norm_nf', [-90,20]
    };

% % Extract data for these RPM values
rpm={};

parts = {
%      {},   [1],   [],  '0. RPM step test'
%      {},   [2],   [],  '1. RPM changes'
%      
%      {},   [3],   [],  '2. 4.5mm balloon inflation'
%      {},   [4],   [],  '3. 4.5mm balloon inflation'
%      {},   [5],   [],  '4. 4.5mm Balloon inflation'
%      {},   [6],   [],  '5. 4.5mm Balloon inflation'
%      
%      {},   [7],   [],  '6. 6mm balloon inflation'
%      {},   [8],   [],  '7. 6mm balloon inflation'
%      {},   [9],   [],  '8. 6mm Balloon inflation'
%      {},   [10],  [],  '9. 6mm Balloon inflation'
%      
%      {},   [13],  [],  '10. 11mm balloon inflation'
%      {},   [14],  [],  '11. 11mm balloon inflation'
%      {},   [15],  [],  '12. 11mm Balloon inflation'
%      {},   [16],  [],  '13. 11mm Balloon inflation'
%
%      {},         [17],  [],  '14. RPM changes, before afterload clamping'
%      {17,179},   [18],  [],  '15. Afterload clamping'
%      {17,177},   [19],  [],  '16. Afterload clamping'
%      {17,175},   [20],  [],  '17. Afterload clamping'
%      {17,173},   [21],  [],  '18. Afterload clamping'
% 
%        {},         [22],  [],  '19. RPM changes, before preload clamping'
%        {22,226},   [23],  [],  '20. Preload clamping'
%        {22,224},   [24],  [],  '21. Preload clamping'
%        {22,223},   [25],  [],  '22. Preload clamping'
%        {22,220},   [26],  [],  '23. Preload clamping'
%};

%          {},         [1,2,12,17,22,27],  [],  '00. Baselines'
%      };
% rpm={3100};


if numel(rpm)==1, rpm = repmat(rpm,numel(parts),1); end
if numel(rpm)==0, rpm = cell(numel(parts),1); end

for j=1:size(mapSpec,1)
    for i=1:size(parts,1)
        welcome(['Part(s) ',num2str(parts{i,2})],'iteration')
        
        [T,rpms] = make_plot_data(parts{i,2},S_parts,rpm{i},sampleRate,parts{i,1},...
            parts{i,3},graphSpec{j,1});
        [h_fig,h_ax] = plot_ordermap_with_vars(...
            T,mapSpec{j,1},sampleRate,parts{i,1},mapSpec{j,2},Notes,graphSpec{j,2},mapSpec{j,3});
        
        % TODO Move into plot-function
        fig_name = make_fig_name_G1(h_fig,h_ax,...
            parts{i,2},parts{i,4},mapSpec{j,1},rpms,seq_no);
        
        save_to_png_G1(h_fig,proc_path,fig_subdir,300)
    end
    
    close all

end


function [T,rpm] = make_plot_data(parts,T,rpm,fs,bl_part,cbl_part,movStdVar)
    % Extract relevant data, and baseline is always put first
    if numel(bl_part)==2
        BL = T{bl_part{1}}(T{bl_part{1}}.noteRow==bl_part{2},:);
        T = merge_table_blocks([{BL};T(sort([parts,cbl_part]))]);
    else
        T = merge_table_blocks(T(parts));
    end
    
    
    if isempty(T), warning('Empty table. Is data initialized?'); end
    T.dur = linspace(0,1/fs*height(T),height(T))';
    
    % If not given, find RPM values from all parts (that are not baseline parts)
    if isempty(rpm)
        rpm = unique(T.pumpSpeed);
    end
    T = T(ismember(T.pumpSpeed,rpm),:);
    %T = T(not(contains(string(T.event),'clamp start')),:);
    
    T.Properties.SampleRate = fs;
    T = add_moving_statistics(T,{movStdVar},{'std'});
    T = add_moving_statistics(T,{'p_aff'},{'avg'});
    
    % Keep only steady or baseline denoted row in the baseline parts
    %     T(contains(string(T.part),string([bl_part{1},cbl_part])) & ...
    %         not(contains(lower(string(T.intervType)),{'baseline'})),:) = [];
    
    if height(T)==0
        warning('No rows in data parts %s, with RPM=%s',...
            mat2str(parts),mat2str(rpm));
    end
    
    blocks = find_cat_block_inds(T,{'balloonLev','intervType'});
    
    if isempty(bl_part)
        bl_inds = ismember(lower(string(T.intervType)),{'baseline'});
    else
        bl_inds = contains(string(T.part),string(bl_part)) & ...
            ismember(lower(string(T.intervType)),{'baseline','steady-state'});
    end
    if nnz(bl_inds)==0
        warning('No baseline intervals explicitly given in notes')
        bl_inds = blocks.start_inds(1):blocks.end_inds(1);
    end
    
    for k=1:height(blocks)
        range = blocks.start_inds(k):blocks.end_inds(k);
        
        % This is a workaround for bug
        if numel(range)==1, continue; end
        % TODO: Fix issue with numel(range)==1 in find_cat_block_inds instead.
        
        T.accA_norm_std(range) = std(T.accA_norm(range));
        T.accA_norm_rms(range) = rms(T.accA_norm(range));
        
        %        freqx{k} = meanfreq(detrend(T.accA_x(range)),fs);
        %        T.accA_x_mpf(range) = freqx{k};
        %       T.accA_x_mpf_shift(range) = freqx{k} - freqx{1};
        %        freqy{k} = meanfreq(detrend(T.accA_y(range)),fs);
        %        T.accA_y_mpf(range) = freqy{k};
        %       T.accA_y_mpf_shift(range) = freqy{k} - freqy{1};
        %       freqz{k} = meanfreq(detrend(T.accA_z(range)),fs);
        %       T.accA_z_mpf(range) = freqz{k};
        %      T.accA_z_mpf_shift(range) = freqz{k} - freqz{1};
        %      freq{k} = meanfreq(detrend(T.accA_norm(range)),fs);
        %     T.accA_norm_mpf(range) = freq{k};
        %    T.accA_norm_mpf_shift(range) = freq{k} - freq{1};
        
        Q = T.Q;
        T.Q_ultrasound_shift = 100*(Q-mean(Q(bl_inds),'omitnan'))/mean(Q(bl_inds),'omitnan');
        T.p_aff_shift = 100*(T.p_aff_movAvg-mean(T.p_aff(bl_inds),'omitnan'))/mean(T.p_aff(bl_inds),'omitnan');
        T.Q_LVAD_shift = 100*(T.Q_LVAD-mean(T.Q_LVAD(bl_inds),'omitnan'))/mean(T.Q_LVAD(bl_inds),'omitnan');
        T.P_LVAD_shift = 100*(T.P_LVAD-mean(T.P_LVAD(bl_inds),'omitnan'))/mean(T.P_LVAD(bl_inds),'omitnan');
        
        % If segment-wise overall std is to be plottet
        T.orderMapVar_std(range) = std(T.(movStdVar)(range));
        T.orderMapVar_shift = -100*(T.orderMapVar_std-mean(T.orderMapVar_std(bl_inds)))/mean(T.orderMapVar_std(bl_inds));
        
        % If ...
        T.orderMapVar_movStd_shift = -100*(T.([movStdVar,'_movStd'])-mean(T.([movStdVar,'_movStd'])(bl_inds),'omitnan'))/mean(T.([movStdVar,'_movStd'])(bl_inds),'omitnan');
        %T.orderMapVar_movRMS_shift = -100*(T.([movRMSVar,'_movRMS'])-mean(T.([movRMSVar,'_movRMS'])(bl_inds),'omitnan'))/mean(T.([movRMSVar,'_movRMS'])(bl_inds),'omitnan');
        
        %         T.accA_norm_std_shift = -100*(T.accA_norm_std-mean(T.accA_norm_std(bl_inds)))/mean(T.accA_norm_std(bl_inds));
        %         T.accA_norm_movStd_shift = -100*(T.accA_norm_movStd-mean(T.accA_norm_movStd(bl_inds),'omitnan'))/mean(T.accA_norm_movStd(bl_inds),'omitnan');
        
    end
    
    %T = T(get_steady_state_rows(T),:);
    T.Properties.SampleRate = fs;
    
end

function [h_fig,h_ax,map,order] = plot_ordermap_with_vars(...
        T,orderMapVar,fs,bl_part,mapColScale,notes,circ_ylim,mapOrderLim)
    
    if nargin<4, bl_part = []; end
    if nargin<5, mapColScale = []; end
    if nargin<6, mapOrderLim = [0, 6.25]; end
    [map,order,rpm,map_time] = make_rpm_order_map(T,orderMapVar,fs,...
        'pumpSpeed', 0.015, 80); %
    T.t = seconds(T.time-T.time(1))+map_time(1);
    
    flow_ax = 3;
    %freqStats_ax = 3;
    
    specs.leg_yGap = 0.005;
    specs.leg_xPos = 0.85;
    specs.yLab_xPos = -0.058;
    specs.yyLab_xPos = 1.039;
    
    % TODO: Make this programatically determined
    specs.circ_ylim = circ_ylim;
    
    specs.mapOrderLim = mapOrderLim;
    specs.mapColScale = mapColScale;
    specs.baseline_title = {
        'Units','data',...
        'HorizontalAlignment','center',...
        'FontSize',11,...
        'FontWeight','bold'};
    specs.event_bar = {
        'LineStyle','-',...
        'LineWidth',7,...
        'Marker','none',...
        'Color', [.85 .85 .85]};
    specs.bal_lev_bar = {
        'LineStyle','-',...
        'LineWidth',7,...
        'Marker','none',...
        'Color', [0.96,0.68,0.68]};
    specs.trans_lev_bar = {
        'LineStyle',':',...
        'LineWidth',1.5,...
        'Marker','none',...
        'Color', [.7 .7 .7]};
    specs.leg = {
        'EdgeColor','none',...
        'Box','off',...
        'FontSize',11};
    specs.leg_title = {
        'FontSize',11};
    specs.yLab = {
        'Interpreter','tex',...
        'Units','normalized',...
        'FontSize',11};
    
    [h_fig,h_ax] = init_axes_layout;
    set(h_ax,'UserData',specs);
    
    add_interv_bar(h_ax(1),T,notes,orderMapVar)
    add_order_map(h_ax(2),map_time,order,map,rpm)
    %add_freqStats(h_ax(freqStats_ax),T)
    %add_vibrations(h_ax(acc_ax),T)
    add_circulation(h_ax(flow_ax),T,orderMapVar);
    %add_baseline_xlines(h_ax,T,bl_part{1});
    
    h_xlab = xlabel(h_ax(end),'Duration (sec)',...
        'Units','normalized');
    h_xlab.Position = [1.0667,0.0205,0];
    adjust_axes(h_ax);
    
end

function [h_fig,h_ax] = init_axes_layout
    
    h_fig = figure(...
        ...'WindowState','maximized',...
        ...'Position',[0 70 1100 950],...
        'Units','pixels');
    fig_pos = get(0, 'MonitorPositions');
    fig_pos = fig_pos(end,:); % take position of monitor 2 if multiple monitors
    win_taskbar_height = 31;
    fig_pos(3) = 0.65*fig_pos(3);
    fig_pos(2) = win_taskbar_height;
    fig_pos(4) = fig_pos(4) - win_taskbar_height;
    h_fig.OuterPosition = fig_pos;
    
    ax_xPos = 0.075;
    ax_width = 0.72;
    ax_yGap = 0.0040;
    bar_height = 0.050;
    xLab_space = 0.035;
    
    ax_height(3) = 0.5;
    ax_yPos(3) = xLab_space;
    
    %     ax_height(3) = 0.15;
    %     ax_yPos(3) = ax_yPos(4)+ax_height(4)+ax_yGap;
    
    ax_height(2) = 1-ax_yPos(3)-ax_height(3)-ax_yGap-bar_height;
    ax_yPos(2) = ax_yPos(3)+ax_height(3)+ax_yGap;
    
    ax_height(1) = bar_height;
    ax_yPos(1) = ax_yPos(2)+ax_height(2);
    
    h_ax(1) = axes('Position', [ax_xPos ax_yPos(1) ax_width ax_height(1)]);
    h_ax(2) = axes('Position', [ax_xPos ax_yPos(2) ax_width ax_height(2)]);
    h_ax(3) = axes('Position', [ax_xPos ax_yPos(3) ax_width ax_height(3)]);
    %h_ax(4) = axes('Position', [ax_xPos ax_yPos(4) ax_width ax_height(4)]);
    
end

function add_interv_bar(h,T,notes,mapVar)
    
    specs = h.UserData;
    axes(h);
    yyaxis right
    hold on
    
    % remove unused categories and given categories of no interest
    ss_inds = get_steady_state_rows(T);
    
    %T.event = renamecats(T.event,{'Balloon volume change'},{'Volume change'});
    eventCol = removecats(removecats(T.event),{'-'});
    %event = mergecats(event,categories(event),'Hands on');
    events = categories(eventCol);
    for i=1:numel(events)
        events(i)
        inds = ismember(T.event,events{i});
        if nnz(inds)==0, continue; end
        eventEnds = find(diff(inds)<0)-1;
        eventStarts = find(diff(inds)>0)+1;
        if inds(1), eventStarts = [1;eventStarts]; end
        if inds(end), eventEnds = [eventEnds;1]; end
        for j=1:numel(eventStarts)
            block_rows = eventStarts(j):eventEnds(j);
            plot(T.t(block_rows),eventCol(block_rows),specs.event_bar{:})
        end
    end
    
    try
        T.balloonLev = mergecats(T.balloonLev,{'2','3','4','5'},...
            'Inflated balloon');%sprintf('Inflated %s balloon',catheter));
        T.balloonLev = renamecats(T.balloonLev,'1',...
            sprintf('Deflated balloon'));%sprintf('Deflated %s balloon',catheter));
        T.balloonLev = removecats(removecats(T.balloonLev),{'-'});
    catch
    end
    
    plot(T.t(ss_inds),T.balloonLev(ss_inds),specs.trans_lev_bar{:})
    t_ss = nan(height(T),1);
    t_ss(ss_inds) = T.t(ss_inds);
    plot(t_ss,T.balloonLev,specs.bal_lev_bar{:})
    
    h.YColor = [0 0 0];
    
    yyaxis left
    
    h.YTickLabel = [];
    h.YColor = [0 0 0];
    h.XAxisLocation = 'top';
    
    % TODO: Make this as separate function(?)
    [start_inds, end_inds, rpm_vals] = find_rpm_blocks(T);
    titleStr = {'\bfRPM\rm',mat2str(rpm_vals),'\bfVariable\rm',strrep(mapVar,'_','\_')};
    annotation(gcf,'textbox',...
        'Position',[0.861 0.857 0.1277822 0.070402],...
        'FitBoxToText','on',...
        'BackgroundColor',[1 1 1],...
        'String',titleStr,...
        'FontSize',10);
    
    [bl_start_ind, bl_end_ind] = get_baseline_block(T);
    %     try
    %         text(double(T.t( floor(mean([bl_start_ind(1),bl_end_ind(1)])) )),0.5,...
    %             sprintf('%Baseline_{%d}',T.pumpSpeed(bl_start_ind)),...
    %         specs.baseline_title{:})
    %     catch
    %         text(0,0.5,'Baseline',...
    %             specs.baseline_title{:})
    %     end
    
end

function add_order_map(h,map_time,order,map,rpm)
    
    specs = h.UserData;
    
    axes(h);
    imagesc(map_time,order,map);
    if not(isnan(specs.mapColScale)) & not(isempty(specs.mapColScale)) %#ok<AND2>
        caxis(specs.mapColScale);
    end
    set(h,'ydir','normal');
    h.YLim = specs.mapOrderLim;
    
    add_colorbar(h,specs)
    add_ylabel('Harmonics',specs);
    add_linked_map_yyaxis(h,rpm,specs);
end

function [start_ind, end_ind] = get_baseline_block(T,bl_part)
    
    if nargin<2, bl_part = []; end
    
    if not(isempty(bl_part))
        start_ind = find(T.part==string(bl_part),1,'first');
        end_ind = find(T.part==string(bl_part),1,'last');
    else
        block = find_cat_blocks(T,'intervType');
        start_ind = block.start_inds(ismember(lower(string(...
            T.intervType(block.start_inds))),'baseline'));
        end_ind = block.end_inds(ismember(lower(string(...
            T.intervType(block.end_inds))),'baseline'));
        if numel(start_ind)>1
            fprintf('\nMultiple baseline intervals in signal part.\n')
            %             start_ind = start_ind(1);
            %             end_ind = end_ind(1);
            %TODO Ask for which one to use
        end
    end
    
    if numel(start_ind)==0
        fprintf('\nNo baseline intervals in signal part.\n')
    end
    
end

function add_colorbar(h,specs)
    h_col = colorbar(h,...
        'Position',[0.881607, h.Position(2), 0.01921, 0.10526],...
        'Box', 'off',...
        'FontSize',8);
    h_col.Position(2) = h.Position(2)+0.3*h.Position(4)-0.5*h_col.Position(4);
    h_col.Label.String = {'Frequency';'amplitude (dB)'};
    h_leg = add_legend(h,{},'Spectrogram',specs);
    h_leg.Position = [0.8549524,sum(h_col.Position([2,4]))-0.005,0.1127575,0.043817];
end

function add_baseline_xlines(h_ax,T,bl_part)
    
    if nargin<3, bl_part = []; end
    
    [start_ind, end_ind] = get_baseline_block(T,bl_part);
    
    start_ind = start_ind(start_ind>1);
    for i=1:numel(start_ind)
        draw_xline_for_all_axes(h_ax,T.t(start_ind(i)))
    end
    end_ind = end_ind(end_ind<height(T));
    for i=1:numel(end_ind)
        draw_xline_for_all_axes(h_ax,T.t(end_ind(i)))
    end
    
    
end

function draw_xline_for_all_axes(h_ax,pos)
    for j=1:numel(h_ax)
        xline(h_ax(j),pos,'LineWidth',3,'Color',[1 1 1 0]);
        xline(h_ax(j),pos,'LineWidth',0.5,'Color',[1 0 0 0]);
    end
end

function add_ylabel(text_str,specs)
    h_yLab = ylabel(text_str,specs.yLab{:});
    h_yLab.Position(1) = specs.yLab_xPos;
end

function add_yylabel(text_str,specs)
    h_yyLab = ylabel(text_str,specs.yLab{:});
    h_yyLab.Position(1) = specs.yyLab_xPos;
end

function add_linked_map_yyaxis(h,rpm,specs)
    orderTicks = h.YTick;
    rpm = unique(rpm);
    if numel(rpm)==1
        yyaxis right
        yyLab = ylabel('(Hz)',specs.yLab{:});
        yyLab.Position(1) = specs.yyLab_xPos;
        linkprop(h.YAxis, 'Limits');
        set(h,'YTickLabel',strsplit(num2str(orderTicks*(rpm/60),'%2.0f ')));
    end
end

function add_freqStats(h,T)
    
    specs = h.UserData;
    axes(h);
    hold on
    
    fullColorRows = get_steady_state_rows(T) | contains(T.event,'Injection');
    
    plot(T.t(fullColorRows),T.accA_norm_mpf_shift(fullColorRows),...
        'LineWidth',1.5,...
        'LineStyle',':',...
        'Color',[0 0 0,0.8],...
        'HandleVisibility','off');
    T.accA_norm_mpf_shift(not(fullColorRows)) = nan;
    plot(T.t,T.accA_norm_mpf_shift,...
        'LineWidth',2,...
        'LineStyle','-',...
        'DisplayName','MPF_{|(x,y,z)|}',...
        'Color',[0 0 0,0.8]);
    
    add_ylabel('Shift  (Hz)',specs);
    
    plot(T.t(fullColorRows),T.accA_x_mpf_shift(fullColorRows),...
        'LineWidth',1.5,...
        'LineStyle',':',...
        'Color',[0.39,0.56,0.15,0.7],...
        'HandleVisibility','off');
    T.accA_x_mpf_shift(not(fullColorRows)) = nan;
    plot(T.t,T.accA_x_mpf_shift,...
        'LineWidth',2,...
        'LineStyle','-',...
        'DisplayName','MPF_x',...
        'Color',[0.39,0.56,0.15,0.9]);
    
    %     plot(T.t(ss_rows),T.accA_z_mpf_shift(ss_rows),...
    %         'LineWidth',1.5,...
    %         'LineStyle',':',...
    %         'HandleVisibility','off');...,'Color',[0.39,0.56,0.15,0.7]);
    %     T.accA_z_mpf_shift(not(ss_rows)) = nan;
    %     plot(T.t,T.accA_z_mpf_shift,...
    %         'LineWidth',2,...
    %         'LineStyle','-',...
    %         'DisplayName','MPF_y');...,'Color',[0.39,0.56,0.15,0.9]);
    
    %
    %     h_yyLab = ylabel({'Rectangular';'Window RMS'},specs.yLab{:});
    %     h_yyLab.Position(1) = specs.yyLab_xPos;
    
    yrange = h.YLim(2)-h.YLim(1);
    h.YLim = [h.YLim(1)-0.1*yrange, h.YLim(2)+0.1*yrange];
    %h.YTick(end) = [];
    %h.YLim = [-2, 10];
    h.Clipping = 'on';
    
    add_legend(h,{},'Frequency energy',specs);
    
    h.YGrid = 'on';
    h.GridAlpha = 0.1;
end

function add_vibrations(h,T)
    
    specs = h.UserData;
    axes(h);
    hold on
    
    ss_rows = get_steady_state_rows(T);
    
    plot(T.t,T.accA_x_movStd,...
        'LineWidth',0.5,...
        'LineStyle','-',...
        'DisplayName','SD_x, moving 5sec',...
        'Color',[0.30,0.50,0.88,0.3]);
    accA_x_std_ss = T.accA_x_std;
    accA_x_std_ss(not(ss_rows)) = nan;
    plot(T.t,accA_x_std_ss,....
        'LineWidth',2,...
        'LineStyle','-',...
        'DisplayName','SD_x, steady-state',...
        'Color',[0.0156,0.3555, 0.7188]);
    add_ylabel('SD_x  (g)',specs);
    
    %     plot(T.t,T.accA_z_movStd,...
    %         'LineWidth',0.5,...
    %         'LineStyle','-',...
    %         'DisplayName','SD_z, moving 1sec',...
    %         'Color',[0.46,0.66,0.79,0.3]);
    %     accA_z_std_ss = T.accA_z_std;
    %     accA_z_std_ss(not(ss_rows)) = nan;
    %     plot(T.t,accA_z_std_ss,....
    %         'LineWidth',2,...
    %         'LineStyle','-',...
    %         'DisplayName','SD_z, steady-state',...
    %         'Color',[0.0156,0.3555, 0.7188]);
    %    add_ylabel('SD_z  (g)',specs);
    
    yrange = h.YLim(2)-h.YLim(1);
    h.YLim = [h.YLim(1)-0.1*yrange, h.YLim(2)+0.1*yrange];
    %h.YTick([1,end]) = [];
    
    yyaxis right
    
    plot(T.t,T.accA_norm_movStd,...
        'LineWidth',.5,...
        'LineStyle','-',...
        'DisplayName','SD_{|x,y,z|^{*}}, moving 5sec',...
        'Color',[0.96,0.39,0.35,0.65]);
    accA_norm_std_ss = T.accA_norm_std;
    accA_norm_std_ss(not(ss_rows)) = nan;
    plot(T.t,accA_norm_std_ss,....
        'LineWidth',2,...
        'LineStyle','-',...
        'DisplayName','SD_{|x,y,z|}, steady-state',...
        'Color',[0.74,0.04,0.17]);
    
    add_yylabel('SD_{|x,y,z|} (10^{-3} g)',specs);
    add_legend(h,{},'Vibration Intensity',specs);
    
    yrange = h.YLim(2)-h.YLim(1);
    h.YLim = [h.YLim(1)-0.1*yrange, h.YLim(2)+0.1*yrange];
    h.YTickLabel = string(h.YTick*1000);
    h.YTick([1]) = [];
    
end

function add_circulation(h,T,orderMapVar)
    
    specs = h.UserData;
    axes(h);
    hold on
    
    fullColorRows = get_steady_state_rows(T) | contains(string(T.event),'Injection');
    
    %     area_bal = pi*((double(string(T.balloonDiam))/2).^2);
    %     area_inlet = pi*(13.0/2)^2;
    %     area_red = 100*((area_inlet-area_bal)/area_inlet - 1);
    %     area_red_ss = area_red;
    %     area_red_ss(not(ss_rows)) = nan;
    %     if all(isnan(area_red_ss))
    %         areaRedVisability = 'off';
    %     else
    %         areaRedVisability = 'on';
    %     end
    %     plot(T.t,area_red_ss,...
    %         'LineWidth',2,...
    %         'LineStyle','-',...
    %         'Color',[0.5781,0.5117,0.9453],...
    %         'DisplayName','Inlet area reduction',...);%[0.7188,0.6289,0.9297]);%[0.6055,0.1406, 0.4414, 0.85]);
    %         'HandleVisibility',areaRedVisability);
    %     plot(T.t(ss_rows),area_red(ss_rows),...
    %         'LineWidth',1,...
    %         'LineStyle',':',...
    %         'Color',[0.5781,0.5117,0.9453],...[0.7188,0.6289,0.9297,0.7],...[0.6055,0.1406, 0.4414,0.6],...
    %         'HandleVisibility','off');
    
    %     plot(T.t,T.p_aff_shift,...
    %         'LineWidth',0.5,...
    %         'LineStyle','-',...
    %         'Color',[0.52,0.07,0.67, 0.05],...
    %         'HandleVisibility','off');
    %     T.p_aff_shift(not(fullColorRows)) = nan;
    %     plot(T.t,T.p_aff_shift,...
    %         'LineWidth',0.75,...
    %         'LineStyle','-',...
    %         'Color',[0.52,0.07,0.67, 0.7],...
    %         'DisplayName','\itP\rm, graft');
    
    plot(T.t,T.Q_ultrasound_shift,...
        'LineWidth',0.5,...
        'LineStyle','-',...
        'Color',[0.04,0.37,0.37, 0.11],...
        'HandleVisibility','off');
    T.Q_ultrasound_shift(not(fullColorRows)) = nan;
    plot(T.t,T.Q_ultrasound_shift,...
        'LineWidth',0.75,...
        'LineStyle','-',...
        'Color',[0.04,0.37,0.37, 0.75],...
        'DisplayName','\itQ\rm, ultrasound');
    
    
    
    
    %     accA_x_std_shift_ss = T.accA_x_std_shift;
    %     accA_x_std_shift_ss(not(ss_rows)) = nan;
    % %     plot(T.t,T.accA_x_movStd_shift,...
    % %         'LineWidth',0.5,...
    % %         'LineStyle','-',...
    % %         'Color',[0.96,0.39,0.35,0.3],...
    % %         'DisplayName','SD*, moving 5sec');
    %     plot(T.t,accA_x_std_shift_ss,...
    %         'LineWidth',2,...
    %         'LineStyle','-',...
    %         'Color',[0.74,0.04,0.17],...
    %         'DisplayName','SD*_x, steady-state');
    %     plot(T.t(ss_rows),accA_x_std_shift_ss(ss_rows),...
    %         'LineWidth',1.25,...
    %         'LineStyle',':',...
    %         'Color',[0.74,0.04,0.17,0.6],...[0.7188,0.6289,0.9297,0.7],...[0.6055,0.1406, 0.4414,0.6],...
    %         'HandleVisibility','off');
    
    %     accA_norm_std_shift_ss = T.accA_norm_std_shift;
    %     accA_norm_std_shift_ss(not(ss_rows)) = nan;
    % %     plot(T.t,T.accA_norm_movStd_shift,...
    % %         'LineWidth',0.5,...
    % %         'LineStyle','-',...
    % %         'Color',[0.74,0.04,0.17,0.05],...
    % %         'DisplayName','SD*, moving 5sec');
    %     plot(T.t,accA_norm_std_shift_ss,...
    %         'LineWidth',2,...
    %         'LineStyle','-',...
    %         'Color',[0.74,0.04,0.17],...
    %         'DisplayName','-SD_{|\it\bfa\rm|}');
    %     plot(T.t(ss_rows),accA_norm_std_shift_ss(ss_rows),...
    %         'LineWidth',1.25,...
    %         'LineStyle',':',...
    %         'Color',[0.74,0.04,0.17,0.6],...[0.7188,0.6289,0.9297,0.7],...[0.6055,0.1406, 0.4414,0.6],...
    %         'HandleVisibility','off');
    
    
    plot(T.t,T.orderMapVar_movStd_shift,...
        'LineWidth',1,...
        'LineStyle','-',...
        'Color',[0.74,0.04,0.17,0.1],...
        'HandleVisibility','off');
    T.orderMapVar_movStd_shift(not(fullColorRows)) = nan;
    movWinDur = T.Properties.CustomProperties.MovingWindowSeconds(...
        [orderMapVar,'_movStd']);
    plot(T.t,T.orderMapVar_movStd_shift,...
        'LineWidth',.5,...
        'LineStyle','-',...
        'Color',[0.74,0.04,0.17,0.65],...
        'DisplayName',['SD_{|(x,y,z)|}^{*}, mov. ',num2str(movWinDur),'sec']);
    
    
    P_LVAD_shift_ss = T.P_LVAD_shift;
    P_LVAD_shift_ss(not(fullColorRows)) = nan;
    if all(isnan(P_LVAD_shift_ss))
        powVisability = 'off';
    else
        powVisability = 'on';
    end
    plot(T.t,P_LVAD_shift_ss,...
        'LineWidth',2,...
        'LineStyle','-',...
        'Color',[0.9961,0.4961,0,1],...
        'HandleVisibility',powVisability,...
        'DisplayName','Power, monitor')
    plot(T.t(fullColorRows),T.P_LVAD_shift(fullColorRows),...
        'LineWidth',1.5,...
        'LineStyle',':',...
        'Color',[0.9961,0.4961,0,0.5],...
        'HandleVisibility','off')
    
    Q_LVAD_shift_ss = T.Q_LVAD_shift;
    Q_LVAD_shift_ss(not(fullColorRows)) = nan;
    if all(isnan(Q_LVAD_shift_ss))
        QVisability = 'off';
    else
        QVisability = 'on';
    end
    plot(T.t,Q_LVAD_shift_ss,...
        'LineWidth',2,...
        'LineStyle','-',...
        'Color',[0.00,0.78,0.00,0.7],...
        'HandleVisibility',QVisability,...
        'DisplayName','\itQ\rm, monitor');
    plot(T.t(fullColorRows),T.Q_LVAD_shift(fullColorRows),...
        'LineWidth',1.5,...
        'LineStyle',':',...
        'Color',[0.00,0.78,0.00,0.5],...
        'HandleVisibility','off');
    
    
    
    
    h.YLim = specs.circ_ylim;
    
    h_yLab = ylabel('Relative Change',specs.yLab{:});
    h_yLab.Position(1) = specs.yLab_xPos;
    
    h.Clipping = 'on';
    h.YGrid = 'on';
    h.GridAlpha = 0.1;
    
    add_legend(h,{},'Flow Modalities',specs);
    
end

function h_leg = add_legend(h_ax,entries,titleString,specs)
    
    if isempty(entries)
        h_leg = legend(specs.leg{:});
    else
        h_leg = legend(entries,specs.leg{:});
    end
    h_leg.AutoUpdate = 'off';
    title(h_leg,titleString,...
        specs.leg_title{:});
    h_leg.Position(2) = h_ax.Position(2)+0.5*h_ax.Position(4)-0.5*h_leg.Position(4);
    h_leg.Position(1) = specs.leg_xPos;
end

function adjust_axes(h_ax)
    set(h_ax(3:end),'Color',[1 1 1])
    set(h_ax(3:end),'Box','off');
    set(h_ax,'xlim',h_ax(2).XLim)
    linkaxes(h_ax,'x')
    set(h_ax,'TickDir','both')
    set(h_ax,'TickLength',[0.005,0.025])
    set(h_ax(1),'TickLength',[0,0])
    set(h_ax(1:end-1),'XTickLabel',{});
    set(h_ax(1:end-1),'XTick',[]);
    set(h_ax,'FontSize',11)
    set(h_ax,'YColor',[0 0 0]);
    h_ax(end).YTickLabel = cellstr(string(h_ax(end).YTick)+"%");
    xlims = xlim(h_ax(end));
    %    h_ax(end).XTick = seconds(120:120:xlims(2)-60);
    %    xtickformat(h_ax(end),'mm:ss')
    totHDur = diff(xlims)/60;
    if totHDur<30
        h_ax(end).XTick = 60:120:xlims(2);
    elseif totHDur>=30 && totHDur<60
        h_ax(end).XTick = 60:180:xlims(2);
    elseif totHDur>=60 && totHDur<90
        h_ax(end).XTick = 60:240:xlims(2);
    elseif totHDur>=90
        h_ax(end).XTick = 60:300:xlims(2);
    end
    %h_ax(end).XMinorTick = 'on';
    %Minor = 60:60:xlims(2);
    %h_ax(end).XTickLabel = durs/60
end
%xtickformat('mm:ss')