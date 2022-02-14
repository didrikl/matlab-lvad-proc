function specs = get_plot_specs
	% TODO: Implement return of which plot type on request by user input
	% TODO: Make it object oriented
	
	% Import color palettes
	Colors_IV2
	
	fontSize = 17; 
	fontName = 'Arial';%'Gill Sans Nova';%'Arial';%;
	axLineWidth = 2;
	labelColor = [.2 .2 .2];

	specs.fig = {
		'Color',[1,1,1]
		};
	specs.speedMarkers = {'o','diamond','square','hexagram'};%'pentagram'};
	specs.backPtsSize = 12;
	specs.backPts = {specs.backPtsSize,...
		'MarkerEdgeAlpha',0.65,...
		'MarkerFaceAlpha',0.65};
	specs.backLines = {
		'LineWidth',1.1 ...
		};
	specs.line= {...
		'MarkerSize',6,...
		'LineStyle','-',...
		'LineWidth',2.0};
	specs.ax = {...
		'LineWidth',axLineWidth,...
		'FontSize',fontSize-0.5,...
		'FontName',fontName,...
		...'GridColor',[0.95,0.95,0.95],...
		...'Color',[1 1 1],...
 		'GridColor',[1,1,1],...
		'Color',[.97 .97 .97],...
 		'YGrid','on',...
		'XGrid','on',...
		'GridLineStyle','-',...
		'GridAlpha',1,...
		...'TickLabelRotation',0,...
		'ColorOrder',Colors.Fig.Cats.Speeds4
		};
	specs.rocAx = {...
		'LineWidth',axLineWidth,...
		'FontSize',15,...
		'FontName',fontName,...
		'GridColor',[.925 .925 .925],...
		...'GridColor',[.9 .9 .9],...
		...'GridColor',[1,1,1],...
		'Color',[1 1 1],...
		...'Color',[.97 .97 .97],...
		'YGrid','on',...
		'XGrid','on',...
		'GridLineStyle','-',...
		'GridAlpha',1,...
		'box','on',...
		'ColorOrder',Colors.Fig.Cats.Components4
		};
	specs.rocSubTit = {
		'FontSize',fontSize+2.5,...
		'FontName',fontName,...
		'FontWeight','normal'
	};
	specs.rocDiag = {
		'LineStyle','-',...
		...'Color',[0.8906,0.1016,0.1094,0.5],...
		'Color',[.5 .5 .5],...
		'LineWidth',1.75 ...
		};
	specs.axTick = {
		'TickDirection', 'out',...
		'TickLength',[0.015,0.015] ...
		};
	specs.axSpecTick = {
		'TickDirection', 'out',...
		'TickLength',[0.025,0] ...
		};
	specs.subPlt = {
		'ColorOrder',Colors.Fig.Cats.Speeds4,...
		'Units','points',...
		'Nextplot','add' ...
		};
	specs.titBox = {
		...'BackgroundColor',[0.97,0.97,0.97], ...
		'BackgroundColor',[1 1 1], ...
		'HorizontalAlignment','center',...
		'Units','points',...
		'VerticalAlignment','baseline',...
		'FontSize',fontSize+2.5,...
		'FontName',fontName,...
		'FontWeight','normal',...
		'Margin',4,...
		'EdgeColor','none',...
		'Color',labelColor
		};
	specs.sepBox = {
		...'BackgroundColor',[0.95,0.95,0.95], ...
		'BackgroundColor',[1 1 1], ...
		'Units','points',...
		'EdgeColor','none'
		};
	specs.text = {
		'LineWidth',1.5,...
		'FontSize',fontSize,...
		'FontName',fontName,...
		};
	specs.rocText = {
		specs.text{:}, ...
		'FontSize',fontSize+2.5 ...
		};
	specs.leg = {
		'Box','off',...
		'Units','points',...
		'Location','southeastoutside',...
		'FontName',fontName,...
		'FontSize',fontSize,...
		'Color',[0.15 0.15 0.15],...
		'FontWeight','normal'
		};
	specs.legTit = {
		'FontWeight','bold',...
		'FontName',fontName,...
		'Color',labelColor
		};
	specs.supTit = {
		'FontName',fontName,...
		'FontSize',fontSize+3,...
		'Color',labelColor
		};
	specs.subTit = {
		'Units','points',...
		'FontWeight','normal',...
		'FontSize',fontSize+2.5,...
		'FontName',fontName,...
		'Color',labelColor
		};
	specs.yLab = {
		'Units','points',...
		'Color',[0.15 0.15 0.15],...
		'FontWeight','normal',...
		'FontSize',fontSize,...
		'FontName',fontName,...
		'Color',labelColor
		};
	specs.xLab = {
		'Units','points',...
		'FontSize',fontSize,...
		'FontName',fontName,...
		'Color',labelColor,...
		'FontWeight','normal'
		};
	specs.supXLab = {
		specs.xLab{:},...
		'FontSize',fontSize+2.5,...
		}; %#ok<*CCAT> 
	specs.effIntervAx = {
		'LineWidth',3,...
		'FontSize',fontSize,...
		'FontName',fontName,...
		'Color',[.965 .965 .965],...
		'YGrid','on',...
		'XGrid','off',...
		'GridLineStyle','-',...
		'GridColor',[1,1,1],...
		'GridAlpha',1
		};
	specs.xline = {
		'LineWidth',axLineWidth,...
		'Color',[1 1 1,1],...
		'Alpha',0.6 ,...
		'LabelOrientation','horizontal',...
		'LabelVerticalAlignment','bottom',...
		'LabelHorizontalAlignment','right',...
		'FontSize',fontSize-1
		};
	specs.weakXline = {
		specs.xline{:},...
		'LineWidth',axLineWidth-1,...
		'Alpha', 0.3
		};
	specs.colorBar = {
		'Box','off', ...
		'FontSize',fontSize-2, ...
		'Units','Points' ...
		};
	specs.numeral = {
		specs.text{:},...
		'Color',[0 0 0],...
		'FontSize',24,...
		'VerticalAlignment','bottom'...
		'Units','Points'
		};
	specs.asterix = {
		specs.text{:},...
		'FontSize',fontSize+1.5};

	% For sequence parts plot of spectrogram and time domain curves
	% -------------------------------------------------------------
	specs.sequence_parts.leg_yGap = 0.005;
    specs.sequence_parts.leg_xPos = 0.85;
    specs.sequence_parts.yLab_xPos = -0.058;
    specs.sequence_parts.yyLab_xPos = 1.039;
    specs.sequence_parts.baseline_title = {
        'Units','data',...
        'HorizontalAlignment','center',...
        'FontSize',11,...
        'FontWeight','bold'};
    specs.sequence_parts.event_bar = {
        'LineStyle','-',...
        'LineWidth',7,...
        'Marker','none',...
        'Color', [.85 .85 .85]};
    specs.sequence_parts.bal_lev_bar = {
        'LineStyle','-',...
        'LineWidth',7,...
        'Marker','none',...
        'Color', [0.96,0.68,0.68]};
    specs.sequence_parts.trans_lev_bar = {
        'LineStyle',':',...
        'LineWidth',1.5,...
        'Marker','none',...
        'Color', [.7 .7 .7]};
    specs.sequence_parts.leg = {
        'EdgeColor','none',...
        'Box','off',...
        'FontSize',11};
    specs.sequence_parts.leg_title = {
        'FontSize',11};
    specs.sequence_parts.yLab = {
        'Interpreter','tex',...
        'Units','normalized',...
        'FontSize',11};