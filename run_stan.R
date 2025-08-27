
args <- commandArgs(trailingOnly = TRUE)
model_name <- args[1]
seed <- ifelse(length(args) >= 2, as.integer(args[2]), 20250814)

library(tidyverse)
library(cmdstanr)

output_dir_stan <- str_glue("stan/draws/{model_name}")
unlink(output_dir_stan, recursive = TRUE)
dir.create(output_dir_stan, recursive = TRUE)

data <- read_rds("data/exam_data_preprocessed.rds")

obs_index <- which(!data$Missing)

data_stan <- list(
  N = 101, D = 9, M = 10, 
  N_obs = length(obs_index),
  ii_obs = data$Participant[obs_index], 
  jj_obs = data$Day[obs_index],
  kk_obs = data$Moment[obs_index], 
  y_obs = data$Neg_aff[obs_index]
)

mod_stan <- cmdstan_model(str_glue("stan/{model_name}.stan"))

mod_fit_stan <- mod_stan$sample(
  data = data_stan, 
  chains = 4, 
  parallel_chains = 4,
  output_dir = output_dir_stan, 
  iter_warmup = 8000, 
  iter_sampling = 4000,
  thin = 1, 
  seed = seed, 
  refresh = 1000, 
  show_messages = TRUE
)

mod_summary <- mod_fit_stan$summary()
write_csv(mod_summary, str_glue("stan/summary/{model_name}_summary.csv"))
