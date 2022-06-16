import delimited "$table_results_path/partial_data_for_figure_in_r.csv", clear 
keep if label == "Amenable " 
list in 1/4


import delimited "$table_results_path/partial_data_for_figure_in_r.csv", clear 
drop if label == "Amenable " 
sum mde if geographic_level == "county" & spec_type == "dd"
sum mde if geographic_level == "county" & spec_type == "dd", detail
sumup mde if geographic_level == "county" & spec_type == "dd", s(mean median)
sumup mde if geographic_level == "county" & spec_type == "ddd", s(mean median)
sumup mde if geographic_level == "state" & spec_type == "dd", s(mean median)
sumup mde if geographic_level == "state" & spec_type == "ddd", s(mean median)

