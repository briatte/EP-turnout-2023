/* -----------------------------------------------------------------------------
   (4) Models
   -------------------------------------------------------------------------- */

// required packages

which estout
which coefplot
which xtcsd
which xtistest
which xttest3

// graph scheme
which scheme-modern.scheme

// export folder
cap mkdir "outputs"

/* -----------------------------------------------------------------------------
   Preprocessing
   -------------------------------------------------------------------------- */

run "00-dependencies.do"
run "01-data.do"
run "02-plots.do"
run "03-globals.do"

cap log close
cap log using "outputs/log-02-models.log", replace
eststo clear

/* -----------------------------------------------------------------------------
   (1-4) Choice of estimator
   -------------------------------------------------------------------------- */

// pooled OLS, clustered SEs
// -------------------------
eststo ols1: reg $rv1 , vce(cl cty)
eststo ols2: reg $rv2 , vce(cl cty)
eststo ols3: reg $rv3 , vce(cl cty)
eststo ols4: reg $rv4 , vce(cl cty)

// fixed effects
// -------------
xtset cty year
eststo fe1: xtreg $rv1, fe
eststo fe2: xtreg $rv2, fe
eststo fe3: xtreg $rv3, fe
eststo fe4: xtreg $rv4, fe

// linear hypothesis test for year dummies
forv i = 1/4 {
	qui est restore fe`i'
	qui testparm i.year
	assert r(p) < 0.05
}
// Pesaran test for cross-sectional independence
// note: won't run on actual panel structure with year gaps
xtset cty t
forv i = 1/4 {
	qui est restore fe`i'
	qui xtcsd, pes
	assert r(p) > 0.05 // accept H0
}

// random effects
// --------------
xtset cty year
eststo re1: xtreg $rv1, re
eststo re2: xtreg $rv2, re
eststo re3: xtreg $rv3, re
eststo re4: xtreg $rv4, re

// residuals-versus-fitted plots
forv i = 1/4 {
	qui est restore re`i'
	cap drop yhat
	predict yhat, xb
	cap drop r
	predict r, e
	sc r yhat, name(rvf`i', replace) ms(i) mlab(cty)
}
// Breusch-Pagan test to reject pooled OLS
forv i = 1/4 {
	qui est restore re`i'
	xttest0
	assert r(p) < 0.05
}
// Inoue-Solon test for absence of serial correlation in residuals
// note: order 1 lag only
forv i = 1/4 {
	qui est restore re`i'
	cap predict re`i'_e, e
	xtistest re`i'_e, lags(1)
	assert r(pvalue1) > 0.05 // accept H0
}
// Pesaran test for cross-sectional independence
// note: won't run on actual panel structure with year gaps
xtset cty t
forv i = 1/4 {
	qui est restore re`i'
	qui xtcsd, pes
	assert r(p) > 0.05 // accept H0
}
// Hausman test
// note: assumptions unmet on Models 2 and 4
forv i = 1/4 {
	qui hausman fe`i' re`i'
	assert r(p) > 0.05 // accept H0
	if r(chi2) < 0 {
		di "Assumptions unmet for Hausman test on Models FE-RE `i'"
	}
}

//export main models
esttab re? using "outputs/tbl-02-main-models.rtf", ///
	sca(N_g r2_w rmse) sfmt(2) ///
	indicate("Year dummies=**year") ///
	d(_cons) addn("Constant term and year dummies omitted.") ///
	mti("Model 1" "Model 2" "Model 3" "Model 4") ///
	$xprt

// Prais-Winsten (clustered SEs)
// -----------------------------
forv i = 1/4 {
	// remove year dummies from equation
	gl pw`i' = regexr("${rv`i'}", "i.year", "")
}
xtset cty year
eststo pw1: prais $pw1, vce(cl cty) rhotype(reg)
eststo pw2: prais $pw2, vce(cl cty) rhotype(reg)
eststo pw3: prais $pw3, vce(cl cty) rhotype(reg)
eststo pw4: prais $pw4, vce(cl cty) rhotype(reg)

