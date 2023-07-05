#!/bin/bash
#BSUB -o stdout.plot_BP_M1.txt
#BSUB -e stderr.plot_BP_M1.txt
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

stdout_file="stdout.output_M1.txt"
stderr_file="stderr.output_M1.txt"

stdout_file2="stdout.output_M1R.txt"
stderr_file2="stderr.output_M1R.txt"

stdout_file3="stdout.output_M2.txt"
stderr_file3="stderr.output_M2.txt"

# delete the output file if it already exists
if [ -f $stdout_file ]; then
    rm $stdout_file
fi

# delete the output file if it already exists
if [ -f $stderr_file ]; then
    rm $stderr_file
fi

# delete the output file if it already exists
if [ -f $stdout_file2 ]; then
    rm $stdout_file2
fi

# delete the output file if it already exists
if [ -f $stderr_file2 ]; then
    rm $stderr_file2
fi

# delete the output file if it already exists
if [ -f $stdout_file3 ]; then
    rm $stdout_file3
fi

# delete the output file if it already exists
if [ -f $stderr_file3 ]; then
    rm $stderr_file3
fi

# iterate over the range of numbers
# the output data retrieved from aperp field is stored in stdout.output.txt
for i in {0..200}
do
    python3 $py_script_directory/PlotBeamProfile.py M1_ap_0_P_${i}.h5 >> $stdout_file 2>> $stderr_file
    python3 $py_script_directory/PlotBeamProfile.py M1R_ap_0_P_${i}.h5 >> $stdout_file2 2>> $stderr_file2
    python3 $py_script_directory/PlotBeamProfile.py M1R_ap_0_P_${i}.h5 >> $stdout_file3 2>> $stderr_file3
done
mkdir mirrorOutput
mv *BeamProfile.png mirrorOutput
cp stdout.output_M1.txt mirrorOutput
cp stdout.output_M1R.txt mirrorOutput
cp stdout.output_M2.txt mirrorOutput
zip -r mirrorOutput.zip mirrorOutput
