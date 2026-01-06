library(StrathE2EPolar)
library(dplyr)
library(furrr)
library(ggplot2)
library(purrr)
source("./R Scripts/optimisation/parallel_y_curve.R")

plan(multisession,workers = availableCores())

# model <- e2ep_read("Barents_Sea","2011-2019-CNRM-SSP370")
# results_NM <- e2ep_run(model = model,nyears = 50)
# e2ep_plot_ts(model = model,results = results_NM)


# e2ep_compare_obs(model = model,results = results_NM)

ddmorts <- seq(15,50,0.05)
hr_mult <- seq(0,6,0.25)
results <- future_map(
  .x = ddmorts,
  .f = ~ parallel_y_curve(
    Guild      = "PLANKTIV",
    mult       = 1,
    nyears     = 50,
    ddmort_mult = .x,
    hsat_mult   = 1,
    maxup_mult  = 1,
    HRscale     = 1
  )
  ,.progress = T)

res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds") %>% 
  filter(Multiplier == 1) %>% 
  filter(Description != "Plank.fish_discards")

pfish <- map2(results,ddmorts,function(results,ddmorts){
  df <- cbind(results,ddmorts)
  }) %>% 
  data.table::rbindlist() %>%
  subset(select = -c(HalfSatMult,MaxUpMult)) %>% 
  filter(Description != "Plank.fish_discards")

ggplot() +
  geom_point(data = pfish,aes(x = ddmorts,y = Model_annual_flux)) +
  geom_hline(yintercept = res_all_NM_pfish$Model_annual_flux) +
  # geom_smooth(data = pfish,aes(x = ddmorts,y = Model_annual_flux)) +
  NULL

results <- future_map(
  .x = seq(0,6,0.25),
  .f = ~ parallel_y_curve(
    Guild      = "PLANKTIV",
    mult       = .x,
    nyears     = 50,
    ddmort_mult = 23.5,
    hsat_mult   = 1,
    maxup_mult  = 0.9,
    HRscale     = 1.4
  )
  ,.progress = T)

res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds") %>% 
  filter(Description != "Plank.fish_discards")

pfish <- results %>% 
  bind_rows() %>% 
  subset(select = -c(HalfSatMult,MaxUpMult)) %>% 
  filter(Description != "Plank.fish_discards") %>% 
  rbind(res_all_NM_pfish)

ggplot() +
  geom_line(data = pfish,
            aes(x = Multiplier, y = Model_annual_flux, linetype = Model))

## -- To get the yield curves to better match -- ##
# This causes other issues (Carn zoo dead).
results_ddmort <- future_map(
  .x = seq(0,6,0.25),
  .f = ~ parallel_y_curve(
    Guild      = "PLANKTIV",
    mult       = .x,
    nyears     = 50,
    ddmort_mult = 0.225,
    hsat_mult   = 1,
    maxup_mult  = 1,
    HRscale     = 1
  )
  ,.progress = T)

pfish_ddmort <- bind_rows(results_ddmort) %>%
  subset(select = -c(HalfSatMult,MaxUpMult)) %>% 
  rbind(res_all_NM_pfish)

ggplot() +
  geom_line(data = pfish_ddmort %>% filter(Description == "Plank.fish_landings_live_weight"),
            aes(x = Multiplier, y = Model_annual_flux, linetype = Model))