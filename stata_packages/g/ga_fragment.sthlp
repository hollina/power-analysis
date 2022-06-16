{title:Analytics}

{pstd}
In order to demonstrate to the University and our funders that the time
spent working on this program was worthwhile, we would like to
track of the number of installations and the number of times it is
used. To achieve this, you will be asked, the first time you run
{cmd:thisprog}, if you mind sending some usage information to Google
Analytics. If you agree, we will be informed that an installation has
taken place, and that {cmd:thisprog} has been run. 

{pstd}
Each time {cmd:thisprog} runs, it checks if you have agreed to send
data to google, and if you have then it will record the fact that the
program has been run. We will also receive some information about the
rough geographical area in which it was run, and if you have agreed to
this, the options with which it was run (but not the variable names,
since that could be viewed as potentially confidential information). 

{pstd}
{bf Opting out:} It would us greatly to dedicate time to this program 
if we could show that it was widely used, but {cmd:thisprog} will respect your
desire for privacy if you request it. If you agree initially to
sending analytics information and then change your mind, you can set
the top line of {cmd:thisprog.conf} in your ado file directory from
"analytics : 1" to "analytics : 0" and no further data will be
sent. Alternatively, the command {cmd:trackuse thisprog} will enable
you to change any of the tracking options without needing to edit any
files (for more information see {help trackuse:trackuse for users}). 


