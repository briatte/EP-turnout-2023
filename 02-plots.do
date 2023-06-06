// export folder
cap mkdir "outputs"

/* -----------------------------------------------------------------------------
   Fig. 1 - Turnout
   -------------------------------------------------------------------------- */

loc fig1 "outputs/fig-01-turnout.png"

if !(fileexists("`fig1'")) {
	
	tw ///
		(line voter_turnout year, lp(solid)) ///
		(line vap_turnout year, lp(shortdash)) ///
		, xti("") subtitle(, size(medium) fcolor(gs14)) ///
		ylab(10(20)90, labsize(medium)) xlab(1979(10)2019, labsize(medium)) ///
		legend(bmargin(10 0 0 0) symxsize(*4) size(medlarge)) ///
		by(cty, legend(at(29) pos(3)) note("")) ///
		scheme(modern) ///
		name(turnout, replace)

	gr export "`fig1'"

}

/* -----------------------------------------------------------------------------
   Fig. 2a - Rounds
   -------------------------------------------------------------------------- */

loc fig2a "outputs/fig-02a-rounds.png"

if !(fileexists("`fig2a'")) {

	tw (lfitci voter_turnout ne_count) ///
		(sc voter_turnout ne_count, color(gs8)), ///
		yti("Voter turnout (% registered)") ///
		legend(off) ///
		scheme(modern) ///
		name(ne_count, replace)

	gr export "`fig2a'"

}

/* -----------------------------------------------------------------------------
   Fig. 2b - Contests
   -------------------------------------------------------------------------- */

loc fig2b "outputs/fig-02b-contests.png"

if !(fileexists("`fig2b'")) {

	tw (lfitci voter_turnout ne_count2) ///
		(sc voter_turnout ne_count2, color(gs8)), ///
		yti("Voter turnout (% registered)") ///
		legend(off) ///
		scheme(modern) ///
		name(ne_count2, replace)

	gr export "`fig2b'"

}

// draft
//
// yti("") ylab(none) yticks(none) legend(off) ///
//	aspectratio(1.25) ///
// gr combine ne_count ne_count2, col(1) imargin(small) ycommon commonscheme

// done
