function R = compile_results_table_G1B2(R, R_rel)
	% One sorted and combined results table with absolute and relative results

	levSortOrder = {
		'RPM, 2400, Nominal'
		'RPM, 2400, Nominal #2'
		'RPM, 2200, Nominal'
		'RPM, 2200, Nominal #2'
		'RPM, 2600, Nominal'
		'RPM, 2600, Nominal #2'
		'Clamp, 2400, Nominal'
		'Clamp, 2400, 25%'
		'Clamp, 2400, 50%'
		'Clamp, 2400, 75%'
		'Clamp, 2400, Reversal'
		'Balloon, 2400, Nominal'
		'Balloon, 2400, Lev1'
		'Balloon, 2400, Lev2'
		'Balloon, 2400, Lev3'
		'Balloon, 2400, Lev4'
		'Balloon, 2400, Lev5'
		'Balloon, 2400, Reversal'
		'Balloon, 2200, Nominal'
		'Balloon, 2200, Lev1'
		'Balloon, 2200, Lev2'
		'Balloon, 2200, Lev3'
		'Balloon, 2200, Lev4'
		'Balloon, 2200, Lev5'
		'Balloon, 2200, Reversal'
		'Balloon, 2600, Nominal'
		'Balloon, 2600, Lev1'
		'Balloon, 2600, Lev2'
		'Balloon, 2600, Lev3'
		'Balloon, 2600, Lev4'
		'Balloon, 2600, Lev5'
		'Balloon, 2600, Reversal'
		};

	relVars = {
		'Q_LVAD_mean'
		'P_LVAD_mean'
		'Q_mean'
		'accB_xyz_NF_b2_pow_norm'
		};

	R.levelLabel = categorical(R.levelLabel, levSortOrder, 'Ordinal',true);
	R_rel.levelLabel = categorical(R_rel.levelLabel, levSortOrder, 'Ordinal',true);

	% Sort according to ordinal order
	R = sortrows(R, {'levelLabel'});
	R_rel = sortrows(R_rel, {'levelLabel'});
	
	R_rel = convert_to_percent(R_rel, relVars);
	R = [R,R_rel];
	R = movevars(R,'GroupCount','After','levelLabel');
	
function T = convert_to_percent(R_rel, relVars)
	T = split(R_rel{:,relVars});
	P1 = string(100*double(T(:,:,1)));
	P2 = "["+100*double(erase(T(:,:,2),{'[',']'}))+"]";
	T = P1+" "+P2+" "+T(:,:,3);
	T = table(T);
	T = splitvars(T,'T','NewVariableNames',relVars+"_rel");
	