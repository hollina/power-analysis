
	///////////////////////////////////////////////////////////////////////////////
	// Reload results into memory
	clear all

	// Foreach death type
	foreach death_type in any amen namen resp can card hiv dia {
		// For each age	
		foreach age in 55_64 65_74 ddd {
			est use "$table_results_path/ln_`death_type'_`age'_c.ster"
			est sto ln_`death_type'_`age'_c

			est use "$table_results_path/state_ln_`death_type'_`age'_c.ster"
			est sto state_ln_`death_type'_`age'_c
			
		}
	}

	// Foreach death type
	foreach age in 55_64 65_74 ddd {
		foreach dem_group in male fem white_non_hisp black_non_hisp hisp {
		// For each age	
		
			est use "$table_results_path/ln_amen_`dem_group'_`age'_c.ster"
			if "`dem_group'" == "white_non_hisp" { 
				local dem_group white
			}
			if "`dem_group'" == "black_non_hisp" { 
				local dem_group black
			}
			est sto ln_amen_`dem_group'_`age'_c


		}
	}
	
// Foreach death type
	foreach age in 55_64 65_74 ddd {
		foreach dem_group in male fem white_non_hisp black_non_hisp hisp {
		// For each age	
			est use "$table_results_path/state_ln_amen_`dem_group'_`age'_c.ster"
			if "`dem_group'" == "white_non_hisp" { 
				local dem_group white
			}
			if "`dem_group'" == "black_non_hisp" { 
				local dem_group black
			}
			est sto state_ln_amen_`dem_group'_`age'_c
}
}



	////////////////////////////////////////////////////////////////////////
	// Export results

		esttab ///
			state_ln_amen_55_64_c ///
			state_ln_amen_65_74_c ///
			state_ln_amen_ddd_c ///
			ln_amen_55_64_c ///
			ln_amen_65_74_c ///
			ln_amen_ddd_c ///
			using "$table_results_path/combined_appendix_regression_results.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				, fmt(0 0 ) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("Healthcare amenable mortality" "\vspace{.25cm}~")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				replace  ///
				nomtitles ///
				mgroups("\shortstack{DD\\ 55-64}" "\shortstack{DD\\ 65-74}" "\shortstack{DDD\\\textcolor{white}{55-64}}" "\shortstack{DD\\ 55-64}" "\shortstack{DD\\ 65-74}" "\shortstack{DDD\\\textcolor{white}{55-64}}", pattern(1 1 1 1 1 1) prefix(\multicolumn{1}{c}{\underline{\smash{~) suffix(~}}})  span) ///
				prehead( "&\multicolumn{3}{c}{State-level}&\multicolumn{3}{c}{County-level}\\ \cmidrule(l){2-4} \cmidrule(l){5-7} &\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}\\ ")
		
		
	foreach death_type in  namen any resp can card hiv dia  {
		if "`death_type'" == "namen" {
			local lbl "Non-amenable mortality"
		}
		if "`death_type'" == "any" {
			local lbl "All mortality"
		}
		if "`death_type'" == "resp" {
			local lbl "Respiratory mortality"
		}
		if "`death_type'" == "can" {
			local lbl "Cancer mortality"
		}
		if "`death_type'" == "card" {
			local lbl "Cardiac mortality"
		}
		if "`death_type'" == "hiv" {
			local lbl "HIV mortality"
		}
		if "`death_type'" == "dia" {
			local lbl "Diabetes mortality"
		}
		esttab ///
			 state_ln_`death_type'_55_64_c ///
			 state_ln_`death_type'_65_74_c ///
			 state_ln_`death_type'_ddd_c ///
			 ln_`death_type'_55_64_c ///
			 ln_`death_type'_65_74_c ///
			 ln_`death_type'_ddd_c ///
			using "$table_results_path/combined_appendix_regression_results.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				, fmt(0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("`lbl'" "\vspace{.25cm}~")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///		
				append  ///
			nomtitles noline nonumbers	
	}
	foreach dem_group in   male fem white black   {
		if "`dem_group'" == "male" {
			local lbl "Male, amenable mortality"
		}
		if "`dem_group'" == "fem" {
			local lbl "Female, amenable mortality"
		}
		if "`dem_group'" == "white" {
			local lbl "White, amenable mortality"
		}
		if "`dem_group'" == "black" {
			local lbl "Black, amenable mortality"
		}
		if "`dem_group'" == "hisp" {
			local lbl "Hispanic, amenable mortality"
		}
	
		esttab ///
			 state_ln_amen_`dem_group'_55_64_c ///
			 state_ln_amen_`dem_group'_65_74_c ///
			 state_ln_amen_`dem_group'_ddd_c ///
			 ln_amen_`dem_group'_55_64_c ///
			 ln_amen_`dem_group'_65_74_c ///
			 ln_amen_`dem_group'_ddd_c ///
			using "$table_results_path/combined_appendix_regression_results.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				, fmt(0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("`lbl'" "\vspace{.25cm}~")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///		
				append  ///
			nomtitles noline nonumbers	
	}	
	
	
		
		esttab ///
			 state_ln_amen_hisp_55_64_c ///
			 state_ln_amen_hisp_65_74_c ///
			 state_ln_amen_hisp_ddd_c ///
			 ln_amen_hisp_55_64_c ///
			 ln_amen_hisp_65_74_c ///
			 ln_amen_hisp_ddd_c ///
			using "$table_results_path/combined_appendix_regression_results.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				pop_weights county_fe year_fe controls ///
				, fmt(0 0 ///
					  0 0 ///
				0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("Hispanic, amenable mortality" "\vspace{.25cm}~" ///
					" \addlinespace \hline Weights" "Unit fixed-effects (state or county)" "Year fixed-effects" "Covariates")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				append  ///
				nomtitles nonumbers noline 	
	
