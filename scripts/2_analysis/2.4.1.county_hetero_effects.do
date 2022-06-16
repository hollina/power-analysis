
	
	// For debugging
	local weight_var attpop // weight variable (pop attpop)
	local weight_label "ATTxPop"  // weight label (pop attpop)
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

	// Open main dataset
	use "$restricted_data_analysis/death_rates_1999_2017.dta", clear

	// Merge in control data at the county-level
	merge 1:1 state county year using "$restricted_data_analysis/county_controls_with_att_pop.dta"
	keep if _merge == 3
	drop _merge 

	// Keep only certain years
	keep if year >= 2004
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
	replace expansion_4=1 if state_abbr == "LA" //LA expanded in Nov 2016
	//LA expanded in July 2016

	** Creating post Variable
	gen post = (year>= 2014)
	replace post=0 if state_abbr == "NH" & year == 2014  //NH expanded in August 2014
	replace post=0 if state_abbr == "PA" & year == 2014  //PA expanded in Jan 2015
	replace post=0 if state_abbr == "IN" & year == 2014 //IN expanded in Feb 2015
	replace post=0 if state_abbr == "AK" & (year == 2014 | year == 2015) //AK expanded in Sept 2015	
	replace post=0 if state_abbr == "MT" & (year == 2014 | year == 2015) //MT expanded in Jan 2016	
	replace post=0 if state_abbr == "LA" & (year == 2014 | year == 2015 | year == 2016) //LA expanded in Nov 2016	

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
	gen expansion = expansion_4
	gen treatment = expansion * post 


	// Generate a weight of one for the unweighted loop
	foreach age in 55_64 65_74 {
		gen one_`age' = 1
	}
	
	// Foreach death type
	foreach death_type in amen namen any resp can card hiv dia {
	*local death_type amen
		
		// For each age	
		foreach age in 55_64 65_74 {
			*local age 55_64
			

			
			////////////////////////////////////////////////////////////////////////		
			// DD
			

			////////////////////////////////////////////////////////////////////////
			// With controls
			reghdfe ln_`death_type'_`age'   i.treatment i.post i.expansion Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc  [aw = attpop_`age'] , absorb(unique_county_id year) cluster(state)
			
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
			sum unique_county_id if e(sample) == 1 & expansion == 1
			local full_exp_count = `r(N)'
			
			sum unique_county_id if e(sample) == 1 & expansion == 0
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
			est save "$table_results_path/ln_`death_type'_`age'_c", replace


		}
	}
	
	// Foreach demographic group type
	foreach dem_group in male fem white_non_hisp black_non_hisp hisp {
	*local death_type amen
		
		// For each age	
		foreach age in 55_64 65_74 {
			*local age 55_64
			

			
			////////////////////////////////////////////////////////////////////////		
			// DD
			

			////////////////////////////////////////////////////////////////////////
			// With controls
			reghdfe ln_amen_`dem_group'_`age'   i.treatment i.post i.expansion Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc  [aw = attpop_`dem_group'_`age' ] , absorb(unique_county_id year) cluster(state)
			
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
			sum unique_county_id if e(sample) == 1 & expansion == 1
			local full_exp_count = `r(N)'
			
			sum unique_county_id if e(sample) == 1 & expansion == 0
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
			est save "$table_results_path/ln_amen_`dem_group'_`age'_c", replace


		}
	}
	
	////////////////////////////////////////////////////////////////////////
	// DDD
		
	// Reshape the data
	keep ///
		state county year unique_county_id ///
		ln_amen_* ln_namen_* ln_any_* ln_resp_* ln_can_* ln_card_* ln_hiv_* ln_dia_* ///
		attpop_* pop_* ///
		Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc ///
		expansion post
	keep ///
		state county year unique_county_id /// 
		*_55_64 *_65_74 *45_64 *_eld /// 
		Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc ///
		expansion post

	reshape long ///
		ln_amen_@ ln_resp_@ ln_can_@ ln_card_@ ln_hiv_@ ln_dia_@ ///
		ln_namen_@ ln_any_@ attpop_@ pop_@, i(unique_county_id year) j(age) string
	rename *_ *
	
	save $temp_path/temp_mort_data.dta, replace
	clear
	// By cause-of-death
	foreach death_type in amen namen any resp can card hiv dia {

		use $temp_path/temp_mort_data.dta, clear
		
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

		////////////////////////////////////////////////////////////////////////////
		// Run the regression: With Controls
		reghdfe ln_`death_type' ///
			expansion post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			`list_of_controls' ///
			[aw = attpop] , absorb(unique_county_id year) cluster(state)
			
		
			
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
		sum unique_county_id if e(sample) == 1 & expansion == 1
		local full_exp_count = `r(N)'
		
		sum unique_county_id if e(sample) == 1 & expansion == 0
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

		// Add the results (Note, I am calling the DDD coef the DD so it will end up on the same line in esttab exported tex table)
		estadd local dd_b_str = ddd_b_string_estimate
		estadd local dd_se_str= ddd_b_string_se			
		
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
		est save "$table_results_path/ln_`death_type'_ddd_c", replace

	}
	
	// By demographic group
	foreach dem_group in male fem white_non_hisp black_non_hisp hisp {

		use $temp_path/temp_mort_data.dta, clear
		
		keep if age == "`dem_group'_55_64" | age == "`dem_group'_65_74"	
		replace age = "55_64" if age == "`dem_group'_55_64" 
		replace age = "65_74" if age == "`dem_group'_65_74" 
		
		
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

		////////////////////////////////////////////////////////////////////////////
		// Run the regression: With Controls
		reghdfe ln_amen ///
			expansion post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			`list_of_controls' ///
			[aw = attpop] , absorb(unique_county_id year) cluster(state)
			
		
			
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
		sum unique_county_id if e(sample) == 1 & expansion == 1
		local full_exp_count = `r(N)'
		
		sum unique_county_id if e(sample) == 1 & expansion == 0
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

		// Add the results (Note, I am calling the DDD coef the DD so it will end up on the same line in esttab exported tex table)
		estadd local dd_b_str = ddd_b_string_estimate
		estadd local dd_se_str= ddd_b_string_se			
		
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
		est save "$table_results_path/ln_amen_`dem_group'_ddd_c", replace

	}

	///////////////////////////////////////////////////////////////////////////////
	// Reload results into memory
	clear all

	// Foreach death type
	foreach death_type in any amen namen resp can card hiv dia {
		// For each age	
		foreach age in 55_64 65_74 ddd {
			est use "$table_results_path/ln_`death_type'_`age'_c.ster"
			est sto ln_`death_type'_`age'_c
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

	////////////////////////////////////////////////////////////////////////
	// Export results

		esttab ///
			ln_amen_55_64_c ///
			ln_amen_65_74_c ///
			ln_amen_ddd_c ///
			using "$table_results_path/appendix_regression_results_`file_name_suffix'.tex" ///
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
				mgroups("\shortstack{DD\\ 55-64 years}" "\shortstack{DD\\ 65-74 years}" "\shortstack{DDD\\\textcolor{white}{55-64 years}}", pattern(1 1 1) prefix(\multicolumn{1}{c}{\underline{\smash{~) suffix(~}}})  span) ///
				prehead( "&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}&\multicolumn{1}{c}{~}\\")
		
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
			 ln_`death_type'_55_64_c ///
			 ln_`death_type'_65_74_c ///
			 ln_`death_type'_ddd_c ///
			using "$table_results_path/appendix_regression_results_`file_name_suffix'.tex" ///
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
			 ln_amen_`dem_group'_55_64_c ///
			 ln_amen_`dem_group'_65_74_c ///
			 ln_amen_`dem_group'_ddd_c ///
			using "$table_results_path/appendix_regression_results_`file_name_suffix'.tex" ///
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
			 ln_amen_hisp_55_64_c ///
			 ln_amen_hisp_65_74_c ///
			 ln_amen_hisp_ddd_c ///
			using "$table_results_path/appendix_regression_results_`file_name_suffix'.tex" ///
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
					" \addlinespace \hline Weights" "County fixed-effects" "Year fixed-effects" "Covariates")) ///
				drop(*) ///
				se ///
				b(%9.2f) ///
				booktabs ///
				f ///
				append  ///
				nomtitles nonumbers noline 	
	
// Clean up 
erase "$temp_path/temp_mort_data.dta"
