* Leticia Nunes
* 2020-12-17
* First Stage: estimating drop in insurance caused by Medicaid expansion
* ACS State Level Data & SAHIE State & County Data
* Paper Table

//-----------------------------------------------------------------
// SET UP - ACS DATA
//-----------------------------------------------------------------

**** Set up
clear all


**** Input File
global df_ACS = "$public_data_analysis/Ins_PopCtrlAtt_StYr_ACS_2008-2017.dta"
global df_SAHIE_St = "$public_data_analysis/Unins_PopCtrlAtt_StYr_SAHIE.dta"
global df_SAHIE_Cty = "$public_data_analysis/Unins_PopCtrlAtt_CtyYr_SAHIE.dta"


**** Locals
loc controls Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate ///
			 diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent ///
			 smoking_all physicians_pc
loc AgeGrp `" "_55_64" "_65_74" "' //"_18_64" "_55_64" "_65_74"
loc ageacs "_55_64" // "_18_64" "_55_64"
loc agesahie "_50_64" //"18_64" "50_64"
loc DemogrEducIncGrp_ACS `" "" "_female" "_male" "_whitenohisp" "_blacknohisp" "_othernohisp" "_hisp" "_elemsch" "_highschincomp" "_highschcomp" "_college" "_blw138pvt" "_btw138400pvt" "'
loc DemogrEducIncGrp_SAHIE_St `" "" "_fem" "_male" "_wh" "_bl" "_hi" "_blw138pvt" "_btw138400pvt" "'
loc DemogrEducIncGrp_SAHIE_Cty `" "" "_fem" "_male" "_blw138pvt" "_btw138400pvt" "'

//////////////////////////////////////////////////////////////////////////////////
// SAHIE 

//---------------------------------------------------------------
// DD for First Stage - SAHIE DATA
//---------------------------------------------------------------

**** Run DD for each Age/Demogr-Educ-Income
foreach weight in "pop" "attpop" {
	
	if "`weight'" == "pop" {
		local weight_label "Pop"
	}
	if "`weight'" == "attpop" {
		local weight_label "ATTxPop"
	}
	foreach ctyst in "St" "Cty" {
	   
		** Load data
		use "${df_SAHIE_`ctyst'}", clear
		drop if Year == 2017
		keep if Expansion4 == 1 | Expansion4 == 0
		
		** Create DD main variable
		gen exp_post = Expansion * Post
	
		foreach dei of loc DemogrEducIncGrp_SAHIE_`ctyst' {

			** Regression
				reghdfe pctui`agesahie'`dei' exp_post Post Expansion ///
						`controls' ///
						[aw=`weight'`agesahie'`dei'], ///
						a(`ctyst'_FIPS Year)  cluster(St_FIPS)
				// Add indicators for state and year fixed-effects.
				estadd local county_fe "Yes"
				estadd local year_fe "Yes"
				estadd local pop_weights "`weight_label'"
				estadd local controls "Yes"	
							
				// Store the model
				est save "$first_stage_results_path/first_stage_sahie_dd_`ctyst'_`weight'`dei'_c", replace
		}
	}
}
//////////////////////////////////////////////////////////////////////////////////
// ACS 
**** Load data
use "$df_ACS", clear

**** Create DD main variable
gen exp_post = Expansion * Post
keep if Expansion == 1 | Expansion == 0
drop if Year == 2017

local weight attpop
local age _55_64
local dei

** Regression

/////////////////////////////////////////////////////////////////////////////////
// ACS DD

foreach weight in pop attpop {	
	if "`weight'" == "pop" {
		local weight_label "Pop"
	}
	if "`weight'" == "attpop" {
		local weight_label "ATTxPop"
	}
	foreach age of loc AgeGrp {
		foreach dei of loc DemogrEducIncGrp_ACS {
			
			// With controls
			capture drop temp_y 
			gen temp_y = 100-pct_hins`age'`dei'
			reghdfe temp_y   i.exp_post i.Post i.Expansion ///
				`controls' ///
				[aw = `weight'`age'`dei'] , ///
				absorb(St_FIPS Year) cluster(St_FIPS)
						
				// Add indicators for state and year fixed-effects.
				estadd local county_fe "Yes"
				estadd local year_fe "Yes"
				estadd local pop_weights "`weight_label'"
				estadd local controls "Yes"	
				
				// Store the model
				est save "$first_stage_results_path/first_stage_acs_dd_`weight'`age'`dei'_c", replace
		}
	}
}


