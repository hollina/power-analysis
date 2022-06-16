
///////////////////////////////////////////////////////////////////////////////
// Write a program to make mde-first stage-tot graph
capture program drop mde_tot_graph
program mde_tot_graph
	syntax, ///
		file_name(string) ///
		mde(real) ///
		exp_first_stage(real)


// Clear memory
clear

// Goal: graph
	*Y-axis: implied treatment on treated % 
	*X-axis: Rtio of mortality rate of compliers to v population average
	
// Also show estimated saved lives 

// Make a panel DD, DDD, control only, synth only. 
local total_exp_pop 15300000
local death_rate_avg 575
local large_first_stage .05
local tot_threshold 30

// Create 100 observations
set obs 11

// Set ratio of mortality rate of compliers to v population average
gen ratio = .
replace ratio = .5 in 1 

forvalues i = 1(1)10 {
	local j = `i' + 1
	replace ratio = `i' in `j'
}

// Calculate expansion population death rate
gen death_rate_exp_pop = `death_rate_avg'*ratio

// Gen expected deaths for expansion population 
gen e_deaths_exp_pop = death_rate_exp_pop*((`total_exp_pop'*`exp_first_stage')/100000)

// Gen total expected deaths
gen e_deaths_tot_pop = e_deaths_exp_pop + `death_rate_avg'*((`total_exp_pop'*(1-`exp_first_stage'))/100000) 

// Gen saved lives if population average effect true
gen saved_lives = e_deaths_tot_pop*`mde'

// Gen implied treatment on treated 
gen implied_tot = (saved_lives/e_deaths_exp_pop)*100

// Gen expected deaths for expansion population 
gen l_deaths_exp_pop = death_rate_exp_pop*((`total_exp_pop'*`large_first_stage')/100000)

// Gen total expected deaths
gen l_deaths_tot_pop = l_deaths_exp_pop + `death_rate_avg'*((`total_exp_pop'*(1-`large_first_stage'))/100000) 

// Gen saved lives if population average effect true
gen l_saved_lives = l_deaths_tot_pop*`mde'

// Gen implied treatment on treated 
gen l_implied_tot = (l_saved_lives/l_deaths_exp_pop)*100




	
// Create a variable that is the gap between desired power level and closest estimates
capture drop gap
gen  gap = abs(`tot_threshold'-implied_tot)

// Sort on this variable
sort gap 

// Run a regression on the two closest observations
reg implied_tot ratio in 1/2
local ratio_mde = (`tot_threshold'-_b[_cons])/_b[ratio]
local ratio_mde : di %4.1f `ratio_mde'  // Fix floating point error that occassionally happens. 

local bottom_arrow_x = `ratio_mde'*1.025
local top_arrow_x = `ratio_mde'*1.1

local bottom_arrow_y = `tot_threshold'*1.4
local top_arrow_y = `tot_threshold'*1.1

sort ratio

sum implied_tot
local max_height = ceil(`r(max)'/100)*100
di "`max_height'"

// Create a variable that is the gap between desired power level and closest estimates
capture drop gap
gen  gap = abs(`tot_threshold'-l_implied_tot)

// Sort on this variable
sort ratio 

// Run a regression on the two closest observations
reg l_implied_tot ratio in 2/3
local l_ratio_mde = (`tot_threshold'-_b[_cons])/_b[ratio]
local l_ratio_mde : di %4.1f `l_ratio_mde'  // Fix floating point error that occassionally happens. 

// Add point here. 

local l_bottom_arrow_x = `l_ratio_mde'*1.025
local l_top_arrow_x = `l_ratio_mde'*1.5

local l_bottom_arrow_y = `tot_threshold'*1.25
local l_top_arrow_y = `tot_threshold'*1.1

sort ratio



// Graph results
twoway ///
	|| scatteri `tot_threshold' 0 `tot_threshold' `ratio_mde', recast(line) lcol(gs7) lp("_") lwidth(.25) ///
	|| scatteri 0 `ratio_mde' `tot_threshold' `ratio_mde', recast(line) lcol(gs7) lp("_") lwidth(.25) ///
	|| scatteri 0 `l_ratio_mde' `tot_threshold' `l_ratio_mde', recast(line) lcol(gs7) lp("_") lwidth(.25) ///
	|| connected l_implied_tot ratio, msymbol(none) lpattern("-") lwidth(.5) lcolor(black) ///
	|| connected implied_tot ratio, msymbol(none) lpattern("l") lwidth(1.5) lcolor(black) ///
	|| connected implied_tot ratio, msymbol(none) lpattern("l") lwidth(1) lcolor(orange) ///
	|| pcarrowi 80 `top_arrow_x' `bottom_arrow_y'  `bottom_arrow_x' , mlcolor(black) mfcolor(black) lcolor(black) barbsize(1.5) /// 
	|| pcarrowi 100 `l_top_arrow_x' `l_bottom_arrow_y'  `l_bottom_arrow_x' , mlcolor(black) mfcolor(black) lcolor(black) barbsize(1.5) /// 
	xtitle("Ratio of mortality rate for newly enrolled to population",  size(4) ) ///
	text(90 `top_arrow_x' "Ratio > `ratio_mde'", place(e) si(3)) ///
	text(80 `top_arrow_x' "implies TOT < `tot_threshold'% ", place(e) si(3)) ///
	text(70 `top_arrow_x' "for 2% first stage", place(e) si(3)) ///
	text(130 `l_top_arrow_x' "Ratio > `l_ratio_mde'", place(e) si(3)) ///
	text(120 `l_top_arrow_x' "implies TOT < `tot_threshold'%", place(e) si(3)) ///
	text(110 `l_top_arrow_x' "for 5% first stage", place(e) si(3)) ///
	yla(0 "0%" 30 "30%" 100 "100%" 200 "200%", nogrid notick labsize(4) ) ///
	xla(.5 2 4 6 8 10, nogrid notick labsize(4) ) ///
	ytitle("Implied treatment on the treated (TOT)") ///
	xla(,nogrid notick labsize(6)) ///
	legend(off) ///
	ysize(4)
	
graph export "$figure_results_path/mort_ratio_tot_`file_name'.pdf",  replace
graph export "$figure_results_path/mort_ratio_tot_`file_name'.png",  replace 


end

////////////////////////////////////////////////////////////////////////////////
// Make graph DDD 
mde_tot_graph, ///
		file_name(mde_217) ///
		mde(.0217) ///
		exp_first_stage(.02)
