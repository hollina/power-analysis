// File list 

// Right column
local ddd_column ///
	ddd_ln_resp_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_hiv_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_dia_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 /// 
	ddd_ln_card_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_can_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_white_non_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_black_non_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_male_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	ddd_ln_amen_fem_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_resp_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_hiv_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_dia_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 /// 
	st_ddd_ln_card_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_can_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_white_non_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_black_non_hisp_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_none_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_male_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_ddd_ln_amen_fem_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 

// Left column
local dd_column ///
	dd_ln_resp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_hiv_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010  ///
	dd_ln_dia_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_card_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_can_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_white_non_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_black_non_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_male_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_fem_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	dd_ln_amen_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 	///
	st_dd_ln_resp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_hiv_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010  ///
	st_dd_ln_dia_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_card_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_can_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_white_non_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_black_non_hisp_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_male_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_fem_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 ///
	st_dd_ln_amen_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010 	
///////////////////////////////////////////////////////////////////////////////
// Create excel sheet to store results
putexcel set "$table_results_path/temp_partial_data_for_figure.xlsx", replace

putexcel A1 = "Name"
putexcel B1 = "death_type"
putexcel C1 = "dem_group"
putexcel D1 = "mean"
putexcel E1 = "sd"
putexcel F1 = "N"
putexcel G1 = "coef_of_var"
putexcel H1 = "geographic_level"