//---------------------------------------------------------------
// DDD for First Stage - ACS DATA
//---------------------------------------------------------------

**** Run DDD for each Demogr-Educ-Income

// First for 55-64 and 65-74
use "$df_ACS", clear
reshape long pct_hins_ pct_hipriv_ pct_himcaid_ pop_ attpop_, i(Year St_FIPS) j(aux) string
drop if Expansion == .
drop if Year == 2017
keep if Expansion == 1 | Expansion == 0

// Keep only the ages
keep if aux == "55_64" | aux == "65_74"		

// Generate age indicator
gen treated_age = 0
replace treated_age = 1 if aux == "55_64"

// Generate treatment_effect_ddd
gen ddd_treat  = treated_age*Post*Expansion

gen dd_treat = Expansion*Post
gen age_post = treated_age*Post
gen age_treat = treated_age*Expansion
		
foreach weight in pop attpop {	
	if "`weight'" == "pop" {
		local weight_label "Pop"
	}
	if "`weight'" == "attpop" {
		local weight_label "ATTxPop"
	}

	capture drop temp_y
	gen temp_y = 100-pct_hins_
	reghdfe temp_y ///
		Expansion Post treated_age ///
		i.dd_treat age_post age_treat ///
		i.ddd_treat ///
		`controls' ///
		[aw = `weight'] , absorb(St_FIPS Year) cluster(St_FIPS)
		
	// Add indicators for state and year fixed-effects.
	estadd local county_fe "Yes"
	estadd local year_fe "Yes"
	estadd local pop_weights "`weight_label'"
	estadd local controls "Yes"	
				
	// Store the model
	est save "$first_stage_results_path/first_stage_acs_ddd_`weight'_c", replace				
}		

foreach dei of loc DemogrEducIncGrp_ACS {

	// Second for demographic subgroups
	use "$df_ACS", clear
	reshape long pct_hins_ pct_hipriv_ pct_himcaid_ pop_ attpop_, i(Year St_FIPS) j(aux) string
	drop if Expansion == .
	drop if Year == 2017
	keep if Expansion == 1 | Expansion == 0

	// Keep only the ages
	keep if aux == "55_64`dei'" | aux == "65_74`dei'"		

	// Generate age indicator
	gen treated_age = 0
	replace treated_age = 1 if aux == "55_64`dei'"

	// Generate treatment_effect_ddd
	gen ddd_treat  = treated_age*Post*Expansion

	gen dd_treat = Expansion*Post
	gen age_post = treated_age*Post
	gen age_treat = treated_age*Expansion
			
	
	foreach weight in pop attpop {	
		if "`weight'" == "pop" {
			local weight_label "Pop"
		}
		if "`weight'" == "attpop" {
			local weight_label "ATTxPop"
		}
		capture drop temp_y
		gen temp_y = 100-pct_hins_
		reghdfe temp_y ///
			Expansion Post treated_age ///
			i.dd_treat age_post age_treat ///
			i.ddd_treat ///
			`controls' ///
			[aw = `weight'] , absorb(St_FIPS Year) cluster(St_FIPS)
			
		// Add indicators for state and year fixed-effects.
		estadd local county_fe "Yes"
		estadd local year_fe "Yes"
		estadd local pop_weights "`weight_label'"
		estadd local controls "Yes"	
					
		// Store the model
		est save "$first_stage_results_path/first_stage_acs_ddd_`weight'`dei'_c", replace				
	}		
}

	// Create blank regression
	reg PovertyPrcnt St_FIPS
	est save "$first_stage_results_path/first_stage_blank_c", replace

