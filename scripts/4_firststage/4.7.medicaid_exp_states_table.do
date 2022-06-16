* Leticia Nunes
* 01/10/2017
* Medicaid Expansion States Table

//-----------------------------------------------------------------
// SET UP
//-----------------------------------------------------------------

clear all

**** INPUT Files
global df_ACS = "$public_data_analysis/Ins_PopCtrlAtt_StYr_ACS_2008-2017.dta"
global df_aux = "$public_data_analysis/states_abbrev_names.dta"

**** OUTPUT Files
global tablefile = "$table_results_path/medicaid_exp_states_health_uninsurance.xlsx"

//-----------------------------------------------------------------
// ORGANIZE TABLE
//-----------------------------------------------------------------

use "$df_ACS", clear

keep Year StAbbrev pct_hins_18_64 pct_hins_allyrs

keep if Year == 2013 | Year == 2016

reshape wide pct_hins_18_64 pct_hins_allyrs, i(StAbbrev) j(Year) 

//gen diff_allyrs = pct_hins_allyrs2013 - pct_hins_allyrs2016
gen diff_18_64 = pct_hins_18_642013 - pct_hins_18_642016
la var diff_18_64 " % Change Uninsurance (2013-2016), 18-64 years"

keep StAbbrev diff_*

merge 1:1 StAbbrev using "$df_aux"
keep if _merge == 3
drop _merge
order StName
sort StName

export excel using "$table_results_path/medicaid_exp_states_health_uninsurance.xlsx", firstrow(varlabels) replace

