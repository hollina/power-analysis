* Leticia Nunes
* 01/10/2017
* Organizing ACS insurance data by State


//-----------------------------------------------------------------
// SET UP
//-----------------------------------------------------------------

clear all

**** Input Files
foreach yr of numlist 2008/2017 {
	global masterfile_`yr' = "$public_data/raw_data/acs/acs_`yr'.dta"
}
global controlfile = "$restricted_data_analysis/state_controls_with_att_pop_state.dta"

**** Output Files
global sf_uns_master = "$public_data_analysis/InsPop_StYrDemogr_ACS_2008-2017.dta"
global savefile = "$public_data_analysis/Ins_PopCtrlAtt_StYr_ACS_2008-2017.dta"

//-----------------------------------------------------------------
// ORGANIZING ACS
//-----------------------------------------------------------------

foreach yr of numlist 2008/2017 {

use "${masterfile_`yr'}", clear

keep statefip perwgt hins hipriv himcaid age schl female racbl racwht hisp povpip //hiep hipind himcare hiothpub

compress

* Organizing Health Uninsurance Variable
* gen hunins = 1-hins
* la var hunins "Health Uninsurance"
* drop hins

* Organize Gender
la var female "Female"
gen male=1-female
la var male "Male"

* Organizing Hispanic Dummy
recode hisp (1=0)
replace hisp = 1 if hisp >= 2 & !missing(hisp)
la var hisp "Hispanic"

* Organizing Race Dummies (related to hispanic)
gen blacknohisp = (racbl == 1 & hisp == 0)
replace blacknohisp = . if missing(racbl) | missing(hisp)
gen whitenohisp = (racwht == 1 & hisp == 0)
replace blacknohisp = . if missing(racwht) | missing(hisp)
gen othernohisp = (racwht == 0 & racbl == 0 & hisp == 0)
replace blacknohisp = . if missing(racwht) | missing(racbl) | missing(hisp)
drop racbl racwht
la var blacknohisp "Black Not Hisp"
la var whitenohisp "White Not Hisp"
la var othernohisp "Other Not Hisp"

* Organizing Education variable
gen elemsch = (schl == . | (schl >= 1 & schl <= 11))
gen highschincomp = (schl >= 12 & schl <= 15)
gen highschcomp = (schl >= 16 & schl <= 17)
gen college = (schl >= 18)
la var elemsch "8th grade or less"
la var highschincomp "High School Incomplete"
la var highschcomp "High School Complete"
la var college "Incomp College or Higher"

* Create age categories
gen agegrp=0 if age>=0 & age<=4
replace agegrp=1 if age>=5 & age<=17
replace agegrp=2 if age>=18 & age<=34
replace agegrp=3 if age>=35 & age<=44
replace agegrp=4 if age>=45 & age<=54
replace agegrp=5 if age>=55 & age<=64
replace agegrp=6 if age>=65 & age<=74
replace agegrp=7 if age>=75 & age<=84
replace agegrp=8 if age>=85
drop age
label define ageLabels 0 "0-4" 1 "5-17" 2 "18 - 34" 3 "35 - 44" 4 "45 - 54" 5 "55 - 64" 6 "65 - 74" 7 "75 - 84" 8 "85+"
label values agegrp ageLabels
la var agegrp "age Groups"

* Dummies for age Groups
gen age18_64 = (agegrp >=2 & agegrp <=5)
gen age45_64 = (agegrp==4) + (agegrp==5)
gen age55_64 = (agegrp==5)
gen age65_74 = (agegrp==6)
gen age65p = (agegrp>=6 & agegrp!=.)
gen ageallyrs = 1
la var age18_64 "18-64 yrs"
la var age45_64 "45-64 yrs"
la var age55_64 "55-64 yrs"
la var age65_74 "65-74 yrs"
la var age65p "65+ yrs"
la var ageallyrs "All ages"

* Poverty Ratio Dummies
gen blw100pvt = (povpip<= 100)
la var blw100pvt "Blw 100% FPL"
gen btw100138pvt = (povpip> 100 & povpip<= 138)
la var btw100138pvt "Btw 100-138% FPL"
gen blw138pvt = (povpip<= 138)
la var blw138pvt "Blw 138% FPL"
gen btw138200pvt = (povpip> 138 & povpip<= 200)
la var btw138200pvt "Btw 138-200% FPL"
gen btw100200pvt = (povpip> 100 & povpip<= 200)
la var btw100200pvt "Btw 100-200% FPL"
gen btw200400pvt = (povpip> 200 & povpip<= 400)
la var btw200400pvt "Btw 200-400% FPL"
gen blw200pvt = (povpip<= 200)
la var blw200pvt "Blw 200% FPL"
gen blw400pvt = (povpip<= 400)
la var blw400pvt "Blw 400% FPL"
gen btw138400pvt = (povpip>= 138 & povpip<= 400)
la var btw138400pvt "Btw 138-400% FPL"

* State, Year & Pop variables
gen Year = `yr'
rename statefip St_FIPS
la var St_FIPS "State FIPS"
la var Year "Year"
decode St_FIPS, generate(StAbbrev)
la var StAbbrev "State Abbreviation"
gen pop = 1
la var pop "Population"

* Collapse to the State-Level
gcollapse (sum) hins hipriv himcaid pop [aw=perwgt], by(Year StAbbrev St_FIPS male female hisp blacknohisp whitenohisp othernohisp elemsch highschincomp highschcomp college age18_64 age45_64 age55_64 age65_74 age65p ageallyrs blw100pvt btw100138pvt blw138pvt btw138200pvt btw100200pvt btw200400pvt blw200pvt blw400pvt btw138400pvt) labelformat(#sourcelabel#)

* Saving
tempfile temp`yr'
save "`temp`yr''", replace
}

