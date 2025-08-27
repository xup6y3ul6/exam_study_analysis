// Stan model prepared for bridgesampling
data {
  int<lower=1> N; // number of subjects
  int<lower=1> D; // number of days
  int<lower=1> M; // number of time points
  int<lower=0, upper=N*D*M> N_obs;
  array[N_obs] int<lower=1, upper=N> ii_obs;
  array[N_obs] int<lower=1, upper=D> jj_obs;
  array[N_obs] int<lower=1, upper=M> kk_obs;
  vector[N_obs] y_obs;
}

parameters {
  real beta; // ground mean (fixed effect)
  vector[N] s_raw;
  real<lower=0> sigma_s; // population sd for the subject effect
  
  array[N] vector[D] nu_raw;
  real<lower=-1, upper=1> phi_d; // autoregressive parameter between days
  real<lower=0> eta_d; // sd of the innovation noise for days
  
  vector<lower=0>[M] sigma_epsilon; // population sd for the measurment error (heterogenity between moments)
}

transformed parameters {
  vector[N] s = sigma_s * s_raw; // subject effect (random effect)

  real<lower=0> tau_d = sqrt(eta_d^2 / (1 - phi_d^2));
  array[N] vector[D] nu;
  for (i in 1:N) {
    nu[i, 1] = tau_d * nu_raw[i, 1];
    for (j in 2:D) {
      nu[i, j] = phi_d * nu[i, j-1] + eta_d * nu_raw[i, j];
    }
  }
}

model {
  // priors
  target += normal_lpdf(beta | 50, 100);
  target += student_t_lpdf(sigma_s | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(eta_d | 3, 0, 2.5) - log(0.5);
  target += normal_lpdf(phi_d | 0, 0.5) 
        - log_diff_exp(normal_lcdf(1 | 0, 0.5), normal_lcdf(-1  | 0, 0.5));
  target += student_t_lpdf(sigma_epsilon | 3, 0, 2.5) - log(0.5);
  
  // Level 3:
  target += std_normal_lpdf(s_raw);
  
  // Level 2:
  for (i in 1:N) {
    target += std_normal_lpdf(nu_raw[i]);
  }
 
  // Level 1:

  // Likelihood
  vector[N_obs] mu_obs;
  for (l in 1:N_obs) {
      mu_obs[l] = beta 
                  + s[ii_obs[l]] 
                  + nu[ii_obs[l], jj_obs[l]]; 
  }
  target += normal_lpdf(y_obs | mu_obs, sigma_epsilon[kk_obs]);
}
