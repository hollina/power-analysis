use "$restricted_data_analysis/death_rates_1999_2017.dta", clear

// Merge in control data at the county-level
merge 1:1 state county year using "$restricted_data_analysis/county_controls_with_att_pop.dta"
keep if _merge == 3
drop _merge 


// Keep only certain years
keep if year >= 2004 & year <= 2016

*year >= 2009 &

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


bysort state year: keep if _n == 1






gen expansion = expansion_4
replace expansion = 1 if expansion_4 == 2
replace expansion = 1 if expansion_4 == 3

gen treatment = expansion * post 


********************************************************************************
*Make an adoption year variable.
capture drop exp_year
gen exp_year = year if treatment==1
egen adopt_year = min(exp_year), by(state)


count if year == 2014
tab expansion_4 post if year == 2014
tab expansion_4 post if year == 2015
tab expansion_4 post if year == 2016

distinct StAbbrev if adopt_year == 2014
levelsof StAbbrev if adopt_year == 2014

distinct StAbbrev if adopt_year == 2015
levelsof StAbbrev if adopt_year == 2015

distinct StAbbrev if adopt_year == 2016
levelsof StAbbrev if adopt_year == 2016

distinct StAbbrev if adopt_year == 2017
levelsof StAbbrev if adopt_year == 2017


///////////////////////////////////////////
// Keep non-expansion and full-expansion
drop if  expansion_4 == 2 | expansion_4 == 3

count if year == 2014
distinct StAbbrev if adopt_year == 2014
levelsof StAbbrev if adopt_year == 2014

distinct StAbbrev if adopt_year == 2015
levelsof StAbbrev if adopt_year == 2015

distinct StAbbrev if adopt_year == 2016
levelsof StAbbrev if adopt_year == 2016

distinct StAbbrev if adopt_year == 2017
levelsof StAbbrev if adopt_year == 2017