use "`temp2008'"
foreach yr of numlist 2009/2017 {
append using "`temp`yr''"
}

order St_FIPS StAbbrev Year hins hipriv himcaid pop

save $sf_uns_master, replace

//-----------------------------------------------------------------
// COLLAPSE INTO YEAR-STATE LEVEL BY DIFFERENT DEMOGRAPHIC GROUPS
//-----------------------------------------------------------------

use $sf_uns_master, clear

**** Save labels
foreach v of varlist _all {
    local l`v' : variable label `v'
        if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

**** Create variables for each demographic
foreach var in pop hins hipriv himcaid {

	if "`var'" == "pop" {
		loc lpop = "Population"
	}
	if "`var'" == "hins" {
		loc lhins = "Health Ins"
	}

	foreach age in 55_64 65_74 45_64 18_64 65p allyrs {
		bysort St_FIPS Year: gegen aux = total(`var') if age`age' ==  1
		bysort St_FIPS Year: gegen `var'_`age' = max(aux)
		la var `var'_`age' "`l`var'': `lage`age'' `l`gen''"
		drop aux

		foreach gen in female male  {
			bysort St_FIPS Year: gegen aux = total(`var') if age`age' ==  1 & `gen' == 1
			bysort St_FIPS Year: gegen `var'_`age'_`gen' = max(aux)
			la var `var'_`age'_`gen' "`l`var'': `lage`age'' - `l`gen''"
			drop aux
		}

		foreach race in whitenohisp blacknohisp othernohisp hisp {
			bysort St_FIPS Year: gegen aux = total(`var') if age`age' ==  1 & `race' == 1
			bysort St_FIPS Year: gegen `var'_`age'_`race' = max(aux)
			la var `var'_`age'_`race' "`l`var'': `lage`age'' - `l`race''"
			drop aux
		}

		foreach educ in elemsch highschincomp highschcomp college {
			bysort St_FIPS Year: gegen aux = total(`var') if age`age' ==  1 & `educ' == 1
			bysort St_FIPS Year: gegen `var'_`age'_`educ' = max(aux)
			la var `var'_`age'_`educ' "`l`var'': `lage`age'' - `l`educ''"
			drop aux
		}

		foreach inc in blw100pvt btw100138pvt blw138pvt btw138200pvt btw100200pvt btw200400pvt blw200pvt blw400pvt btw138400pvt  {
			bysort St_FIPS Year: gegen aux = total(`var') if age`age' ==  1 & `inc' == 1
			bysort St_FIPS Year: gegen `var'_`age'_`inc' = max(aux)
			la var `var'_`age'_`inc' "`l`var'': `lage`age'' - `l`inc''"
			drop aux
		}
	}
}

drop hins hipriv himcaid pop male female hisp blacknohisp whitenohisp othernohisp elemsch highschincomp highschcomp college age18_64 age45_64 age55_64 age65_74 age65p ageallyrs blw100pvt btw100138pvt blw138pvt btw138200pvt btw100200pvt btw200400pvt blw200pvt blw400pvt btw138400pvt

**** Keep only first observation
duplicates drop
unique St_FIPS Year

**** Create percentage insured
foreach ins in hins hipriv himcaid {

	if "`ins'" == "hins" {
		loc lhins = "% Health Ins"
	}
	if "`ins'" == "hipriv" {
		loc lhipriv= "% Priv Ins"
	}
	if "`ins'" == "himcaid" {
		loc lhimcaid= "% Medicaid Ins"
	}

	foreach age in 55_64 65_74 45_64 18_64 65p allyrs {
		gen pct_`ins'_`age' = `ins'_`age'*100/pop_`age'
		la var pct_`ins'_`age' "`l`ins'': `lage`age''"

		foreach gen in female male  {
			gen pct_`ins'_`age'_`gen' = `ins'_`age'_`gen'*100/pop_`age'_`gen'
			la var pct_`ins'_`age'_`gen' "`l`ins'': `lage`age'' - `l`gen''"
		}
		foreach race in whitenohisp blacknohisp othernohisp hisp {
			gen pct_`ins'_`age'_`race' = `ins'_`age'_`race'*100/pop_`age'_`race'
			la var pct_`ins'_`age'_`race' "`l`ins'': `lage`age'' - `l`race''"
		}
		foreach educ in elemsch highschincomp highschcomp college {
			gen pct_`ins'_`age'_`educ' = `ins'_`age'_`educ'*100/pop_`age'_`educ'
			la var pct_`ins'_`age'_`educ' "`l`ins'': `lage`age'' - `l`educ''"
		}
		foreach inc in blw100pvt btw100138pvt blw138pvt btw138200pvt btw100200pvt btw200400pvt blw200pvt blw400pvt btw138400pvt {
			gen pct_`ins'_`age'_`inc' = `ins'_`age'_`inc'*100/pop_`age'_`inc'
			la var pct_`ins'_`age'_`inc' "`l`ins'': `lage`age'' - `l`inc''"
		}
	}
}

**** Drop counts, we will keep only the % variables and pop
drop hins_* hipriv_* himcaid_*

//-----------------------------------------------------------------
// MERGE WITH CONTROLS & GENERATE ATTXPOP WEIGHTS
//-----------------------------------------------------------------

**** Merge with controls
rename Year year
rename St_FIPS state

merge 1:1 year state using "$controlfile", keepusing(IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj Mcare_Disab smoking_all physicians_pc att)
drop if _merge == 2
drop _merge

rename year Year
rename state St_FIPS


**** Generate AttxPop weights

foreach age in 55_64 65_74 45_64 18_64 65p allyrs {
	gen attpop_`age' = att*pop_`age'
	la var attpop_`age' "AttxPop weights: `lage`age''"

	foreach gen in female male  {
		gen attpop_`age'_`gen' = att*pop_`age'_`gen'
		la var attpop_`age'_`gen' "AttxPop weights: `lage`age''- `l`gen''"
	}
	foreach race in whitenohisp blacknohisp othernohisp hisp {
		gen attpop_`age'_`race' = att*pop_`age'_`race'
		la var attpop_`age'_`race' "AttxPop weights: `lage`age''- `l`race''"
	}
	foreach educ in elemsch highschincomp highschcomp college {
		gen attpop_`age'_`educ' = att*pop_`age'_`educ'
		la var attpop_`age'_`educ' "AttxPop weights: `lage`age''- `l`educ''"
	}
	foreach inc in blw100pvt btw100138pvt blw138pvt btw138200pvt btw100200pvt btw200400pvt blw200pvt blw400pvt btw138400pvt {
		gen attpop_`age'_`inc' = att*pop_`age'_`inc'
		la var attpop_`age'_`inc' "AttxPop weights: `lage`age''- `l`inc''"
	}
}

//-----------------------------------------------------------------
// CREATE MEDICAID EXPANSION VAR
//-----------------------------------------------------------------

** Create Medicaid Expansion Variable
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
replace Expansion4=1 if StAbbrev == "LA" //LA expanded in July 2016

** Create Post Variable
gen Post = (Year>= 2014)
replace Post=0 if StAbbrev == "NH" & Year == 2014  //NH expanded in August 2014
replace Post=0 if StAbbrev == "PA" & Year == 2014  //PA expanded in Jan 2015
replace Post=0 if StAbbrev == "IN" & Year == 2014 //IN expanded in Feb 2015
replace Post=0 if StAbbrev == "AK" & (Year == 2014 | Year == 2015) //AK expanded in Sept 2015
replace Post=0 if StAbbrev == "MT" & (Year == 2014 | Year == 2015) //MT expanded in Jan 2016
replace Post=0 if StAbbrev == "LA" & (Year == 2014 | Year == 2015  | Year == 2016) ///LA expanded in July 2016

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
// SAVE
//-----------------------------------------------------------------

* Save
order Year StAbbrev St_FIPS Expansion4 Post EventTime IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj Mcare_Disab smoking_all physicians_pc pct_* pop_* attpop_*
sort St_FIPS Year
save "$savefile", replace
