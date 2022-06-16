
///////////////////////////////////////////////////////////////////////////////
// Create program to make main table for 55-64 DD, 65-74 DD, and DDD. 

capture program drop combined_regression_results

// *----------
program define combined_regression_results
syntax, ///
	weight_var(string) /// 
	weight_label(string) /// 
	y_var_prefix(string) ///   
	cluster_var(string) ///
	file_name_suffix(string) ///
	first_year(real)  ///
	last_year(real)  ///
	last_treated_year(real)  ///
	first_treated_year(real) /// 
	low_event_cap(real) ///
	high_event_cap(real) ///
	list_of_controls(string)
	
	///////////////////////////////////////////////////////////////////////////////
	// Load county level results into memory
	clear all

	// Foreach death type
	foreach death_type in amen namen any  {	
		// For each age	
		foreach age in 55_64 65_74 ddd {
			est use "$table_results_path/`y_var_prefix'_`death_type'_`age'_nc.ster"
			est sto ln_`death_type'_`age'_nc
			est use "$table_results_path/`y_var_prefix'_`death_type'_`age'_c.ster"
			est sto ln_`death_type'_`age'_c
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////
	// Load state-level results into memory

	// Foreach death type
	foreach death_type in amen namen any  {	
		// For each age	
		foreach age in 55_64 65_74 ddd {
			est use "$table_results_path/state_`y_var_prefix'_`death_type'_`age'_nc.ster"
			est sto state_ln_`death_type'_`age'_nc
			est use "$table_results_path/state_`y_var_prefix'_`death_type'_`age'_c.ster"
			est sto state_ln_`death_type'_`age'_c
		}
	}

	
	

	////////////////////////////////////////////////////////////////////////
	// Export results

		esttab ///
			state_`y_var_prefix'_amen_55_64_nc state_`y_var_prefix'_amen_55_64_c ///
			state_`y_var_prefix'_amen_65_74_nc state_`y_var_prefix'_amen_65_74_c ///
			state_`y_var_prefix'_amen_ddd_nc state_`y_var_prefix'_amen_ddd_c ///
			`y_var_prefix'_amen_55_64_nc `y_var_prefix'_amen_55_64_c ///
			`y_var_prefix'_amen_65_74_nc `y_var_prefix'_amen_65_74_c ///
			`y_var_prefix'_amen_ddd_nc `y_var_prefix'_amen_ddd_c ///
			using "$table_results_path/combined_regression_results_`file_name_suffix'.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				ddd_b_str ddd_se_str ///
				, fmt(0 0 ///
					  0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
				"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ) ///
				label("\emph{Healthcare amenable mortality} &&&&&\\ \addlinespace  \hspace{0.5cm}Full expansion dummy" "\vspace{.25cm}~" ///
					"\hspace{0.5cm}Full expansion dummy x Age 55-64 dummy"  "\vspace{.25cm}~")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				replace  ///
				nomtitles ///
				mgroups("\shortstack{DD\\ 55-64 years}" "\shortstack{DD\\ 65-74 years}" "\shortstack{DDD\\\textcolor{white}{55-64 years}}" "\shortstack{DD\\ 55-64 years}" "\shortstack{DD\\ 65-74 years}" "\shortstack{DDD\\\textcolor{white}{55-64 years}}", pattern(1 0 1 0 1 0 1 0 1 0 1 0) prefix(\multicolumn{2}{c}{\underline{\smash{~) suffix(~}}})  span) ///
				prehead( "&\multicolumn{6}{c}{State-level}&\multicolumn{6}{c}{County-level}\\ \cmidrule(l){2-7} \cmidrule(l){8-13} &\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}\\ ")
		

		esttab ///
			state_`y_var_prefix'_namen_55_64_nc state_`y_var_prefix'_namen_55_64_c ///
			state_`y_var_prefix'_namen_65_74_nc state_`y_var_prefix'_namen_65_74_c ///
			state_`y_var_prefix'_namen_ddd_nc state_`y_var_prefix'_namen_ddd_c ///
			`y_var_prefix'_namen_55_64_nc `y_var_prefix'_namen_55_64_c ///
			`y_var_prefix'_namen_65_74_nc `y_var_prefix'_namen_65_74_c ///
			`y_var_prefix'_namen_ddd_nc `y_var_prefix'_namen_ddd_c ///
			using "$table_results_path/combined_regression_results_`file_name_suffix'.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				ddd_b_str ddd_se_str ///
				, fmt(0 0 ///
					  0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
				"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ) ///
				label("\emph{Non-amenable mortality} &&&&&\\ \addlinespace  \hspace{0.5cm}Full expansion dummy" "\vspace{.25cm}~" ///
									"\hspace{0.5cm}Full expansion dummy x age 55-64 dummy"  "\vspace{.25cm}~")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///		
				append  ///
				nomtitles noline nonumbers	
				
		esttab ///
			state_`y_var_prefix'_any_55_64_nc state_`y_var_prefix'_any_55_64_c ///
			state_`y_var_prefix'_any_65_74_nc state_`y_var_prefix'_any_65_74_c ///
			state_`y_var_prefix'_any_ddd_nc state_`y_var_prefix'_any_ddd_c ///
			`y_var_prefix'_any_55_64_nc `y_var_prefix'_any_55_64_c ///
			`y_var_prefix'_any_65_74_nc `y_var_prefix'_any_65_74_c ///
			`y_var_prefix'_any_ddd_nc `y_var_prefix'_any_ddd_c ///
			using "$table_results_path/combined_regression_results_`file_name_suffix'.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				ddd_b_str ddd_se_str ///
				pop_weights county_fe year_fe controls ///
				N  ///
				, fmt(0 0 ///
					  0 0 ///
				0 0 0 0 ///
				0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}") ///
				label("\emph{All Mortality} &&&&&\\ \addlinespace  \hspace{0.5cm}Full expansion dummy" "\vspace{.25cm}~" ///
						"\hspace{0.5cm}Full expansion dummy x Age 55-64 dummy"  "\vspace{.25cm}~" ///
					" \addlinespace \hline Weights" "Unit fixed-effects (state or county)" "Year fixed-effects" "Covariates" ///
					"\hline Observations")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				append  ///
				nomtitles nonumbers noline 	
	
end


// ATTxPop - State Cluster
combined_regression_results, ///
	weight_var(attpop) /// 
	weight_label(ATTxPop) /// 
	y_var_prefix(ln) ///   
	cluster_var(state) ///
	file_name_suffix(combined_ln_amenable_attpop) ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")
