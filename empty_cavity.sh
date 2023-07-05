#!/bin/bash
#BSUB -o stdout.empty.txt
#BSUB -e stderr.empty.txt
#BSUB -R "span[ptile=32]"
#BSUB -q scafellpikeSKL
#BSUB -n 64 
#BSUB -J empty_cav
#BSUB -W 8:00

export PUFFDIR=$HCBASE/puffin/bin
export MYSCRIPT=$HCBASE/rafel-script
export MYHOME=`pwd`
export OMP_NUM_THREADS=1
export OPC_HOME=$HCBASE/OPC/Physics-OPC-0.7.10.3
export RAFEL=$HCBASE/OPC/Physics-OPC-0.7.10.3/opc-puffin
export py_script_directory=$HCBASE/plot-script

# setup simulation parameters
# basename of the input file
BASENAME=6microns
LFN=1
detune_factor=0
R1=1.0
R2=1.0

# setup modules
. /etc/profile.d/modules.sh
module load intel_mpi > /dev/null 2>&1
module load intel
module load python3/anaconda

export LD_LIBRARY_PATH=/lustre/scafellpike/local/HCP098/jkj01/pxp52-jkj01/hdf5/lib:$LD_LIBRARY_PATH
date

stdout_file1="stdout.output_M1.txt"
stderr_file1="stderr.output_M1.txt"

stdout_file2="stdout.output_M1R.txt"
stderr_file2="stderr.output_M1R.txt"

stdout_file3="stdout.output_M2.txt"
stderr_file3="stderr.output_M2.txt"

stdout_file3="stdout.waist.txt"
stderr_file3="stderr.waist.txt"

# delete the output file if it already exists
if [ -f $stdout_file1 ]; then
    rm $stdout_file1
fi

# delete the output file if it already exists
if [ -f $stderr_file1 ]; then
    rm $stderr_file1
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

# delete the output file if it already exists
if [ -f $stdout_file4 ]; then
    rm $stdout_file4
fi

# delete the output file if it already exists
if [ -f $stderr_file4 ]; then
    rm $stderr_file4
fi

mpiexec.hydra -np 64 $PUFFDIR/puffin ${BASENAME}.in
date
python3 $HCBASE/rafel-script/Puffin-to-OPC-nslices_v2.py ${BASENAME}_aperp_${LFN}
date
perl $RAFEL/IR_cavity_empty.pl ${detune_factor} ${R1} ${R2}
date
python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py entrance
date

python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M1
mpiexec.hydra -np 64 $PUFFDIR/puffin M1.in
mv M1_aperp_0.h5 M1_ap_0_P_0.h5
mv M1_integrated_0.h5 M1_int_0_P_0.h5
python3 $py_script_directory/PlotBeamProfile.py M1_ap_0_P_0.h5 >> $stdout_file1 2>> $stderr_file1

python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M1R
mpiexec.hydra -np 64 $PUFFDIR/puffin M1R.in
mv M1R_aperp_0.h5 M1R_ap_0_P_0.h5
mv M1R_integrated_0.h5 M1R_int_0_P_0.h5
python3 $py_script_directory/PlotBeamProfile.py M1R_ap_0_P_0.h5 >> $stdout_file2 2>> $stderr_file2

python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M2
mpiexec.hydra -np 64 $PUFFDIR/puffin M2.in
mv M2_aperp_0.h5 M2_ap_0_P_0.h5
mv M2_integrated_0.h5 M2_int_0_P_0.h5
python3 $py_script_directory/PlotBeamProfile.py M2_ap_0_P_0.h5 >> $stdout_file3 2>> $stderr_file3

mv ${BASENAME}_aperp_0.h5 ${BASENAME}_ap_0_P_0.h5
mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_0_P_${LFN}.h5
python3 $py_script_directory/PlotBeamProfile.py ${BASENAME}_ap_0_P_${LFN}.h5 >> $stdout_file4 2>> $stderr_file4

mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_0.h5

for loop in {1..100}
do
	date
  mpiexec.hydra -np 64 $PUFFDIR/puffin ${BASENAME}.ins
	date
	python3 $HCBASE/rafel-script/Puffin-to-OPC-nslices_v2.py ${BASENAME}_aperp_${LFN}
	date        
	perl $RAFEL/IR_cavity_empty.pl ${detune_factor} ${R1} ${R2}
	date
	python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py entrance
  date

  python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M1
  mpiexec.hydra -np 64 $PUFFDIR/puffin M1.in
  mv M1_aperp_0.h5 M1_ap_0_P_${loop}.h5
  mv M1_integrated_0.h5 M1_int_0_P_${loop}.h5
  python3 $py_script_directory/PlotBeamProfile.py M1_ap_0_P_${loop}.h5 >> $stdout_file1 2>> $stderr_file1

  python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M1R
  mpiexec.hydra -np 64 $PUFFDIR/puffin M1R.in
  mv M1R_aperp_0.h5 M1R_ap_0_P_${loop}.h5
  mv M1R_integrated_0.h5 M1R_int_0_P_${loop}.h5
  python3 $py_script_directory/PlotBeamProfile.py M1R_ap_0_P_${loop}.h5 >> $stdout_file2 2>> $stderr_file2

  python3 $HCBASE/rafel-script/OPC-to-Puffin-nslices.py M2
  mpiexec.hydra -np 64 $PUFFDIR/puffin M2.in
  mv M2_aperp_0.h5 M2_ap_0_P_${loop}.h5
  mv M2_integrated_0.h5 M2_int_0_P_${loop}.h5
  python3 $py_script_directory/PlotBeamProfile.py M2_ap_0_P_${loop}.h5 >> $stdout_file3 2>> $stderr_file3

	mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_${LFN}_P_${loop}.h5
	mv ${BASENAME}_aperp_0.h5 ${BASENAME}_ap_0_P_${loop}.h5
  mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_${loop}.h5
  python3 $py_script_directory/PlotBeamProfile.py ${BASENAME}_ap_0_P_${loop}.h5 >> $stdout_file4 2>> $stderr_file4
	
	echo pass ${loop} done
done
echo all given passes done
mkdir beamOutput
mv *BeamProfile.png beamOutput
zip -r beamOutput.zip beamOutput
mkdir logOutput
mv stdout* logOutput
zip -r logOutput.zip logOutput
