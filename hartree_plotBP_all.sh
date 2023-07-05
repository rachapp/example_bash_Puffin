#!/bin/bash
#BSUB -o stdout.plot_BP.txt
#BSUB -e stderr.plot_BP.txt
#BSUB -R "span[ptile=16]"
#BSUB -q scafellpikeSKL
#BSUB -n 32
#BSUB -J plot_BeamProfile
#BSUB -W 8:00

export PUFFDIR=$HCBASE/puffin/bin
export py_script_directory=$HCBASE/plot-script
export MYHOME=`pwd`
export OMP_NUM_THREADS=1

# setup modules
. /etc/profile.d/modules.sh
module load intel_mpi > /dev/null 2>&1
module load intel
module load python3/anaconda

stdout_file="stdout.output.txt"
stderr_file="stderr.output.txt"

# delete the output file if it already exists
if [ -f $stdout_file ]; then
    rm $stdout_file
fi

# delete the output file if it already exists
if [ -f $stderr_file ]; then
    rm $stderr_file
fi

# iterate over the range of numbers
# the output data retrieved from aperp field is stored in stdout.output.txt
for i in {0..200}
do
    python3 $py_script_directory/PlotBeamProfile.py 6microns_ap_1_P_${i}.h5 >> $stdout_file 2>> $stderr_file
done
