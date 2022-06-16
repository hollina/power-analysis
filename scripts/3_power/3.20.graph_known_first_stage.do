// Set options for debugging

local alpha 05
local power 80
local file_name known_first_stage_ddd_ln_amen_55_64_cluster_state_weight_attpop_split_controls_yes_preperiod_2001_2010_first_stage
local first_stage_list "02 03 05 10 20"
local step_macro "0 .0025 .005 .0075 .01 .0125 .015 .02 .025 .03 .04"

	// Clear memory
	clear



	// Determine the length of the macro 
	local num :  word count `step_macro'
	local max_steps = `num'
	di `max_steps'
	
	// Determine the length of the macro 
	local num_fs :  word count `first_stage_list'
	di `num_fs'
	
	
	
	// Import relevant data from power analysis
	
	foreach first_stage_value in `first_stage_list' {
		import delimited "$file_path_power_data_raw/b_storage_`file_name'_`first_stage_value'.csv", clear
		compress
		save "$file_path_power_data_combined/temp_b_storage_`first_stage_value'.dta", replace
		
		import delimited "$file_path_power_data_raw/p_storage_`file_name'_`first_stage_value'.csv", clear
		compress
		save "$file_path_power_data_combined/temp_p_storage_`first_stage_value'.dta", replace
		
		import delimited "$file_path_power_data_raw/se_storage_`file_name'_`first_stage_value'.csv", clear
		compress
		merge 1:1 _n using "$file_path_power_data_combined/temp_b_storage_`first_stage_value'.dta"
		
		drop _merge
		erase  "$file_path_power_data_combined/temp_b_storage_`first_stage_value'.dta"
		merge 1:1 _n using "$file_path_power_data_combined/temp_p_storage_`first_stage_value'.dta"
		drop _merge
		erase  "$file_path_power_data_combined/temp_p_storage_`first_stage_value'.dta"
		
		// Add first stage 
		gen first_stage = `first_stage_value'
		
		// Save power data
		compress
		save "$file_path_power_data_combined/temp_`file_name'_`first_stage_value'.dta", replace
	}
	
	clear 
	foreach first_stage_value in `first_stage_list' {
		append using "$file_path_power_data_combined/temp_`file_name'_`first_stage_value'.dta"
		erase "$file_path_power_data_combined/temp_`file_name'_`first_stage_value'.dta"
	}
	
	save "$file_path_power_data_combined/`file_name'.dta", replace
	
	
	// Calculate power for a chosen alpha
	local counter = 1

		foreach x in `step_macro' {
			di "`x'"
			// Calculate indicator for power threshold for an observation
			gen power_`alpha'_`counter' = 0
			
			replace power_`alpha'_`counter' = 1 if p_storage`counter' <= .`alpha'
			
			// Move the counter one forward
			local counter = `counter' + 1 
		}
		
	// Calculate a count variable
	gen count = 1

	// Collapse by effect size
	gcollapse (sum) count power_* , by(first_stage)

	// Reshape data so each observation is effect size
	reshape long ///
		power_`alpha'_@ , ///
		i(count first_stage) j(effect_size)

	// Remove hanging _
	rename *_ *

	// Turn into a percent
	qui ds power_*
	foreach x in `r(varlist)' {
		replace `x' = (`x'/count)*100
	}

	// Fix effect size 
	forvalues i = 1/`num_fs' {
		local counter = (`i' - 1)*`max_steps' + 1
		
		foreach x in `step_macro' {
			replace effect_size = `x'*100 in `counter'
		// Move the counter one forward
		local counter = `counter' + 1 	
		}
	}
	// Drop unneeded variables
	drop count 
	
	// Create a variable that is the gap between desired power level and closest estimates
	capture drop gap
	gen  gap = abs(`power'-power_`alpha')
	
	// Find largest treatment below 80
	bysort first_stage: egen lower_bound = max(effect_size) if power_`alpha' <= 80
	// Find smallest treatment above 80
	bysort first_stage: egen upper_bound = min(effect_size) if power_`alpha' >= 80
	
	// Identify these as "keepers" for the regression
	gen keeper = 0
	replace keeper = 1 if effect_size == lower_bound
	replace keeper = 1 if effect_size == upper_bound 
	
	// Run a regression on the two closest observations
	reg power_`alpha' effect_size if first_stage == 10 & keeper == 1
	gen mark = e(sample)  
	// Predict MDE using these two points and save as a matrix
	mat mde = (`power'-_b[_cons])/_b[effect_size]	
			
	// Turn MDE and 95% CI into rounded scalars
	scalar mde_scalar = round(mde[1,1], .01)
	di mde_scalar
	local mde = mde_scalar
	local mde : di %04.2f `mde'  // Fix floating point error that occassionally happens. 

		
	// Plot power 
	twoway ///
		|| scatteri 0 `mde' 100 `mde', recast(line) lcol(gs7) lp("_") lwidth(.5) ///
		|| connected power_05 effect_size if first_stage == 2 & effect_size <= 4,  lpattern("l") color(vermillion) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected power_05 effect_size if first_stage == 3 & effect_size <= 4,  lpattern("--") color(sea) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected power_05 effect_size if first_stage == 5 & effect_size <= 4,  lpattern("l") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected power_05 effect_size if first_stage == 10 & effect_size <= 4,  lpattern("_") color(turquoise) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
		|| connected power_05 effect_size if first_stage == 20 & effect_size <= 4,  lpattern(".._") color(black) msymbol(none) mlabcolor(black) mlabel("") mlabsize(3) mlabpos(3) ///
			xsc(r(0 4)) ///
			xlabel(0(.5)4, nogrid labsize(4)) ///
			ytitle("Power", size(4)) ///
			xtitle("Imposed Effect on Treated (Percent Reduction in Amenable Mortality)", size(4) ) ///
			ylabel(0 "0%" 20 "20%"  40 "40%" 60 "60%" 80 "80%" 100 "100%", gmax noticks labsize(4)) ///
			legend(order(2 3 4 5 6 ) pos(6) col(3) ///
			label(2 "First Stage = 2%") label(3 "First Stage = 3%") label(4 "First Stage = 5%") ///
			label(5 "First Stage = 10%") label(6 "First Stage = 20%") size(4)) ///
			text(5 `mde' " MDE for 10% first-stage: `mde'%", place(e) si(4)) ///
			title("Power simulation", pos(11) size(4))

	graph export "$figure_results_path/power_`file_name'.pdf",  replace
	graph export "$figure_results_path/power_`file_name'.png",  replace


