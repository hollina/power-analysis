// Close any open log files
capture log close
// Clear Memory
clear all
// Set Date
global date = subinstr("$S_DATE", " ", "-", .)
// Set your file paths.
global root_path "/N/project/Simon_HealthEcProj1/power_health_insurance_and_mortality_20_DEC_2020"
global restricted_data "$root_path/data/restricted_access" // Path for data used in analysis
global public_data "$root_path/data/public_access" // Path for data used in analysis
global restricted_data_raw "$restricted_data/raw_data"
global public_data_raw "$public_data/raw_data" 
global restricted_data_analysis "$restricted_data/data_for_analysis"  // Path for data used in analysis
global public_data_analysis "$public_data/data_for_analysis"  // Path for data used in analysis
global temp_path "$root_path/temp" // Path for temp folder
global script_path "$root_path/scripts" // Path for running the scripts to create tables and figures
global table_results_path "$root_path/output/tables" // Path for tables/figures output
global figure_results_path "$root_path/output/figures" // Path for tables/figures output
global log_path "$root_path/output/logs" // Path for logs
adopath + "$root_path/stata_packages"
// Specify Screen Width for log files
set linesize 255
// Set font type
graph set window fontface "Times New Roman"
// Set Graph Scheme
set scheme plotplainblind
// Allow the screen to move without having to click more
set more off
// Drop everything in mata
matrix drop _all
// Load programs
do "$script_path/3_power/3.1.power_analysis_dd.do"
do "$script_path/3_power/3.2.power_analysis_ddd.do"
do "$script_path/3_power/3.3.power_analysis_dd_state_level.do"
do "$script_path/3_power/3.4.power_analysis_ddd_state_level.do"
do "$script_path/3_power/3.5.power_analysis_dd_control_only.do"
do "$script_path/3_power/3.6.power_analysis_ddd_control_only.do"
do "$script_path/3_power/3.7.power_analysis_dd_control_only_state_level.do"
do "$script_path/3_power/3.8.power_analysis_ddd_control_only_state_level.do"
do "$script_path/3_power/3.9.power_analysis_dd_simple_synth.do"
do "$script_path/3_power/3.10.power_analysis_ddd_simple_synth.do"
do "$script_path/3_power/3.11.power_analysis_dd_simple_synth_state_level.do"
do "$script_path/3_power/3.12.power_analysis_ddd_simple_synth_state_level.do"
// Run single program
power_analysis_ddd, ///
        end_value(.12) ///
        step_size(.005) ///
        max_dataset_number(1000) ///
        first_year(2001) ///
        last_year(2010) ///
        death_type(amen) ///
        dem_type(fem) ///
        list_of_controls(yes) ///
        weight_var(attpop) /// 
        cluster_var(state) ///
        prefix(ln)
