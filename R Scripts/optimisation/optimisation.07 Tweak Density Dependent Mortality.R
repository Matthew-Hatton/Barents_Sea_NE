## Script to test scalars on density dependent mortality
rm(list = ls()) # reset

library(tidyverse)
library(StrathE2EPolar)
library(furrr)
library(purrr)
library(patchwork)

plan(multisession,workers = availableCores() - 1)

parallel_ddmort <- function(Guild, mult, nyears) {
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Apply multiplier based on guild
  if (Guild == "PLANKTIV") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- 1.5 #pfish in first position
    model[["data"]][["fitted.parameters"]][["xxpfish"]] <- model[["data"]][["fitted.parameters"]][["xxpfish"]] * mult #pfish in first position
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Plank.fish_landings_live_weight",
                                "Plank.fish_discards")) %>% 
      mutate(Multiplier = mult,
             Model = "NE")
    
  } else if (Guild == "DEMERSAL") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][2] <- 2.5 #dfish in second position
    model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxdfish"]] * mult #dfish in second position
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Dem.fish_landings_live_weight",
                                "Dem.fish_discards")) %>% 
      mutate(Multiplier = mult,
             Model = "NE")
  }
  
  return(catch)
}


res_pfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_ddmort(Guild = "PLANKTIV", mult = .x, nyears = 50)
)

res_dfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_ddmort(Guild = "DEMERSAL", mult = .x, nyears = 50)
)

res_all_pfish <- bind_rows(res_pfish)
res_all_dfish <- bind_rows(res_dfish)

model_NM <- e2ep_read("Barents_Sea","2011-2019")
results_NM <- e2ep_run(model = model_NM,nyears = 1)

pfish <- res_all_pfish %>% 
  filter(Description == "Plank.fish_landings_live_weight") %>% 
  mutate(Difference = results_NM[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
           filter(Description == "Plank.fish_landings_live_weight") %>% .$Model_annual_flux - Model_annual_flux)

ggplot() +
  geom_line(data = pfish,aes(x = Multiplier,y = Difference)) +
  geom_vline(xintercept = 0.7) +
  labs(title = "Planktivorous fish (HR: 1.5)",x = "DDmort multiplier",caption = "Multipliers applied to Density Dependent Mortality rates for Planktivorous fish.") +
  NULL

dfish <- res_all_dfish %>% 
  filter(Description == "Dem.fish_landings_live_weight") %>% 
  mutate(Difference = results_NM[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
           filter(Description == "Dem.fish_landings_live_weight") %>% .$Model_annual_flux - Model_annual_flux)

ggplot() +
  geom_line(data = dfish,aes(x = Multiplier,y = Difference)) +
  geom_vline(xintercept = 1.3) +
  labs(title = "Demersal fish (2.5x)",x = "DDmort multiplier",caption = "Multipliers applied to Density Dependent Mortality rates for Demersal fish.") +
  NULL
