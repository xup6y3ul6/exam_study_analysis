# The Reliaiblity Analysis for the Exam Study

This repository contains the data, code, and analysis procedure for the reliability analysis of the exam study. The results are presented in the our draft paper: "Reliability for three level linear mixed-effect models".


## Project structure

- `README.md`: This file, providing an overview of the project.
- `exam_data_analysis.qmd`: The Quarto document that contains the analysis code and results.
- `data/`: Contains the data files used in the analysis.
- `stan/`: Contains the Stan model files used for the analysis.
  - stan files are named following the pattern `exam_[model]_[specification].stan`
  - `draws/`: save the MCMC draws from the Stan models.
  - `summary/`: save the summary statistics of the MCMC draws.
- `jags/`: Contains the JAGS model files used for the analysis.
- `slurm_jobs/`: Contains the SLURM job files for running the analysis on a cluster.
- `results/`: Contains the results of the analysis.- 




## Model naming

model name / file name pattern: exam_[model]_[spcification]<.[extension]>

- 3llmm = three-level linear mixed-effect model
- specification components:
  - RIs = random effect for subjects
  - RId = random effect for days
  - HEd = heterogeneity of variances/standard deviations between days
  - HOd = homogeneity of variances/standard deviations between subjects
  - ARd = autoregressive process for days
  - ARm = autoregressive process for moments
  - ERm = error term (cannot be separated from moment effect) for moments
  - HEm = heterogeneity of variances/standard deviations between moments
  - HOm = heterogeneity of variances/standard deviations between moments
- extension:
  - stan = stan code
  - jag = jags code

### Possible model

 |Model|RIs|RId|HOd|HEd|ARd|ARm|ERm|HOm|HEm|Results                          |
|-----|---|---|---|---|---|---|---|---|---|----------------------------------|
|1    | + | + | + | - | - | - | + | + | - | [exam_3llmm_RIsRIdHOdERmHOm](results/exam_3llmm_RIsRIdHOdERmHOm_nonc_result.html)             |
|2    | + | + | - | + | - | - | + | - | + | [exam_3llmm_RIsRIdHEdERmHEm](results/exam_3llmm_RIsRIdHEdERmHEm_nonc_result.html)             |
| 2+3 | + | + | - | + | - | + | + | - | + | [exam_3llmm_RIsRIdHEdARmERmHEm](results/exam_3llmm_RIsRIdHEdARmERmHEm_nonc_result.html)       |
|3    | + | + | - | - | - | + | + | + | - | [exam_3llmm_RIsRIdHOdARmERmHOm](results/exam_3llmm_RIsRIdHOdARmERmHOm_nonc_result.html)       |
| 3+4 | + | + | - | - | + | + | + | + | - | [exam_3llmm_RIsRIdHOdARdARmERmHOm](results/exam_3llmm_RIsRIdHOdARdARmERmHOm_nonc_result.html) |
|4    | + | - | - | - | + | + | + | + | - | [exam_3llmm_RIsARdARmERmHOm](results/exam_3llmm_RIsARdARmERmHOm_nonc_result.html)             |
|5    | + | - | - | - | + | - | + | + | - | [exam_3llmm_RIsARdERmHOm](results/exam_3llmm_RIsARdERmHOm_nonc_result.html)                   |
|6    | + | - | - | - | + | - | + | - | + | [exam_3llmm_RIsARdERmHEm](results/exam_3llmm_RIsARdERmHEm_nonc_result.html)                   |

If I used the lmm expression for AR(1) process instead of the ssm expression

Model 3': [exam_3llmm_RIsRIdHOdARmERmHOm_m](results/exam_3llmm_RIsRIdHOdARmERmHOm_nonc_m_result.html)