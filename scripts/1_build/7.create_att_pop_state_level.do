

// Set local macro year
foreach top_trim in 900 925 950 975 1000 {
	local top_trim 950
	use "$restricted_data_analysis/death_rates_1999_2017.dta", clear
	
	qui ds state year ///
		dr_* ln_*, not
		
	gcollapse (sum) `r(varlist)', by(state year)
		
	// Merge in control data at the county-level
	merge 1:1 state year using "$public_data_analysis/state_controls.dta"
	keep if _merge == 3
	drop _merge 
	***TODO (hollinal) FIGURE OUT WHY IT IS NOT PERFECT LATER ON***

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

	// Save this point for merge back in the future
	compress
	save  "$temp_path/temp_state_controls.dta", replace 
	
	drop if year>2013

	gcollapse (mean) ///
		IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet ///
		diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj ///
		pct_unins_65 Mcare_Disab smoking_all physicians_pc ///
		expansion_4 pop* , by(state)
		*pop_male pop_white_non_hisp pop_black_non_hisp pop_55_64 pop_65_74
	drop if  expansion_4 == 2 | expansion_4 == 3

	rename expansion_4 expansion

	logit expansion ///
		pop_male pop_white_non_hisp pop_55_64 IncMedHH ///
		PovertyPrcnt UnempRate Mcare_Adv_Penet pct_unins_65
	
	capture drop p_hat
	predict p_hat


	// ATT WEIGHTS

	// Trip top and bottom 10%
	*gen pctile = 0 

	_pctile p_hat, nq(1000)
	replace p_hat = r(r`top_trim') if p_hat > r(r`top_trim')
	/*
	replace pctile = 1 if p_hat>r(r970) & p_hat < r(r990)

	drop if expansion == 1
	*replace p_hat = r(r`top_trim') if p_hat > r(r`top_trim')
	sort state county 
	bro if pctile == 1
	exit
	*replace p_hat = r(p`bottom_trim') if p_hat < r(p`bottom_trim')
	*/

	// Make att weights, bind at 1 for exp states
	gen att = p_hat / (1 - p_hat)
	replace att = 1 if expansion == 1

	keep state att

	merge 1:m state using "$temp_path/temp_state_controls.dta"
	drop _merge
	erase "$temp_path/temp_state_controls.dta"

	// Create ATT x Pop weights
	ds pop*
	foreach x in `r(varlist)' {
		gen double att`x' = att*`x'
	}
	*gen attpop_55_64 = att*pop_55_64
	*gen attpop_65_74 = att*pop_65_74


	// Save 
	keep state year attpop* att // _55_64 attpop_65_74
	compress
	save "$restricted_data_analysis/attpop_state_level_trim_`top_trim'.dta", replace
}

// Open the windsorized @ 95th percentile data
use "$restricted_data_analysis/attpop_state_level_trim_950.dta", clear
merge 1:1 state year using "$public_data_analysis/state_controls.dta" 
keep if _merge == 3
drop _merge 
compress
save "$restricted_data_analysis/state_controls_with_att_pop_state.dta" , replace
