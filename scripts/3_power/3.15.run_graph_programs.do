///////////////////////////////////////////////////////////////////////////////
// Start an excel file for output 
putexcel set "$table_results_path/mde_tot.xlsx", sheet(mde_tot) replace
local numb = 1
putexcel A`numb' = "Name"
putexcel B`numb' = "MDE"
putexcel C`numb' = "MDE_LL"
putexcel D`numb' = "MDE_UL"
putexcel E`numb' =  "Ratio"

// Start on the second row of the excel sheet that is storing the results.
local numb = 2

////////////////////////////////////////////////////////////////////
// County level
////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////
	// power_analysis_dd

	// Baseline
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// Baseline with different pre-treatment years
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2007) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2004) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline - without controls
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(no) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	//  Baseline - county clustering 
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(id) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - pop weights
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(pop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		


		
	////////////////////////////////////////////////////////////////////
	// power_analysis_ddd

	// Baseline 
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline with different pre-periods
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2004) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2007) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline - without controls
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(no) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	//  Baseline - county clustering 
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(id) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - pop weights
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(pop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		


		
		
	////////////////////////
	// Subgroups

	// black
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(black_non_hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// white
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(white_non_hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// hispanic
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.2) ///
		step_size(.01) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// female
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(fem_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	//male	
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(male_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// cardiac deaths
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(card) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// hiv deaths		
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(hiv) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// diabetes deaths		
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(dia) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// respiratory deaths				
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(resp) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	// cancer deaths				
	power_graph, ///
		program_name(power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(can) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	////////////////////////////////////////////////////////////////////////
	// DDD
	
	// black
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(black_non_hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline - only looking at white non-hispanics
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(white_non_hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - only looking at hispanics
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.2) ///
		step_size(.01) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline - only looking at men
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(male) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - only looking at women
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(fem) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - Cancer deaths
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(can) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - Cardiac deaths
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(card) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - HIV deaths
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(hiv) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		

	// Baseline - Diabetes deaths
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(dia) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
		
	// Baseline - Respiratory deaths
	power_graph, ///
		program_name(power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(resp) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
		
		local numb = `numb' + 1
		
	
////////////////////////////////////////////////////////////////////	
// State-level
////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////
	// st_power_analysis_dd

	// Baseline
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		

	// Baseline- 2004
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2004) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	
	// Baseline - 2007
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2007) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	// Baseline - without controls
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(no) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline - pop weights
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(pop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	


	////////////////////////////////////////////////////////////////////
	// st_power_analysis_ddd
	////////////////////////////////////////////////////////////////////


	// Baseline
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline- 2004
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2004) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	
	// Baseline- 2007
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2007) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	
	// Baseline - without controls
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(no) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		

	
	// Baseline - pop weights
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(pop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1		
	
	// Baseline - only looking at black non-hispanics
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(black_non_hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		

	// Baseline - only looking at white non-hispanics
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(white_non_hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline - only looking at hispanics
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(hisp) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		

	// Baseline - only looking at men
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(male) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline - only looking at women
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(fem) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	
	// Baseline - Cancer deaths
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(can) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	
	// Baseline - Cardiac deaths
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(card) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline - HIV deaths
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(hiv) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			

	// Baseline - Diabetes deaths
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(dia) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// Baseline - Respiratory deaths
	power_graph, ///
		program_name(st_power_analysis_ddd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(resp) ///
		dem_type(none) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	
	// black
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(black_non_hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// white
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(white_non_hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// hispanic
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.2) ///
		step_size(.01) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(hisp_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// female
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(fem_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	// male
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(amen) ///
		dem_type(male_55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
		
	// cardiac
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(card) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// hiv
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(hiv) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// diabetes	
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(dia) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
			
	// respiratory
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(resp) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1
		
	// cancer
	power_graph, ///
		program_name(st_power_analysis_dd) ///
		end_value(.12) ///
		step_size(.005) ///
		max_dataset_number(1000) ///
		first_year(2001) ///
		last_year(2010) ///
		death_type(can) ///
		dem_type(55_64) ///
		list_of_controls(yes) ///
		weight_var(attpop) /// 
		cluster_var(state) ///
		prefix(ln) ///
		alpha(05) ///
		power(80) ///
		bootstrap_reps(1000) /// 
		graph_effect_size_max(8) /// 
		graph_effect_size_step (2) /// 
		graph_subtitle(" ") ///
		numb(`numb')
			
		local numb = `numb' + 1

	////////////////////////////////////////////////////////////////////
	// control_only
	
	// County
		// DD
		power_graph, ///
			program_name(control_only_power_analysis_dd) ///
			end_value(.12) ///
			step_size(.005) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(55_64) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
			local numb = `numb' + 1
			
		// DDD
		power_graph, ///
			program_name(control_only_power_analysis_ddd) ///
			end_value(.12) ///
			step_size(.005) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(none) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
			local numb = `numb' + 1	
	// State
		// DD
		power_graph, ///
			program_name(st_cntrl_only_power_analysis_dd) ///
			end_value(.12) ///
			step_size(.005) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(55_64) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
				
			local numb = `numb' + 1
				

		// DDD
		power_graph, ///
			program_name(st_cntrl_only_power_analysis_ddd) ///
			end_value(.12) ///
			step_size(.005) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(none) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
				
			local numb = `numb' + 1
			


	////////////////////////////////////////////////////////////////////
	// simp_synth

	// County
		// DD
		power_graph, ///
			program_name(simp_synth_power_analysis_dd) ///
			end_value(.2) ///
			step_size(.01) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(55_64) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
			local numb = `numb' + 1
		
		// DDD
		power_graph, ///
			program_name(simp_synth_power_analysis_ddd) ///
			end_value(.2) ///
			step_size(.01) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(none) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
			local numb = `numb' + 1
				
	// State
		// DD
		power_graph, ///
			program_name(st_simsynth_power_analysis_dd) ///
			end_value(.2) ///
			step_size(.01) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(55_64) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
		local numb = `numb' + 1
			
			

		// DDD
		power_graph, ///
			program_name(st_simsynth_power_analysis_ddd) ///
			end_value(.2) ///
			step_size(.01) ///
			max_dataset_number(1000) ///
			first_year(2003) ///
			last_year(2013) ///
			death_type(amen) ///
			dem_type(none) ///
			list_of_controls(yes) ///
			weight_var(attpop) /// 
			cluster_var(state) ///
			prefix(ln) ///
			alpha(05) ///
			power(80) ///
			bootstrap_reps(1000) /// 
			graph_effect_size_max(8) /// 
			graph_effect_size_step (2) /// 
			graph_subtitle(" ") ///
			numb(`numb')
			
			local numb = `numb' + 1