////////////////////////////////////////////////////////////////////////////////
// Make combined table


	// Reload results into memory
	clear all
	
	**** Locals
	loc controls Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH PovertyPrcnt UnempRate ///
				 diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent ///
				 smoking_all physicians_pc
	loc AgeGrp `" "_55_64" "_65_74" "' //"_18_64" "_55_64" "_65_74"
	loc ageacs "_55_64" // "_18_64" "_55_64"
	loc agesahie "_50_64" //"18_64" "50_64"
	loc DemogrEducIncGrp_ACS `" "" "_female" "_male" "_whitenohisp" "_blacknohisp" "_othernohisp" "_hisp" "_elemsch" "_highschincomp" "_highschcomp" "_college" "_blw138pvt" "_btw138400pvt" "'
	loc DemogrEducIncGrp_SAHIE_St `" "" "_fem" "_male" "_wh" "_bl" "_hi" "_blw138pvt" "_btw138400pvt" "'
	loc DemogrEducIncGrp_SAHIE_Cty `" "" "_fem" "_male" "_blw138pvt" "_btw138400pvt" "'


	// SAHIE
	foreach weight in "pop" "attpop" {
		foreach ctyst in "St" "Cty" {
			foreach dei of loc DemogrEducIncGrp_SAHIE_`ctyst' {
			
				est use "$first_stage_results_path/first_stage_sahie_dd_`ctyst'_`weight'`dei'_c"
				if "`dei'" == "_highschincomp" {
					local dei _nohs
				}
				if "`dei'" == "_highschcomp" {
					local dei _hs
				}
				if "`dei'" == "_whitenohisp" {
					local dei _w
				}				
				if "`dei'" == "_blacknohisp" {
					local dei _b
				}	
				if "`dei'" == "_othernohisp" {
					local dei _o
				}	
				if "`dei'" == "_btw138400pvt" {
					local dei _14
				}	
				est sto s_`ctyst'_dd_`weight'`dei'
				
			}
		}
	}

	// ACS DD 
	foreach weight in pop attpop {	
		foreach age of loc AgeGrp {
			foreach dei of loc DemogrEducIncGrp_ACS {
				est use "$first_stage_results_path/first_stage_acs_dd_`weight'`age'`dei'_c"
				if "`dei'" == "_highschincomp" {
					local dei _nohs
				}
				if "`dei'" == "_highschcomp" {
					local dei _hs
				}
				if "`dei'" == "_whitenohisp" {
					local dei _w
				}	
				if "`dei'" == "_blacknohisp" {
					local dei _b
				}	
				if "`dei'" == "_othernohisp" {
					local dei _o
				}	
				if "`dei'" == "_btw138400pvt" {
					local dei _14
				}					
				est sto a_dd_`weight'`age'`dei'
			}
		}
	}

	// ACS DDD
	foreach weight in pop attpop {	
		foreach age of loc AgeGrp {
			foreach dei of loc DemogrEducIncGrp_ACS {
				est use "$first_stage_results_path/first_stage_acs_ddd_`weight'`dei'_c"
				if "`dei'" == "_highschincomp" {
					local dei _nohs
				}
				if "`dei'" == "_highschcomp" {
					local dei _hs
				}
				if "`dei'" == "_whitenohisp" {
					local dei _w
				}				
				if "`dei'" == "_blacknohisp" {
					local dei _b
				}	
				if "`dei'" == "_othernohisp" {
					local dei _o
				}	
				if "`dei'" == "_btw138400pvt" {
					local dei _14
				}	
				est sto a_ddd_`weight'`dei'
			}
		}
	}
	
	// Blank regression
	est use "$first_stage_results_path/first_stage_blank_c"
	est sto blank
	////////////////////////////////////////////////////////////////////////
	// Export results

