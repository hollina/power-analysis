* Leticia Nunes
* 25/10/2019
* Organizing SAHIE Uninsurance Data for First Stage (State Level)

//-----------------------------------------------------------------
// SET UP
//-----------------------------------------------------------------

**** Set up
clear all

**** Main Directory
//cd "C:/Users/letic/Dropbox"
*cd "D:/Dropbox/Projects/"

**** Input Files
global masterfile = "$public_data_raw/sahie/SAHIE2006-2017.dta"
global controlfile = "$restricted_data_analysis/state_controls_with_att_pop_state.dta"

**** Temporary Files
global tempfile_nipr = "$temp_path/temp_nipr.dta"
global tempfile_pctui = "$temp_path/temp_pctui.dta"

**** Output files
global savefile = "$public_data_analysis/Unins_PopCtrlAtt_StYr_SAHIE.dta"

//------------------------------------------------------------------------------------
// ORGANIZING POPULATION & % UNINSURED BY GENDER, INCOME LEVEL, RACE AND ETHNICITY
//------------------------------------------------------------------------------------

foreach var in nipr pctui {

	use "$masterfile", clear

	**** Keep only data at the State level
	keep if geocat == 40

	**** Keep age group: 65- years, 18-64 years, 40-64 years, 50-64 years old
	keep if agecat <=3

	**** Keep income categories: all, <138% FPL, <200%, FPL <400% FPL, between 138% and 400% FPL
	//keep if iprcat == 0 | iprcat == 1 | iprcat == 3 | iprcat == 4 | iprcat == 5

	**** The goal is to reashape wide the data until it is only at the County-Year level
	*** We are going to do it for pctui and nipr variable and than merge them together

	*** Keep only necessary variables
	keep FIPS year agecat sexcat racecat iprcat `var'

	*** Reshape age category
	reshape wide `var', i(FIPS year iprcat sexcat racecat) j(agecat)
	** Rename variables accordingly
	ds FIPS year, not
	rename `var'0 `var'_65m
	rename `var'1 `var'_18_64
	rename `var'2 `var'_40_64
	rename `var'3 `var'_50_64
	
	*** Reshape gender category
	reshape wide `var'_65m `var'_18_64 `var'_40_64 `var'_50_64, i(FIPS year iprcat racecat) j(sexcat)
	** Rename variables accordingly
	ds FIPS year racecat iprcat, not
	foreach v of varlist `r(varlist)' {
		local aux = substr("`v'", 1, strlen("`v'")-1)
		capture rename `aux'0 `aux' //_allg
		capture rename `aux'1 `aux'_male
		capture rename `aux'2 `aux'_fem
	}

	*** Reshape race category
	ds FIPS year iprcat racecat, not
	reshape wide `r(varlist)', i(FIPS year iprcat) j(racecat)

	** Rename variables accordingly
	ds FIPS year iprcat, not
	foreach v of varlist `r(varlist)' {
		local aux = substr("`v'", 1, strlen("`v'")-1)
		capture rename `aux'0 `aux' //_allr
		capture rename `aux'1 `aux'_wh
		capture rename `aux'2 `aux'_bl
		capture rename `aux'3 `aux'_hi
	}	
	
	*** Reshape income category
	ds FIPS year iprcat, not
	reshape wide `r(varlist)', i(FIPS year) j(iprcat)
	** Rename variables accordingly
	ds FIPS year, not
	foreach v of varlist `r(varlist)' {
		local aux = substr("`v'", 1, strlen("`v'")-1)
		capture rename `aux'0 `aux' //_allinc
		capture rename `aux'1 `aux'_blw200pvt
		capture rename `aux'2 `aux'_blw250pvt
		capture rename `aux'3 `aux'_blw138pvt
		capture rename `aux'4 `aux'_blw400pvt
		capture rename `aux'5 `aux'_btw138400pvt
	}

	**** Final organization
	rename FIPS statefip
	replace statefip = statefip/1000
	order statefip year

	**** Save
	save "${tempfile_`var'}", replace

}

**** Merge both temporary files
merge 1:1 statefip year using "$tempfile_nipr", nogen

//-----------------------------------------------------------------
// MERGE WITH CONTROLS & GENERATE ATTXPOP WEIGHTS
//-----------------------------------------------------------------

**** Merge with controls
rename statefip state

merge 1:1 year state using "$controlfile", keepusing(StAbbrev IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj Mcare_Disab smoking_all physicians_pc att)
drop if _merge == 2
drop _merge

rename year Year
rename state St_FIPS

rename nipr* pop*

