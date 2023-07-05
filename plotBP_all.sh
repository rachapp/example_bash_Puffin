#!/bin/bash
# directory of files to process
data_directory="./"
py_script_directory="/mnt/d/My_python_script/Modified_script"
# output file
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
for i in {0..100}
do
    python3 $py_script_directory/PlotBeamProfile.py f6microns_aperp_${i}.h5 >> $stdout_file 2>> $stderr_file
done
