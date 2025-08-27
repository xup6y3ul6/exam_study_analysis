#!/bin/bash -l
# submit multiple SLURM jobs

# defined the path of the parameter file
PARAM_FILE="pars.csv"

# delete the first line then read each line of the parameter file
sed 1d $PARAM_FILE | while IFS=, read -r model_name seed; do
    # print current line
    echo "Submitting job with model_name=$model_name, seed=$seed"
    
    # export the local variables to the environmental variables
    export model_name
    export seed
    
    # submit each Slurm job
    sbatch --job-name="${model_name}"\
           --export=model_name,seed\
           submit_job.slurm
    sleep 3
done
