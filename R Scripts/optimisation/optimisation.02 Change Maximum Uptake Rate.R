## Script to altar the phytoplankton maximum uptake rate so that the model data matches between NE and NM

rm(list = ls()) # reset

library(StrathE2EPolar)
library(tidyverse)
library(furrr)

plan(multisession,workers = availableCores() - 2)

scale_uptake <- function(percentage_decrease){
  # Read model
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Scale max uptake rate
  model[["data"]][["fitted.parameters"]][["u_phyt"]] <- model[["data"]][["fitted.parameters"]][["u_phyt"]] * percentage_decrease
  
  # Run model
  results <- e2ep_run(model = model, nyears = 50)
  
  # Extract chi
  chi <- results[["final.year.outputs"]][["opt_results"]]
  
  # Return data frame with scalar + chi
  return(data.frame(
    scalar = percentage_decrease,
    chi
  ))
}

percentage_decrease <- seq(0.6, 1.2, 0.01)

length(percentage_decrease)

results_tbl <- future_map_dfr(
  .x = percentage_decrease,
  .f = scale_uptake)

saveRDS(results_tbl, "./Objects/Optimisation/MaximumUptakeScaled2.rds")