**** Generate AttxPop weights
foreach age in 18_64 40_64 50_64 65m {
	gen attpop_`age' = att*pop_`age'
	la var attpop_`age' "AttxPop weights: `lage`age''"

	foreach gen in fem male  {
		gen attpop_`age'_`gen' = att*pop_`age'_`gen'
		la var attpop_`age'_`gen' "AttxPop weights: `lage`age''- `l`gen''"
	}
	foreach race in wh bl hi {
		gen attpop_`age'_`race' = att*pop_`age'_`race'
		la var attpop_`age'_`race' "AttxPop weights: `lage`age''- `l`race''"
	}
	foreach inc in blw200pvt blw250pvt blw138pvt blw400pvt btw138400pvt {
		gen attpop_`age'_`inc' = att*pop_`age'_`inc'
		la var attpop_`age'_`inc' "AttxPop weights: `lage`age''- `l`inc''"
	}
}

//-----------------------------------------------------------------
// CREATING MEDICAID EXPANSION VAR
//-----------------------------------------------------------------

** Creating Medicaid Expansion Variable
* Four category expansion info
gen Expansion4 = .

local control AL AK FL GA ID IN KS LA MS ME MO MT NE NH NC OK PA SC SD TN TX UT VA WY
foreach control in `control' {
	replace Expansion4 = 0 if StAbbrev == `"`control'"'
}
local treatment AR AZ CO IL IA KY MD MI NV NM NJ ND OH OR RI WV WA
foreach treatment in `treatment' {
	replace Expansion4 = 1 if StAbbrev ==`"`treatment'"'
}
local mild DE DC MA NY VT
foreach exc in `mild' {
	replace Expansion4 = 2 if StAbbrev == `"`exc'"'
}
local medium CA CT HI MN WI
foreach exc in `medium' {
	replace Expansion4 = 3 if StAbbrev == `"`exc'"'
}

codebook Expansion4

* Account for mid-year expansions
replace Expansion4=1 if StAbbrev == "MI" //MI expanded in April 2014
replace Expansion4=1 if StAbbrev == "NH" //NH expanded in August 2014
replace Expansion4=1 if StAbbrev == "PA" //PA expanded in Jan 2015
replace Expansion4=1 if StAbbrev == "IN" //IN expanded in Feb 2015
replace Expansion4=1 if StAbbrev == "AK" //AK expanded in Sept 2015
replace Expansion4=1 if StAbbrev == "MT" //MT expanded in Jan 2016
la var Expansion4 "0 is no expansion, 1 is full expansion, 2 is mild expansion, 3 is substantial expansion"

** Create Post Variable
gen Post = (Year>= 2014)
replace Post=0 if StAbbrev == "NH" & Year == 2014  //NH expanded in August 2014
replace Post=0 if StAbbrev == "PA" & Year == 2014  //PA expanded in Jan 2015
replace Post=0 if StAbbrev == "IN" & Year == 2014 //IN expanded in Feb 2015
replace Post=0 if StAbbrev == "AK" & (Year == 2014 | Year == 2015) //AK expanded in Sept 2015
replace Post=0 if StAbbrev == "MT" & (Year == 2014 | Year == 2015) //MT expanded in Jan 2016

** Create Event Time Variable
gen EventTime = .
replace EventTime = 0 if Year == 2014 & (StAbbrev != "NH" & StAbbrev != "PA"  & StAbbrev != "IN" & StAbbrev != "AK" & StAbbrev != "MT")
replace EventTime = 0 if Year == 2015 & (StAbbrev == "NH" | StAbbrev == "PA"  | StAbbrev == "IN")
replace EventTime = 0 if Year == 2016 & (StAbbrev == "AK" | StAbbrev == "MT")
bysort St_FIPS (Year): replace EventTime = EventTime[_n-1] +1 if missing(EventTime)
gsort St_FIPS -Year
bysort St_FIPS: replace EventTime = EventTime[_n-1] -1 if missing(EventTime)

** Labels
la var Expansion4 "0 is no expansion, 1 is full expansion, 2 is mild expansion, 3 is substantial expansion"
la var Post "1(Post Expansion)"
la var EventTime "Event Time"

//-----------------------------------------------------------------
// SAVING
//-----------------------------------------------------------------

* Saving
order Year StAbbrev St_FIPS Expansion Post EventTime IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj Mcare_Disab smoking_all physicians_pc pctui_* pop_* attpop_*
sort St_FIPS Year
save "$savefile", replace

erase "$tempfile_nipr"
erase "$tempfile_pctui"
