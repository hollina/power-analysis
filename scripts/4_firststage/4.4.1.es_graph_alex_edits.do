capture program drop es_graph
program es_graph

args outcome treatment panel_id time_id cluster_id event_time weight $controls lags leads $title $subtitle $xtitle $ytitle

{

	loc ncfes = abs(`lags')+`leads'+1

	* Creating interaction dummies treatment*time_dummy
	foreach lev of numlist `lags'/`leads' {
	if `lev' < 0 {
	loc aux = substr(string(`lev'),2,2)
	loc levm = "m`aux'"
	}
	else {
	loc levm = "`lev'"
	}
	gen deventtime_`levm' = (`event_time' == `lev')
	gen dtreat_time_`levm' = deventtime_`levm'*`treatment'
	drop deventtime_`levm'
	}
	replace dtreat_time_m1 = 0

	global main_interactions ""
	foreach lev of numlist `lags'/`leads' {
	if `lev' < 0 {
	loc aux = substr(string(`lev'),2,2)
	loc levm = "m`aux'"
	disp "m`aux'"
	}
	else {
	loc levm = "`lev'"
	}
	global main_interactions "$main_interactions dtreat_time_`levm'"
	}
	disp "$main_interactions"


	//--------------------------------------------------------------------
	// EVENT STUDY
	//--------------------------------------------------------------------
	//cv_`outcome' tt_`outcome'
	reghdfe `outcome' $main_interactions $controls [aw=`weight'], absorb(`panel_id' `time_id') vce(cluster `cluster_id')
		qui sum `outcome' if e(sample)==1
		eret2 scalar Mean_DepVar=r(mean)
		
		local vtext : variable label `outcome'
		if `"`vtext'"' == "" local vtext "`outcome'"
		
		mat b = e(b)'
		mat list b 
		*mata st_matrix("b",select(st_matrix("b"),st_matrix("b")[.,1]))
		*mat list b

		mata st_matrix("ll", (st_matrix("e(b)"))'- invt(st_numscalar("e(df_r)"), 0.975)*sqrt(diagonal(st_matrix("e(V)"))))
		mat list ll
		*mata st_matrix("ll",select(st_matrix("ll"),st_matrix("ll")[.,1]))
		*mat list ll
		
		mata st_matrix("ul", (st_matrix("e(b)"))'+ invt(st_numscalar("e(df_r)"), 0.975)*sqrt(diagonal(st_matrix("e(V)"))))
		mat list ul
		*mata st_matrix("ul",select(st_matrix("ul"),st_matrix("ul")[.,1]))
		*mat list ul		

		// Combine event time, coef, lower ci, and upper ci into one matrix
		mat results =  b[1..`ncfes',.], ll[1..`ncfes',.], ul[1..`ncfes',.]
		mat list results
		/*
		local ref_event_time = abs(`lags')
		local time_b4_ref_event_time = `ref_event_time' - 1
		local time_after_ref_event_time = `ref_event_time' // Since we removed the zero this is -1
		local end_time_in_results = `ncfes' -1 // Since we removed the zero this is -1
		
		// Add row where reference group should be
		mat results_new = results[1..`time_b4_ref_event_time',.] \ `ref_event_time', 0, 0, 0 \ results[`time_after_ref_event_time'..`end_time_in_results',.]
		mat list results_new
		*/
		
		capture drop b 
		capture drop high 
		capture drop low
					
		svmat results 
		rename results1 b
		rename results2 low
		rename results3 high
			
	preserve
	/*
	mat b =e(b)
	mat b1 = b[1,1..`ncfes']'
	mat b1=[. \ b1]
	mat drop b
	mat v=e(V)
	mat sd1=[.]
	forval k=1(1)`ncfes'{
		mat sd1 = [sd1 \ sqrt(v[`k',`k'])]
		}
	mat sd1 = sd1*1.96
	mat ul = sd1*1.96
	mat ll = sd1*1.96
	mat drop v
	svmat b1
	svmat sd1
	drop if b11==.
	*/
	//gen t=_n
	egen t=seq(),f(`lags') t(`leads')

	local vtext : variable label `outcome'
	if `"`vtext'"' == "" local vtext "`outcome'"

	//qui serrbar b1 sd1 t, yline(0, lcolor(black)) scale(1) xlabel(`lags'(1)`leads', labsize(tiny) angle(vertical)) ///
	//xline(-.5, lpattern(shortdash)lstyle(refline) lcolor(red)) 
	//title("$title", size(medium)) subtitle("$subtitle", size(medsmall))  xtitle("$xtitle", size(small)) ytitle("$ytitle") ylabel(, labsize(vsmall) angle(horizontal)) xlabel(, labsize(vsmall) angle(horizontal)) scheme(s1color) lcolor(navy) mvop(mcolor(navy)) name(`i')

	// Plot estimates	
	twoway rarea low high t, fcol(gs14) lcol(white) msize(3) /// estimates
		|| connected b t, lw(1.1) col(white) msize(7) msymbol(s) lp(solid) /// highlighting
		|| connected b t, lw(0.6) col("71 71 179") msize(5) msymbol(s) lp(solid) /// connect estimates
		|| scatteri 0 `lags' 0 `leads', recast(line) lcol(gs8) lp(longdash) lwidth(0.5) /// zero line 
			xlab(`lags'(1)`leads' ///
					, nogrid labsize(7) angle(0)) ///
			ylab(, nogrid labs(7)) ///
			legend(off) ///
			xtitle("$xtitle", size(4)) ///
			ytitle("$ytitle", size(4)) ///
			subtitle("$subtitle", size(4) pos(11)) ///
			title("$title", size(5) pos(11)) ///
			xline(-.5, lpattern(dash) lcolor(gs7) lwidth(1)) 	///
			name(`i') ///
			graphregion(color(white))
				
	
//	graph save "${graphpath}\es_`outcome'.gph", replace
//	graph export "${graphpath}\es_`outcome'.png", replace width(3000)
//	graph drop _all
	restore


	}

	end
