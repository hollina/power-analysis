{smcl}
{hline}
help for {hi:pbalchk}
{hline}

{title:Checking Covariate Balance}

{p 4 8 2}
{cmdab:pbalchk}
{it:treatvar}
{it:varlist}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
  {opt strata(varname)}
  {opt wt(varname)}
  {opt f}
  {opt p}
  {opt mahal}
  {opt metric(matrix)}
  {opt diag}
  {opt sqrt}
  {opt xip:refix(string)}
  {opt graph}
  {opt xline(numlist)}
  {opt xlab:el(numlist)}
  {opt nostandardize}
  {opt nocatstandardize}
  {opt sigrep}
]       


{title:Description}

{pstd}
The command {cmd:pbalchk} checks the balancing of the covariates in
{it:varlist} between two groups, given by {it:treatvar} = 1 and
{it:treatvar} = 0. It was designed for use in propensity modelling,
which aims to balance the distribution of covariates in treated and
untreated subjects.  The extent to which this balancing was successful
can be illustrated by {cmd:pbalchk}

{title:Options}

{phang}
{opt strata(varname)} If you are using stratification on the propensity
score to estimate the effect of treatment, you should give the name of
the variable containing the strata of propensity score in {it: varname}.

{phang}
{opt wt(varname)} The alternatives to stratification are matching and
weighting. If you are using weighting, {it: varname} should contain the
weighting variable. If you are using 1-1 matching, you can again use
{it:varname}: subjects included in the matching should have a weight
of 1 and those excluded have a weight of 0. For other types of matching,
the weight for each exposed subject should be the number of unexposed
subjects in the matched set divided by the number of exposed subjects, and
the weight for each unexposed subject should be the number of exposed
subjects in the matched set divided by the number of unexposed subjects.

{phang}
{opt f} By default, {cmd:pbalchk} gives the difference between treated
and untreated subjects in terms of the standard deviation of that
variable in the treated subjects. With the option {cmd:f}, an F-statistic
(or chi-squared, for categorical variables) for the significance of the
difference between treated and untreated subjects is returned instead.

{phang}
{opt p} If you wish to see a p-value for the significance of the difference
between treated and untreated subjects in each variable, use the option
{cmd:p}.

{phang}
{opt mahal} If the option {cmd:mahal} is given, the multivariate distance
between treated and untreated is given.

{phang}
{opt metric(matrix)} The Mahalonobis distance is calculated using the
inverse of the covariance matrix in the treated as a metric. If you wish to
use a different metric, give the name of the matrix to use here.

{phang}
{opt sqrt} Presents the square root of the Mahalonobis distance.

{phang}
{opt diag} Only uses the diagonal of the metric matrix when comparing
means. This ignores correlations  between variables, and simply
measures the distance in terms of standard deviations.

{phang}
{opt xip:refix(string)} Usually, {cmd:pbalchk} uses the prefix string _I
to recognise categorical variables. If you have used a different prefix,
with the {opt prefix(string)} option to {cmd:xi}, you may need to use the
same string in this option so that {cmd:pbalchk} can recognise the
categorical variables.

{phang}
{opt graph} Produces a graph showing, for each variable, the
standardised difference between treated and untreated subjects before
and after adjusting.

{phang}
{opt xline(numlist)} If the option "graph" has been used, the numlist
given in {opt xline(numlist)} gives the x-values at which vertical
lines should be drawn on the graph. By default, the values used are
-0.1, 0, 0.1. 

{phang}
{opt xlab:el(numlist)} If the option "graph" has been used, the numlist
given in {opt xlab:el(numlist)} gives the values at which labels
should appear on the x-axis.

{phang}
{opt nostandardize} By default, differences are presented as the
standardized difference. With this option, differences are presented
in the original scale of the variable.

{phang}
{opt nocatstandardize} This option presents differences in categorical
variables as differences in prevalence, rather than standardized
differences (which is the default).

{phang}
{opt sigrep} The original version of {cmd:pbalchk} presented a list of
all variables that differed significantly between exposed and
unexposed subjects. This confused some users, and statistical
significance is a poor way to identify imbalanced
variables. Therefore, {cmd:pbalchk} no longer presents this list by
default, but it can be requested by adding the option {opt sigrep}.

{title:Remarks}

{pstd}
If you wish to check the balance of categorical variables, you need to
specify this by using stata's older syntax for categorical variables

{cmd:xi: pbalchk} {it:treatvar} {cmd:i.}{it:catvar}

{pstd}
It is not as yet possible to check the balance of interaction terms
using the {cmd:xi} syntax. You would need to generate your own
variables to contain the interaction terms, and check the balance of
these variables. Equally, the newer syntax using factor variables
without the {cmd:xi} prefix is not yet supported. 

{title:Analytics}

