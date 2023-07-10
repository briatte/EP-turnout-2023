Replication material for "Do (Too Many) Elections Depress Participation? The Limited Effect of the Electoral Calendar on Turnout in European Parliament Elections" (under review).

## HOWTO

From Stata, simply execute the following:

```stata
run 04-models.do
```

All previous scripts will be run by that script:

- `00-dependencies.do` installs all package dependencies.
- `01-data.do` prepares the data for analysis and produce a few panel tests.
- `02-plots.do` produces the plots shown in the main paper.
- `03-globals.do` sets the equations and other global macros.
- `04-models.do` performs most of the work by estimating all reported models.

As stated in the appendix, all code was written and tested in Stata 17, but should be executable on past versions of the software as long as package dependencies can be installed.
