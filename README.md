# Replication package for "Simulated Power Analyses for Observational Studies: An Application to the Affordable Care Act Medicaid Expansion"
-------------
Bernard Black, Alex Hollingsworth, Leticia Nunes, and Kosali Simon
Journal of Public Economics

You can cite this replication package using zenodo, where an archival version of this repository is stored. 
 [![DOI](https://zenodo.org/badge/XXX.svg)](XXX)
 
## Overview
-------------

The code and data in this replication package will replicate all tables and figures from raw data using Stata, R, and a few unix shell commands. 

The entire project can be replicated by opening the stata project file `simulated-power-analysis.stpr` and then by running the `scripts/0_run_all.do` do file. This file will also run the necessary R code. The paper can be rebuilt using the latex file `latex/manuscript.tex`. 

Using nodes on Indiana University's supercomputer Carbonate (https://kb.iu.edu/d/aolp), the entire replication takes around three days. Each requested node had 16 GB of RAM and 4 cores from a 12-core Intel Xeon E5-2680 v3 CPUs. If line 51 is set to 1, `global carbonate 1`, then the power analysis will be set to run on Carbonate. If line 51 is set to zero `global carbonate 0` then the power analysis will be done in serial rather than submitted as jobs on Carbonate be run in parallel. 

The majority of this time is spent on the many power simulations reported in Table 2. In `scripts/0_run_all.do`, the user can choose to not run the power analyses code by altering line 47 to be `global slow_code 0`. If this is done the entire replication will take around than 3 hours. 

**Note**: The github version of this replication package only contains the code and output. The zenodo version of this replication package contains all publicly available raw data and data used in analysis (as well as the code). 

The zenodo replication package is available here: XXX

The github version (only code and output) is available here: XXX


## Data availability statement

**Note**: The mortality data are available from the Centers for Disease Control but restrictions apply to the availability of these data, which were used under license for the current study, and so are not publicly available. More information about these data can be found here, https://www.cdc.gov/nchs/nvss/dvs_data_release.htm. 

All other data are contained in the zenodo repository. 


## Software Requirements

- Stata (code was last run with version 15.1 MP)
	- the program `scripts/0_run_all.do` will install all stata dependencies locally if line 102 is set to `local install_stata_packages 1`
	- All user-written stata programs used in this project can be found in `stata_packages` directory

- R 3.6 
	+ We use the package `renv` for this project
	+ The `renv.lock` file has the version of each R package used in this project. 

- Portions of the code use shell commands, which may require Unix (the analysis was done on a unix machine).


## Instructions to Replicators

- Edit line 35 of `scripts/0_run_all.do` to R executible path
	- e.g., `global r_path "/usr/local/bin/R"`
- Edit line 102 of `scripts/0_run_all.do`  if you'd like to install stata code again rather than running code using `stata_packages` folder
- Edit line 41 of `scripts/0_run_all.do`  if you want to build analytic data from raw data
- Edit line 47 of `scripts/0_run_all.do`  if you want to run slow code (power analysis)
- Edit line 51 of `scripts/0_run_all.do`  if you want to run code that submits power analysis as jobs to IU's carbonate (unlikely you'll want to select this!)

	+ The shell program `scripts/3_power/3.13.pbs_scripts/create_pbs_scripts.sh` was used to create the files `scripts/3_power/3.13.pbs_scripts/power_*.txt`. This will need to be edited for your own machine. Each file `power_0.txt`-`power_73.do` was submitted as a job to Indiana University's supercomputer carbonate, requesting 16 GB of virtual memory and one node, being run on Stata MP 15.1. 
	+ The shell program  `scripts/3_power/3.13.pbs_scripts/submit_all_files.sh` was used to submit all of the jobs via line 236 of the file `scripts/0_run_all.do`
	+ If you set line 51 to zero, `global carbonate 0`, then each power analysis code will run sequentially


- Compile `latex/manuscript.tex` to recreate paper.


The provided code reproduces all tables, figures, and results in the paper. 

## Acknowledgements
This code is based on AEA data editor's readme guidelines. (https://aeadataeditor.github.io/posts/2020-12-08-template-readme). Some content on this page was copied from [Hindawi](https://www.hindawi.com/research.data/#statement.templates). Other content was adapted  from [Fort (2016)](https://doi.org/10.1093/restud/rdw057), Supplementary data, with the author's permission. 