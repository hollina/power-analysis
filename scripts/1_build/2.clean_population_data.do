////////////////////////////////////////////////////////////////////////////////
// Part 1. Unzip SEER population data and store in temp location 
!unzip "$public_data_raw/us.1990_2017.singleages.adjusted.txt.zip" -d "$temp_path"

////////////////////////////////////////////////////////////////////////////////
// Part 1. Unzip population data

// Import data 
infix year 1-4 state 7-8 county 9-11 race 14 origin 15 sex 16 age 17-18 population 19-27 using "$temp_path/us.1990_2017.singleages.adjusted.txt", clear

// Keep only the years we need
keep if year>=1999

// Create age categories
gen age_18_64 = 0
replace  age_18_64 = 1 if age>=18 & age<=64
 
gen age_eld = 0
replace  age_eld = 1 if age>=65 

gen age_55_64 = 0
replace  age_55_64 = 1 if age>=55 & age<=64

gen age_65_74 = 0
replace  age_65_74 = 1 if age>=65 & age<=74

gen age_45_64 = 0
replace  age_45_64 = 1 if age>=45 & age<=64

gen age_tot = 1

// Create variables for race/hispanic
gen white = 0
replace white = 1 if race ==1

gen black = 0
replace black = 1 if race ==2

gen other = 0
replace other = 1 if race ==3

rename origin hispanic

// Fix gener 
gen female = sex - 1
drop sex


/*
// What groups do we want?

white_not_hisp --> by each age (6)
black_not_hisp --> by each age (6)
hispanic --> by each age (6)

female --> by each age (6)
male --> by each age (6)

each age (5)

total (1)
-->36 total 
*/

	
foreach age in 55_64 65_74 45_64 18_64 eld tot {
	// Non-hispanic black and white by age group
	foreach race in white black {
		bysort state county year: gegen temp_pop_`race'_non_hisp_`age' = total(population) if `race' == 1 & hispanic == 0 & age_`age' == 1
		bysort state county year: gegen pop_`race'_non_hisp_`age' = max(temp_pop_`race'_non_hisp_`age')
		drop temp_pop_`race'_non_hisp_`age'
	}
	
	// Hispanic by age group
	bysort state county year: gegen temp_pop_hisp_`age' = total(population) if hispanic == 1 & age_`age' == 1
	bysort state county year: gegen pop_hisp_`age' = max(temp_pop_hisp_`age')
	drop temp_pop_hisp_`age'
	
	// Female by age
	bysort state county year: gegen temp_pop_fem_`age' = total(population) if female == 1 & age_`age' == 1
	bysort state county year: gegen pop_fem_`age' = max(temp_pop_fem_`age')
	drop temp_pop_fem_`age'
	
	// Male by age
	bysort state county year: gegen temp_pop_male_`age' = total(population) if female == 0 & age_`age' == 1
	bysort state county year: gegen pop_male_`age' = max(temp_pop_male_`age')
	drop temp_pop_male_`age'
	
	// By age
	bysort state county year: gegen temp_pop_`age' = total(population) if age_`age' == 1
	bysort state county year: gegen pop_`age' = max(temp_pop_`age')
	drop temp_pop_`age'
}

// Rename total 
drop age_tot age
rename *_tot *

// Drop the meaninglys variables 
drop race hispanic  population age_18_64 age_eld age_55_64 age_65_74 age_45_64  white black other female

// Drop duplicate observations
bysort state county year: keep if _n == 1

// create a 45-64 year old pop with the low education label
gen pop_le_45_64 = pop_45_64
gen pop_le_eld = pop_eld
	
// Replace missing variables with zeros
qui ds pop*
foreach x in `r(varlist)' {
	replace `x' = 0 if missing(`x')
}

// Save 
compress
save "$public_data_analysis/population_by_race_age_group_year.dta", replace 
// Clean up
erase "$temp_path/us.1990_2017.singleages.adjusted.txt"


