/* -----------------------------------------------------------------------------
   (3) Globals
   -------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Export settings
   -------------------------------------------------------------------------- */

// screen view (not used)
gl scrn "b(2) se(2) compress nodep nocons"
// variable sorting order
gl srtd "order(ne_months lne_fo lne_fo_x_ne_months ne_count ne_count2 concurrent lne_turnout cv first_ep *.year)"
gl scrn "$scrn $srtd"
// table export
gl xprt "nonum nogap one lab mti star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(2)"
gl xprt "$xprt $srtd replace"

/* -----------------------------------------------------------------------------
   (1-4) Models 1-4
   -------------------------------------------------------------------------- */

gl eq1 "ne_months ne_count concurrent lne_turnout cv"
gl eq2 "lne_fo ne_count concurrent lne_turnout cv"
gl eq3 "ne_months lne_fo ne_count2 concurrent lne_turnout cv"
gl eq4 "ne_months lne_fo lne_fo_x_ne_months ne_count concurrent lne_turnout cv"

// year dummies
gl yd1 "$eq1 i.year"
gl yd2 "$eq2 i.year"
gl yd3 "$eq3 i.year"
gl yd4 "$eq4 i.year"

// main models (DV = % registered voters)
gl rv1 "voter_turnout $yd1"
gl rv2 "voter_turnout $yd2"
gl rv3 "voter_turnout $yd3"
gl rv4 "voter_turnout $yd4"

/* -----------------------------------------------------------------------------
   (5) Alternative CV predictor
   -------------------------------------------------------------------------- */

// DV = % voting-age population
gl cv1 = regexr("$rv1", " cv", " cv2")
gl cv2 = regexr("$rv2", " cv", " cv2")
gl cv3 = regexr("$rv3", " cv", " cv2")
gl cv4 = regexr("$rv4", " cv", " cv2")

/* -----------------------------------------------------------------------------
   (6) Controlling for first EP election
   -------------------------------------------------------------------------- */

gl fep1 = regexr("$rv1", " cv", " cv first_ep")
gl fep2 = regexr("$rv2", " cv", " cv first_ep")
gl fep3 = regexr("$rv3", " cv", " cv first_ep")
gl fep4 = regexr("$rv4", " cv", " cv first_ep")

/* -----------------------------------------------------------------------------
   (7-8) Sample subsets
   -------------------------------------------------------------------------- */

// excluding Germany and Italy (unsynchronised local elections)
gl ss1 if !inlist(iso3c, "DEU", "ITA")
count $ss1

// excluding France, Lithuania, Poland (semi-presidential regimes)
gl ss2 if !inlist(iso3c, "FRA", "LTU", "POL")
count $ss2

/* -----------------------------------------------------------------------------
   (9) Alternative DV: % voting-age population
   -------------------------------------------------------------------------- */

gl va1 "vap_turnout $yd1"
gl va2 "vap_turnout $yd2"
gl va3 "vap_turnout $yd3"
gl va4 "vap_turnout $yd4"

// done
