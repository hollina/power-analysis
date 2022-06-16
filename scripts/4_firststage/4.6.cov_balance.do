* Leticia Nunes
* 01/10/2017
* Covariance Balance Table

//-----------------------------------------------------------------
// SET UP
//-----------------------------------------------------------------

global df_deaths = "$restricted_data_analysis/death_rates_1999_2017.dta"
global df_controls = "$restricted_data_analysis/county_controls_with_att_pop.dta"
global df_ins = "$public_data_analysis/Unins_PopCtrlAtt_CtyYr_SAHIE.dta"

global tablefile = "$table_results_path/cov_balance.xlsx"

//-----------------------------------------------------------------
// INSURANCE
//-----------------------------------------------------------------

use Year StAbbrev Cty_FIPS pctui_18_64 pctui_50_64 pctui_18_64_blw138pvt pctui_50_64_blw138pvt using "$df_ins", clear
// pctui_18_64_btw138400pvt pctui_50_64_btw138400pvt
rename Year year
gen county = real(substr(string(Cty_FIPS),-3,3))
drop Cty_FIPS
keep if year <= 2013
tab year
tempfile temp_hins
save "`temp_hins'", replace

//-----------------------------------------------------------------
// DEMOGRAPHICS (DECEASED)
//-----------------------------------------------------------------

use "$df_deaths", clear

**** Keep years and variables used in the analysis
keep if year <= 2013

keep state county year  ///
	 dr_any dr_any_55_64 dr_any_65_74 ///
	 dr_amen dr_amen_55_64 dr_amen_65_74 ///
	 dr_namen dr_namen_55_64 dr_namen_65_74 ///
	 any any_55_64 any_65_74 ///
	 any_fem any_fem_55_64 any_fem_65_74 ///
	 any_white_non_hisp any_white_non_hisp_55_64 any_white_non_hisp_65_74 ///
	 any_black_non_hisp any_black_non_hisp_55_64 any_black_non_hisp_65_74 ///
	 any_hisp any_hisp_55_64 any_hisp_65_74 

**** Create % variables
foreach demogr in 55_64 65_74 fem fem_55_64 fem_65_74 white_non_hisp white_non_hisp_55_64 white_non_hisp_65_74 black_non_hisp black_non_hisp_55_64 black_non_hisp_65_74 hisp hisp_55_64 hisp_65_74  {
	gen pct_`demogr' = any_`demogr'*100/any	
}
drop any*

//-----------------------------------------------------------------
// MERGE ALL INFORMATION
//-----------------------------------------------------------------

**** Merge with controls
merge 1:1 state county year using "$df_controls", keepusing(StAbbrev PovertyPrcnt Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH UnempRate diabetes_prev_rate_age_adj inactivity_percent_age_adj obesity_percent smoking_all physicians_pc pop* attpop*) //
keep if _merge == 3
drop _merge 

**** Merge with Insurance
merge 1:1 StAbbrev county year using "`temp_hins'"
drop if _merge == 2
drop _merge

//-----------------------------------------------------------------
// CREATE MEDICAID EXPANSION VAR
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

** Expansion and treatment variables
drop if  Expansion4 == 2 | Expansion4 == 3
rename Expansion4 Expansion
la var Expansion "0 is no expansion, 1 is full expansion"


** Gen expansion Ali
gen exp_ali = Expansion
replace exp_ali = . if StAbbrev == "AK" | StAbbrev == "IN" | StAbbrev == "LA" | StAbbrev == "MT" | StAbbrev == "PA"
replace exp_ali = . if exp_ali == 2 | exp_ali == 3
la var exp_ali "Expansion - Ali Definition"


//-----------------------------------------------------------------
// COVARIANCE BALANCE - EXCEL TABLE
//-----------------------------------------------------------------

order state county year Expansion dr_any dr_any* dr_amen dr_amen* dr_namen dr_namen* 

la var dr_any "Death Rate"
la var dr_any_55_64 "Death Rate 55-64 years"
la var dr_any_65_74 "Death Rate 65-74 years"
la var dr_namen "Amenable Death Rate"
la var dr_namen_55_64 "Amenable Death Rate 55-64 years"
la var dr_namen_65_74 "Amenable Death Rate 65-74 years"
la var dr_amen "Non-amenable Death Rate"
la var dr_amen_55_64 "Non-amenable Death Rate 55-64 years"
la var dr_amen_65_74 "Npn-amenable Death Rate 65-74 years"
la var pct_55_64 "% 55-64 years"
la var pct_65_74 "% 65-74 years"
la var pct_fem "% Female"
la var pct_fem_55_64 "% Female, 55-64 years"
la var pct_fem_65_74 "% Female, 65-74 years"
la var pct_white_non_hisp "% White"
la var pct_white_non_hisp_55_64 "% White, 55-64 years"
la var pct_white_non_hisp_65_74 "% White, 65-74 years"
la var pct_black_non_hisp "% Black"
la var pct_black_non_hisp_55_64 "% Black, 55-64 years"
la var pct_black_non_hisp_65_74 "% Black, 65-74 years"
la var pct_hisp "% Hispanic"
la var pct_hisp_55_64 "% Hispanic, 55-64 years"
la var pct_hisp_65_74 "% Hispanic, 65-74 years"