local excel_row = 2
foreach dataset_name in `dd_column' `ddd_column' {
	quietly {

*local excel_row = 2
			////////////////////////////////////////////////////////////////////////////////	
			// Clear memory
			clear all
			// Create identifiers for dataset
			*local dataset_name =  "st_dd_ln_amen_55_64_cluster_state_weight_attpop_controls_yes_preperiod_2001_2010"
			putexcel A`excel_row' = "`dataset_name'"

			// Extract the first to characters to see if its a state-level dataset or county level
			local first_two_digits = substr("`dataset_name'", 1, 2)

			// Create needed variables if it is a county-level dataset 
			
			if "`first_two_digits'" != "st" {
				
				// Open death rate data
				use "$restricted_data_analysis/death_rates_1999_2017.dta", clear
						


				gen dataset_name =  "`dataset_name'"

				// Adjust items to harmonize elements
				replace dataset_name = subinstr(dataset_name, "white_non_hisp","whitenonhisp",.)
				replace dataset_name = subinstr(dataset_name, "black_non_hisp","blacknonhisp",.)

				replace dataset_name = subinstr(dataset_name, "attpop_whitenonhisp_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_blacknonhisp_55_64","attpop",.)

				replace dataset_name = subinstr(dataset_name, "attpop_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_hisp_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_male_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_fem_55_64","attpop",.)


				replace dataset_name = subinstr(dataset_name, "amen_55_64","amen_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "card_55_64","card_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "can_55_64","can_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "dia_55_64","dia_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "hiv_55_64","hiv_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "resp_55_64","resp_none_55_64",.)

				replace dataset_name = subinstr(dataset_name, "resp_none_cluster","resp_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "hiv_none_cluster","hiv_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "dia_none_cluster","dia_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "card_none_cluster","card_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "can_none_cluster","can_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_whitenonhisp_cluster","amen_whitenonhisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_hisp_cluster","amen_hisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_blacknonhisp_cluster","amen_blacknonhisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_none_cluster","amen_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_male_cluster","amen_male_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_fem_cluster","amen_fem_55_64_cluster",.)
				
				replace dataset_name = subinstr(dataset_name, "st_dd_","stdd_",.)
				replace dataset_name = subinstr(dataset_name, "st_ddd_","stddd_",.)
				

				// Split dataset by underscore
				split dataset_name, p("_")
				
				order dataset_name*
				
				// Rename variables 
				list dataset_name* in 1 
				rename dataset_name1 specification
				rename dataset_name2 transform
				rename dataset_name3 death_type
				rename dataset_name4 dem_group
				rename dataset_name5 lower_age
				rename dataset_name6 upper_age
				drop dataset_name7 
				rename dataset_name8 cluster_level
				drop dataset_name9 
				rename dataset_name10 weight_var
				drop dataset_name11 dataset_name12 dataset_name13
				rename dataset_name14 first_year
				rename dataset_name15 last_year
				
				// Add "_" back in for two dem groups with longernames
				replace dem_group = subinstr(dem_group,"whitenonhisp", "white_non_hisp",.)
				replace dem_group = subinstr(dem_group, "blacknonhisp", "black_non_hisp",.)

				local var_list dataset_name specification transform death_type dem_group lower_age upper_age cluster_level weight_var first_year last_year
				foreach x in `var_list' {
					destring `x', replace
				}

				// Keep if year is within range
				keep if year >= first_year[1]
				keep if year <= last_year[1]
			
				// Keep if demographics are correct 
				local dem_group = dem_group[1]
				local lower_age = lower_age[1]
				local upper_age = upper_age[1]
			
				// Keep if death rate is correct 
				local death_type = death_type[1]
				
				// Store cause of death
				putexcel B`excel_row' = "`death_type'"
				
				// Store demographic group
				putexcel C`excel_row' = "`dem_group'"
				
				// Collapse to get mean over this period
				if "`dem_group'" != "none" {
					keep ///
						pop_`dem_group'_`lower_age'_`upper_age' ///
						`death_type'_`dem_group'_`lower_age'_`upper_age' ///
						state county year
					
					gen average = (`death_type'_`dem_group'_`lower_age'_`upper_age'/	pop_`dem_group'_`lower_age'_`upper_age')*100000
					
					sort state county year
					collapse (mean) mean = average (sd) sd = average (lastnm) N = `death_type'_`dem_group'_`lower_age'_`upper_age' [aw = pop_`dem_group'_`lower_age'_`upper_age'], by(state county)
					gen coef_of_var = sd/mean


					collapse (mean) mean sd coef_of_var (sum) N
					
				}
				if "`dem_group'" == "none" {
					keep ///
						pop_`lower_age'_`upper_age' ///
						`death_type'_`lower_age'_`upper_age' ///
						state county year
					
					
					gen average = (`death_type'_`lower_age'_`upper_age'/	pop_`lower_age'_`upper_age')*100000
					
					sort state county year
					collapse (mean) mean = average (sd) sd = average (lastnm) N = `death_type'_`lower_age'_`upper_age' [aw = pop_`lower_age'_`upper_age'], by(state county)
					gen coef_of_var = sd/mean


					collapse (mean) mean sd coef_of_var (sum) N
					
			
				}
			
						
				// Store mean
				putexcel D`excel_row' = mean[1]
			
				// Store standard deviation
				putexcel E`excel_row' = sd[1]
			
				// Store number of observations 
				putexcel F`excel_row' = N[1]
				
				// Store number of observations 
				putexcel G`excel_row' = coef_of_var[1]
				
				// Store geographic level 
				putexcel H`excel_row' = "county"

				// Add one to excel_row
				local excel_row = `excel_row'+1
			}
			
			// Create needed variables if it is a state-level dataset 
			if "`first_two_digits'" == "st" {
				
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
				

				// Foreach death rate create a log death rate
				qui ds dr_*
				foreach x in `r(varlist)' {
					gen ln_`x' = ln(`x' + 1)
				}
				rename ln_dr_* ln_*	
						


				gen dataset_name =  "`dataset_name'"

				// Adjust items to harmonize elements
				replace dataset_name = subinstr(dataset_name, "white_non_hisp","whitenonhisp",.)
				replace dataset_name = subinstr(dataset_name, "black_non_hisp","blacknonhisp",.)

				replace dataset_name = subinstr(dataset_name, "attpop_whitenonhisp_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_blacknonhisp_55_64","attpop",.)

				replace dataset_name = subinstr(dataset_name, "attpop_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_hisp_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_male_55_64","attpop",.)
				replace dataset_name = subinstr(dataset_name, "attpop_fem_55_64","attpop",.)


				replace dataset_name = subinstr(dataset_name, "amen_55_64","amen_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "card_55_64","card_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "can_55_64","can_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "dia_55_64","dia_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "hiv_55_64","hiv_none_55_64",.)
				replace dataset_name = subinstr(dataset_name, "resp_55_64","resp_none_55_64",.)

				replace dataset_name = subinstr(dataset_name, "resp_none_cluster","resp_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "hiv_none_cluster","hiv_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "dia_none_cluster","dia_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "card_none_cluster","card_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "can_none_cluster","can_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_whitenonhisp_cluster","amen_whitenonhisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_hisp_cluster","amen_hisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_blacknonhisp_cluster","amen_blacknonhisp_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_none_cluster","amen_none_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_male_cluster","amen_male_55_64_cluster",.)
				replace dataset_name = subinstr(dataset_name, "amen_fem_cluster","amen_fem_55_64_cluster",.)
				
				replace dataset_name = subinstr(dataset_name, "st_dd_","dd_",.)
				replace dataset_name = subinstr(dataset_name, "st_ddd_","ddd_",.)
				

				// Split dataset by underscore
				split dataset_name, p("_")
				
				order dataset_name*
				
				// Rename variables 
				list dataset_name* in 1 
				rename dataset_name1 specification
				rename dataset_name2 transform
				rename dataset_name3 death_type
				rename dataset_name4 dem_group
				rename dataset_name5 lower_age
				rename dataset_name6 upper_age
				drop dataset_name7 
				rename dataset_name8 cluster_level
				drop dataset_name9 
				rename dataset_name10 weight_var
				drop dataset_name11 dataset_name12 dataset_name13
				rename dataset_name14 first_year
				rename dataset_name15 last_year
				
				// Add "_" back in for two dem groups with longernames
				replace dem_group = subinstr(dem_group,"whitenonhisp", "white_non_hisp",.)
				replace dem_group = subinstr(dem_group, "blacknonhisp", "black_non_hisp",.)

				local var_list dataset_name specification transform death_type dem_group lower_age upper_age cluster_level weight_var first_year last_year
				foreach x in `var_list' {
					destring `x', replace
				}

				// Keep if year is within range
				keep if year >= first_year[1]
				keep if year <= last_year[1]
			
				// Keep if demographics are correct 
				local dem_group = dem_group[1]
				local lower_age = lower_age[1]
				local upper_age = upper_age[1]
			
				// Keep if death rate is correct 
				local death_type = death_type[1]
				
				// Store cause of death
				putexcel B`excel_row' = "`death_type'"
				
				// Store demographic group
				putexcel C`excel_row' = "`dem_group'"
				
				// Collapse to get mean over this period
				if "`dem_group'" != "none" {
					keep ///
						pop_`dem_group'_`lower_age'_`upper_age' ///
						`death_type'_`dem_group'_`lower_age'_`upper_age' ///
						state year
					
					gen average = (`death_type'_`dem_group'_`lower_age'_`upper_age'/	pop_`dem_group'_`lower_age'_`upper_age')*100000
					
					sort state year
					collapse (mean) mean = average (sd) sd = average (lastnm) N = `death_type'_`dem_group'_`lower_age'_`upper_age' [aw = pop_`dem_group'_`lower_age'_`upper_age'], by(state)
					gen coef_of_var = sd/mean


					collapse (mean) mean sd coef_of_var (sum) N
					
				}
				if "`dem_group'" == "none" {
					keep ///
						pop_`lower_age'_`upper_age' ///
						`death_type'_`lower_age'_`upper_age' ///
						state year
					
					
					gen average = (`death_type'_`lower_age'_`upper_age'/	pop_`lower_age'_`upper_age')*100000
					
					sort state year
					collapse (mean) mean = average (sd) sd = average (lastnm) N = `death_type'_`lower_age'_`upper_age' [aw = pop_`lower_age'_`upper_age'], by(state)
					gen coef_of_var = sd/mean


					collapse (mean) mean sd coef_of_var (sum) N
					
			
				}
			
						
				// Store mean
				putexcel D`excel_row' = mean[1]
			
				// Store standard deviation
				putexcel E`excel_row' = sd[1]
			
				// Store number of observations 
				putexcel F`excel_row' = N[1]
				
				// Store number of observations 
				putexcel G`excel_row' = coef_of_var[1]
							
				// Store geographic level 
				putexcel H`excel_row' = "state"
			
				// Add one to excel_row
				local excel_row = `excel_row'+1
			}
		}
	}