foreach weight in pop attpop {		
	// All groups 
	esttab ///
		a_dd_`weight'_55_64 ///
		a_dd_`weight'_65_74 ///
		a_ddd_`weight' ///
		s_St_dd_`weight' ///
		s_Cty_dd_`weight' /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "All") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		replace  ///
		nomtitles ///
		noobs ///
		mgroups("\shortstack{DD\\ 55-64}" "\shortstack{DD\\ 65-74}" "\shortstack{DDD\\\textcolor{white}{55-64}}" "\shortstack{State DD\\ 50-64}" "\shortstack{County DD\\ 50-64}", pattern(1 1 1 1 1) prefix(\multicolumn{1}{c}{\underline{\smash{~) suffix(~}}})  span) ///
		prehead( "&\multicolumn{3}{c}{ACS (County-level)}&\multicolumn{2}{c}{SAHIE}\\ \cmidrule(l){2-4} \cmidrule(l){5-6} \\ ")
		

	// Females
	esttab ///
		a_dd_`weight'_55_64_female ///
		a_dd_`weight'_65_74_female ///
		a_ddd_`weight'_female ///
		s_St_dd_`weight'_fem ///
		s_Cty_dd_`weight'_fem /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Female") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// Males
	esttab ///
		a_dd_`weight'_55_64_male ///
		a_dd_`weight'_65_74_male ///
		a_ddd_`weight'_male ///
		s_St_dd_`weight'_male ///
		s_Cty_dd_`weight'_male /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Male") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	

	// White non-hispanic
	esttab ///
		a_dd_`weight'_55_64_w ///
		a_dd_`weight'_65_74_w ///
		a_ddd_`weight'_w ///
		s_St_dd_`weight'_wh ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "White (non-Hispanic)") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// Black non-hispanic
	esttab ///
		a_dd_`weight'_55_64_b ///
		a_dd_`weight'_65_74_b ///
		a_ddd_`weight'_b ///
		s_St_dd_`weight'_bl ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Black (non-Hispanic)") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers			
	
	// Other non-hispanic
	esttab ///
		a_dd_`weight'_55_64_o ///
		a_dd_`weight'_65_74_o ///
		a_ddd_`weight'_o ///
		blank ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Other (non-Hispanic)") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// Hispanic
	esttab ///
		a_dd_`weight'_55_64_hisp ///
		a_dd_`weight'_65_74_hisp ///
		a_ddd_`weight'_hisp ///
		s_St_dd_`weight'_hi ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Hispanic") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// Elementary School
	esttab ///
		a_dd_`weight'_55_64_elemsch ///
		a_dd_`weight'_65_74_elemsch ///
		a_ddd_`weight'_elemsch ///
		blank ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Elementary school") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers
		
	// NO HS
	esttab ///
		a_dd_`weight'_55_64_nohs ///
		a_dd_`weight'_65_74_nohs ///
		a_ddd_`weight'_nohs ///
		blank ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "High school incomplete") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers		
	// HS
	esttab ///
		a_dd_`weight'_55_64_hs ///
		a_dd_`weight'_65_74_hs ///
		a_ddd_`weight'_hs ///
		blank ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "High school complete") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// College
	esttab ///
		a_dd_`weight'_55_64_college ///
		a_dd_`weight'_65_74_college ///
		a_ddd_`weight'_college ///
		blank ///
		blank /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Some college") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers			
		
	// Below 138% FPL
	esttab ///
		a_dd_`weight'_55_64_blw138pvt ///
		a_dd_`weight'_65_74_blw138pvt ///
		a_ddd_`weight'_blw138pvt ///
		s_St_dd_`weight'_blw138pvt ///
		s_Cty_dd_`weight'_blw138pvt /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "Below 138\% FPL") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// 138%-400% FPL
	esttab ///
		a_dd_`weight'_55_64_14 ///
		a_dd_`weight'_65_74_14 ///
		a_ddd_`weight'_14 ///
		s_St_dd_`weight'_14 ///
		s_Cty_dd_`weight'_14 /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		keep(treatment) ///
		coeflabel(treatment "138\%-400\% FPL") ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		noobs ///
		nomtitles ///
		noline ///
		nonumbers	
		
	// End matter
	esttab ///
		a_dd_`weight'_55_64 ///
		a_dd_`weight'_65_74 ///
		a_ddd_`weight' ///
		s_St_dd_`weight' ///
		s_Cty_dd_`weight' /// 
		using "$first_stage_results_path/first_stage_`weight'.tex" ///
		, ///
		star(* 0.10 ** 0.05 *** .01) ///
		rename(1.exp_post treatment 1.ddd_treat treatment exp_post treatment) ///
		drop(*) ///
		se ///
		b(%9.2f) ///
		booktabs ///
		f ///
		append  ///
		nomtitles ///
		noline ///
		nonumbers	///
		stats(N county_fe year_fe  controls pop_weights ///
				, fmt(0 0 ///
					  0 0 ///
				0 ) ///
				layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
					"\multicolumn{1}{c}{@}") ///
				label( "\midrule Observations" "Unit fixed-effects (state or county)" "Year fixed-effects" "Covariates" "Weights used"  )) 
}		
				
