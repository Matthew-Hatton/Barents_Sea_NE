rm(list = ls()) # reset

library(tidyverse)
library(furrr)
library(StrathE2EPolar)
source("./R Scripts/optimisation/parallel_y_curve.R")

plan(multisession,workers = availableCores()-2)

grid <- readRDS("./Objects/Optimisation/YieldCurve_hsat_maxup.RDS") # bind with multipliers 3-10

BS_maxYield <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds") %>% 
  slice_max(order_by = Model_annual_flux)

filtered <- grid %>%
  group_by(Description,HalfSatMult,MaxUpMult) %>%
  slice_max(order_by = Model_annual_flux) %>% 
  mutate(Fmsy_msy = 1/Multiplier) %>% 
  mutate(Fmsy_msy_diff = Fmsy_msy - BS_maxYield$Multiplier) %>% 
  filter(between(abs(Fmsy_msy_diff),0,1)) %>% 
  ungroup() %>% 
  slice_min(order_by = abs(Fmsy_msy_diff), n = 1)  # pick closest to 0

## -- check if curves were resolved -- ##
landings_resolved <- grid %>%
  filter(Description == "Plank.fish_landings_live_weight") %>%
  group_by(HalfSatMult, MaxUpMult) %>%
  arrange(Multiplier, .by_group = TRUE) %>%
  
  # Add previous and next flux for ALL rows before finding the peak
  mutate(
    flux_before = lag(Model_annual_flux),
    flux_after  = lead(Model_annual_flux)
  ) %>%
  
  # Identify peak
  mutate(peak_flux = max(Model_annual_flux, na.rm = TRUE),
         is_peak   = Model_annual_flux == peak_flux) %>%
  filter(is_peak) %>%
  slice(1) %>%   # choose first peak if ties
  
  mutate(
    diff_before = Model_annual_flux - flux_before,
    diff_after  = flux_after - Model_annual_flux,
    
    resolved = case_when(
      is.na(flux_after) ~ FALSE,                 # peak at LAST multiplier
      diff_before > 0 & diff_after < 0 ~ TRUE,   # proper local max
      TRUE ~ FALSE
    )
  ) %>%
  ungroup() %>%
  select(
    HalfSatMult, MaxUpMult, Multiplier, Model_annual_flux,
    diff_before, diff_after, resolved
  ) %>% 
  mutate(Fmsy_msy = 1/Multiplier) %>% 
  mutate(Fmsy_msy_diff = Fmsy_msy - 1/(BS_maxYield$Multiplier))

landings_true <- landings_resolved %>% 
  filter(resolved == T) %>% 
  arrange(abs(Fmsy_msy_diff)) %>% 
  subset(select = -c(diff_before,diff_after))

ggplot() +
  geom_raster(data = landings_true,aes(x = HalfSatMult,y = MaxUpMult,fill = log(abs(Fmsy_msy_diff))))

## -- First instance -- ##
# - none resolved. I guess we must increase the HR multipliers! - #
## -- Second instance -- ##
# - Some have resolved. - #

## -- Check yield curve -- ##
hr_mult <- seq(0,6,0.25)
results <- future_map(
  .x = seq(0,6,0.25),
  .f = ~ parallel_y_curve(
      Guild      = "PLANKTIV",
      mult       = .x,
      nyears     = 50,
      ddmort_mult = 50,
      hsat_mult   = 5.5,
      maxup_mult  = 2.25,
      HRscale     = 1
    )
  ,.progress = T)

res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds")
pfish <- bind_rows(results) %>%
  subset(select = -c(HalfSatMult,MaxUpMult)) %>% 
  rbind(res_all_NM_pfish)
  
ggplot() +
  geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
            aes(x = Multiplier, y = Model_annual_flux, linetype = Model))
