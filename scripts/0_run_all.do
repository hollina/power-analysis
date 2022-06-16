////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// Replication code for:

// Black et al. (2022).

// Email: hollinal@indiana.edu

// Version: v1.0.0

// Date: 15 June 2022

// Code is also available at https://github.com/hollina/simulated-power-analysis

// File: 0_run_all.do

// Description: This file runs all code needed to replicate our paper

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Close any open log files
capture log close

// Clear Memory
clear all

// Set Date
global date = subinstr("$S_DATE", " ", "-", .)

// Set R path
global r_path "/usr/local/bin/R" 

///////////////////////////////////////////////////////////////////////////////
// Set options 

// Build dataset used in analysis (0 for no; 1 for yes)
global build_data 1

// Use restricted access mortality data  (0 for no; 1 for yes)
global restricted_access 1

// Run very slow parts of the analysis code (0 for no; 1 for yes)
global slow_code 0

// Indicator if you're using IU's supercomputer carbonate. 
// If not the power analysis will be done in serial rather than submitted as jobs to be run in parallel
global carbonate 0

////////////////////////////////////////////////////////////////////////////
// Set your file paths

// For data
global restricted_data "data/restricted_access" 
global public_data "data/public_access" 

global restricted_data_raw "$restricted_data/raw_data"
global public_data_raw "$public_data/raw_data"

global restricted_data_analysis "$restricted_data/data_for_analysis"  
global public_data_analysis "$public_data/data_for_analysis"  

// For temp
global temp_path "temp"

// For scripts
global script_path "scripts" 

// For output
global table_results_path "output/tables" 
global figure_results_path "output/figures" 
global first_stage_results_path "output/first_stage"

// For saved power simulation results
if $slow_code == 0 {
	//  We want to pull the power simulation results from above from a saved cache
	global file_path_power_data_raw "cached-power-simulation-output/raw"
	global file_path_power_data_combined  "cached-power-simulation-output/combined"
}

if $slow_code == 1 {
	//  We want to pull the power simulation results from temp folder when running them all
	global file_path_power_data_raw "temp"
	global file_path_power_data_combined  "temp"

}

///////////////////////////////////////////////////////////////////////////////
// Use included packages rather than current packages on ssc 

cap adopath - PERSONAL
cap adopath - PLUS
cap adopath - SITE
cap adopath - OLDPLACE
adopath + "stata_packages"
net set ado "stata_packages"

// Install Stata Packages
local install_stata_packages 0

