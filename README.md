# The Reliaiblity Analysis for the Exam Study

Please check the results from this [website](https://xup6y3ul6.github.io/exam_study_analysis/).

This repository contains the data, code, and analysis procedure for the reliability analysis of the exam study. The results are presented in the our draft paper: "Reliability for three level linear mixed-effect models".

> Note that the negative affect scores used in this analysis is based on the students' self-reported ratings (one item only). In my previous anlaysis (see [exam_analysis](https://github.com/xup6y3ul6/exam_analysis)), I used the mean scores which average of six items (afraid, nervous, jittery, irritable, ashamed, upset).

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

MCMC sampling with chain = 4, burnin = 16000, iter = 16000, thin = 4.

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
|7    | + | + | - | + | + | + | + | + | - | [exam_3llmm_RIsRIdHEdARdARmERmHOm](results/exam_3llmm_RIsRIdHEdARdARmERmHOm_nonc_m_result.html)                   |


Additional runs:

- If I used the lmm expression for AR(1) process instead of the ssm expression
  - Model 3_m: [exam_3llmm_RIsRIdHOdARmERmHOm_m](results/exam_3llmm_RIsRIdHOdARmERmHOm_nonc_m_result.html)
  - Model (3+4)_m: [exam_3llmm_RIsRIdHOdARdARmERmHOm_m](results/exam_3llmm_RIsRIdHOdARdARmERmHOm_nonc_m_result.html)
- Longer version of MCMC (chain = 4, burnin = 32000, iter = 32000, thin = 8)
  - Model 3_m_long: [exam_3llmm_RIsRIdHOdARmERmHOm_m_long](results/exam_3llmm_RIsRIdHOdARmERmHOm_nonc_m_long_result.html)
  - Model (3+4)_m_long: [exam_3llmm_RIsRIdHOdARdARmERmHOm_m_long](results/exam_3llmm_RIsRIdHOdARdARmERmHOm_nonc_m_long_result.html)
- Sophie's suggestion: fix the range of beta and center parameterized for the day random effect.
  - Model 3_fix: [exam_3llmm_RIsRIdHOdARmERmHOm_centd](results/exam_3llmm_RIsRIdHOdARmERmHOm_centd_result.html)
  - Model 3_fix (non-centerized other parameters) [exam_3llmm_RIsRIdHOdARmERmHOm_nonc_centd](results/exam_3llmm_RIsRIdHOdARmERmHOm_nonc_centd_result.html)
- Two day variances
  - Day 3 has a speicific variance, other days share another variance.
    - Noncentered parameterization: [exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_nonc_ver1_result](results/exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_nonc_ver1_result.html)
    - Centered parameterization: [exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_nonc_ver1_result](results/exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_ver1_result.html)
    - Centered parameterization with phi_beta: [exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_phibeta_ver1_result](results/exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_phibeta_ver1_result.html)
  - Days 3 and 4 have a speicific variance, other days share another variance.
    - Noncentered parameterization: Noncentered parameterization: [exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_nonc_ver2_result](results/exam_3llmm_RIsRIdHEd2ARdARmERmHOm_m_nonc_ver2_result.html)


## Primary Restults

The primary results are based on Model 3+4: `exam_3llmm_RIsRIdHOdARdARmERmHOm.stan`. The reliaiblity analysis please check:

- (Not fully finished yet) [exam_study_analysis](results/exam_study_analysis.html)

