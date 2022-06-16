////////////////////////////////////////////////////////////////////////////////
// Part 1. Unzip mortality data and store in temp location 
!unzip "$restricted_data_raw/mortality_data.zip" -d "$temp_path"

////////////////////////////////////////////////////////////////////////////////
// Part 2. Create a bunch of temp dta files with only the data elements that we need

////////////////////////////////////////////////////////////////////////////////
// 1999

// Set local macro so we can use the same code
local year 1999

// Import raw data
infix res 20 educ 52-53 female 59 race 62 age1 64 age2 65-66 hispanic 82 ///
	state 124-125 county 126-128 str icd10 142-145 ucr39 157-158 using "$temp_path/mortality_data/MULT1999.AllCnty.txt", clear		
		// Call cleaning do file. Note the `year' local macro gets passed to the do file and "accepted" by the arg command on the first line
do "$script_path/1_build/1.1.cleaning_code_for_1999_2002.do" `year'

// Save in the temp folder
compress 
save "$temp_path/mcod1999.dta", replace

/////////////////////////////////////////////////////////////////////////////////
// 2000 - 2002

foreach mort_type in ps us {
	local upper_mort_type = upper("`mort_type'")
	
	forvalues year = 2000(1)2002 {
		// Import raw data
		infix res 20 educ 52-53 female 59 race 62 age1 64 age2 65-66 hispanic 82 ///
			state 124-125 county 126-128 str icd10 142-145 ucr39 157-158 using "$temp_path/mortality_data/MULT`year'.`upper_mort_type'AllCnty.txt", clear		
		
		// Call cleaning do file. Note the `year' local macro gets passed to the do file and "accepted" by the arg command on the first line
		do "$script_path/1_build/1.1.cleaning_code_for_1999_2002.do"  `year'

		// Save in the temp folder
		compress 
		save "$temp_path/`mort_type'_mcod`year'.dta", replace
		
	}
}

/////////////////////////////////////////////////////////////////////////////////
// 2003 - 2017
foreach mort_type in ps us {
	local upper_mort_type = upper("`mort_type'")
	
	forvalues year = 2003(1)2017 {
	
		// Import raw data
		infix res 20 str statel 29-30 county 35-37 educ1 61-62 educ2 63 educflag 64 ///
			str fem 69 age1 70 age2 71-73 str icd10 146-149 ucr39 160-161 ///
			race 449 hispanic 488 ///
			using "$temp_path/mortality_data/MULT`year'.`upper_mort_type'AllCnty.txt", clear
		// Call cleaning do file. Note the `year' local macro gets passed to the do file and "accepted" by the arg command on the first line
		do "$script_path/1_build/1.2.cleaning_code_for_2003_2017.do"  `year' 
		
		// Save in the temp folder
		compress 
		save "$temp_path/`mort_type'_mcod`year'.dta", replace
	}
}

////////////////////////////////////////////////////////////////////////////////
// Part 3. Combine temp files together

use  "$temp_path/mcod1999.dta"

forvalues year = 2000(1)2017 {

	append using "$temp_path/ps_mcod`year'.dta"
	append using "$temp_path/us_mcod`year'.dta"

}


// It's possible for duplicate values if anyone died in a territory that is a resident in 51 states
qui ds state county year, not
gcollapse (sum) `r(varlist)', by(state county year)

////////////////////////////////////////////////////////////////////////////////
// Part 4. Save analytic file of just mortality data
compress
save  "$restricted_data_analysis/mortality_data_1999_2017.dta", replace

////////////////////////////////////////////////////////////////////////////////
// Part 5. Erase temp files

erase  "$temp_path/mcod1999.dta"

forvalues year = 2000(1)2017 {
	erase  "$temp_path/ps_mcod`year'.dta"
	erase  "$temp_path/us_mcod`year'.dta"
}

// Delete unzipped raw mortality data
!rm -r "$temp_path/mortality_data"

// Delete weird file that gets made on macs
!rm -r "$temp_path/__MACOSX"
