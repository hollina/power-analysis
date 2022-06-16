///////////////////////////////////////////////////////////////////////////////
// Write a program to do this in a loop for a bootstrapped sample.
capture program drop power_est
program power_est, rclass
	syntax, ///
		alpha(string) ///
		power(real) ///
		file_name(string) ///
		end_value(real) ///
		step_size(real)
		
	// Suppress all output
	quietly{
	
		// Create the list 
		local step_macro 
		forvalues x = 0(`step_size')`end_value' {
			local step_macro `step_macro'  `x'
		}
		di "`step_macro'"

		// Determine the length of the macro 
		local num :  word count `step_macro'
		local max_steps = `num'
		di `max_steps'
		
		// Import relevant data
		use "$file_path_power_data_combined/`file_name'.dta", clear
		
		// Take a bootstrapped sample
		bsample

		// Calculate power for a given alpha
		local counter = 1
		
			foreach x in `step_macro' {
				// Calculate indicator for power threshold for an observation
				gen power_`alpha'_`counter' = 0
				
				replace power_`alpha'_`counter' = 1 if p_storage`counter' <= .`alpha'
				
				// Move the counter one forward
				local counter = `counter' + 1 
			}
			
		// Calculate a count variable
		gen count = 1
		
		// Collapse by effect size
		gcollapse (sum) count power_* 

		reshape long ///
			power_`alpha'_@ , ///
			i(count) j(effect_size)

		
		// Remove hanging _
		rename *_ *

		// Turn into a percent
		qui ds power_*
		foreach x in `r(varlist)' {
			replace `x' = (`x'/count)*100
		}

		// Fix effect size 
			local counter = 1
			foreach x in `step_macro' {
				replace effect_size = `x'*100 in `counter'
			// Move the counter one forward
			local counter = `counter' + 1 	
			}

		// Drop unneeded variables
		drop count 
				
		// Create a variable that is the gap between desired power level and closest estimates
		capture drop gap
		gen  gap = abs(`power'-power_`alpha')
		
		// Sort on this variable
		sort gap 
		
		// Run a regression on the two closest observations
		qui reg power_`alpha' effect_size in 1/2
		
		// Predict MDE using these two points
		return scalar mde = (`power'-_b[_cons])/_b[effect_size]	
	}
end



