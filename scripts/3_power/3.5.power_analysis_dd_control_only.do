///////////////////////////////////////////////////////////////////////////////
// Create program to make DD power analysis data. 

capture program drop control_only_power_analysis_dd

// *----------
program define control_only_power_analysis_dd
syntax, ///
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
	prefix(string) 
*----------
quietly {
	set matsize 10000
	
	///////////////////////////////////////////////////////////////////////////////
	// Set parameters for debugging simulation
	/*
	// Create (or set) a local macro with step sizes
	local end_value .12
	local step_size .005

	
		
	// Set a max number of datasets
	local max_dataset_number 2

	// Set the first year in the pre-treatment period
	local first_year 2004

	// Set the last year in the pre-treatment period
	local last_year 2013

	// Set death type
	local death_type  amen

	// Set demographic group	
	local dem_type  55_64

	// Create list of control variables
	local list_of_controls yes
				 
	local weight_var attpop // weight variable (pop attpop)
		
	local cluster_var state // state or county
	
	local prefix ln // ln or dr
	*/
	
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
	

	local file_name_suffix control_only_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
	
	if "`list_of_controls'" == "yes" {
		local list_of_controls 	"Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc"
	}
	if "`list_of_controls'" == "no" {
		local list_of_controls 	
	}


	// Open death rate data
	use "$restricted_data_analysis/death_rates_1999_2017.dta", clear
	
	// Merge in control data at the county-level
	merge 1:1 state county year using "$restricted_data_analysis/county_controls_with_att_pop.dta"
	keep if _merge == 3
	drop _merge 
	
	// Keep only certain years
	keep if year <= 2016
	
	// Add state abbreviation
	gen state_abbr =""
	replace state_abbr = "AK" if state==2
	replace state_abbr = "AL" if state==1
	replace state_abbr = "AR" if state==5
	replace state_abbr = "AS" if state==60
	replace state_abbr = "AZ" if state==4
	replace state_abbr = "CA" if state==6
	replace state_abbr = "CO" if state==8
	replace state_abbr = "CT" if state==9
	replace state_abbr = "DC" if state==11
	replace state_abbr = "DE" if state==10
	replace state_abbr = "FL" if state==12
	replace state_abbr = "GA" if state==13
	replace state_abbr = "GU" if state==66
	replace state_abbr = "HI" if state==15
	replace state_abbr = "IA" if state==19
	replace state_abbr = "ID" if state==16
	replace state_abbr = "IL" if state==17
	replace state_abbr = "IN" if state==18
	replace state_abbr = "KS" if state==20
	replace state_abbr = "KY" if state==21
	replace state_abbr = "LA" if state==22
	replace state_abbr = "MA" if state==25
	replace state_abbr = "MD" if state==24
	replace state_abbr = "ME" if state==23
	replace state_abbr = "MI" if state==26
	replace state_abbr = "MN" if state==27
	replace state_abbr = "MO" if state==29
	replace state_abbr = "MS" if state==28
	replace state_abbr = "MT" if state==30
	replace state_abbr = "NC" if state==37
	replace state_abbr = "ND" if state==38
	replace state_abbr = "NE" if state==31
	replace state_abbr = "NH" if state==33
	replace state_abbr = "NJ" if state==34
	replace state_abbr = "NM" if state==35
	replace state_abbr = "NV" if state==32
	replace state_abbr = "NY" if state==36
	replace state_abbr = "OH" if state==39
	replace state_abbr = "OK" if state==40
	replace state_abbr = "OR" if state==41
	replace state_abbr = "PA" if state==42
	replace state_abbr = "PR" if state==72
	replace state_abbr = "RI" if state==44
	replace state_abbr = "SC" if state==45
	replace state_abbr = "SD" if state==46
	replace state_abbr = "TN" if state==47
	replace state_abbr = "TX" if state==48
	replace state_abbr = "UT" if state==49
	replace state_abbr = "VA" if state==51
	replace state_abbr = "VI" if state==78
	replace state_abbr = "VT" if state==50
	replace state_abbr = "WA" if state==53
	replace state_abbr = "WI" if state==55
	replace state_abbr = "WV" if state==54
	replace state_abbr = "WY" if state==56
	
	** Creating Medicaid Expansion Variable
	* Four category expansion info
	gen expansion_4 = .
	
	local control AL AK FL GA ID IN KS LA MS ME MO MT NE NH NC OK PA SC SD TN TX UT VA WY 
	foreach control in `control' {
	replace expansion_4 = 0 if state_abbr == `"`control'"'
		}
	local treatment AR AZ CO IL IA KY MD MI NV NM NJ ND OH OR RI WV WA
	foreach treatment in `treatment' {
	replace expansion_4 = 1 if state_abbr ==`"`treatment'"'
		}	
	local mild DE DC MA NY VT
	foreach exc in `mild' {
	replace expansion_4 = 2 if state_abbr == `"`exc'"'
		}
	local medium CA CT HI MN WI 
	foreach exc in `medium' {
	replace expansion_4 = 3 if state_abbr == `"`exc'"'
		}
	
	codebook expansion_4
		
	* Account for mid-year expansions
	replace expansion_4=1 if state_abbr == "MI" //MI expanded in April 2014
	replace expansion_4=1 if state_abbr == "NH" //NH expanded in August 2014
	replace expansion_4=1 if state_abbr == "PA" //PA expanded in Jan 2015
	replace expansion_4=1 if state_abbr == "IN" //IN expanded in Feb 2015
	replace expansion_4=1 if state_abbr == "AK" //AK expanded in Sept 2015
	replace expansion_4=1 if state_abbr == "MT" //MT expanded in Jan 2016
	//LA expanded in July 2016
	
	** Creating post Variable
	gen post = (year>= 2014)
	replace post=0 if state_abbr == "NH" & year == 2014  //NH expanded in August 2014
	replace post=0 if state_abbr == "PA" & year == 2014  //PA expanded in Jan 2015
	replace post=0 if state_abbr == "IN" & year == 2014 //IN expanded in Feb 2015
	replace post=0 if state_abbr == "AK" & (year == 2014 | year == 2015) //AK expanded in Sept 2015	
	replace post=0 if state_abbr == "MT" & (year == 2014 | year == 2015) //MT expanded in Jan 2016	
	
	** Create Event Time Variable
	gen event_time = .
	replace event_time = 0 if year == 2014 & (state_abbr != "NH" & state_abbr != "PA"  & state_abbr != "IN" & state_abbr != "AK" & state_abbr != "MT")
	replace event_time = 0 if year == 2015 & (state_abbr == "NH" | state_abbr == "PA"  | state_abbr == "IN")
	replace event_time = 0 if year == 2016 & (state_abbr == "AK" | state_abbr == "MT")
	bysort state county (year): replace event_time = event_time[_n-1] +1 if missing(event_time)
	gsort state county -year
	bysort state county: replace event_time = event_time[_n-1] -1 if missing(event_time)
	
	egen unique_county_id = group(state county)
	drop if  expansion_4 == 2 | expansion_4 == 3
	
	rename post real_post
	gen real_expansion = expansion_4
	gen real_treatment = real_expansion * real_post
	
	//////////////////////////////////////////////////////////////////////////////	
	// How many total states 
	distinct state
	scalar number_states = r(ndistinct)				

	///////////////////////////////////////////////////////////////////////////////
	// Generate a new random variable
	distinct state  if real_treatment == 1
	scalar number_expand = r(ndistinct)	
	
	// Drop expansion states
	drop if expansion_4 == 1
		
	// Set up non-string mumeric id for remaining states that ranges between 1 and N
	egen numeric_state_id = group(state)

	// Make a variable list for the logit regression for "expansion"

	local var_list ///
		pop_male pop_white_non_hisp pop_black_non_hisp pop_55_64 pop_65_74 ///
		pct_unin_All_1864 pct_unin_GIV_below138pvty_1864 /// pct_unin_GIV_above138pvty_1864 ///
		pct_unin_All_5064 pct_unin_GIV_below138pvty_5064 /// pct_unin_GIV_above138pvty_5064 ///
		IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet Mcare_Disab ///
		diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent ///
		percent_everyday_smoker percent_someday_smoker percent_former_smoker /// smoking_all
		physicians_pc 
			
	// Make a variable that represents the mean of each of these prior to the expansion year
	local year_in_data = `last_year' - 1

	capture drop m_*
	foreach x in `var_list' {
		bysort state county: egen m_`x' = mean(`x') if year <= `year_in_data'
		sort state county year
		bysort state county: carryforward  m_`x', replace
	}
	
	
	// Save a temporary file for each state
	compress
	save "$temp_path/cty_dd_temp_state_all.dta", replace
	
	use "$temp_path/cty_dd_temp_state_all.dta", clear
	sum numeric_state_id
	scalar number_control = `r(max)' 
	local number_control = number_control
	forvalues x = 1(1)`number_control' {
		use  "$temp_path/cty_dd_temp_state_all.dta", clear
		keep if numeric_state_id == `x'
		save "$temp_path/cty_dd_temp_state_id_`x'.dta", replace
	}	
	
	
	
	////////////////////////////////////////////////////////////////////////////////
	//  Create matrix to store results
	
	matrix b_storage = J(`max_dataset_number',`max_steps',.) 
	matrix se_storage = J(`max_dataset_number',`max_steps',.) 
	matrix p_storage = J(`max_dataset_number',`max_steps',.) 
	
	////////////////////////////////////////////////////////////////////////////////
	//  Assign psuedo-treatment
}	
	forvalues dataset_number = 1(1)`max_dataset_number'	{
	*local dataset_number 1
	di "///////////////////////////////////////////////////////////////////////"
	di "			`dataset_number'/`max_dataset_number' complete			   "
	di "///////////////////////////////////////////////////////////////////////"
quietly {
		// Open main dataset
		*use "$temp_path/temp_data.dta", clear
	
		// Set seed for reproducability. We want the seed to be the same within a dataset. 
		local rand_seed = 1234 + `dataset_number'
		set seed   `rand_seed'
		
		// Create new dataset
		use "$temp_path/cty_dd_temp_state_all.dta", clear
		gen new_state_id = .
		drop in 1/`=_N'
		local number_states = number_states
		forvalues x = 1(1)`number_states' {
			local y = ceil(number_control * uniform()) 
			di "`y'"
			append using "$temp_path/cty_dd_temp_state_id_`y'.dta"
			replace new_state_id = `x' if missing(new_state_id)
		}
		
		egen id = group(new_state_id county)
	
	// Sort Data
	sort id year 
	order id new_state_id state county year
		// Generate a random variable for each state, then the first 20 in rank will be 
		// considered expansion states 
		capture drop random_variable
		bysort new_state_id: gen random_variable = runiform() if _n==1
		bysort new_state_id: carryforward random_variable, replace
	
		// Rank
		capture drop rank
		egen rank = group(random_variable)
		*sort  rank StateFIPS FIPS
	
		// Given this random ordering of states, assign expansion status to the # set above
		capture drop expansion
		gen expansion = 0 
		replace expansion = 1 if rank <= number_expand
	
		// Do this same thing for the treatment variable
		capture drop treatment
		gen treatment = 0 
		replace treatment = 1 if expansion == 1 & year > `last_year' // & age_55_64==1
	
		// Drop if after 2014 or before first year
		*drop if year >= 2014
		drop if year < `first_year'
	
		// Replace Post 
		capture drop post
		gen post = 0
		replace post = 1 if year > `last_year' 
		
		////////////////////////////////////////////////////////////////////////////////
		// Do a logistic regression (only for one year)

		qui logit ///
			expansion ///
			m_* ///
			if year == `year_in_data' 
				
		// Predict proability
		capture drop p_hat
		predict p_hat

		////////////////////////////////////////////////////////////////////////////////
		// Gen new ATT weight

		// Trip top 5 percentile
		_pctile p_hat, nq(1000)
		replace p_hat = r(r950) if p_hat > r(r950)

		// Make att weights, bind at 1 for exp states
		capture drop att*
		gen att = p_hat / (1 - p_hat)
		replace att = 1 if expansion == 1

		// Create ATT x Pop weights
		ds pop*
		foreach x in `r(varlist)' {
			gen att`x' = att*`x'
		}
		
		////////////////////////////////////////////////////////////////////////////////
		//  Reduce deaths by a given percentage using the binomial 
		local counter = 1
	
		foreach x in `step_macro' {
			
			capture drop reduced_deaths_`counter'
			capture drop death_count_`counter' 
			capture drop dr_`counter'
			capture drop dr_no_mult_`counter'
			capture drop ln_dr_`counter'
			capture drop ln_dr_no_mult_`counter'
	
					
			gen reduced_deaths_`counter' = 0 
			replace reduced_deaths_`counter' = rbinomial(`death_type'_`dem_type',`x') if treatment == 1
			replace reduced_deaths_`counter' = 0 if missing(reduced_deaths_`counter')
			
			gen death_count_`counter' = `death_type'_`dem_type' - reduced_deaths_`counter'
			replace death_count_`counter' = 0 if missing(death_count_`counter')
			
			gen dr_`counter'= (death_count_`counter'/pop_`dem_type')*100000
			
			if "`prefix'" == "ln"{
				gen ln_dr_`counter' = ln(dr_`counter' + 1)
				
				// Run the regression
				qui reghdfe ln_dr_`counter' ///
					i.treatment ///
					i.post i.expansion ///
					`list_of_controls'  ///
					[aweight = `weight_var'_`dem_type'] ,  absorb(id year)  vce(cluster `cluster_var') 
				
				//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
				qui nlcom 100*(exp(_b[1.treatment])-1)
			}
			if "`prefix'" == "dr"{
				// Run the regression
				qui reghdfe dr_`counter' ///
					i.treatment ///
					i.post i.expansion ///
					`list_of_controls'  ///
					[aweight = `weight_var'_`dem_type'] ,  absorb(id year)  vce(cluster `cluster_var') 
				
				//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
				qui nlcom _b[1.treatment]
			}
			mat b = r(b)	
			mat V = r(V)
	
			scalar b = b[1,1]
			scalar se_v2 = sqrt(V[1,1])
			scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))
			
			mat b_storage[`dataset_number', `counter'] = b
			mat se_storage[`dataset_number', `counter'] = se_v2
			mat p_storage[`dataset_number', `counter'] = p_val
			
			// Move the counter one forward
			local counter = `counter' + 1 
		}	
	}
}	
	
quietly {	
	clear 
	svmat b_storage
	format * %20.5f
	export delimited using "$temp_path/b_storage_`file_name_suffix'.csv", replace
	
	clear 
	svmat se_storage
	format * %20.5f
	export delimited using "$temp_path/se_storage_`file_name_suffix'.csv", replace
	
	clear 
	svmat p_storage
	format * %20.5f
	ds
	foreach x in `r(varlist)' {
		replace `x' = 0 if `x' < .00001
	}
	export delimited using "$temp_path/p_storage_`file_name_suffix'.csv", replace
		
	// Clean up 
	use "$temp_path/cty_dd_temp_state_all.dta", clear
	sum numeric_state_id
	scalar number_control = `r(max)' 
	local number_control = number_control
	forvalues x = 1(1)`number_control' {
			erase "$temp_path/cty_dd_temp_state_id_`x'.dta"
	}	
	erase "$temp_path/cty_dd_temp_state_all.dta"
}
end	
	
////////////////////////////////////////////////////////////////////////////////
// Use Program

// Baseline