la var Mcare_Adv_Penet "% Managed Care Penetration"
la var Mcare_Disab "% Disabled (ages 18-64)"
la var PovertyPrcnt "% In Poverty"
la var UnempRate "Unemployment Rate, 16+"
la var IncMedHH "Median Household Income"
la var IncPC "Mean Per Capita Income"
la var diabetes_prev_rate_age_adj "% with Diabetes"
la var obesity_percent "% Obese"
la var inactivity_percent_age_adj "% Physically Inactive"
la var smoking_all "% Smoker"
la var physicians_pc "Physicians/1,000 people"

la var pctui_18_64 "% Uninsured (18-64 years)"
la var pctui_50_64 "% Uninsured (50-64 years)"
la var pctui_18_64_blw138pvt "% Uninsured (18-64 years), <138% FPL"
la var pctui_50_64_blw138pvt "% Uninsured (50-64 years), <138% FPL"

foreach wgt in pop attpop {

	eststo diff: pbalchk Expansion ///
				   pct_55_64 pct_65_74 pct_fem pct_fem_55_64 pct_fem_65_74 pct_white_non_hisp pct_white_non_hisp_55_64 pct_white_non_hisp_65_74 ///
				   pct_black_non_hisp pct_black_non_hisp_55_64 pct_black_non_hisp_65_74 pct_hisp pct_hisp_55_64 pct_hisp_65_74  ///
				   PovertyPrcnt Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH ///
				   UnempRate diabetes_prev_rate_age_adj ///
				   inactivity_percent_age_adj obesity_percent smoking_all physicians_pc ///
				   pctui_18_64 pctui_50_64 pctui_18_64_blw138pvt pctui_50_64_blw138pvt ///
				   dr_any dr_any_55_64 dr_any_65_74 dr_amen dr_amen_55_64 dr_amen_65_74 dr_namen dr_namen_55_64 dr_namen_65_74, ///
				   wt(`wgt') f
			  
	matrix A = (r(meantreat)', r(meanuntreat)')
	matrix B = (r(smeandiff)')	

	quietly putexcel set "$tablefile", sheet("Cov Balance (`wgt')") modify

	loc row = 3
	foreach var in pct_55_64 pct_65_74 pct_fem pct_fem_55_64 pct_fem_65_74 pct_white_non_hisp pct_white_non_hisp_55_64 pct_white_non_hisp_65_74 ///
				   pct_black_non_hisp pct_black_non_hisp_55_64 pct_black_non_hisp_65_74 pct_hisp pct_hisp_55_64 pct_hisp_65_74  ///
				   PovertyPrcnt Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH ///
				   UnempRate diabetes_prev_rate_age_adj ///
				   inactivity_percent_age_adj obesity_percent smoking_all physicians_pc ///
				   pctui_18_64 pctui_50_64 pctui_18_64_blw138pvt pctui_50_64_blw138pvt ///
				   dr_any dr_any_55_64 dr_any_65_74 dr_amen dr_amen_55_64 dr_amen_65_74 dr_namen dr_namen_55_64 dr_namen_65_74 {				 
		reg `var' Expansion [aw=`wgt'], vce(cluster state)
		qui putexcel D`row' = matrix(sqrt(e(F))), nformat("0.00") hcenter
		loc ++row
	}	
			
	quietly putexcel B1 = "Full Expansion States", hcenter bold
	quietly putexcel C1 = "Non-Expansion States", hcenter bold
	quietly putexcel D1 = "Difference t-stat", hcenter bold
	quietly putexcel E1 = "Normalized Difference", hcenter bold
	quietly putexcel B2 = "(1)", hcenter bold
	quietly putexcel C2 = "(2)", hcenter bold
	quietly putexcel D2 = "(3)", hcenter bold
	quietly putexcel E2 = "(4)", hcenter bold

	loc row = 3
	foreach var in pct_55_64 pct_65_74 pct_fem pct_fem_55_64 pct_fem_65_74 pct_white_non_hisp pct_white_non_hisp_55_64 pct_white_non_hisp_65_74 ///
				   pct_black_non_hisp pct_black_non_hisp_55_64 pct_black_non_hisp_65_74 pct_hisp pct_hisp_55_64 pct_hisp_65_74  ///
				   PovertyPrcnt Mcare_Adv_Penet Mcare_Disab IncPC IncMedHH ///
				   UnempRate diabetes_prev_rate_age_adj ///
				   inactivity_percent_age_adj obesity_percent smoking_all physicians_pc ///
				   pctui_18_64 pctui_50_64 pctui_18_64_blw138pvt pctui_50_64_blw138pvt ///
				   dr_any dr_any_55_64 dr_any_65_74 dr_amen dr_amen_55_64 dr_amen_65_74 dr_namen dr_namen_55_64 dr_namen_65_74 {
		local varlabel : var label `var'
		qui putexcel A`row' = ("`varlabel'")
		loc ++row
	}

	quietly putexcel B3= matrix(A), nformat("0.00") hcenter
	quietly putexcel E3= matrix(B), nformat("0.00") hcenter

	putexcel A1:E40, fpatter(solid, white)
	putexcel A1:E40, font("Times New Roman", 10)

	putexcel A1:E1, border(top, double)
	putexcel A2:E2, border(bottom)
	putexcel A27:E27, border(bottom)
	putexcel A40:E40, border(bottom, double)

}
