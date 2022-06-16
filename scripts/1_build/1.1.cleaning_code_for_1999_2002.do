// Set local macro year
args year

// Harmonize age for merge with 2003 on
gen age=age2 if age1==0
replace age=age2+100 if age1==1
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

// Generate female binary
replace female=female-1

// Create education (missing for many observations)
gen education = . 
replace education = 1 if educ<= 8 // ElemSch
replace education = 2 if educ>= 9 & educ<= 11 // HighSchIncomp
replace education = 3 if educ == 12 // HighSchComp
replace education = 4 if educ>= 13 & educ<= 17 // College
replace education = 9 if missing(education)
drop educ

la define education_label 1 "8th grade or less" 2 "High School Incomplete" 3 "High School Complete" 4 "Incomplete College or higher" 9 "Unknown", replace
la values education education_label

// Keep only US 51 state residents
gen us_51 = .

replace us_51 = 1 if state == 02 
replace us_51 = 1 if state == 01 	
replace us_51 = 1 if state == 05 	
replace us_51 = 1 if state == 04 	
replace us_51 = 1 if state == 06 	
replace us_51 = 1 if state == 08 	
replace us_51 = 1 if state == 09 	
replace us_51 = 1 if state == 11 	
replace us_51 = 1 if state == 10 	
replace us_51 = 1 if state == 12 	
replace us_51 = 1 if state == 13 	
replace us_51 = 1 if state == 15 	
replace us_51 = 1 if state == 19 	
replace us_51 = 1 if state == 16 	
replace us_51 = 1 if state == 17 	
replace us_51 = 1 if state == 18 	
replace us_51 = 1 if state == 20 	
replace us_51 = 1 if state == 21 	
replace us_51 = 1 if state == 22 	
replace us_51 = 1 if state == 25 	
replace us_51 = 1 if state == 24 	
replace us_51 = 1 if state == 23 	
replace us_51 = 1 if state == 26 	
replace us_51 = 1 if state == 27 	
replace us_51 = 1 if state == 29 	
replace us_51 = 1 if state == 28 	
replace us_51 = 1 if state == 30 	
replace us_51 = 1 if state == 37 	
replace us_51 = 1 if state == 38 	
replace us_51 = 1 if state == 31 	
replace us_51 = 1 if state == 33 	
replace us_51 = 1 if state == 34 	
replace us_51 = 1 if state == 35 	
replace us_51 = 1 if state == 32 	
replace us_51 = 1 if state == 36 	
replace us_51 = 1 if state == 39 	
replace us_51 = 1 if state == 40 	
replace us_51 = 1 if state == 41 	
replace us_51 = 1 if state == 42 	
replace us_51 = 1 if state == 44 	
replace us_51 = 1 if state == 45 	
replace us_51 = 1 if state == 46 	
replace us_51 = 1 if state == 47 
replace us_51 = 1 if state == 48 	
replace us_51 = 1 if state == 49 	
replace us_51 = 1 if state == 51 	
replace us_51 = 1 if state == 50 	
replace us_51 = 1 if state == 53 	
replace us_51 = 1 if state == 55 	
replace us_51 = 1 if state == 54 	
replace us_51 = 1 if state == 56 

keep if us_51 == 1
drop us_51


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
