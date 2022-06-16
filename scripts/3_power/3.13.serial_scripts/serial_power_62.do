
// Run single program
st_power_analysis_dd, ///
        end_value(.2) ///
        step_size(.01) ///
        max_dataset_number(1000) ///
        first_year(2001) ///
        last_year(2010) ///
        death_type(amen) ///
        dem_type(hisp_55_64) ///
        list_of_controls(yes) ///
        weight_var(attpop) /// 
        cluster_var(state) ///
        prefix(ln)
