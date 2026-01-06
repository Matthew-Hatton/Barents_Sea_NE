## Maritime mammals were a little high, so apply maxuptake and ddmort multipliers to try and bring
## the biomass a little more in line with that of BS NM.

rm(list = ls()) # reset

library(StrathE2EPolar)
library(furrr)
library(stringr)

plan(multisession,workers = availableCores()-2)

mults <- seq(0, 3, 0.05)

# Create index with padded numbers (01, 02, 03...)
idx <- str_pad(seq_along(mults), width = 2, pad = "0")

run_with_mult <- function(mult, id) {
  
  message("Running multiplier ", mult, " (ID ", id, ")")
  
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Apply multiplier
  model[["data"]][["fitted.parameters"]][["u_bear"]] <-
    model[["data"]][["fitted.parameters"]][["u_bear"]] * mult
  
  results <- e2ep_run(model = model, nyears = 50)
  
  # --- Timeseries plot ---
  jpeg(
    paste0("./Figures/optimisation/Fixing/Maritime Mammal/MaxUptake/ts/",
           id, ".TS.MaxUp.", mult, ".jpeg"),
    units = "px", width = 1920, height = 1080
  )
  e2ep_plot_ts(model, results = results)
  dev.off()
  
  # --- Observation plot ---
  jpeg(
    paste0("./Figures/optimisation/Fixing/Maritime Mammal/MaxUptake/obs/",
           id, ".Obs.MaxUp.", mult, ".png"),
    units = "px", width = 1920, height = 1080
  )
  e2ep_compare_obs(model, results = results)
  dev.off()
  
  return(list(mult = mult, id = id))
}

future_map2(mults, idx, run_with_mult)