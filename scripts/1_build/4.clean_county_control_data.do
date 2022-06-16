use "$public_data_analysis/Controls_Cty.dta", clear


gen str5 str_fips = string(FIPS_numeric , "%05.0f")

gen state = substr(str_fips,1,2)
gen county = substr(str_fips,3,3)
destring state, replace
destring county, replace
rename Year year
drop  FIPS FIPS_numeric str_fips St_FIPS

compress
sort state county year
order state county year
save "$public_data_analysis/county_controls.dta", replace 