import excel "$table_results_path/temp_partial_data_for_figure.xlsx", sheet("Sheet1") firstrow clear
compress
save "$temp_path/temp_partial_data_for_figure.dta", replace 


import excel "$table_results_path//mde_tot.xlsx", sheet("mde_tot") firstrow clear
merge 1:1 Name using "$temp_path/temp_partial_data_for_figure.dta"

keep if _merge == 3
erase  "$temp_path/temp_partial_data_for_figure.dta"

replace MDE = MDE
replace MDE_LL = MDE_LL
replace MDE_UL = MDE_UL

gen spec_type = substr(Name, 1, 3)
replace spec_type = "dd" if spec_type == "dd_"
replace spec_type = substr(Name, 4, 3) if geographic_level == "state"
replace spec_type = "dd" if spec_type == "dd_"

replace dem_group = subinstr(dem_group, "none", "", .)
replace dem_group = subinstr(dem_group, "black_non_hisp", "Black", .)
replace dem_group = subinstr(dem_group, "white_non_hisp", "White", .)
replace dem_group = subinstr(dem_group, "hisp", "Hispanic", .)

replace dem_group = subinstr(dem_group, "le", "Low-education", .)

replace dem_group = subinstr(dem_group, "male", "Male", .)
replace dem_group = subinstr(dem_group, "maLow-education", "Male", .)

