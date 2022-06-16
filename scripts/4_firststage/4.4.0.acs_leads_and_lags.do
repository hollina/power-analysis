* Leticia Nunes
* 01/10/2017
* ACS Leads & Lags Graphs

//-----------------------------------------------------------------
// SET UP
//-----------------------------------------------------------------

**** Clear memory
clear all

**** INPUT DATA
global datafile = "$public_data_analysis/Ins_PopCtrlAtt_StYr_ACS_2008-2017.dta"

**** OUTPUT
** Graphs path
global graphpath = "$first_stage_results_path"

**** Locals
loc weights pop attpop
loc instype hins hipric himcaid_
loc controls

**** Programs
do "$script_path/4_firststage/4.4.1.es_graph_alex_edits.do"

//-----------------------------------------------------------------
// DDD Graphs
//-----------------------------------------------------------------

use "$datafile", clear
reshape long pct_hins_ pct_hipriv_ pct_himcaid_ pop_, i(Year St_FIPS) j(aux) string
drop if Year == 2017
keep if Expansion == 1 | Expansion == 0

foreach inc in  "_blw138pvt" ""  { //"_blw100pvt" "_btw100138pvt" "_btw138200pvt" "_btw100200pvt" "_btw200400pvt" "_blw200pvt" "_blw400pvt" "_btw138400pvt"

	preserve
	keep if aux == "55_64`inc'" | aux == "65_74`inc'"
	replace pct_hins_ = 100-pct_hins_
	gen d55_64 = (aux == "55_64`inc'")
	gen treatment = d55_64*Expansion
	gen post_age = Post*d55_64
	gen post_exp = Post*Expansion
	gen age_exp = d55_64*Expansion
	
	gen attpop = attpop_55_64`inc'
	replace attpop = attpop_65_74`inc' if aux ==  "65_74`inc'"


/*	if "`inc'" == "" {
		global title = "Percent Uninsured All Income"
	}
	if "`inc'" == "_blw100pvt" {
		global title "Percent Uninsured Below 100 FPL"
	}
	if "`inc'" == "_blw200pvt" {
		global title "Percent Uninsured Below 200 FPL"
	}
	if "`inc'" == "_blw138pvt" {
		global title "Percent Uninsured Below 138 FPL"
	}
	if "`inc'" == "_blw400pvt" {
		global title "Percent Uninsured Below 400 FPL"
	}
	if "`inc'" == "_btw100138pvt" {
		global title "Percent Uninsured 100 to 138 FPL"
	}
	if "`inc'" == "_btw138200pvt" {
		global title "Percent Uninsured 138 to 200 FPL"
	}
	if "`inc'" == "_btw100200pvt" {
		global title "Percent Uninsured 100 to 200 FPL"
	}
	if "`inc'" == "_btw200400pvt" {
		global title "Percent Uninsured 200 to 400 FPL"
	}
	if "`inc'" == "_btw138400pvt" {
		global title "Percent Uninsured 138 to 400 FPL"
	}*/

	//global subtitle "55to64 vs 65to74 yrs and Expansion vs Non Expansion"
	global title ""
	global subtitle ""
	global xtitle "Years since ACA Expansion"
	global ytitle "DDD Coefficient"

	global panel_id Year
	global panel_time Year
	global binary_treatment treatment
	global controls "IncPC IncMedHH PovertyPrcnt UnempRate Mcare_Adv_Penet diabetes_prev_rate_age_adj obesity_percent inactivity_percent_age_adj Mcare_Disab smoking_all physicians_pc Post d55_64 Expansion post_age post_exp age_exp"

	es_graph pct_hins_ treatment St_FIPS Year St_FIPS EventTime attpop $controls -5 2  $title $subtitle $xtitle $ytitle
	graph save "${graphpath}/fs_ddd_55-64vs65-74_ExpvsNoExp`inc'.gph", replace
	graph export "${graphpath}/fs_ddd_55-64vs65-74_ExpvsNoExp`inc'.png", replace width(3000)

	restore

}
