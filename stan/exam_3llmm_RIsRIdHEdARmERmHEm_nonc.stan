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
  
  array[N] vector[D] d_raw;
  vector<lower=0>[D] sigma_d; // population sd for the day effect (heterogenity between days)
  
  array[N, D] vector[M] omega_raw;
  real<lower=-1, upper=1> phi_m; // autoregressive parameter between moments
  real<lower=0> eta_m; // sd of the innovation noise for moments
  
  vector<lower=0>[M] sigma_epsilon; // population sd for the measurment error (heterogenity between moments)
}

transformed parameters {
  vector[N] s = sigma_s * s_raw; // subject effect (random effect)
  
  array[N] vector[D] d; // day(/subject) effect (random effect)
  for (i in 1:N) {
    d[i] = sigma_d .* d_raw[i]; // dot product for element-wise multiplication
  }
  
  real<lower=0> tau_m = sqrt(eta_m^2 / (1 - phi_m^2));
  array[N, D] vector[M] omega;
  for (i in 1:N) {
    for (j in 1:D) {
      omega[i, j, 1] = tau_m * omega_raw[i, j, 1];
      for (k in 2:M) {
        omega[i, j, k] = phi_m * omega[i, j, k-1] + eta_m * omega_raw[i, j, k];
      }
    }
  }
}

model {
  // priors
  target += normal_lpdf(beta | 50, 100);
  target += student_t_lpdf(sigma_s | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(sigma_d | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(eta_m | 3, 0, 2.5) - log(0.5);
  target += normal_lpdf(phi_m | 0, 0.5) 
            - log_diff_exp(normal_lcdf(1 | 0, 0.5), normal_lcdf(-1  | 0, 0.5));
  target += student_t_lpdf(sigma_epsilon | 3, 0, 2.5) - log(0.5);
  
  // Level 3:
  target += std_normal_lpdf(s_raw);

  // Level 2:
  for (i in 1:N) {
    target += std_normal_lpdf(d_raw[i]);
  }
 
  // Level 1:
  for (i in 1:N) {
    for (j in 1:D) {
      target += std_normal_lpdf(omega_raw[i, j]);
    }
  }

  // Likelihood
  vector[N_obs] mu_obs;
  for (l in 1:N_obs) {
      mu_obs[l] = beta 
                  + s[ii_obs[l]] 
                  + d[ii_obs[l], jj_obs[l]] 
                  + omega[ii_obs[l], jj_obs[l], kk_obs[l]];
  }
  target += normal_lpdf(y_obs | mu_obs, sigma_epsilon[kk_obs]);
}
