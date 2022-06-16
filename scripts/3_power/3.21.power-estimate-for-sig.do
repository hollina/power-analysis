 
	
	local end_value .12 
	local step_size .005
	local alpha 05
	use "$file_path_power_data_combined/ddd_ln_amen_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010.dta", clear

		
		// Clear memory
	

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
	reg power_05 effect_size in 4/5
	di _b[_cons] + _b[effect_size]*1.53
	*51.2
