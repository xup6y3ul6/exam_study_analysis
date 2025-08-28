args <- commandArgs(trailingOnly = TRUE)
model_name <- args[1]
seed <- ifelse(length(args) >= 2, as.integer(args[2]), 20250814)

library(readr)
library(stringr)
library(jagsUI)
library(posterior)

include_RId <- str_detect(model_name, "RId")
include_ARd <- str_detect(model_name, "ARd")
include_HEd <- str_detect(model_name, "HEd")
include_ARm <- str_detect(model_name, "ARm")
include_HEm <- str_detect(model_name, "HEm")

output_dir_stan <- str_glue("jags/draws/{model_name}")
unlink(output_dir_stan, recursive = TRUE)
dir.create(output_dir_stan, recursive = TRUE)

data <- read_rds("data/exam_data_preprocessed.rds")
N <- 101
D <- 9
M <- 10
y <- array(NA, dim = c(N, D, M))

for (i in 1:N) {
  for (j in 1:D) {
    for (k in 1:M) {
      y[i, j, k] <- data$Neg_aff[data$Participant == i & data$Day == j & data$Moment == k]
    }
  }
}

data_jags <- list(
  N = N,
  D = D,
  M = M,
  y = y
)

par_save <- c("beta", "s", "sigma_s",
              if (include_RId) {c("d", "sigma_d")},
              if (include_ARd) {c("phi_d", "eta_d", "tau_d")},
              if (include_ARm) {c("phi_m", "eta_m", "tau_m")},
              "sigma_epsilon")

mod_fit_jags <- jags(data = data_jags,
                     parameters.to.save = par_save,
                     model.file = str_glue("jags/{model_name}.jag"),
                     n.chains = 4,
                     n.adapt = 1000,
                     n.burnin = 16000,
                     n.iter = 32000,
                     n.thin = 4,
                     parallel = TRUE)

write_rds(mod_fit_jags, file = "jags/draws/{model_name}_jags.rds")

mod_draws <- as_draws(mod_fit_jags$samples)

mod_summary <- summarise_draws(mod_draws)
write_csv(mod_summary, str_glue("jags/summary/{model_name}_summary.csv"))