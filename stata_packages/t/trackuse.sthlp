{smcl}
{* *! version November 13, 2017 @ 10:33:36}{...}
{cmd:help trackuse}
{hline}

{title:Title}

{phang}
{bf:Usage Tracking with Google Analytics}


{title:Syntax}

{p 8 17 2}
{cmd:trackuse} program_name

{title:Description}

{pstd}
The command {cmd:trackuse} is primarily of use to programmers to
enable them to use Google Analytics to keep track of the installation
and use of their programs. However, it can also be used by users to
change the data reported to Google Analytics by a particular program,
and that is the usage documented here. If you want to see the
programming use, see {help trackuse_prog:trackuse for programmers}

{title:Remarks}

{pstd}
Entering the command {cmd:trackuse program_name} allows the usage
tracking for {cmd:program_name} to be changed. It will create a dialog
box from which it is possible to choose whether or not to send usage
data to Google Analytics. If you choose to send data, the name of the
program being run will always be sent. In addition, your IP address
will be sent, though this can be anonymised if you select the
appropriate checkbox. The IP address is not passed on by Google, but
it is used to give and idea of where the command is being used.

{pstd}
Your preferences are stored in {ccl sysdir_personal}{cmd:program_name}.conf, in
the format "keyword : value". The first keyword is "analytics": if
this has the value 0, no data is sent to Google: if it is 1, data is
sent. The next line contains the keyword "uuid" and its value, which
is a version 4 UUID. This identifier should be the same for any of my programs:
it exists in this file and in {ccl sysdir_personal/trackuse.uuid}.

The other keywords are are:
{phang}
{opt send_aip}, which determines whether the IP address should be anonymised before sending,

{phang}
{opt send_options}, which will send Google the list of options used
with the command {cmd:progname} (but not their values, since that
could potentially leak sensitive information). 

{phang}

{opt delay_minutes}, the time that must pass after the programme has
sent data to Google before it will send further data. The initial
version sent data every time a tracked programme was run, which led to
a performance hit when analysing multiple datasets (simulations,
bootstrapping etc). This option is to minimise that performance hit.

{title:Author}

{pstd}
Mark Lunt, Arthritis Research UK Centre for Epidemiology

{pstd}
The University of Manchester

{pstd}
Please email {browse "mailto:mark.lunt@manchester.ac.uk":mark.lunt@manchester.ac.uk} if you encounter problems with this program

{title:References}

{phang}

