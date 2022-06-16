// Set local macro year
args year

// Create age
gen age=age2 if age1==1
replace age=0 if age1>=2 & age1<=6
drop age1 age2

// Create race
gen white=race==1
gen othrace=race==2
gen black=race==3
drop race

// Generate hispanic binary (unknown is counted as non-hispanic)
qui replace hispanic=1 if hispanic>=1 & hispanic<=5
qui replace hispanic=0 if hispanic>=6 & hispanic<=9

// Create female binary to match 1999-2002
gen female=fem=="F"
drop fem

// Create education
gen education = . 
replace education = 1 if educ1<= 8 & educflag==0 // ElemSch and 1989 reporting type
replace education = 2 if educ1>= 9 & educ1<= 11 & educflag==0  // HighSchIncomp and 1989 reporting type
replace education = 3 if educ1 == 12 & educflag==0  // HighSchComp and 1989 reporting type
replace education = 4 if educ1>= 13 & educ1<= 17 & educflag==0  // College and 1989 reporting type

replace education = 1 if educ2 == 1 & educflag==1  // ElemSch and 1989 reporting type
replace education = 2 if educ2 == 2 & educflag==1  // HighSchIncomp and 1989 reporting type
replace education = 3 if educ2 == 3 & educflag==1  // HighSchComp and 1989 reporting type
replace education = 4 if educ2 >= 4 & educ2 <=8 & educflag==1  // College and 1989 reporting type

replace education = 9 if missing(education)

la define education_label 1 "8th grade or less" 2 "High School Incomplete" 3 "High School Complete" 4 "Incomplete College or higher" 9 "Unknown", replace
la values education education_label

drop educ1 educ2 educflag

// Recode string state of residence to fips
gen state = .

replace state=02 if statel=="AK"	
replace state=01 if statel=="AL"	
replace state=05 if statel=="AR"	
replace state=04 if statel=="AZ"	
replace state=06 if statel=="CA"	
replace state=08 if statel=="CO"	
replace state=09 if statel=="CT"	
replace state=11 if statel=="DC"	
replace state=10 if statel=="DE"	
replace state=12 if statel=="FL"	
replace state=13 if statel=="GA"	
replace state=15 if statel=="HI"	
replace state=19 if statel=="IA"	
replace state=16 if statel=="ID"	
replace state=17 if statel=="IL"	
replace state=18 if statel=="IN"	
replace state=20 if statel=="KS"	
replace state=21 if statel=="KY"	
replace state=22 if statel=="LA"	
replace state=25 if statel=="MA"	
replace state=24 if statel=="MD"	
replace state=23 if statel=="ME"	
replace state=26 if statel=="MI"	
replace state=27 if statel=="MN"	
replace state=29 if statel=="MO"	
replace state=28 if statel=="MS"	
replace state=30 if statel=="MT"	
replace state=37 if statel=="NC"	
replace state=38 if statel=="ND"	
replace state=31 if statel=="NE"	
replace state=33 if statel=="NH"	
replace state=34 if statel=="NJ"	
replace state=35 if statel=="NM"	
replace state=32 if statel=="NV"	
replace state=36 if statel=="NY"	
replace state=39 if statel=="OH"	
replace state=40 if statel=="OK"	
replace state=41 if statel=="OR"	
replace state=42 if statel=="PA"	
replace state=44 if statel=="RI"	
replace state=45 if statel=="SC"	
replace state=46 if statel=="SD"	
replace state=47 if statel=="TN"	
replace state=48 if statel=="TX"	
replace state=49 if statel=="UT"	
replace state=51 if statel=="VA"	
replace state=50 if statel=="VT"	
replace state=53 if statel=="WA"	
replace state=55 if statel=="WI"	
replace state=54 if statel=="WV"	
replace state=56 if statel=="WY"

drop statel

// Keep only US 51 state residents
keep if !missing(state)

