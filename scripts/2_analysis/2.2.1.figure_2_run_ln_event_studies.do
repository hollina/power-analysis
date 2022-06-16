///////////////////////////////////////////////////////////////////////////////
// Create program to make event studies for 55-64 DD, 65-74 DD, and DDD. 


capture program drop event_study_graphs

// *----------
program define event_study_graphs
syntax, ///
	weight_var(string) /// 
	y_var_prefix(string) ///   
	cluster_var(string) ///
	file_name_suffix(string) ///
	label_for_graph(string) ///
	first_year(real)  ///
	last_year(real)  ///
	last_treated_year(real)  ///
	first_treated_year(real) /// 
	low_event_cap(real) ///
	high_event_cap(real) ///
	low_event_cap_graph(real) ///
	high_event_cap_graph(real) ///
	list_of_controls(string)
	
*----------
	/*
	// For debugging
	local weight_var attpop // weight variable (pop attpop)
	local y_var_prefix ln_amen  
	local cluster_var state // state or county
	local file_name_suffix ln_amenable // end of file name, before png
	local label_for_graph "amenable mortality rate per 100,000" 
	local first_year 2004 // Anything before 2014. Oldest year of data in analysis
	local last_year  2016 // Anything after 2013. Oldest year of data in analysis
	local last_treated_year 2016 // The last post-period year
	local first_treated_year 2014 // The first post-period year
	local low_event_cap -11 // The earliest year in event time 
	local high_event_cap 2 // The last year in event time
	local low_event_cap_graph -10 // The earliest year in event time to graph (if binding the data above this help keep composition the same in points shown)
	local high_event_cap_graph 2 // The last year in event time to graph (if binding the data above this help keep composition the same in points shown)

	// Create list of control variables
	local list_of_controls Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate ///
				 diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent ///
				 smoking_all physicians_pc
	*/
	
	use "$restricted_data_analysis/death_rates_1999_2017.dta", clear

	// Merge in control data at the county-level
	merge 1:1 state county year using "$restricted_data_analysis/county_controls_with_att_pop.dta"
	keep if _merge == 3
	drop _merge 

	// Keep only certain years
	keep if year >= `first_year' 
	keep if year <= `last_year'

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
	gen expansion = expansion_4
	gen treatment = expansion * post 


	// Set up event studies 
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

	* Position of -2
	if `low_event_cap' > ( `first_year' - `last_treated_year') {
	 local pos_of_neg_2 = abs(2 - (-`low_event_cap' + 1))
	}	

	if `low_event_cap' <= ( `first_year' - `last_treated_year') {
	 local pos_of_neg_2 = abs(2 - (-( `first_year' - `last_treated_year') + 1))
	}

	* Position of 0
	local pos_of_zero = `pos_of_neg_2' + 2

	* Position of max
	if `high_event_cap' >= ( `last_year' - `first_treated_year') {
	 local pos_of_max = `last_year' - `first_treated_year' + `pos_of_zero'
	}	

	if `high_event_cap' < ( `last_year' - `first_treated_year') {
	 local pos_of_max = `high_event_cap' + `pos_of_zero'
	}


	///////////////////////////////////////////////////////////////////////////////

	// Run for each age group
	foreach age in 55_64 65_74 {

		if "`age'" == "55_64" {
			local age_label "55 to 64"
		}
		if "`age'" == "65_74" {
			local age_label "65 to 74"
		}
		
		// Generate a weight of one for the unweighted loop
		gen one_`age' = 1
		
		reghdfe `y_var_prefix'_`age'  i.treatment i.post i.expansion `list_of_controls' [aw = `weight_var'_`age'] , absorb(unique_county_id year) cluster(`cluster_var')

		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.treatment])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		local p = 2*ttail(`e(df_r)',abs(b/se_v2))
				
		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		local estimate = "`b_rounded_estimate'"


		if `p' <= .01 {
			local stars = "***"
			}
			else if `p' <= .05 {
			local stars = "**"
			}
			else if `p' <= .1 {
			local stars = "*"
			}
			else {
			local stars = ""
			}
			
		// Event study 55 - 64
		reghdfe `y_var_prefix'_`age'  _T* `list_of_controls' [aw = `weight_var'_`age'] , absorb(unique_county_id year) cluster(`cluster_var')
		forvalues i = 1(1)`pos_of_neg_2'{
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[_Tevent_tim_`i'])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b_`i' = b[1,1]
			scalar se_v2_`i' = sqrt(V[1,1])
		}
		

		forvalues i = `pos_of_zero'(1)`pos_of_max'{
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[_Tevent_tim_`i'])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b_`i' = b[1,1]
			scalar se_v2_`i' = sqrt(V[1,1])
		}

		capture drop order
		capture drop b 
		capture drop high 
		capture drop low

		gen order = .
		gen b =. 
		gen high =. 
		gen low =.
		
		
		local i = 1
		
		local graph_start  = `low_event_cap_graph' - `low_event_cap' + 1

		forvalues yr = `graph_start'(1)`pos_of_neg_2'{
			local event_time = `yr' - 2 - `pos_of_neg_2'
			replace order = `event_time' in `i'
			
			replace b    = b_`yr' in `i'
			replace high = b_`yr' + 1.96*se_v2_`yr' in `i'
			replace low  = b_`yr' - 1.96*se_v2_`yr' in `i'
				
			local i = `i' + 1
		}

		replace order = -1 in `i'

		replace b    = 0  in `i'
		replace high = 0  in `i'
		replace low  = 0  in `i'

		local i = `i' + 1

		forvalues yr = `pos_of_zero'(1)`pos_of_max'{
			local event_time = `yr' - 2 - `pos_of_neg_2'

			replace order = `event_time' in `i'
			
			replace b    = b_`yr' in `i'
			replace high = b_`yr' + 1.96*se_v2_`yr' in `i'
			replace low  = b_`yr' - 1.96*se_v2_`yr' in `i'
				
			local i = `i' + 1
		}


		////////////////////////////////////////////////////////////////////
		// Plot them together Version

		// Generate color palette (better categorical color scheme)
		colorpalette hsv, dark n(3) nograph
		return list
		
		/*
		local event_pointer_label = b_8 - 1.96*se_v2_8
		local label = (b_8 - 1.96*se_v2_8)*.8
		local event_pointer_end = `event_pointer_label'*1.03

		local pointer_lower = (`estimate')*1.02
		local pointer_upper = (`estimate')*1.07
		local text_location = (`pointer_upper')*0.025
		*/

		twoway rarea low high order if order<=`high_event_cap_graph' & order >= `low_event_cap_graph' , fcol(gs14) lcol(white) msize(3) /// estimates
			|| connected b order if order<=`high_event_cap_graph' & order >= `low_event_cap_graph', lw(1.1) col(white) msize(7) msymbol(s) lp(solid) /// highlighting
			|| connected b order if order<=`high_event_cap_graph' & order >= `low_event_cap_graph', lw(0.6) col("71 71 179") msize(5) msymbol(s) lp(solid) /// connect estimates
			|| scatteri 0 `low_event_cap_graph' 0 `high_event_cap_graph', recast(line) lcol(gs8) lp(longdash) lwidth(0.5) /// zero line 
				xlab(`low_event_cap_graph'(1)`high_event_cap_graph' ///
						, nogrid labsize(7) angle(0)) ///
				ylab(, nogrid labs(7)) ///
				legend(off) ///
				xtitle("Years since ACA expansion", size(7)) ///
				ytitle("Percent effect", size(7)) ///
				subtitle("DD, `age_label'", size(6) pos(11)) ///
				xline(-.5, lpattern(dash) lcolor(gs7) lwidth(1)) 	
				
		graph export "$figure_results_path/event_study_`age'_`file_name_suffix'.png", replace 
		graph export "$figure_results_path/event_study_`age'_`file_name_suffix'.pdf", replace 
	}

	////////////////////////////////////////////////////////////////////////
	// DDD
		
	// Reshape the data
	keep ///
		state county year unique_county_id ///
		`y_var_prefix'_*  pop_* attpop_* ///
		`list_of_controls' ///
		expansion post
		
		*ln_namen_* ln_any_*
		
	keep ///
		state county year unique_county_id /// 
		*_55_64 *_65_74 /// 
		`list_of_controls' ///
		expansion post

	reshape long `y_var_prefix'_@ pop_@ attpop_@, i(unique_county_id year) j(age) string
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

	// Generate a weight of one for the unweighted loop
	gen one = 1
	
	// Run the main regression

		reghdfe `y_var_prefix' ///
			expansion post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			`list_of_controls' ///
			[aw = `weight_var'] , absorb(unique_county_id year) cluster(`cluster_var')
			
		//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
		nlcom 100*(exp(_b[1.ddd_treat])-1)
		mat b = r(b)
		mat V = r(V)

		scalar b = b[1,1]
		scalar se_v2 = sqrt(V[1,1])
		local p = 2*ttail(`e(df_r)',abs(b/se_v2))
				
		// Round Estimates to Whatever place we need
		scalar b_rounded_estimate = round(b,.01)
		local  b_rounded_estimate : di %04.2f b_rounded_estimate
		local estimate = "`b_rounded_estimate'"


		if `p' <= .01 {
			local stars = "***"
			}
			else if `p' <= .05 {
			local stars = "**"
			}
			else if `p' <= .1 {
			local stars = "*"
			}
			else {
			local stars = ""
			}


	// Set up event studies 
	********************************************************************************
	*Make timing for DDD (Treat X Age 55-64 X Post)

	capture drop exp_year
	gen exp_year = year if ddd_treat==1

	egen adopt_year = min(exp_year), by(state age)

	* gen event-time (adoption_date = treatment adoption date )
	gen event_time_bacon = year - adopt_year

	* make sure untreated units are included, but also don't get dummies (by giving them "-1")
	recode event_time_bacon (.=-1)  (-1000/`low_event_cap'=`low_event_cap') (`high_event_cap'/1000=`high_event_cap')

	*ensure that "xi" omits -1
	char event_time_bacon[omit] -1

	*mak dummies
	xi i.event_time_bacon, pref(_T)

	* Position of -2
	if `low_event_cap' > ( `first_year' - `last_treated_year') {
	 local pos_of_neg_2 = abs(2 - (-`low_event_cap' + 1))
	}	

	if `low_event_cap' <= ( `first_year' - `last_treated_year') {
	 local pos_of_neg_2 = abs(2 - (-( `first_year' - `last_treated_year') + 1))
	}

	* Position of 0
	local pos_of_zero = `pos_of_neg_2' + 2

	* Position of max
	if `high_event_cap' >= ( `last_year' - `first_treated_year') {
	 local pos_of_max = `last_year' - `first_treated_year' + `pos_of_zero'
	}	

	if `high_event_cap' < ( `last_year' - `first_treated_year') {
	 local pos_of_max = `high_event_cap' + `pos_of_zero'
	}


	********************************************************************************
	*Make timing for DD (Post X Treat) 

	capture drop exp_year
	gen exp_year = year if dd_treat==1
	capture drop adopt_year
	egen adopt_year = min(exp_year), by(state age)

	* gen event-time (adoption_date = treatment adoption date )
	capture drop event_time_bacon
	gen event_time_bacon = year - adopt_year

	* make sure untreated units are included, but also don't get dummies (by giving them "-1")
	recode event_time_bacon (.=-1) (-1000/`low_event_cap'=`low_event_cap') (`high_event_cap'/1000=`high_event_cap')

	*ensure that "xi" omits -1
	char event_time_bacon[omit] -1

	*mak dummies
	xi i.event_time_bacon, pref(_dd_)

	********************************************************************************
	*Make timing for DD (Post X Age 55-64) 

	capture drop exp_year
	gen exp_year = year if age_post==1
	capture drop adopt_year
	egen adopt_year = min(exp_year), by(state age)

	* gen event-time (adoption_date = treatment adoption date )
	capture drop event_time_bacon
	gen event_time_bacon = year - adopt_year

	* make sure untreated units are included, but also don't get dummies (by giving them "-1")
	recode event_time_bacon (.=-1) (-1000/`low_event_cap'=`low_event_cap') (`high_event_cap'/1000=`high_event_cap')

	*ensure that "xi" omits -1
	char event_time_bacon[omit] -1

	*mak dummies
	xi i.event_time_bacon, pref(_da_)


		// Event study 55 - 64
		reghdfe `y_var_prefix' ///
			_T* ///
			_dd_* ///
			_da_* ///
			expansion post treated_age ///
			age_post age_treat ///
			`list_of_controls' ///
			[aw = `weight_var'] , absorb(unique_county_id year) cluster(`cluster_var')
		
			
		forvalues i = 1(1)`pos_of_neg_2'{
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[_Tevent_tim_`i'])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b_`i' = b[1,1]
			scalar se_v2_`i' = sqrt(V[1,1])
		}

		forvalues i = `pos_of_zero'(1)`pos_of_max'{
			//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
			nlcom 100*(exp(_b[_Tevent_tim_`i'])-1)
			mat b = r(b)
			mat V = r(V)

			scalar b_`i' = b[1,1]
			scalar se_v2_`i' = sqrt(V[1,1])
		}

		capture drop order
		capture drop b 
		capture drop high 
		capture drop low

		gen order = .
		gen b =. 
		gen high =. 
		gen low =.
		local i = 1
		
		local graph_start  = `low_event_cap_graph' - `low_event_cap' + 1


		forvalues yr = `graph_start'(1)`pos_of_neg_2'{
			local event_time = `yr' - 2 - `pos_of_neg_2'
			replace order = `event_time' in `i'
			
			replace b    = b_`yr' in `i'
			replace high = b_`yr' + 1.96*se_v2_`yr' in `i'
			replace low  = b_`yr' - 1.96*se_v2_`yr' in `i'
				
			local i = `i' + 1
		}

		replace order = -1 in `i'

		replace b    = 0  in `i'
		replace high = 0  in `i'
		replace low  = 0  in `i'

		local i = `i' + 1

		forvalues yr = `pos_of_zero'(1)`pos_of_max'{
			local event_time = `yr' - 2 - `pos_of_neg_2'


			replace order = `event_time' in `i'
			
			replace b    = b_`yr' in `i'
			replace high = b_`yr' + 1.96*se_v2_`yr' in `i'
			replace low  = b_`yr' - 1.96*se_v2_`yr' in `i'
				
			local i = `i' + 1
		}


		////////////////////////////////////////////////////////////////////
		// Plot them together Version

		// Generate color palette (better categorical color scheme)
		colorpalette hsv, dark n(3) nograph
		return list

		local event_pointer_label = b_8 - 1.96*se_v2_8
		local label = (b_8 - 1.96*se_v2_8)*.8
		local event_pointer_end = `event_pointer_label'*1.03

		local pointer_lower = (`estimate')*1.02
		local pointer_upper = (`estimate')*1.07
		local text_location = (`pointer_upper')*0.025

		twoway rarea low high order if order<=`high_event_cap_graph' & order  >= `low_event_cap_graph' , fcol(gs14) lcol(white) msize(3) /// estimates
			|| connected b order if order<=`high_event_cap_graph' & order  >= `low_event_cap_graph', lw(1.1) col(white) msize(7) msymbol(s) lp(solid) /// highlighting
			|| connected b order if order<=`high_event_cap_graph' &  order >= `low_event_cap_graph', lw(0.6) col("71 71 179") msize(5) msymbol(s) lp(solid) /// connect estimates
			|| scatteri 0 `low_event_cap_graph' 0 `high_event_cap_graph', recast(line) lcol(gs8) lp(longdash) lwidth(0.5) /// zero line 
				xlab(`low_event_cap_graph'(1)`high_event_cap_graph' ///
						, nogrid labsize(7) angle(0)) ///
				ylab(, nogrid labs(7)) ///
				legend(off) ///
				xtitle("Years since ACA expansion", size(7)) ///
				ytitle("Percent effect", size(7)) ///
				subtitle("DDD, 55 to 64 vs. 65 to 74", pos(11) size(6)) ///
				xline(-.5, lpattern(dash) lcolor(gs7) lwidth(1)) 	
				
		graph export "$figure_results_path/event_study_ddd_`file_name_suffix'.png", replace 
		graph export "$figure_results_path/event_study_ddd_`file_name_suffix'.pdf", replace 
end

/////////////////////////////////////////////////////////////////////////////////
// Run program

// Amenable - ATTxPop - State Cluster
event_study_graphs, ///
	weight_var(attpop) /// 
	y_var_prefix(ln_amen) ///   
	cluster_var(state) ///
	file_name_suffix(ln_amenable_attpop) ///
	label_for_graph("log amenable mortality rate") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")

// Amenable - Pop- State Cluster
event_study_graphs, ///
	weight_var(pop) /// 
	y_var_prefix(ln_amen) ///   
	cluster_var(state) ///
	file_name_suffix(ln_amenable_pop) ///
	label_for_graph("amenable mortality rate per 100,000") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")
	
// Amenable - Unweighted- State Cluster- 
event_study_graphs, ///
	weight_var(one) /// 
	y_var_prefix(ln_amen) ///   
	cluster_var(state) ///
	file_name_suffix(ln_amenable_unweighted) ///
	label_for_graph("amenable mortality rate per 100,000") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")

// Amenable - ATTxPop - County Cluster
event_study_graphs, ///
	weight_var(attpop) /// 
	y_var_prefix(ln_amen) ///   
	cluster_var(unique_county_id) ///
	file_name_suffix(ln_amenable_attpop_county_cluster) ///
	label_for_graph("amenable mortality rate per 100,000") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")

		
// Non-amenable - ATTxPop - State Cluster
event_study_graphs, ///
	weight_var(attpop) /// 
	y_var_prefix(ln_namen) ///   
	cluster_var(state) ///
	file_name_suffix(ln_namenable_attpop) ///
	label_for_graph("non-amenable mortality rate per 100,000") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")

	
// All-cause - ATTxPop - State Cluster
event_study_graphs, ///
	weight_var(attpop) /// 
	y_var_prefix(ln_any) ///   
	cluster_var(state) ///
	file_name_suffix(ln_any_attpop) ///
	label_for_graph("all-cause mortality rate per 100,000") ///
	first_year(2004)  ///
	last_year(2016)  ///
	last_treated_year(2016)  ///
	first_treated_year(2014) /// 
	low_event_cap(-11) ///
	high_event_cap(2) ///
	low_event_cap_graph(-10) ///
	high_event_cap_graph(2) ///
	list_of_controls("Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc")
