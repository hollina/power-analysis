{smcl}
{* *! version #.#.# date}{...}
{cmd:help trackuse}
{hline}

{title:Title}

{phang}
{bf:Usage Tracking with Google Analytics}


{title:Syntax}

{p 8 17 2}
{cmd:trackuse}, options ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt tid(string)}} Tracker ID, given by Google when signing up
for Analytics {p_end}
{synopt:{opt progname(string)}} Name of the the program being tracked {p_end}
{synopt:{opt av(string)}} Application Version: version of {cmd:progname}
being tracked       {p_end}
{synopt:{opt aid(string)}} Application ID: a unique identifier for {cmd:progname} {p_end}
{synopt:{opt options(string)}} The options that were sent to {cmd:progname}  {p_end}
{synoptline}

{title:Description}

{pstd}
The command {cmd:trackuse} is primarily of use to programmers to
enable them to use Google Analytics to keep track of the installation
and use of their programs. However, it can also be used by users to
change the data reported to Google Analytics by a particular program,
and that is the usage documented here. If you want to see the
programming use, see {help trackuse:trackuse for users}.

{pstd}
As a programmer, you would need to add a single call to {cmd:trackuse}
at the beginning of your command. You {bf:must} pass the options
{opt progname(string)}, {opt av(string)} and {opt aid(string)}, to
identify the program being tracked. You may wish to include the
options that were sent to {cmd:progname}, using {opt
  options(string)}. 


{title:Options}{dlgtab:Main}

{phang}
{opt progname(string)} The name of the program that is being tracked

{phang}
{opt av(string)} The version of the program being tracked. This number
should be maintained by your version control software, but will need
to be manually copied into the {cmd:trackuse} command.

{phang}
{opt aid(string)} Application identifier. This should be a unique
identifier for the version of the program being run, for example a DOI
if one is available.

{phang}
{opt options(string)} A list of options that were sent to
{cmd:progname}. I would suggest not sending variable names, since that
could be seen as a privacy violation. Adding the following code to
your program, and passing the local macro {it:tuoptions} to {cmd:trackuse}
would be better.

foreach opt in {it:opt1} {it:opt2} ... {
  if "``opt''" != "" {
    local tuoptions `tuoptions' `opt'
  }
}

{phang}
{opt tid(string)} Tracking ID. When you sign up to track a program
using Google Analytics, you will be given a Tracking ID, which must
form part of all data sent to Google Analytics. The default TID in
{cmd:trackuse} is tied to Mark Lunt's account: when tracking your own
ado files, please ensure that you pass your own TID to {cmd:trackuse} with this
option. Alternatively, you could edit the file {cmd:trackuse.ado} and
replace the default TID with your own.


{title:Remarks}

{pstd}
You need to read the conditions of use published by Google before
adding tracking to any of your programs. In particular, you need to
respect end users privacy and their right to opt out of usage
tracking. In addition, be aware that you may be liable for charges if
the number of hits you receive per month exceeds a threshold (10 M 
at the time of writing).

{pstd}
If you include {cmd:trackuse} in any ado-file you write, you need to
inform users of the program. There is a sample chunk of text in
{help ga_fragment:this file} that you can include in your help file
(after changing {it:thisprog} to the name of your program wherever it
appears). If you make your program available through a package file,
you should warn users about your use of tracking in that file:
{view "http://personalpages.manchester.ac.uk/staff/mark.lunt/ga_fragment.pkg":this file}
contains a possible paragraph that you might like to use.


{title:Author}

{pstd}
Mark Lunt, Arthritis Research UK Centre for Epidemiology

{pstd}
The University of Manchester

{pstd}
Please email {browse "mailto:mark.lunt@manchester.ac.uk":mark.lunt@manchester.ac.uk} if you encounter problems with this program

{title:References}

{phang}