// generate year
gen year = `year'

////////////////////////////////////////////////////////////////////////////////
// Part 3. Create variables that will work with leticia's code

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

/////////////////////////////////////////
// Create certain causes of death 

//Cancer
gen can = (ucr39>=5 & ucr39<=15)


//Diabetes
gen dia = (ucr39==16 | ucr39==31)


//Cardiovascular
gen card = (ucr39>=20 & ucr39<=26)


//Respiratory
gen resp = (ucr39==27 | ucr39==28)


//HIV
gen hiv = (ucr39 == 3)

/////////////////////////////////////////
// Create low education (high-school incomplete)
gen low_educ = . 
replace low_educ = 0 if !missing(education)
replace low_educ = 1 if education <= 2 & !missing(education)


/////////////////////////////////////////
// Create health care amenible indicator 
*Note:  This code is from "05ICD10_HealthcareAmenableMapping_15.06.12-aw" on redwood
*		Written by Yingzi Wang on 2 June 2015

gen cod_amenable_SLB = 1 if match(icd10, "A*") + match(icd10, "B*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "C*") + match(icd10, "D1*") + match(icd10, "D2*")+ match(icd10, "D3*")+ match(icd10, "D4*")== 1
replace cod_amenable_SLB = 1 if match(icd10, "E0*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "E10*")  + match(icd10, "E11*") + match(icd10, "E12*") + match(icd10, "E13*")+ match(icd10, "E14*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "G40*")  + match(icd10, "G41*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "I05*")  + match(icd10, "I06*") + match(icd10, "I07*")+ match(icd10, "I08*")+ match(icd10, "I09*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "I10*")  + match(icd10, "I11*") + match(icd10, "I12*")+ match(icd10, "I13*")+ match(icd10, "I15*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "I20*")  + match(icd10, "I21*") + match(icd10, "I22*")+ match(icd10, "I23*")+match(icd10, "I24*")+ match(icd10, "I25*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "I42*")  + match(icd10, "I48*") + match(icd10, "I49*")+ match(icd10, "I50*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "I6*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "J*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "K25*")  + match(icd10, "K26*") + match(icd10, "K27*")+ match(icd10, "K28*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "K35*")  + match(icd10, "K36*") + match(icd10, "K37*")+ match(icd10, "K38*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "K40*")  + match(icd10, "K41*") + match(icd10, "K42*")+ match(icd10, "K43*") + match(icd10, "K44*") + match(icd10, "K45*")+ match(icd10, "K46*") == 1
replace cod_amenable_SLB = 1 if match(icd10, "K80*")  + match(icd10, "K81*") + match(icd10, "K82*")+ match(icd10, "K83*")== 1 + match(icd10, "K85*")== 1
replace cod_amenable_SLB = 1 if match(icd10, "L0*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "M00*")+ match(icd10, "M01*")+ match(icd10, "M02*")== 1 
replace cod_amenable_SLB = 1 if match(icd10, "N0*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "N1*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "O*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "Y6*") == 1 
replace cod_amenable_SLB = 1 if match(icd10, "Y83*")+match(icd10, "Y84*") == 1 

replace cod_amenable_SLB = 0 if missing(cod_amenable_SLB)
rename cod_amenable_SLB amen

// All causes of death
gen any = 1

// Generate non-amenable causes of 
gen namen = any - amen

////////////////////////////////////////////////////////////////////////////////
// Part 4. Create county-year-age-race-gender counts by cause-of-death

local cod_list any namen amen hiv resp card dia can 
foreach cod in `cod_list' {
	foreach age in 55_64 65_74 45_64 18_64 eld tot {
		// Non-hispanic black and white by age group
		foreach race in white black {
			bysort state county year: gegen temp_`cod'_`race'_non_hisp_`age' = total(`cod') if `race' == 1 & hispanic == 0 & age_`age' == 1
			bysort state county year: gegen `cod'_`race'_non_hisp_`age' = max(temp_`cod'_`race'_non_hisp_`age')
			drop temp_`cod'_`race'_non_hisp_`age'
		}
		
		// Hispanic by age group
		bysort state county year: gegen temp_`cod'_hisp_`age' = total(`cod') if hispanic == 1 & age_`age' == 1
		bysort state county year: gegen `cod'_hisp_`age' = max(temp_`cod'_hisp_`age')
		drop temp_`cod'_hisp_`age'
		
		// Female by age
		bysort state county year: gegen temp_`cod'_fem_`age' = total(`cod') if female == 1 & age_`age' == 1
		bysort state county year: gegen `cod'_fem_`age' = max(temp_`cod'_fem_`age')
		drop temp_`cod'_fem_`age'
		
		// Male by age
		bysort state county year: gegen temp_`cod'_male_`age' = total(`cod') if female == 0 & age_`age' == 1
		bysort state county year: gegen `cod'_male_`age' = max(temp_`cod'_male_`age')
		drop temp_`cod'_male_`age'
		
		// By age
		bysort state county year: gegen temp_`cod'_`age' = total(`cod') if age_`age' == 1
		bysort state county year: gegen `cod'_`age' = max(temp_`cod'_`age')
		drop temp_`cod'_`age'
		
		// For low_education
		bysort state county year: gegen temp_`cod'_le_`age' = total(`cod') if low_educ == 1 & age_`age' == 1
		bysort state county year: gegen `cod'_le_`age' = max(temp_`cod'_le_`age')
		drop temp_`cod'_le_`age'
	}
}


// Drop the meaninglys variables 
drop  othrace hispanic age age_18_64 age_eld age_55_64 age_65_74 age_45_64 age_tot white black female ///
	any namen amen hiv resp card dia can education

// Rename total 
rename *_tot *

// Drop duplicate observations
bysort state county year: keep if _n == 1

// Replace missing variables with zeros
qui ds any* namen* amen* hiv* resp* card* dia* can*
foreach x in `r(varlist)' {
	replace `x' = 0 if missing(`x')
}

////////////////////////////////////////////////////////////////////////////////
// Part 5. Clean up 
drop icd10 ucr39 res
order state county year
sort state county year

// There are a very small number of observations without county fips (72 total across all years 1999-2017)
drop if county == 0
