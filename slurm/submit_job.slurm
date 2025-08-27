#!/bin/bash -l
#SBATCH --account=lp_ppw_okp
#SBATCH --cluster=wice
#SBATCH --partition=batch_sapphirerapids
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=24G
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=All
#SBATCH --mail-user=tzu-yao.lin@kuleuven.be

cd ${VSC_SCRATCH}
cd exam_study_analysis 
module purge
module load R
export OMP_NUM_THREADS=1

Rscript run_stan.R ${model_name} ${seed} &> "slurm/log/${model_name}_${seed}_${SLURM_JOB_ID}.log"
