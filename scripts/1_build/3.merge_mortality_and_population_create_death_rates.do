///////////////////////////////////////////////////////////////////////////////
// Part 1: Open mortality data and harmonize 

use "$restricted_data_analysis/mortality_data_1999_2017.dta", clear

//////////////////////////////////////////////////////////
// A few counties split. Recombine for consistency

// These two counties are combined by SEER. So we need to combine them here
replace county=917 if state==51 & county==19
replace county=917 if state==51 & county==515

// AK- a few counties split ~2007: Recombine them for consistency
*https://www.cdc.gov/nchs/data/nvss/bridged_race/county_geography_changes.pdf
replace county=232 if state==2 & county==105
replace county=232 if state==2 & county==230
replace county=280 if state==2 & county==195
replace county=280 if state==2 & county==275
replace county=201 if state==2 & county==198

// VA
replace county=5 if state==51 & county==560

// Make Miami-Dade into a single fips code across time
replace county = 86 if state==12 & county==25 & year<=2002

// Make Virginia County Consistent Across time
*replace county = 5 if state==51 & county==560 

// Drop a county code that does not exist in 2002.
drop if state==8 & county==14 & year==2002

// Yellowstone park was mapped into Park county 
* https://www.ddorn.net/data/FIPS_County_Code_Changes.pdf
replace county = 67 if county == 113 & state == 30

// Collapse renamed counties above 
qui ds state county year, not
gcollapse (sum) `r(varlist)', ///
	by(state county year)

// Save temp version
compress
save "$temp_path/temp_mort.dta", replace
	
///////////////////////////////////////////////////////////////////////////////
// Part 2: Open population data and harmonize 

use "$public_data_analysis/population_by_race_age_group_year.dta", clear 

// AK- a few counties split ~2007: Recombine them for consistency
*https://www.cdc.gov/nchs/data/nvss/bridged_race/county_geography_changes.pdf
replace county=232 if state==2 & county==105
replace county=232 if state==2 & county==230
replace county=280 if state==2 & county==195
replace county=280 if state==2 & county==275
replace county=201 if state==2 & county==198


// Collapse to get the population by each county-year-age group
qui ds state county year, not
gcollapse (sum) `r(varlist)', ///
	by(state county year)

// There are some FIPS codes that change across time with SEER
// This is done to make sure merge with CDC data is correct.

//adams county. Prior to 2003 it was FIPS code 08911
replace county = 1 if state==8 & county==911 & year<2002

//Boulder county. It should be 08912 prior to 2003
replace county = 13 if state==8 & county==912 & year<2002

//Jefferson county. It should be 08913 prior to 2003
replace county = 59 if state==8 & county==913 & year<2002

//Weld county. It should be 08913 prior to 2003
replace county = 123 if state==8 & county==914 & year<2002

//Miami-Dade county. It should be 12086, but it's two things in the mortality data
* We do this just to make sure that it will merge than we will change it later to be one fips code
replace county = 25 if state==12 & county==86 & year<=2002
replace county = 86 if state==12 & county==25 & year>=2003

// All of Hawaii is screwed up before 2000 at the county level. Drop it.
drop if state==15 & year <=1999

// Drop a county that doesnt seem to exist that is in the mortality data
drop if state==26 & county==124 

// Make Miami-Dade into a single fips code across time
replace county = 86 if state==12 & county==25 & year<=2002

// Make Virginia County Consistent Across time
*replace county = 5 if state==51 & county==560 

// Drop a county code that does not exist in 2002.
drop if state==8 & county==14 & year==2002

///////////////////////////////////////////////////////////////////////////////
// Part 3: Merge and clean up

merge 1:1 state county year using "$temp_path/temp_mort.dta"

///////////////////////////////////////////////////////////////////////////////
// Drop if FIPS code is 9999
drop if state==99

///////////////////////////////////////////////////////////////////////////////
// SEER does not have hawaii population by county in 1999. Use 2000 population 
gsort state county -year
qui ds pop*
foreach x in `r(varlist)' {
	carryforward `x' if state == 15, replace 
}
replace _merge = 3 if _merge == 2 & state == 15 & year == 1999
tab _merge


///////////////////////////////////////////////////////////////////////////////
// Missing deaths should be zero
ds state county year pop*, not
foreach x in `r(varlist)' {
	replace `x' = 0 if missing(`x')
}

// Drop merge 
drop _merge 

///////////////////////////////////////////////////////////////////////////////
// There are a small number of county-year-agecats that have "no population" but
// have 1-3 deaths. I'm sure this is simply an inconsistency with SEER's population 
// estimate. In any case we will put population as the number of deaths
*replace population = all_death if missing(population) & _merge==2


///////////////////////////////////////////////////////////////////////////////
// Part 4: Generate death rates per 100k
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
	
	// Low-education 
	replace pop_le_45_64 = `cod'_le_45_64 if pop_le_45_64 < `cod'_le_45_64 & !missing(`cod'_le_45_64) 
	gen dr_`cod'_le_45_64 = (`cod'_le_45_64/ pop_le_45_64)*100000
	
	
	replace pop_le_eld = `cod'_le_eld if pop_le_eld < `cod'_le_eld & !missing(`cod'_le_eld) 
	gen dr_`cod'_le_eld = (`cod'_le_eld/ pop_le_eld)*100000
	
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

///////////////////////////////////////////////////////////////////////////////
// Part 5: Save
compress
save "$restricted_data_analysis/death_rates_1999_2017.dta", replace 

///////////////////////////////////////////////////////////////////////////////
// Part 6: Clean up

erase "$temp_path/temp_mort.dta"
erase "$restricted_data_analysis/mortality_data_1999_2017.dta"
erase "$public_data_analysis/population_by_race_age_group_year.dta"
