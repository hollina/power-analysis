use "$public_data_analysis/Controls_St.dta", clear


rename St_FIPS state
rename Year year

compress
sort state  year
order state  year
save "$public_data_analysis/state_controls.dta", replace 
