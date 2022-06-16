#!/bin/bash
cd /Users/hollinal/Documents/GitHub/simulated-power-analysis/scripts/3_power/3.13.pbs_scripts
for i in {0..73}
do
    {

		echo '#!/bin/bash'
		echo '#####  Constructed by HPC everywhere #####'
		echo '#PBS -M hollinal@iu.edu'
		echo '#PBS -l nodes=1:ppn=4,walltime=0:23:59:00'
		echo '#PBS -l vmem=16gb'
		echo '#PBS -m abe'
		echo '#PBS -N power_'$i
		echo '#PBS -j oe'

		echo '######  Module commands #####'
		echo 'module load stata'

		echo '######  Job commands go below this line #####'
		echo 'cd /N/project/Simon_HealthEcProj1/simulated-power-analysis/scripts/3_power/3.13.pbs_scripts'
		echo 'stata-mp do power_'$i'.do'

    } > "power_$((num++)).txt"
done 










