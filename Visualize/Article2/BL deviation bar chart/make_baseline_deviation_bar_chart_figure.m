function make_baseline_deviation_bar_chart_figure(...
		G_rel, aggType, vars, cats, Config, saveFig)

	hFig = figure('Position',[150,150,1200,700]);
	hold on

	switch aggType
		case 'median'
			D = G_rel.med;
			U = G_rel.q3;
			L = G_rel.q1;
		case 'mean'
			D = G_rel.avg;
			U = G_rel.std;
			L = G_rel.std;
		otherwise
			error('aggType input must be ''median'' or ''mean''')
	end

	Colors_IV2
	spec = get_plot_specs;

	nGroups = size(vars,1);
	nCats = size(cats,1);
	Y = nan(nCats,nGroups);
	for j=1:nGroups
		for i=1:nCats
			ind = D.levelLabel==cats(i,1);
			Y(i,j) = D{ind,vars{j,1}};
		end
	end
	hBar = bar(Y,'Horizontal','off','BarWidth',0.9,'FaceAlpha',.95,'LineWidth',1,'EdgeColor','none');
	
	hAx = hBar.Parent;
	hAx.Position = [.1, .12, .7, .8];
	yticks(-1:0.25:hAx.YLim(2))
	yticklabels(hAx.YTick*100);
	hYLab = ylabel('Baseline deviation (%)',...
		'FontSize',16);
	hYLab.Position(1) = -0.13;

	hAx.XTickLabel = cats(:,2);
	hAx.XTickLabelRotation = 0;
	set(hAx,spec.ax{:},'XGrid','off','GridLineStyle','-','TickDir','out',...
		'Color',[1 1 1],'FontSize',14, 'LineWidth',1.5)
	hAx.ColorOrder = Colors.Fig.Cats.Components4([1 2 4],:);
	hLeg = legend(hBar, vars(:,2), 'Location', 'NorthWest', spec.leg{:},'FontSize',14);
	hLeg.Position = [750,hAx.Position(2),162,64];

	% xline(hAx,1.5:1:3.5,'HandleVisibility','off','Color',[.97 .97 .97 1],'LineWidth',hAx.LineWidth)
	% xline(hAx,5.5:1:8.5,'HandleVisibility','off','Color',[.97 .97 .97 1],'LineWidth',hAx.LineWidth)
	%xline(hAx,3.5,'HandleVisibility','off','Color',[.75 .75 .75 1],'LineWidth',hAx.LineWidth,LineStyle='--')
	plot([3.5,3.5],[-1.2,1.99],'LineStyle','--','Color',[.75 .75 .75 1],'LineWidth',hAx.LineWidth,'HandleVisibility','off','Clipping','off')
	ylim([-0.9,1.98])
	hAx.GridColor = [.97 .97 .97];
	hAx.XAxis.TickLength = [0,0];
	
	add_titles_and_labels(hFig);
	%grid off
	%yline(hAx.YTick(2:end-1),'Color',[1 1 1 .1],'LineWidth',1,'HandleVisibility','off')

	if saveFig
		sPath = fullfile(Config.fig_path,'BL deviation bar chart');
		fileName = ['BL deviation bar chart - ',aggType,' - [',strjoin(vars(:,1),', '),']'];
		save_figure(hFig, sPath, fileName, 300);
	end
end