{pstd}
In order to demonstrate to the University and my funders that the time
spent working on this program was worthwhile, I am attempting to keep
track of the number of installations and the number of times it is
used. To achieve this, you will be asked, the first time you run
{cmd:pbalchk}, if you mind sending some usage information to Google
Analytics. If you agree, I will be informed that an installation has
taken place, and that {cmd:pbalchk} has been run. 

{pstd}
Each time {cmd:pbalchk} runs, it checks if you have agreed to send
data to google, and if you have then it will record the fact that the
program has been run. I will also receive some information about the
rough geographical area in which it was run, and if you have agreed to
this, the options with which it was run (but not the variable names,
since that could be viewed as potentially confidential information). 

{pstd}
It would help me greatly to dedicate time to this program if I could
show that it was widely used, but {cmd:pbalchk} will respect your
desire for privacy if you request it. If you agree initially to
sending analytics information and then change your mind, you can set
the top line of {cmd:pbalchk.conf} in your ado file directory from
"analytics : 1" to "analytics : 0" and no further data will be sent. 
Alternatively, the command {cmd:trackuse pbalchk} will enable
you to change any of the tracking options without needing to edit any
files (for more information see {help trackuse:trackuse for users}). 


{title:Saved Results}

{pstd}{cmd:pbalchk} saves the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(mahal)}} Mahalanobis distance between treated and
  untreated subjects (if option {opt mahal} is used).{p_end}
{synopt:{cmd:r(mahalsq)}} Square root of the Mahalanobis distance
  between treated and untreated subjects (if options {opt mahal} and
  {opt sqrt} are used).{p_end}
{synopt:{cmd:r(dist)}} Mahalanobis-like distance between treated and
  untreated subjects, if using {opt metric(matrix)} as the metric.{p_end}
{synopt:{cmd:r(distsq)}} Square root of the Mahalanobis-like
  distance between treated and untreated subjects, if using
{opt metric(matrix)} as the metric, and {opt sqrt}.{p_end}
{synopt:{cmd:r(Ebias)}} Expected bias in coefficient of treatment
  effect if using {opt beta(matrix)}.{p_end}
{synopt:{cmd:r(aEbias)}} Expected bias in coefficient of treatment
  effect if using {opt beta(matrix)}, using the magnitudes of the
  imbalances in the confounders and of the coefficients in {it:matrix}.{p_end}
  
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(diff_vars)}} List of variables that differ
significantly between treated and untreated subjects after adjusting

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(meandiff)}}Differences in means of each variable
between treated and untreated subjects, after adjustment{p_end}
{synopt:{cmd:r(umeandiff)}}Differences in means of each variable
between treated and untreated subjects, before adjustment{p_end}
{synopt:{cmd:r(meantreat)}}Means in treated subjects after adjustment{p_end}
{synopt:{cmd:r(umeantreat)}}Means in treated subjects before adjustment{p_end}
{synopt:{cmd:r(meanuntreat)}}Means in untreated subjects after
adjustment{p_end}
{synopt:{cmd:r(umeanuntreat)}}Means in untreated subjects before
adjustment{p_end}
{synopt:{cmd:r(smeandiff)}}Standardised differences between treated
and untreated subjects after adjustment.{p_end}
{synopt:{cmd:r(usmeandiff)}}Standardised differences between treated
and untreated subjects before adjustment.{p_end}
{synopt:{cmd:r(fmat)}}Vector of F-statistics (or chi-squared
statistics for categorical variables) for differences between treated
and untreated subjects after adjustment, if option {opt f} is chosen.{p_end}
{synopt:{cmd:r(pmat)}}Vector of p-values for differences between treated
and untreated subjects after adjustment, if option {opt p} is chosen.{p_end}
{synopt:{cmd:r(covar)}}Covariance matrix in treated subjects after
adjustment{p_end}
{synopt:{cmd:r(ucovar)}}Mean of covariance matrix in treated and
covariance matrix in untreated before adjustment (the variances from
this matrix are used to calculated standardised differences).{p_end}
{synopt:{cmd:r(umetric)}}Inverse of unweighted covariance matrix in
treated subjects (only returned if option {opt mahal} is chosen).{p_end}
{synopt:{cmd:r(metric)}}Inverse of weighted covariance matrix in
treated subjects (only returned if option {opt mahal} is chosen).{p_end}
{synopt:{cmd:r(abeta)}} Matrix containing the magnitudes of the
coefficients in {opt beta(matrix)} (only returned if option
{opt beta(matrix)} is chosen).{p_end}
{synopt:{cmd:r(ssd)}}Square root of the diagonal of {cmd:r(covar)}.{p_end}
{synopt:{cmd:r(ussd)}}Square root of the diagonal of {cmd:r(ucovar)}.{p_end}

{title:Author}

{p 4 4 2}
Mark Lunt, Arthritis Research UK Centre for Epidemiology

{p 4 4 2}
The University of Manchester

{p 4 4 2}
Please email {browse "mailto:mark.lunt@manchester.ac.uk":mark.lunt@manchester.ac.uk} if you encounter problems with this program