// Install Packages if needed, if not, make a note of this. This should be a comprehensive list of all additional packages needed to run the code.
if `install_stata_packages' == 1 {
	ssc install blindschemes, replace
	ssc install gtools, replace

	ssc install carryforward, replace
	ssc install estout, replace
	net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
	net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
	ssc install moremata
	ftools, compile
	reghdfe, compile

	ssc install blindschemes, replace
	ssc install coefplot, replace
	ssc install statastates, replace
	ssc install shp2dta, replace
	ssc install sumup, replace

	ssc install distinct, replace
	ssc install unique, replace
	*ssc install statastates, replace
	*net get statastates.dta, replace
	ssc install binscatter, replace
	ssc install palettes, replace
	ssc install colrspace, replace
	ssc install eret2, replace
	*install pbalchk from https://personalpages.manchester.ac.uk/staff/mark.lunt/propensity.html

}
else  {
	di "All packages up-to-date"
}


///////////////////////////////////////////////////////////////////////////////
// Set other misc.

// Set version of stata
version 15

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

////////////////////////////////////////////////////////////////////////
// Build datasets for analysis 

if $build_data == 1 {
	
	// Build intermediate files
	if $restricted_access == 1 {
	 do "$script_path/1_build/1.0.clean_raw_mortality_data.do"
	}
	
	do "$script_path/1_build/2.clean_population_data.do"
	
	if $restricted_access == 1 {
		do "$script_path/1_build/3.merge_mortality_and_population_create_death_rates.do"
	}
	
	do "$script_path/1_build/4.clean_county_control_data.do"

	if $restricted_access == 1 {
		do "$script_path/1_build/5.create_att_pop.do"
	}
	
	do "$script_path/1_build/6.clean_state_control_data.do"
	
	if $restricted_access == 1 {
		do "$script_path/1_build/7.create_att_pop_state_level.do"
	}
}

////////////////////////////////////////////////////////////////////////
// Run mortality analysis
if $restricted_access == 1 {
	do "$script_path/2_analysis/2.1.1.figure_1_raw_death_rates.do"
	do "$script_path/2_analysis/2.2.1.figure_2_run_ln_event_studies.do"
	do "$script_path/2_analysis/2.2.2.event_studies_with_death_rate_attpop.do"
	do "$script_path/2_analysis/2.2.3.event_studies_with_different_attpop_trimming.do"
	do "$script_path/2_analysis/2.2.4.state_event_studies_with_death_rate_attpop.do"
	
	do "$script_path/2_analysis/2.3.1.table_2_run_ln_regressions.do"
	do "$script_path/2_analysis/2.3.2.regressions_with_death_rate_attpop.do"
	do "$script_path/2_analysis/2.3.3.table_2_run_state_level_ln_regressions.do"
	do "$script_path/2_analysis/2.3.4.table_2_with_combined_state_and_county.do"
	
	do "$script_path/2_analysis/2.4.1.county_hetero_effects.do"
	do "$script_path/2_analysis/2.4.2.state_hetero_effects.do"
	do "$script_path/2_analysis/2.4.3.combine_state_and_county_hetero_effects.do"
	
	do "$script_path/2_analysis/2.5.count-state-years-exp.do"

}
	do "$script_path/2_analysis/2.6.create_hcup_sid_az_graph.do"

////////////////////////////////////////////////////////////////////////
// Power analysis
if $restricted_access == 1 {

	if $slow_code == 1 {
	
		if $carbonate == 1 {
			// Store the project directory
			local root_directory `c(pwd)'
			
			// Navigate to the directory with the pbs scripts for each power simulation
			cd "$script_path/3_power/3.13.pbs_scripts"
			
			// Run all power simulations using server
			shell bash submit_all_files.sh 
			
			// Navigate back to your home directory of the project
			cd "`root_directory'"
			
			// Stop the process. The above power simulations will take a long time to run and will not run in serial.
			exit
		}
		
		if $carbonate == 0 {
			/*
			Note: You will need to edit each "$script_path/3_power/3.13.pbs_scripts/power_`x'.txt"
					file. There you will change the directory. You may also wish to alter the system resources. 
					if you do not use PBS system for submitting you could simply run these sequentially on 
					your own computer using code like
			*/	
			
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
			
			for x = 1(1)73 {
				do "$script_path/3_power/3.13.serial_scripts/power_`x'.do"
			}
		}
	
		// Load programs for graphing power results
		do "$script_path/3_power/3.14.load_graph_programs.do"
		
		// Graph power results
		do "$script_path/3_power/3.15.run_graph_programs.do"
		
		// Create data for R plots
		do "$script_path/3_power/3.16.create_data_for_mde_scatterplot.do"
	
	}
	
	// Call R using the shell command
	shell $r_path --vanilla <scripts/3_power/3.17.graph_mde_by_subgroup.R
	
	do "$script_path/3_power/3.18.create_mde_tot_graph.do"
	
	// For known first stage
	if $slow_code == 1 {
		do "$script_path/3_power/3.19.power_analysis_known-first-stage"
		do "$script_path/3_power/3.20.graph_known_first_stage.do"
	}
	
	do "$script_path/3_power/3.21.power-estimate-for-sig.do" 
	do "$script_path/3_power/3.22.mde_for_subgroup_stats.do"
}

////////////////////////////////////////////////////////////////////////
// First stage analysis
	
	// Clean ACS data
	do "$script_path/4_firststage/4.1.organize_acs.do"	
	
	// Clean up SAHIE data
	do "$script_path/4_firststage/4.2.organize_sahie.do"
	do "$script_path/4_firststage/4.3.organize_sahie_cty.do"
	
	// Event study for ACS data
	do "$script_path/4_firststage/4.4.0.acs_leads_and_lags.do"
	
	// Make first stage table for ACS and SAHIE
	do "$script_path/4_firststage/4.5.create_first_stage_table.do"
	
	// Make a covariate balance table
	if $restricted_access == 1 {
		do "$script_path/4_firststage/4.6.cov_balance.do"
	}
	
	// Make a table for medicaid expansion states and uninsurance rates
	do "$script_path/4_firststage/4.7.medicaid_exp_states_table.do"

////////////////////////////////////////////////////////////////////////
// Clean up files

// Erase inside of temp folder
!rm -r "$temp_path/__MACOSX"

