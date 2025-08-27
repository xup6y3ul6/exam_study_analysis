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
  
  vector<lower=0>[M] sigma_epsilon; // population sd for the measurment error (heterogenity between moments)
}

transformed parameters {
  vector[N] s = sigma_s * s_raw; // subject effect (random effect)
  
  array[N] vector[D] d; // day(/subject) effect (random effect)
  for (i in 1:N) {
    d[i] = sigma_d .* d_raw[i]; // dot product for element-wise multiplication
  }
}

model {
  // priors
  target += normal_lpdf(beta | 50, 100);
  target += student_t_lpdf(sigma_s | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(sigma_d | 3, 0, 2.5) - log(0.5);
  target += student_t_lpdf(sigma_epsilon | 3, 0, 2.5) - log(0.5);
  
  // Level 3:
  target += std_normal_lpdf(s_raw);

  // Level 2:
  for (i in 1:N) {
    target += std_normal_lpdf(d_raw[i]);
  }
 
  // Level 1:
  
  // Likelihood
  vector[N_obs] mu_obs;
  for (l in 1:N_obs) {
      mu_obs[l] = beta 
                  + s[ii_obs[l]] 
                  + d[ii_obs[l], jj_obs[l]]; 
  }
  target += normal_lpdf(y_obs | mu_obs, sigma_epsilon[kk_obs]);
}
