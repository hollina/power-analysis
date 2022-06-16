///////////////////////////////////////////////////////////////////////////////
// Create program to make DD power analysis data. 


capture program drop st_simsynth_power_analysis_dd

// *----------
program define st_simsynth_power_analysis_dd
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
*/
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
	

	local file_name_suffix st_simp_synth_dd_`prefix'_`death_type'_`dem_type'_cluster_`cluster_var'_weight_`weight_var'_controls_`list_of_controls'_preperiod_`first_year'_`last_year'
	
	if "`list_of_controls'" == "yes" {
		local list_of_controls 	"Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc"
	}
	if "`list_of_controls'" == "no" {
		local list_of_controls 	
	}


	// Open death rate data
	use "$restricted_data_analysis/death_rates_1999_2017.dta", clear
	
	// Collapse both death counts and population state-year level
	qui ds  any* namen* amen* hiv* resp* card* dia* can* pop*
	gcollapse (sum) `r(varlist)', by(state year)
	
	// Generate death rates per 100k

	local cod_list any namen amen hiv resp card dia can 

	foreach cod in `cod_list' {
		
		foreach age in 55_64 65_74 45_64 18_64 eld  {
		
			// Non-hispanic black and white by age group
			foreach race in white black {
				gen temp_pop_`race'_non_hisp_`age'  = pop_`race'_non_hisp_`age'
				replace temp_pop_`race'_non_hisp_`age' = `cod'_`race'_non_hisp_`age' if temp_pop_`race'_non_hisp_`age' < `cod'_`race'_non_hisp_`age' & !missing(`cod'_`race'_non_hisp_`age')
				gen dr_`cod'_`race'_non_hisp_`age' = (`cod'_`race'_non_hisp_`age'/ temp_pop_`race'_non_hisp_`age')*100000
				drop temp_pop_`race'_non_hisp_`age'
			}
			
			// Hispanic non-black, non-white by age group 
			gen temp_pop_hisp_`age' = pop_hisp_`age'
			replace temp_pop_hisp_`age' = `cod'_hisp_`age' if temp_pop_hisp_`age' < `cod'_hisp_`age' & !missing(`cod'_hisp_`age') 
			gen dr_`cod'_hisp_`age' = (`cod'_hisp_`age'/ temp_pop_hisp_`age')*100000
			drop temp_pop_hisp_`age'
			
			// Female by age
			gen temp_pop_fem_`age' = pop_fem_`age'
			replace temp_pop_fem_`age' = `cod'_fem_`age' if temp_pop_fem_`age' < `cod'_fem_`age' & !missing(`cod'_fem_`age') 
			gen dr_`cod'_fem_`age' = (`cod'_fem_`age'/ temp_pop_fem_`age')*100000
			drop temp_pop_fem_`age'
			
			// Male by age
			gen temp_pop_male_`age' = pop_male_`age'
			replace temp_pop_male_`age' = `cod'_male_`age' if temp_pop_male_`age' < `cod'_male_`age' & !missing(`cod'_male_`age') 
			gen dr_`cod'_male_`age' = (`cod'_male_`age'/ temp_pop_male_`age')*100000
			drop temp_pop_male_`age' 
			
			// By age
			gen temp_pop_`age' = pop_`age'
			replace temp_pop_`age' = `cod'_`age' if temp_pop_`age' < `cod'_`age' & !missing(`cod'_`age') 
			gen dr_`cod'_`age' = (`cod'_`age'/ temp_pop_`age')*100000
			drop temp_pop_`age'
			
		}
	


		// Non-hispanic black and white 
		foreach race in white black {
			gen temp_pop_`race'_non_hisp  = pop_`race'_non_hisp
			replace temp_pop_`race'_non_hisp = `cod'_`race'_non_hisp if temp_pop_`race'_non_hisp < `cod'_`race'_non_hisp & !missing(`cod'_`race'_non_hisp)
			gen dr_`cod'_`race'_non_hisp = (`cod'_`race'_non_hisp/ temp_pop_`race'_non_hisp)*100000
			drop temp_pop_`race'_non_hisp
		}
		
		// Hispanic non-black, non-white 
		gen temp_pop_hisp = pop_hisp
		replace pop_hisp = `cod'_hisp if temp_pop_hisp < `cod'_hisp & !missing(`cod'_hisp) 
		gen dr_`cod'_hisp = (`cod'_hisp/ temp_pop_hisp)*100000
		drop temp_pop_hisp
		
		// Female 
		gen temp_pop_fem = pop_fem
		replace temp_pop_fem = `cod'_fem if temp_pop_fem < `cod'_fem & !missing(`cod'_fem) 
		gen dr_`cod'_fem = (`cod'_fem/ temp_pop_fem)*100000
		drop temp_pop_fem
		
		// Male 
		gen temp_pop_male = pop_male
		replace temp_pop_male = `cod'_male if temp_pop_male < `cod'_male & !missing(`cod'_male) 
		gen dr_`cod'_male = (`cod'_male/ temp_pop_male)*100000
		drop temp_pop_male
		
		// Total
		gen temp_pop = pop 
		replace pop = `cod' if temp_pop < `cod' & !missing(`cod') 
		gen dr_`cod' = (`cod'/ temp_pop)*100000
		drop temp_pop
	}
	
		gen temp_pop_45_64 = pop_45_64
		replace temp_pop_45_64 = amen_le_45_64 if temp_pop_45_64 < amen_le_45_64 & !missing(amen_le_45_64)
		gen dr_amen_le_45_64 = (amen_le_45_64 /temp_pop_45_64)*100000
		drop temp_pop_45_64
			
		gen temp_pop_eld = pop_eld
		replace temp_pop_eld = amen_le_eld if temp_pop_eld < amen_le_eld & !missing(amen_le_eld)
		gen dr_amen_le_eld = (amen_le_eld /temp_pop_eld)*100000
		drop temp_pop_eld


	// Foreach death rate create a log death rate
	qui ds dr_*
	foreach x in `r(varlist)' {
		gen ln_`x' = ln(`x' + 1)
	}
	rename ln_dr_* ln_*	

	
	// Merge in control data at the state-year level
	merge 1:1 state year using "$restricted_data_analysis/state_controls_with_att_pop_state.dta"
	keep if _merge == 3
	drop _merge 
	
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
	
	// Keep only certain years
	keep if year <= 2016	
	
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
	bysort state  (year): replace event_time = event_time[_n-1] +1 if missing(event_time)
	gsort state  -year
	bysort state : replace event_time = event_time[_n-1] -1 if missing(event_time)
	
	drop if  expansion_4 == 2 | expansion_4 == 3
	
	rename post real_post
	gen real_expansion = expansion_4
	gen real_treatment = real_expansion * real_post 
	
	
	// Drop if after 2014 or before first year
	drop if year < `first_year'
	
	// Calculate the best fit line for each state excluding the post-treatment period
	*Need to do this since counties are trending. If we only pull from pre-period mean, then we will have too high of a death rate to be actually comparable.
	capture drop yhat
	capture drop rate
	capture drop fe_year_slope fe_state fe_year
	
	// Generate rate
	gen rate = `death_type'_`dem_type'/pop_`dem_type'
	
	// Custom regression to estimate rate without post-treatment treated counties data
	*reghdfe rate if real_treatment == 0, absorb(fe_year_slope = c.year#i.unique_county_id fe_county = unique_county_id fe_year = year) savefe 
	
	/*
	*local first_year 2004
	sum rate if year == `first_year'
	
	capture drop rate_normal
	gen rate_normal = rnormal(`r(mean)', `r(sd)') 
	replace rate_normal = . if year != `first_year'
	replace rate_normal = 0 if rate_normal < 0 & !missing(rate_normal)
	
	capture drop new_rate_normal
	bysort state county: egen new_rate_normal = max(rate_normal)
	
	sort state county year

	capture drop order
	bysort state county: gen order = _n
	
	*local last_year 2010
	reghdfe rate c.year if year <= `last_year', noabsorb 

	replace new_rate_normal = new_rate_normal + (order-1)*_b[year] 
	replace new_rate_normal = 0 if new_rate_normal < 0
	
	sort state county year
	order state county year order rate_normal new_rate_normal	
	
	capture drop rate_hat
	gen rate_hat = new_rate_normal
	*/
	
	/*
	// Fill in slope for missing year
	*sort state county year
	*bysort state county: carryforward fe_year_slope, replace
	
	// Fill in FE for missing county-year
	sort state county year
	bysort state county: carryforward fe_county, replace
	
	// Fill in FE for missing year
	*sort  year
	*bysort year: carryforward fe_year, replace
	
	// Gen prediction 
	*gen double rate_hat = _b[_cons] + fe_county + fe_year + year*fe_year_slope
	gen double rate_hat = _b[_cons] + fe_county + year*_b[year]
	
	replace rate_hat = 0 if rate_hat < 0 // This did not come up in practice, but is possible in theory. Would render the binomial draw below useless. 
	*/



	*gen synthetic_deaths = `death_type'_`dem_type'
	*replace synthetic_deaths = . if real_treatment == 1
	*replace synthetic_deaths = rbinomial(pop_`dem_type', rate_hat) if real_treatment == 1	
	
	/*
	// Calculate the pre-expansion probability of death for expansion counties
	bysort state county: egen mean_`death_type'_`dem_type' = mean(`death_type'_`dem_type'/pop_`dem_type') if real_post == 0 & real_expansion == 1

	// Carry this probability forward to the post-expansion years
	sort state county year
	bysort state county: carryforward mean_`death_type'_`dem_type', replace
	*/		
			
	///////////////////////////////////////////////////////////////////////////////
	// Generate a new random variable
	distinct state  if real_treatment == 1
	scalar number_expand = r(ndistinct)				
		
	// Set up non-string id
	egen id = group(state)
	
	// Sort Data
	sort id year
	
	/*
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
	*/
	
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
		
		// Generate a normal death rate for each county
		*local first_year 2004
		capture drop rate_normal
		sum rate if year == `first_year'
		gen rate_normal = rnormal(`r(mean)', `r(sd)') 
		replace rate_normal = . if year != `first_year'
		replace rate_normal = 0 if rate_normal < 0 & !missing(rate_normal)
		
		capture drop new_rate_normal
		bysort state: egen new_rate_normal = max(rate_normal)
		
		sort state year

		capture drop order
		bysort state: gen order = _n
		
		*local last_year 2010
		reghdfe rate c.year if year <= `last_year', noabsorb 
		replace new_rate_normal = new_rate_normal + (order-1)*_b[year] 
		replace new_rate_normal = 0 if new_rate_normal < 0
		
		sort state year
		order state year order rate_normal new_rate_normal	
		
		capture drop rate_hat
		gen rate_hat = new_rate_normal
	
		// Generate synthetic deaths
		capture drop synthetic_deaths
		gen synthetic_deaths = rbinomial(pop_`dem_type', rate_hat) 
		replace synthetic_deaths = 0 if missing(synthetic_deaths)
		
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
			
			// Reduce synthetic deaths
			gen reduced_deaths_`counter' = 0 
			replace reduced_deaths_`counter' = rbinomial(synthetic_deaths,`x') if real_treatment == 1
			replace reduced_deaths_`counter' = 0 if missing(reduced_deaths_`counter')
			
			gen death_count_`counter' = synthetic_deaths - reduced_deaths_`counter'
			replace death_count_`counter' = 0 if missing(death_count_`counter')
			
			gen dr_`counter'= (death_count_`counter'/pop_`dem_type')*100000
			
			if "`prefix'" == "ln"{
				gen ln_dr_`counter' = ln(dr_`counter' + 1)
				
				// Run the regression
				qui reghdfe ln_dr_`counter' ///
					i.real_treatment ///
					i.real_post i.real_expansion ///
					`list_of_controls'  ///
					[aweight = `weight_var'_`dem_type'] ,  absorb(id year)  vce(cluster `cluster_var') 
				
				//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
				qui nlcom 100*(exp(_b[1.real_treatment])-1)
			}
			if "`prefix'" == "dr"{
				// Run the regression
				qui reghdfe dr_`counter' ///
					i.real_treatment ///
					i.real_post i.real_expansion ///
					`list_of_controls'  ///
					[aweight = `weight_var'_`dem_type'] ,  absorb(id year)  vce(cluster `cluster_var') 
				
				//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
				qui nlcom _b[1.real_treatment]
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
}
end	
