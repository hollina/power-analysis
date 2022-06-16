clear all

use "$public_data_raw/hcup_sid_az_data.dta"

gen yq = yq(y, q)
format yq %tq

 
twoway connected medicareage65 yq, ///
	|| connected medicaidage1964 yq, ///
	|| connected privateage1964  yq, ///
	|| connected uninsuredage1964 yq, ///
		legend(pos(6) col(2)) ///
		ytitle("Number of Inpatient Stays, 10k") ///
		xtitle("Year") ///
		ylabel(0 "0" 20000 "20" 40000 "40" 60000 "60" 80000 "80") ///
		xlabel(184 "2006" 192 "2008" 200 "2010" 208 "2012" 216 "2014" 224 "2016") ///
		xline(216)
		
graph export "$figure_results_path/hcup_sid_az_inpatient_stays.pdf", replace