///////////////////////////////////////////////////////////////////////////////
// Write a program to do this in a loop for a bootstrapped sample.
capture program drop power_graph
program power_graph
	syntax, ///
		program_name(string) ///
		end_value(real) ///
		step_size(real) ///
		max_dataset_number(real) ///
		first_year(real) ///
		last_year(real) ///
		death_type(string) ///
		dem_type(string) ///
		list_of_controls(string) ///
		weight_var(string) /// 
		cluster_var(string) ///
		prefix(string) ///
		alpha(string) ///
		power(real) ///
		bootstrap_reps(real) /// 
		graph_effect_size_max(real) /// 
		graph_effect_size_step (real) /// 
		graph_subtitle(string) ///
		numb(real)

	// Clear memory
	clear

	// Create the list of all effect sizes
	local step_macro 
	forvalues x = 0(`step_size')`end_value' {
		local step_macro `step_macro'  `x' 
	}
	di "`step_macro'"

	// Determine the length of the macro 
	local num :  word count `step_macro'
	local max_steps = `num'
	di `max_steps'

	// Create file name based on program

		// Reset file_name to avoid issues incase there is an error in logic below
		local file_name ""

		// Type 1: County - DD
			if "`program_name'" == "power_analysis_dd" {

				local file_name dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 2: County - DDD
			if "`program_name'" == "power_analysis_ddd" {
			
				local file_name ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 3: State - DD
			if "`program_name'" == "st_power_analysis_dd" {
			
				local file_name st_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}	

		// Type 4: State - DDD
			if "`program_name'" == "st_power_analysis_ddd" {

				local file_name st_ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 5: County - DD - Only control states - Include post-expansion data
			if "`program_name'" == "control_only_power_analysis_dd" {

				local file_name control_only_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 6: County - DDD - Only control states - Include post-expansion data
			if "`program_name'" == "control_only_power_analysis_ddd" {

				local file_name control_only_ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 7: State - DD - Only control states - Include post-expansion data
			if "`program_name'" == "st_cntrl_only_power_analysis_dd" {

				local file_name st_control_only_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 8: State - DDD - Only control states - Include post-expansion data
			if "`program_name'" == "st_cntrl_only_power_analysis_ddd" {
			
				local file_name st_control_only_ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 9: County - DD - Entirely simulated death data - Include post-expansion data
			if "`program_name'" == "simp_synth_power_analysis_dd" {

				local file_name simp_synth_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 10: County - DDD - Entirely simulated death data - Include post-expansion data
			if "`program_name'" == "simp_synth_power_analysis_ddd" {

				local file_name simp_synth_ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 11: State - DD - Entirely simulated death data - Include post-expansion data
			if "`program_name'" == "st_simsynth_power_analysis_dd" {

				local file_name st_simp_synth_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}

		// Type 12: State - DDD - Entirely simulated death data - Include post-expansion data
			if "`program_name'" == "st_simsynth_power_analysis_ddd" {

				local file_name st_simp_synth_ddd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
			}


	// Import relevant data from power analysis
	import delimited "$file_path_power_data_raw/b_storage_`file_name'.csv", clear
	compress
	save "$file_path_power_data_combined/temp_b_storage.dta", replace
	import delimited "$file_path_power_data_raw/p_storage_`file_name'.csv", clear
	compress
	save "$file_path_power_data_combined/temp_p_storage.dta", replace
	import delimited "$file_path_power_data_raw/se_storage_`file_name'.csv", clear
	compress
	merge 1:1 _n using "$file_path_power_data_combined/temp_b_storage.dta"
	drop _merge
	erase  "$file_path_power_data_combined/temp_b_storage.dta"
	merge 1:1 _n using "$file_path_power_data_combined/temp_p_storage.dta"
	drop _merge
	erase  "$file_path_power_data_combined/temp_p_storage.dta"

	// Save power data
	compress
	save "$file_path_power_data_combined/`file_name'.dta", replace

	// Calculate power for a chosen alpha
	local counter = 1

		foreach x in `step_macro' {
			// Calculate indicator for power threshold for an observation
			gen power_`alpha'_`counter' = 0
			
			replace power_`alpha'_`counter' = 1 if p_storage`counter' <= .`alpha'
			
			// Move the counter one forward
			local counter = `counter' + 1 
		}
		
	// Calculate a count variable
	gen count = 1

	// Collapse by effect size
	gcollapse (sum) count power_* 

	// Reshape data so each observation is effect size
	reshape long ///
		power_`alpha'_@ , ///
		i(count) j(effect_size)

	// Remove hanging _
	rename *_ *

	// Turn into a percent
	qui ds power_*
	foreach x in `r(varlist)' {
		replace `x' = (`x'/count)*100
	}

	// Fix effect size 
	local counter = 1
	foreach x in `step_macro' {
		replace effect_size = `x'*100 in `counter'
	// Move the counter one forward
	local counter = `counter' + 1 	
	}

	// Drop unneeded variables
	drop count 
			
	// Create a variable that is the gap between desired power level and closest estimates
	capture drop gap
	gen  gap = abs(`power'-power_`alpha')

	// Sort on this variable
	sort gap 

	// Run a regression on the two closest observations
	qui reg power_`alpha' effect_size in 1/2

	// Predict MDE using these two points and save as a matrix
	mat mde = (`power'-_b[_cons])/_b[effect_size]	
			

	// Run this program N times
	simulate mde = r(mde), reps(`bootstrap_reps') seed(1234): power_est, ///
		alpha(`alpha') ///
		power(`power') ///
		file_name(`file_name') ///
		end_value(`end_value') ///
		step_size(`step_size')
		
	// Show bootstrapped estimate, standard error, and 95%CI
	bstat, stat(mde) n(1000)

	// Show a few other 95% CIs
	estat bootstrap, all
	mat ci_95 = e(ci_normal)

	// Turn MDE and 95% CI into rounded scalars
	scalar mde_scalar = round(mde[1,1], .01)
	di mde_scalar

	scalar mde_95_low_scalar = round(ci_95[1,1], .01)
	di mde_95_low_scalar

	scalar mde_95_high_scalar = round(ci_95[2,1], .01)
	di mde_95_high_scalar



	///////////////////////////////////////////////////////////////////////////////
	// Histogram of MDE

	// Local macro for MDE
	local mde = mde_scalar
	local mde_ll = mde_95_low_scalar
	local mde_ul = mde_95_high_scalar

	// Determine max height
	capture drop h
	capture drop x
	twoway__histogram_gen mde, gen(h x)
	sum h
	local max_height = `r(max)'*1.25
	local mde_label_height = `r(max)'*1.2
	*local ci_label_height = `r(max)'*1.15

	twoway ///
		|| hist mde ///
		|| scatteri 0 `mde' `max_height' `mde', recast(line) lcol(gs7) lp("_") lwidth(1) ///
		xtitle("Minimum detectable effect size for `power'% power and `alpha'% significance level", size(4)) ///
		ytitle("") ///
		title("Histogram of estimated minimum detectable effect size across `bootstrap_reps' bootstrap draws", pos(11) size(4)) ///
		subtitle("`graph_subtitle'", pos(11) size(3)) ///
		yla(none , nogrid notick labsize(6)) ///
		xla(, nogrid notick labsize(6)) ///
		legend(off) ///
		text(`mde_label_height' `mde' " MDE: `mde'%; 95% CI: [`mde_ll', `mde_ul']", place(e) si(4)) 

	graph export "$figure_results_path/mde_hist_`file_name'.pdf",  replace
	graph export "$figure_results_path/mde_hist_`file_name'.png",  replace

	// This website was helpful
	*https://stats.idre.ucla.edu/stata/faq/how-do-i-write-my-own-bootstrap-program/

	///////////////////////////////////////////////////////////////////////////////
	// Create power analaysis graphs

	// Open dataset 
	use "$file_path_power_data_combined/`file_name'.dta", clear

	// Calculate a count variable
	gen count = 1
		
	// Make an indicator if powered at a certain level 
	local counter = 1

	foreach x in `step_macro' {
		// Calculate indicator for power threshold for an observation
		gen power_10_`counter' = 0
		gen power_05_`counter' = 0
		gen power_01_`counter' = 0
		gen power_001_`counter' = 0
		
		replace power_10_`counter' = 1 if p_storage`counter' <= .1
		replace power_05_`counter' = 1 if p_storage`counter' <= .05
		replace power_01_`counter' = 1 if p_storage`counter' <= .01
		replace power_001_`counter' = 1 if p_storage`counter' <= .001
		
		
		// Move the counter one forward
		local counter = `counter' + 1 
	}
		
	// Make an indicator if sign error at a certain level 
	local counter = 1

	foreach x in `step_macro' {
		local power_list 10 05 01 001
		foreach y in `power_list' {
			gen s_error_`y'_`counter' = 0
			replace s_error_`y'_`counter' = 1 if power_`y'_`counter' == 1 & b_storage`counter' > 0
		}
		
		// Move the counter one forward
		local counter = `counter' + 1 	
	}
		
	// generate  magnitude-error 
	local counter = 1

	foreach x in `step_macro' {
		gen m_error_`counter' = abs(b_storage`counter'/(`x'*100))
		
		local power_list 10 05 01 001
		foreach y in `power_list' {
			gen m_error_`y'_`counter' = m_error_`counter'
			replace m_error_`y'_`counter' = . if power_`y'_`counter' == 0
		}
		drop m_error_`counter'
		
		// Move the counter one forward
		local counter = `counter' + 1 	
	}
		
	// Generate Beliveabilitiy 

	local counter = 1
	foreach x in `step_macro' {
		
		local power_list 10 05 01 001
		foreach y in `power_list' {
			gen believe_`y'_`counter' = 0
			replace believe_`y'_`counter' = 1 if power_`y'_`counter' == 1 & m_error_`y'_`counter' <= 2 & power_`y'_`counter' == 1
		}
		
		// Move the counter one forward
		local counter = `counter' + 1 	
	}

	// Collapse by effect size
	gcollapse (sum) count power_* s_error_* believe_* (mean) m_error_* 

	// Reshape data by effect size
	reshape long ///
		power_10_@ power_05_@ power_01_@ power_001_@ ///
		s_error_10_@ s_error_05_@ s_error_01_@ s_error_001_@ ///
		m_error_10_@ m_error_05_@ m_error_01_@ m_error_001_@ ///
		believe_10_@ believe_05_@ believe_01_@ believe_001_@, ///
		i(count) j(effect_size)
		
	// Remove hanging _
	rename *_ *
	 
	// Turn into a percent
	local power_list 10 05 01 001
	foreach y in `power_list' {
		replace s_error_`y' = (s_error_`y'/power_`y')*100
		replace s_error_`y' = . if effect_size == 1 // Cannot have a sign-error when no treatment effect

	}


	// Turn into a percent
	qui ds power_* believe_*
	foreach x in `r(varlist)' {
		replace `x' = (`x'/count)*100
	}

	// Cannot have a sign-error when no treatment effect
	local power_list 10 05 01 001
	foreach y in `power_list' {
		replace believe_`y' = . if effect_size == 1
	}


	// Fix effect size 
	local counter = 1

	foreach x in `step_macro' {
		replace effect_size = `x'*100 in `counter'
		
		// Move the counter one forward
		local counter = `counter' + 1 	
	}

	// Drop unneeded variables
	drop count 

	// Make a local that is the labels we want
	local graph_step_macro 
	forvalues x = 0(`graph_effect_size_step')`graph_effect_size_max' {
		local graph_step_macro `graph_step_macro'  `x' 
	}
	di "`graph_step_macro'"

	// Plot power 
	twoway ///
		|| scatteri 0 `mde' 100 `mde', recast(line) lcol(gs7) lp("_") lwidth(.5) ///
		|| connected power_10 effect_size if  effect_size <= `graph_effect_size_max',  lwidth(.5) lpattern("l") color(sea) msymbol(none) mlabcolor(sea) mlabel("") mlabsize(3) mlabpos(11) ///
		|| connected  power_05 effect_size  if  effect_size <= `graph_effect_size_max', lwidth(.5) lpattern(".._") color(turquoise) msymbol(none) mlabcolor(turquoise) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  power_01 effect_size if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("_") color(vermillion) msymbol(none) mlabcolor(vermillion) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  power_001  effect_size  if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("l") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
			xsc(r(0 `graph_effect_size_max')) ///
			xlabel("`graph_step_macro'", nogrid labsize(4)) ///
			ytitle("Power", size(4)) ///
			xtitle("Imposed Effect (Percent Reduction in Amenable Mortality)", size(4) ) ///
			ylabel(0 "0%" 20 "20%"  40 "40%" 60 "60%" 80 "80%" 100 "100%", gmax noticks labsize(4)) ///
			legend(order(2 3 4 5) pos(6) col(4) ///
			label(2 "{&alpha} =.10") label(3 "{&alpha} =.05") ///
			label(4 "{&alpha} =.01") label(5 "{&alpha} =.001") size(4)) ///
			text(10 `mde' " MDE: `mde'%; 95% CI: [`mde_ll', `mde_ul']", place(e) si(4)) ///
			title("Power simulation", pos(11) size(4)) ///
			subtitle("`graph_subtitle'", pos(11) size(3)) 

	graph export "$figure_results_path/power_`file_name'.pdf",  replace
	graph export "$figure_results_path/power_`file_name'.png",  replace


	// Plot believability 

	twoway ///
		|| scatteri 0 `mde' 100 `mde', recast(line) lcol(gs7) lp("_") lwidth(.5) ///
		|| connected believe_10 effect_size if  effect_size <= `graph_effect_size_max',  lwidth(.5) lpattern("l") color(sea) msymbol(none) mlabcolor(sea) mlabel("") mlabsize(3) mlabpos(11) ///
		|| connected  believe_05 effect_size  if  effect_size <= `graph_effect_size_max', lwidth(.5) lpattern(".._") color(turquoise) msymbol(none) mlabcolor(turquoise) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  believe_01 effect_size if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("_") color(vermillion) msymbol(none) mlabcolor(vermillion) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  believe_001  effect_size  if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("l") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
			xsc(r(0 `graph_effect_size_max')) ///
			xlabel("`graph_step_macro'", nogrid labsize(4)) ///
			ytitle("Believability", size(4)) ///
			xtitle("Imposed Effect (Percent Reduction in Amenable Mortality)", size(4) ) ///
			ylabel(0 "0%" 20 "20%"  40 "40%" 60 "60%" 80 "80%" 100 "100%", gmax noticks labsize(4)) ///
			legend(order(2 3 4 5) pos(6) col(4) ///
			label(2 "{&alpha} =.10") label(3 "{&alpha} =.05") ///
			label(4 "{&alpha} =.01") label(5 "{&alpha} =.001") size(4)) ///
			text(10 `mde' " MDE: `mde'%; 95% CI: [`mde_ll', `mde_ul']", place(e) si(4)) ///
			title("Believability simulation", pos(11) size(4)) ///
			subtitle("`graph_subtitle'", pos(11) size(3)) 

	graph export "$figure_results_path/believability_`file_name'.pdf",  replace
	graph export "$figure_results_path/believability_`file_name'.png",  replace

	// Plot sign-error 
	sum s_error_10
	local max_error = `r(max)'

	sum s_error_05
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	sum s_error_01
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	sum s_error_001
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	di `max_error'

	local max_height = ceil(`max_error'/5)*5
	local label_height = `max_height'*.75




	twoway ///
		|| scatteri 0 `mde' `max_height' `mde', recast(line) lcol(gs7) lp("_") lwidth(.5) ///
		|| connected  s_error_10 effect_size if  effect_size <= `graph_effect_size_max',  lwidth(.5) lpattern("l") color(sea) msymbol(none) mlabcolor(sea) mlabel("") mlabsize(3) mlabpos(11) ///
		|| connected  s_error_05 effect_size  if  effect_size <= `graph_effect_size_max', lwidth(.5) lpattern(".._") color(turquoise) msymbol(none) mlabcolor(turquoise) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  s_error_01 effect_size if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("_") color(vermillion) msymbol(none) mlabcolor(vermillion) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  s_error_001  effect_size  if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("l") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
			xsc(r(0 `graph_effect_size_max')) ///
			xlabel("`graph_step_macro'", nogrid labsize(4)) ///
			ytitle("Sign-error percent", size(4)) ///
			xtitle("Imposed Effect (Percent Reduction in Amenable Mortality)", size(4) ) ///
			ylabel(0(5)`max_height', gmax noticks labsize(4)) ///
			legend(order(2 3 4 5) pos(6) col(4) ///
			label(2 "{&alpha} =.10") label(3 "{&alpha} =.05") ///
			label(4 "{&alpha} =.01") label(5 "{&alpha} =.001") size(4)) ///
			text(`label_height' `mde' " MDE: `mde'%; 95% CI: [`mde_ll', `mde_ul']", place(e) si(4)) ///
			title("Sign-error simulation", pos(11) size(4)) ///
			subtitle("`graph_subtitle'", pos(11) size(3)) 


	graph export "$figure_results_path/sign_error_`file_name'.pdf",  replace
	graph export "$figure_results_path/sign_error_`file_name'.png",  replace



	// Plot magnitude error-error 
	sum m_error_10
	local max_error = `r(max)'

	sum m_error_05
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	sum m_error_01
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	sum m_error_001
	if `r(max)' > `max_error' {
		local max_error = `r(max)'
	}

	di `max_error'

	local max_height = ceil(`max_error'/2)*2
	local label_height = `max_height'*.75




	twoway ///
		|| scatteri 0 `mde' `max_height' `mde', recast(line) lcol(gs7) lp("_") lwidth(.5) ///
		|| connected  m_error_10 effect_size if  effect_size <= `graph_effect_size_max',  lwidth(.5) lpattern("l") color(sea) msymbol(none) mlabcolor(sea) mlabel("") mlabsize(3) mlabpos(11) ///
		|| connected  m_error_05 effect_size  if  effect_size <= `graph_effect_size_max', lwidth(.5) lpattern(".._") color(turquoise) msymbol(none) mlabcolor(turquoise) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  m_error_01 effect_size if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("_") color(vermillion) msymbol(none) mlabcolor(vermillion) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected  m_error_001  effect_size  if  effect_size <= `graph_effect_size_max' , lwidth(.5) lpattern("l") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
			xsc(r(0 `graph_effect_size_max')) ///
			xlabel("`graph_step_macro'", nogrid labsize(4)) ///
			ytitle("Observed/(True Magnitude)", size(4)) ///
			xtitle("Imposed Effect (Percent Reduction in Amenable Mortality)", size(4) ) ///
			ylabel(0(2.5)`max_height', gmax noticks labsize(4)) ///
			legend(order(2 3 4 5) pos(6) col(4) ///
			label(2 "{&alpha} =.10") label(3 "{&alpha} =.05") ///
			label(4 "{&alpha} =.01") label(5 "{&alpha} =.001") size(4)) ///
			text(`label_height' `mde' " MDE: `mde'%; 95% CI: [`mde_ll', `mde_ul']", place(e) si(4)) ///
			title("Magnitude-error simulation", pos(11) size(4)) ///
			subtitle("`graph_subtitle'", pos(11) size(3)) ///
			yline(1, lpattern(solid) lcolor(gs7) lwidth(1))


	graph export "$figure_results_path/magnitude_error_`file_name'.pdf",  replace
	graph export "$figure_results_path/magnitude_error_`file_name'.png",  replace 


		/////////////////////////////////////////////////////////////////////////////////
		// Store MDE and TOT in excel sheet. 
		putexcel set "$table_results_path/mde_tot.xlsx", sheet(mde_tot) modify

		putexcel A`numb' = "`file_name'"
		putexcel B`numb' = `mde'
		putexcel C`numb' = `mde_ll'
		putexcel D`numb' = `mde_ul'

end
