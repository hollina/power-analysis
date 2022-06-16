
st_power_analysis_dd, ///
        end_value(.12) ///
        step_size(.005) ///
        max_dataset_number(1000) ///
        first_year(2001) ///
        last_year(2010) ///
        death_type(hiv) ///
        dem_type(55_64) ///
        list_of_controls(yes) ///
        weight_var(attpop) /// 
        cluster_var(state) ///
        prefix(ln)
