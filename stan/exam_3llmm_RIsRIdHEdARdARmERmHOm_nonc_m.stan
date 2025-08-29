functions {
  // ar(1) correlation matrix generator
  matrix ar1_corr_matrix(int m, real phi) {
    matrix[m, m] h;
    for (i in 1:m)
      for (j in 1:m)
        h[i, j] = phi ^ abs(i - j);
    return h;
  }
}

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

  array[N] vector[D] nu_raw;
  real<lower=-1, upper=1> phi_d; // autoregressive parameter between days
  real<lower=0> tau_d;
  
  array[N, D] vector[M] omega_raw;
  real<lower=-1, upper=1> phi_m; // autoregressive parameter between moments
  real<lower=0> tau_m; // sd of the innovation noise for moments
  
  real<lower=0> sigma_epsilon; // population sd for the measurment error (heterogenity between moments)
}

transformed parameters {
  vector[N] s = sigma_s * s_raw; // subject effect (random effect)
  
  array[N] vector[D] d; // day(/subject) effect (random effect)
  for (i in 1:N) {
    d[i] = sigma_d .* d_raw[i];
  }
  
  corr_matrix[D] H_d = ar1_corr_matrix(D, phi_d);
  cov_matrix[D] Sigma_d = tau_d^2 * H_d;
  matrix[D, D] L_Sigma_d = cholesky_decompose(Sigma_d);
  array[N] vector[D] nu;
  for (i in 1:N) {
    nu[i] = L_Sigma_d * nu_raw[i];
  }

  corr_matrix[M] H_m = ar1_corr_matrix(M, phi_m);
  cov_matrix[M] Sigma_m = tau_m^2 * H_m;
  matrix[M, M] L_Sigma_m = cholesky_decompose(Sigma_m);
  array[N, D] vector[M] omega;
  for (i in 1:N) {
    for (j in 1:D) {
      omega[i, j] = L_Sigma_m * omega_raw[i, j];
    }
  }
}

model {
  // priors
  target += normal_lpdf(beta | 50, 100);
  target += student_t_lpdf(sigma_s | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(sigma_d | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(tau_d | 3, 0, 2.5) - log(0.5);
  target += normal_lpdf(phi_d | 0, 0.5) 
        - log_diff_exp(normal_lcdf(1 | 0, 0.5), normal_lcdf(-1  | 0, 0.5));
  target += student_t_lpdf(tau_m | 3, 0, 2.5) - log(0.5);
  target += normal_lpdf(phi_m | 0, 0.5) 
            - log_diff_exp(normal_lcdf(1 | 0, 0.5), normal_lcdf(-1  | 0, 0.5));
  target += student_t_lpdf(sigma_epsilon | 3, 0, 2.5) - log(0.5);
  
  // Level 3:
  target += std_normal_lpdf(s_raw);

  // Level 2:
  for (i in 1:N) {
    target += std_normal_lpdf(d_raw[i]);
    target += std_normal_lpdf(nu_raw[i]);
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
                  + nu[ii_obs[l], jj_obs[l]] 
                  + omega[ii_obs[l], jj_obs[l], kk_obs[l]];
  }
  target += normal_lpdf(y_obs | mu_obs, sigma_epsilon);
}