// compare with `xtpcse` estimation, and show estimates with year dummies
// included alongside the AR(1) term
forv i = 1/4 {
	xtset cty year
	eststo pcse`i': xtpcse ${pw`i'}, c(ar1)
	// serialize years
	xtset cty t
	eststo pw`i'yd: prais ${rv`i'}, vce(cl cty) rhotype(reg)
	eststo pcse`i'yd: xtpcse ${rv`i'}, c(ar1)
}
forv i = 1/4 {

	// RE and FE models included for reference
	coefplot ///
		(re`i', if(@ll<0 & @ul>0)) ///
		(re`i', if(@ll>0 | @ul<0)) || ///
		(fe`i', if(@ll<0 & @ul>0)) ///
		(fe`i', if(@ll>0 | @ul<0)) || ///
		(pw`i', if(@ll<0 & @ul>0)) ///
		(pw`i', if(@ll>0 | @ul<0)) || ///
		(pcse`i', if(@ll<0 & @ul>0)) ///
		(pcse`i', if(@ll>0 | @ul<0)) || ///
		(pw`i'yd, if(@ll<0 & @ul>0)) ///
		(pw`i'yd, if(@ll>0 | @ul<0)) || ///
		(pcse`i'yd, if(@ll<0 & @ul>0)) ///
		(pcse`i'yd, if(@ll>0 | @ul<0)) || ///
		, nooffset drop(_cons *.year) ///
		xlabel(1 "RE" 2 "FE" 3 "PW" 4 "PCSE" 5 "PWt" 6 "PCSEt") ///
		bycoef byopts(yrescale legend(off)) vertical yline(0) grid(none) ///
		subtitle(, size(small) color(gs0) bcolor(gs14)) ///
		p1(mcolor(gs8) ciopts(lcolor(gs8))) ///
		p2(mcolor(gs0) ciopts(lcolor(gs0))) ///
		scheme(modern) ///
		name(pw_pcse`i', replace)

}

/* -----------------------------------------------------------------------------
   (5) Alternative CV predictor (checking for positive effect)
   -------------------------------------------------------------------------- */

eststo cv1: xtreg $cv1, re
assert r(table)[1,5] > 0

eststo cv2: xtreg $cv2, re
assert r(table)[1,5] > 0

eststo cv3: xtreg $cv3, re
assert r(table)[1,6] > 0 // note: cv2 is on 6th column in Model 3

eststo cv4: xtreg $cv4, re
assert r(table)[1,7] > 0 // note: cv2 is on 7th column in Model 3

forv i = 1/4 {
	esttab re`i' cv`i' using "outputs/tbl-B`i'-cv-m`i'.rtf", ///
		keep(cv*) rename(cv2 cv) $xprt wide noobs
}

/* -----------------------------------------------------------------------------
   (6) Controlling for first EP election
   -------------------------------------------------------------------------- */

// beta(first_ep): 6.19 (2.17)
xtreg voter_turnout first_ep, fe vce(cl cty)

eststo fep1: xtreg $fep1, re
assert r(table)[4,6] > 0.1

eststo fep2: xtreg $fep2, re
assert r(table)[4,6] > 0.1

eststo fep3: xtreg $fep3, re
assert r(table)[4,7] > 0.1 // note: first_ep is on 7th column in Model 3

eststo fep4: xtreg $fep4, re
assert r(table)[4,8] > 0.1 // note: first_ep is on 8th column in Model 3

forv i = 1/4 {
	esttab fep`i' using "outputs/tbl-C`i'-first_ep-m`i'.rtf", ///
		keep (first_ep) $xprt wide noobs
}

/* -----------------------------------------------------------------------------
   (7-8) Sample subsets
   -------------------------------------------------------------------------- */

eststo ss11: xtreg $rv1 $ss1, re
eststo ss12: xtreg $rv2 $ss1, re
eststo ss13: xtreg $rv3 $ss1, re
eststo ss14: xtreg $rv4 $ss1, re

eststo ss21: xtreg $rv1 $ss2, re
eststo ss22: xtreg $rv2 $ss2, re
eststo ss23: xtreg $rv3 $ss2, re
eststo ss24: xtreg $rv4 $ss2, re

/* -----------------------------------------------------------------------------
   (9) Alternative DV
   -------------------------------------------------------------------------- */

corr voter_turnout vap_turnout // rho = .92

eststo va1: xtreg $va1, re
eststo va2: xtreg $va2, re
eststo va3: xtreg $va3, re
eststo va4: xtreg $va4, re

/* -----------------------------------------------------------------------------
   Plots and tables for checks 1-4 (PW only) and 7-9 (FEP, SS1, SS2, VAP)
   -------------------------------------------------------------------------- */

forv i = 1/4 {

	esttab re`i' ols`i' fe`i' pw`i' ss1`i' ss2`i' va`i' ///
		using "outputs/tbl-A`i'-est-m`i'.rtf", ///
		sca(rmse) sfmt(2) ///
		indicate("Year dummies=**year") ///
		d(_cons) addn("Constant term and year dummies omitted.") ///
		mti("RE" "OLS" "FE" "PW" "SS1" "SS2" "VAP") ///
		$xprt
	
	coefplot ///
		(re`i', if(@ll<0 & @ul>0)) ///
		(re`i', if(@ll>0 | @ul<0)) || ///
		(ols`i', if(@ll<0 & @ul>0)) ///
		(ols`i', if(@ll>0 | @ul<0)) || ///
		(fe`i', if(@ll<0 & @ul>0)) ///
		(fe`i', if(@ll>0 | @ul<0)) || ///
		(pw`i', if(@ll<0 & @ul>0)) ///
		(pw`i', if(@ll>0 | @ul<0)) || ///
		(ss1`i', if(@ll<0 & @ul>0)) ///
		(ss1`i', if(@ll>0 | @ul<0)) || ///
		(ss2`i', if(@ll<0 & @ul>0)) ///
		(ss2`i', if(@ll>0 | @ul<0)) || ///
		(va`i', if(@ll<0 & @ul>0)) ///
		(va`i', if(@ll>0 | @ul<0)) || ///
		, nooffset drop(_cons *.year) ///
		xlabel(1 "RE" 2 "OLS" 3 "FE" 4 "PW" 5 "SS1" 6 "SS2" 7 "VAP") ///
		bycoef byopts(yrescale legend(off)) vertical yline(0) grid(none) ///
		subtitle(, size(small) color(gs0) bcolor(gs14)) ///
		p1(mcolor(gs8) ciopts(lcolor(gs8))) ///
		p2(mcolor(gs0) ciopts(lcolor(gs0))) ///
		scheme(modern) ///
		name(models`i', replace)
	
	gr export "outputs/fig-est-m`i'.png", replace

}

/* -----------------------------------------------------------------------------
   (10-11) Jackknife estimation and country-level clustered standard errors
   -------------------------------------------------------------------------- */

// heteroskedasticity in all FE models
forv i = 1/4 {
	qui est restore fe`i'
	qui xttest3
	assert r(p) < 0.05
}

// jackknife RE models
eststo re1bs: jackknife, cluster(cty): xtreg $rv1, re
eststo re2bs: jackknife, cluster(cty): xtreg $rv2, re
eststo re3bs: jackknife, cluster(cty): xtreg $rv3, re
eststo re4bs: jackknife, cluster(cty): xtreg $rv4, re

// CRSE-corrected RE models
eststo re1cl: xtreg $rv1, re vce(cl cty)
eststo re2cl: xtreg $rv2, re vce(cl cty)
eststo re3cl: xtreg $rv3, re vce(cl cty)
eststo re4cl: xtreg $rv4, re vce(cl cty)

// jackknife FE models
eststo fe1bs: jackknife, cluster(cty): xtreg $rv1, fe
eststo fe2bs: jackknife, cluster(cty): xtreg $rv2, fe
eststo fe3bs: jackknife, cluster(cty): xtreg $rv3, fe
eststo fe4bs: jackknife, cluster(cty): xtreg $rv4, fe

// CRSE-corrected FE models
eststo fe1cl: xtreg $rv1, fe vce(cl cty)
eststo fe2cl: xtreg $rv2, fe vce(cl cty)
eststo fe3cl: xtreg $rv3, fe vce(cl cty)
eststo fe4cl: xtreg $rv4, fe vce(cl cty)
// note: see below for Driscoll-Kraay errors instead (v. similar results)
forv i = 1/4 {
	qui xi: eststo fe`i'dk: xtscc ${rv`i'}, fe
	esttab fe`i' fe`i'cl fe`i'dk, drop(*year _I*) $scrn
}

forv i = 1/4 {
	
	coefplot ///
		(re`i', if(@ll<0 & @ul>0)) ///
		(re`i', if(@ll>0 | @ul<0)) || ///
		(re`i'bs, if(@ll<0 & @ul>0)) ///
		(re`i'bs, if(@ll>0 | @ul<0)) || ///
		(re`i'cl, if(@ll<0 & @ul>0)) ///
		(re`i'cl, if(@ll>0 | @ul<0)) || ///
		(fe`i', if(@ll<0 & @ul>0)) ///
		(fe`i', if(@ll>0 | @ul<0)) || ///
		(fe`i'bs, if(@ll<0 & @ul>0)) ///
		(fe`i'bs, if(@ll>0 | @ul<0)) || ///
		(fe`i'cl, if(@ll<0 & @ul>0)) ///
		(fe`i'cl, if(@ll>0 | @ul<0)) || ///
		, nooffset drop(_cons *.year) ///
		xlabel(1 "RE" 2 `" "RE" "JK" "'  3 `" "RE" "CR" "' ///
			4 "FE" 5 `" "FE" "JK" "' 6 `" "FE" "CR" "') ///
		bycoef byopts(yrescale legend(off)) vertical yline(0) grid(none) ///
		subtitle(, size(small) color(gs0) bcolor(gs14)) ///
		p1(mcolor(gs8) ciopts(lcolor(gs8))) ///
		p2(mcolor(gs0) ciopts(lcolor(gs0))) ///
		scheme(modern) ///
		name(cl`i', replace)
	
	gr export "outputs/fig-se-m`i'.png", replace

}

cap log close

// endnote: hint as to why jackknife estimation depletes CV point estimates
tab cty if cv == 1, su(cv2)
tab cty if cv == 1 & concurrent == 1, su(cv2)
tab cv concurrent, nof row exact chi2

// done