replace dem_group = subinstr(dem_group, "fem", "Female", .)



replace death_type = subinstr(death_type, "amen", "Amenable", .)
replace death_type = subinstr(death_type, "dia", "Diabetes", .)

replace death_type = subinstr(death_type, "card", "Cardiac", .)
replace death_type = subinstr(death_type, "hiv", "HIV", .)
replace death_type = subinstr(death_type, "resp", "Respiratory", .)
replace death_type = subinstr(death_type, "can", "Cancer", .)


gen label = death_type + " " + dem_group

/////////////////////////////////////////////////////////////////////////////////
// Add first stage percent 

gen first_stage = . 
replace first_stage = 1.814 if dem_group == "Female" & death_type == "Amenable" & spec_type == "dd" 
replace first_stage = 1.683 if dem_group == "Male" & death_type == "Amenable" & spec_type == "dd" 
replace first_stage = 1.568 if dem_group == "White" & death_type == "Amenable" & spec_type == "dd" 
replace first_stage = 2.550 if dem_group == "Black" & death_type == "Amenable" & spec_type == "dd" 
replace first_stage = 3.224 if dem_group == "Hispanic" & death_type == "Amenable" & spec_type == "dd"
replace first_stage = 1.746 if dem_group == "" & death_type == "Amenable" & spec_type == "dd" 

replace first_stage = 1.585 if dem_group == "Female" & death_type == "Amenable" & spec_type == "ddd"
replace first_stage = 1.628 if dem_group == "Male" & death_type == "Amenable" & spec_type == "ddd" 
replace first_stage = 1.377 if dem_group == "White" & death_type == "Amenable" & spec_type == "ddd" 
replace first_stage = 2.640 if dem_group == "Black" & death_type == "Amenable" & spec_type == "ddd" 
replace first_stage = 4.004 if dem_group == "Hispanic" & death_type == "Amenable" & spec_type == "ddd"
replace first_stage = 1.599 if dem_group == "" & death_type == "Amenable" & spec_type == "ddd" 

compress

export delimited using "$table_results_path/partial_data_for_figure_in_r.csv", replace
