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
  vector[N] s;
  real<lower=0> sigma_s; // population sd for the subject effect
  
  array[N] vector[D] d;
  vector<lower=0>[2] sigma_d; // population sd for the day effect (heterogenity between days)

  array[N] vector[D] nu;
  real<lower=0, upper=1> phi_beta_d; // autoregressive parameter between days
  real<lower=0> tau_d;
  
  array[N, D] vector[M] omega;
  real<lower=0, upper=1> phi_beta_m; // autoregressive parameter between moments
  real<lower=0> tau_m; // sd of the innovation noise for moments
  
  real<lower=0> sigma_epsilon; // population sd for the measurment error (heterogenity between moments)
}

transformed parameters {
  vector[D] sigma_d_vec = rep_vector(sigma_d[1], D);
  sigma_d_vec[3:4] = rep_vector(sigma_d[2], 2);
  
  real<lower=-1, upper=1> phi_d = 2 * phi_beta_d - 1;
  corr_matrix[D] H_d = ar1_corr_matrix(D, phi_d);
  cov_matrix[D] Sigma_d = tau_d^2 * H_d;
  matrix[D, D] L_Sigma_d = cholesky_decompose(Sigma_d);

  real<lower=-1, upper=1> phi_m = 2 * phi_beta_m - 1;
  corr_matrix[M] H_m = ar1_corr_matrix(M, phi_m);
  cov_matrix[M] Sigma_m = tau_m^2 * H_m;
  matrix[M, M] L_Sigma_m = cholesky_decompose(Sigma_m);
}

model {
  // priors
  target += normal_lpdf(beta | 50, 100);
  target += student_t_lpdf(sigma_s | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(sigma_d | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(tau_d | 3, 0, 2.5) - log(0.5);
  target += beta_lpdf(phi_beta_d | 2, 2); 
  target += student_t_lpdf(tau_m | 3, 0, 2.5) - log(0.5);
  target += beta_lpdf(phi_beta_m | 2, 2);
  target += student_t_lpdf(sigma_epsilon | 3, 0, 2.5) - log(0.5);
  
  // Level 3:
  target += normal_lpdf(s | 0, sigma_s);

  // Level 2:
  for (i in 1:N) {
    target += normal_lpdf(d[i] | 0, sigma_d_vec);
    target += multi_normal_cholesky_lpdf(nu[i] | rep_vector(0, D), L_Sigma_d);
  }

  // Level 1:
  for (i in 1:N) {
    for (j in 1:D) {
      target += multi_normal_cholesky_lpdf(omega[i, j] | rep_vector(0, M), L_Sigma_m);
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
