rm(list = ls()) # reset

library(StrathE2EPolar)
library(tidyverse)
library(furrr)

plan(multisession,workers = availableCores()-1)


maxUpMult <- seq(0,3,0.1)
res <- future_map(
  .x = seq_along(maxUpMult),
  .f = function(idx) {
    base_model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
    
    mult <- maxUpMult[idx]  # the multiplier for this iteration
    
    # copy the model for this worker - need to find a way to bring model into the future_map
    model <- base_model
    
    # multiply carnzoo maxup
    model$data$fitted.parameters$u_carn <- model$data$fitted.parameters$u_carn * mult
    
    # run the model
    results <- e2ep_run(model = model, nyears = 50)
    
    # save
    jpeg(
      filename = sprintf(
        "./Figures/optimisation/Fixing/Final/CarnZoo MaxUp Mults/%03d_CarnZoo_MaxUpMult_%s.png",
        idx, mult
      ),
      units = "px", width = 1920, height = 1080
    )
    
    e2ep_plot_ts(model, results = results)
    dev.off()
    
    NULL
  }
)

## -- Multiplier of 2 did the trick -- ##
model <- e2ep_read("Barents_Sea",
                   "2011-2019-CNRM-SSP370")
results <- e2ep_run(model = model,nyears = 50)

e2ep_plot_ts(model = model,results = results)
e2ep_compare_obs(model = model,results = results)
