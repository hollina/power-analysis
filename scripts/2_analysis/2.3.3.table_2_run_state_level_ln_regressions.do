
///////////////////////////////////////////////////////////////////////////////
// Create program to make main table for 55-64 DD, 65-74 DD, and DDD. 

capture program drop state_regression_results

// *----------
program define state_regression_results
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
	
*----------
	/*
	// For debugging
	local weight_var attpop // weight variable (pop attpop)
	local weight_label "ATT'"  // weight label (pop attpop)
	local y_var_prefix ln  
	local cluster_var state // state or county
	local file_name_suffix ln_amenable // end of file name, before png
	local first_year 2004 // Anything before 2014. Oldest year of data in analysis
	local last_year  2016 // Anything after 2013. Oldest year of data in analysis
	local last_treated_year 2016 // The last post-period year
	local first_treated_year 2014 // The first post-period year
	local low_event_cap -11 // The earliest year in event time 
	local high_event_cap 2 // The last year in event time

	// Create list of control variables
	local list_of_controls Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate ///
				 diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent ///
				 smoking_all physicians_pc
	*/
*/



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
	
	// Keep only certain years
	keep if year <= 2016	
	
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
	bysort state  (year): replace event_time = event_time[_n-1] +1 if missing(event_time)
	gsort state  -year
	bysort state : replace event_time = event_time[_n-1] -1 if missing(event_time)
	
	drop if  expansion_4 == 2 | expansion_4 == 3
	
	gen expansion = expansion_4
	gen treatment = expansion * post 
	

	// Keep only certain years
	keep if year >= `first_year' 
	keep if year <= `last_year'


	// Set up event time 
	********************************************************************************
	*Make an adoption year variable.
	capture drop exp_year
	gen exp_year = year if treatment==1
	egen adopt_year = min(exp_year), by(state)

	* gen event-time (adoption_date = treatment adoption date )
	gen event_time_bacon = year - adopt_year

	* make sure untreated units are included, but also don't get dummies (by giving them "-1")
	recode event_time_bacon (.=-1) (-1000/`low_event_cap'=`low_event_cap') (`high_event_cap'/1000=`high_event_cap')

	*ensure that "xi" omits -1
	char event_time_bacon[omit] -1

	*mak dummies
	xi i.event_time_bacon, pref(_T)

	// Generate a weight of one for the unweighted loop
	foreach age in 55_64 65_74 {
		gen one_`age' = 1
	}
	
	// Foreach death type
	foreach death_type in amen namen any  {
	*local death_type amen
		
		// For each age	
		foreach age in 55_64 65_74 {
			*local age 55_64
			

			
			////////////////////////////////////////////////////////////////////////		
			// DD
			
			////////////////////////////////////////////////////////////////////////		
			// Without controls
			reghdfe `y_var_prefix'_`death_type'_`age'  i.treatment i.post i.expansion  [aw = `weight_var'_`age'] , absorb(state year) cluster(`cluster_var')
			
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[1.treatment])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b = b[1,1]
			scalar se_v2 = sqrt(V[1,1])
			scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

			// Round Estimates to Whatever place we need
			scalar b_rounded_estimate = round(b,.01)
			local  b_rounded_estimate : di %04.2f b_rounded_estimate
			scalar dd_b_string_estimate = "`b_rounded_estimate'"

			// Round Standard Errors
			scalar b_rounded_se = round(se_v2,.01)
			local  b_rounded_se : di %04.2f b_rounded_se
			scalar dd_b_string_se = "("+"`b_rounded_se'"+")"
			
			//Add Stars for Significance 
			if p_val <= .01	{
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{3}"
			}	

			if p_val>.01 & p_val<=.05 {
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{2}"

			}

			if  p_val>.05 & p_val<=.1 {
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{1}"

			}
			else {
				scalar dd_b_string_estimate = dd_b_string_estimate 
			}	
					
			// Add count of full expansion county-years
			sum state if e(sample) == 1 & expansion == 1
			local full_exp_count = `r(N)'
			
			sum state if e(sample) == 1 & expansion == 0
			local full_no_exp_count = `r(N)'	
			
			// Add count of full expansion county-years
			capture drop temp_pop_`age'
			gen temp_pop_`age' = pop_`age'/1000000
			sum temp_pop_`age' if e(sample) == 1 & expansion == 1 & year == 2013
			scalar exp_pop_13_mil = round(`r(sum)',.1)
			scalar  exp_pop_13 = string(exp_pop_13_mil,"%3.1f")

			sum pop_`age' if e(sample) == 1 & expansion == 0 & year == 2013
			scalar no_exp_pop_13 = round(`r(sum)'/1000000,.1)		
			local  no_exp_pop_13 : di %3.1f no_exp_pop_13

			// Add the results
			estadd local dd_b_str = dd_b_string_estimate
			estadd local dd_se_str= dd_b_string_se
					
			// Add indicators for state and year fixed-effects.
			estadd local county_fe "Yes"
			estadd local year_fe "Yes"
			estadd local pop_weights "`weight_label'"
			estadd local controls "No"	
			
			// Add the count and population data
			estadd local full_exp_count = `full_exp_count'
			estadd local exp_pop = exp_pop_13
			
			estadd local full_no_exp_count = `full_no_exp_count'
			estadd local no_exp_pop_13= `no_exp_pop_13'	
			
			// Store the model
			est save "$table_results_path/state_`y_var_prefix'_`death_type'_`age'_nc", replace
			
			////////////////////////////////////////////////////////////////////////
			// With controls
			reghdfe `y_var_prefix'_`death_type'_`age'   i.treatment i.post i.expansion `list_of_controls'  [aw = `weight_var'_`age'] , absorb(state year) cluster(`cluster_var')
			
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[1.treatment])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b = b[1,1]
			scalar se_v2 = sqrt(V[1,1])
			scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

			// Round Estimates to Whatever place we need
			scalar b_rounded_estimate = round(b,.01)
			local  b_rounded_estimate : di %04.2f b_rounded_estimate
			scalar dd_b_string_estimate = "`b_rounded_estimate'"

			// Round Standard Errors
			scalar b_rounded_se = round(se_v2,.01)
			local  b_rounded_se : di %04.2f b_rounded_se
			scalar dd_b_string_se = "("+"`b_rounded_se'"+")"
			
			//Add Stars for Significance 
			if p_val <= .01	{
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{3}"
			}	

			if p_val>.01 & p_val<=.05 {
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{2}"

			}

			if  p_val>.05 & p_val<=.1 {
				scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{1}"

			}
			else {
				scalar dd_b_string_estimate = dd_b_string_estimate 
			}	
						
			// Add count of full expansion county-years
			sum state if e(sample) == 1 & expansion == 1
			local full_exp_count = `r(N)'
			
			sum state if e(sample) == 1 & expansion == 0
			local full_no_exp_count = `r(N)'	
			
			// Add count of full expansion county-years
			capture drop temp_pop_`age'
			gen temp_pop_`age' = pop_`age'/1000000
			sum temp_pop_`age'  if e(sample) == 1 & expansion == 1 & year == 2013
			scalar exp_pop_13_mil = round(`r(sum)',.1)
			scalar  exp_pop_13 = string(exp_pop_13_mil,"%3.1f")

			sum pop_`age' if e(sample) == 1 & expansion == 0 & year == 2013
			scalar no_exp_pop_13 = round(`r(sum)'/1000000,.1)		
			local  no_exp_pop_13 : di %3.1f no_exp_pop_13

			// Add the results
			estadd local dd_b_str = dd_b_string_estimate
			estadd local dd_se_str= dd_b_string_se
					
			// Add indicators for state and year fixed-effects.
			estadd local county_fe "Yes"
			estadd local year_fe "Yes"
			estadd local pop_weights "`weight_label'"
			estadd local controls "Yes"	
			
			// Add the count and population data
			estadd local full_exp_count = `full_exp_count'
			estadd local exp_pop = exp_pop_13
			
			estadd local full_no_exp_count = `full_no_exp_count'
			estadd local no_exp_pop_13= `no_exp_pop_13'	
			
			// Store the model
			est save "$table_results_path/state_`y_var_prefix'_`death_type'_`age'_c", replace


		}
	}
	////////////////////////////////////////////////////////////////////////
	// DDD
		
	// Reshape the data
	keep ///
		state  year state ///
		`y_var_prefix'_amen_* `y_var_prefix'_namen_* `y_var_prefix'_any_* attpop_* pop_* ///
		`list_of_controls' ///
		expansion post
	keep ///
		state  year state /// 
		*_55_64 *_65_74 /// 
		`list_of_controls' ///
		expansion post

	reshape long `y_var_prefix'_amen_@ `y_var_prefix'_namen_@ `y_var_prefix'_any_@ attpop_@ pop_@, i(state year) j(age) string
	rename *_ *

	// Keep only the ages
	keep if age == "55_64" | age == "65_74"		

	// Generate age indicator
	gen treated_age = 0
	replace treated_age = 1 if age == "55_64"

	// Generate treatment_effect_ddd
	gen ddd_treat  = treated_age*post*expansion

	gen dd_treat = expansion*post
	gen age_post = treated_age*post
	gen age_treat = treated_age*expansion
	
	// Weights for DDD when unweighted
	gen one = 1

	foreach death_type in amen namen any {
		////////////////////////////////////////////////////////////////////////////
		// Run the regression: Without controls
		reghdfe `y_var_prefix'_`death_type' ///
			expansion post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			[aw = `weight_var'] , absorb(state year) cluster(`cluster_var')
			
		////////////////////////////////////////////////////////////////////////////
		// DD
		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.dd_treat])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		scalar dd_b_string_estimate = "`b_rounded_estimate'"

		// Round Standard Errors
		scalar b_rounded_se = round(se_v2,.01)
		local  b_rounded_se : di %04.2f b_rounded_se
		scalar dd_b_string_se = "("+"`b_rounded_se'"+")"
		
		//Add Stars for Significance 
		if p_val <= .01	{
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{3}"
		}	

		if p_val>.01 & p_val<=.05 {
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{2}"

		}

		if  p_val>.05 & p_val<=.1 {
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{1}"

		}
		else {
			scalar dd_b_string_estimate = dd_b_string_estimate 
		}	
			
		////////////////////////////////////////////////////////////////////////////
		// DDD
		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.ddd_treat])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		scalar ddd_b_string_estimate = "`b_rounded_estimate'"

		// Round Standard Errors
		scalar b_rounded_se = round(se_v2,.01)
		local  b_rounded_se : di %04.2f b_rounded_se
		scalar ddd_b_string_se = "("+"`b_rounded_se'"+")"
		
		//Add Stars for Significance 
		if p_val <= .01	{
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{3}"
		}	

		if p_val>.01 & p_val<=.05 {
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{2}"

		}

		if  p_val>.05 & p_val<=.1 {
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{1}"

		}
		else {
			scalar ddd_b_string_estimate = ddd_b_string_estimate 
		}					
		// Add count of full expansion county-years
		sum state if e(sample) == 1 & expansion == 1
		local full_exp_count = `r(N)'
		
		sum state if e(sample) == 1 & expansion == 0
		local full_no_exp_count = `r(N)'	
		
		// Add count of full expansion county-years
		capture drop temp_pop
		gen temp_pop = pop/1000000
		sum temp_pop  if e(sample) == 1 & expansion == 1 & year == 2013
		scalar exp_pop_13_mil = round(`r(sum)',.1)
		scalar  exp_pop_13 = string(exp_pop_13_mil,"%3.1f")

		sum pop if e(sample) == 1 & expansion == 0 & year == 2013
		scalar no_exp_pop_13 = round(`r(sum)'/1000000,.1)		
		local  no_exp_pop_13 : di %3.1f no_exp_pop_13

		// Add the results
		estadd local dd_b_str = dd_b_string_estimate
		estadd local dd_se_str= dd_b_string_se
		
		estadd local ddd_b_str = ddd_b_string_estimate
		estadd local ddd_se_str= ddd_b_string_se			
		
		// Add indicators for state and year fixed-effects.
		estadd local county_fe "Yes"
		estadd local year_fe "Yes"
		estadd local pop_weights "`weight_label'"
		estadd local controls "No"	
		
		// Add the count and population data
		estadd local full_exp_count = `full_exp_count'
		estadd local exp_pop = exp_pop_13
		
		estadd local full_no_exp_count = `full_no_exp_count'
		estadd local no_exp_pop_13= `no_exp_pop_13'	
		
		// Store the model
		est save "$table_results_path/state_`y_var_prefix'_`death_type'_ddd_nc", replace
		
		////////////////////////////////////////////////////////////////////////////
		// Run the regression: With Controls
		reghdfe `y_var_prefix'_`death_type' ///
			expansion post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			`list_of_controls' ///
			[aw = `weight_var'] , absorb(state year) cluster(`cluster_var')
			
		////////////////////////////////////////////////////////////////////////////
		// DD
		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.dd_treat])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		scalar dd_b_string_estimate = "`b_rounded_estimate'"

		// Round Standard Errors
		scalar b_rounded_se = round(se_v2,.01)
		local  b_rounded_se : di %04.2f b_rounded_se
		scalar dd_b_string_se = "("+"`b_rounded_se'"+")"
		
		//Add Stars for Significance 
		if p_val <= .01	{
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{3}"
		}	

		if p_val>.01 & p_val<=.05 {
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{2}"

		}

		if  p_val>.05 & p_val<=.1 {
			scalar dd_b_string_estimate = dd_b_string_estimate + "\nlsym{1}"

		}
		else {
			scalar dd_b_string_estimate = dd_b_string_estimate 
		}	
			
		////////////////////////////////////////////////////////////////////////////
		// DDD
		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.ddd_treat])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		scalar ddd_b_string_estimate = "`b_rounded_estimate'"

		// Round Standard Errors
		scalar b_rounded_se = round(se_v2,.01)
		local  b_rounded_se : di %04.2f b_rounded_se
		scalar ddd_b_string_se = "("+"`b_rounded_se'"+")"
		
		//Add Stars for Significance 
		if p_val <= .01	{
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{3}"
		}	

		if p_val>.01 & p_val<=.05 {
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{2}"

		}

		if  p_val>.05 & p_val<=.1 {
			scalar ddd_b_string_estimate = ddd_b_string_estimate + "\nlsym{1}"

		}
		else {
			scalar ddd_b_string_estimate = ddd_b_string_estimate 
		}					
		// Add count of full expansion county-years
		sum state if e(sample) == 1 & expansion == 1
		local full_exp_count = `r(N)'
		
		sum state if e(sample) == 1 & expansion == 0
		local full_no_exp_count = `r(N)'	
		
		// Add count of full expansion county-years
		capture drop temp_pop
		gen temp_pop = pop/1000000
		sum temp_pop  if e(sample) == 1 & expansion == 1 & year == 2013
		scalar exp_pop_13_mil = round(`r(sum)',.1)
		scalar  exp_pop_13 = string(exp_pop_13_mil,"%3.1f")
		
		sum pop if e(sample) == 1 & expansion == 0 & year == 2013
		scalar no_exp_pop_13 = round(`r(sum)'/1000000,.1)		
		local  no_exp_pop_13 : di %3.1f no_exp_pop_13

		// Add the results
		estadd local dd_b_str = dd_b_string_estimate
		estadd local dd_se_str= dd_b_string_se
		
		estadd local ddd_b_str = ddd_b_string_estimate
		estadd local ddd_se_str= ddd_b_string_se			
		
		// Add indicators for state and year fixed-effects.
		estadd local county_fe "Yes"
		estadd local year_fe "Yes"
		estadd local pop_weights "`weight_label'"
		estadd local controls "Yes"	
		
		// Add the count and population data
		estadd local full_exp_count = `full_exp_count'
		estadd local exp_pop = exp_pop_13
		
		estadd local full_no_exp_count = `full_no_exp_count'
		estadd local no_exp_pop_13= `no_exp_pop_13'	
		
		// Store the model
		est save "$table_results_path/state_`y_var_prefix'_`death_type'_ddd_c", replace

	}

	///////////////////////////////////////////////////////////////////////////////
	// Reload results into memory
	clear all

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
			using "$table_results_path/state_regression_results_`file_name_suffix'.tex" ///
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
				mgroups("\shortstack{DD\\ 55-64 years}" "\shortstack{DD\\ 65-74 years}" "\shortstack{DDD\\\textcolor{white}{55-64 years}}", pattern(1 0 1 0 1 0) prefix(\multicolumn{2}{c}{\underline{\smash{~) suffix(~}}})  span) ///
				prehead( "&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}\\")
		

		esttab ///
			state_`y_var_prefix'_namen_55_64_nc state_`y_var_prefix'_namen_55_64_c ///
			state_`y_var_prefix'_namen_65_74_nc state_`y_var_prefix'_namen_65_74_c ///
			state_`y_var_prefix'_namen_ddd_nc state_`y_var_prefix'_namen_ddd_c ///
			using "$table_results_path/state_regression_results_`file_name_suffix'.tex" ///
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
			using "$table_results_path/state_regression_results_`file_name_suffix'.tex" ///
			,star(* 0.10 ** 0.05 *** .01) ///
			stats( ///
				dd_b_str dd_se_str ///
				ddd_b_str ddd_se_str ///
				pop_weights county_fe year_fe controls ///
				N ///
				full_exp_count exp_pop ///	
				full_no_exp_count no_exp_pop_13 ///
				, fmt(0 0 ///
					  0 0 ///
				0 0 0 0 ///
				0 ///
				0 0 ///
				0 0) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}"  ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("\emph{All Mortality} &&&&&\\ \addlinespace  \hspace{0.5cm}Full expansion dummy" "\vspace{.25cm}~" ///
						"\hspace{0.5cm}Full expansion dummy x Age 55-64 dummy"  "\vspace{.25cm}~" ///
					" \addlinespace \hline Weights" "County fixed-effects" "Year fixed-effects" "Covariates" ///
					"\hline Observations" ///
					"Full expansion county-years" "Full expansion population, 2013 (millions)" ///
					"Non-expansion county-years" "Non-expansion population, 2013 (millions)")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				append  ///
				nomtitles nonumbers noline 
end				

/////////////////////////////////////////////////////////////////////////////////
// Run program

// ATTxPop - State Cluster
state_regression_results, ///
	weight_var(attpop) /// 
	weight_label(ATTxPop) /// 
	y_var_prefix(ln) ///   
	cluster_var(state) ///
	file_name_suffix(state_ln_amenable_attpop) ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")
/*
// ATTxPop - State Cluster
state_regression_results, ///
	weight_var(pop) /// 
	weight_label(pop) /// 
	y_var_prefix(ln) ///   
	cluster_var(state) ///
	file_name_suffix(state_ln_amenable_pop) ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")
*/
