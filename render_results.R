library(quarto)
library(tidyverse)

mcmc_engine <- "jags" # or "stan"
model_names <- list.dirs(str_glue("{mcmc_engine}/draws"), full.names = FALSE, recursive = FALSE) |> 
  #str_subset("nonc_m")
model_names

for (m in model_names[1]) {
  tryCatch ({
    print(str_glue("Started: {m}"))
    file_name <- str_glue("{m}_result.html")
    quarto::quarto_render(
      input = "check_convergence.qmd",
      execute_params = list(model_name = m, mcmc_engine = mcmc_engine),
      output_file = file_name)
    
    file.rename(file_name, file.path("results", mcmc_engine, file_name))

    print(str_glue("Finished: {m}\n"))
  }, error = function(e){
    print(str_glue("Failed: {m}\n Error messamge: {e}"))
  })
}
