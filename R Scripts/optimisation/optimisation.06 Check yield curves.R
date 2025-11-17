rm(list = ls()) # reset

library(tidyverse)
library(StrathE2EPolar)
library(furrr)
library(purrr)
library(patchwork)

plan(multisession,workers = availableCores() - 1)

parallel_y_curve <- function(Guild, mult, nyears,ddmort_mult,HRscale) {
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Apply multiplier based on guild
  if (Guild == "PLANKTIV") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- mult #pfish in first position
    model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxpfish"]] * ddmort_mult
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] * HRscale
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Plank.fish_landings_live_weight",
                                "Plank.fish_discards")) %>% 
      mutate(Multiplier = mult,
             Model = "NE")
    
  } else if (Guild == "DEMERSAL") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][2] <- mult #dfish in second position
    model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxdfish"]] * ddmort_mult
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Dem.fish_landings_live_weight",
                                "Dem.fish_discards")) %>% 
      mutate(Multiplier = mult,
             Model = "NE")
  }
  
  return(catch)
}

mort_mults <- seq(0,2,0.1)
# read BS NM values
res_all_NM_dfish <- readRDS("./Objects/Optimisation/DFISH_BS_NM_yield.rds")
res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds")

# Just yield curves
res_pfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_y_curve(Guild = "PLANKTIV", mult = .x, nyears = 50,ddmort_mult = 20,HRscale = 1.4)
)
res_dfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_y_curve(Guild = "DEMERSAL", mult = .x, nyears = 50,ddmort_mult = 1,HRscale = 1)
)

pfish <- bind_rows(res_pfish) %>% 
  rbind(res_all_NM_pfish)
dfish <- bind_rows(res_dfish) %>% 
  rbind(res_all_NM_dfish)
p1 <- ggplot() +
  geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
            aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
  labs(title = "Planktivorous fish",y = "Catch",caption = "Planktivorous fish DDMort: 20x, HR Scale: 1.4x, Max Uptake Rate: 1.5x")
p2 <- ggplot() +
  geom_line(data = dfish %>% filter(Description == "Dem.fish_landings_live_weight"),
            aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
  labs(title = "Demersal fish",y = "Catch")

p1 + p2 + plot_layout(guides = "collect")
ggsave(paste0("./Figures/optimisation/Fixing/After fitting fishing/YieldCurves.png"))

## -- DDMort multipliers -- ##
for (i in mort_mults) {
  message(paste0("Multiplier: ",i))
  # run pfish yield curve
  res_pfish <- future_map(
    .x = seq(0, 3, 0.1),
    .f = ~ parallel_y_curve(Guild = "PLANKTIV", mult = .x, nyears = 50,ddmort_mult = i)
  )
  
  # run dfish yield curve
  res_dfish <- future_map(
    .x = seq(0, 3, 0.1),
    .f = ~ parallel_y_curve(Guild = "DEMERSAL", mult = .x, nyears = 50,ddmort_mult = i)
  )
  
  pfish <- bind_rows(res_pfish) %>% 
    rbind(res_all_NM_pfish)
  dfish <- bind_rows(res_dfish) %>% 
    rbind(res_all_NM_dfish)
  
  # draw and save yield curves
  p1 <- ggplot() +
    geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
              aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
    labs(title = "Planktivorous fish",y = "Catch")
  p2 <- ggplot() +
    geom_line(data = dfish %>% filter(Description == "Dem.fish_landings_live_weight"),
              aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
    labs(title = "Demersal fish",y = "Catch",caption = paste0("DDMort Multiplier ",i))
  
  p1 + p2 + plot_layout(guides = "collect")
  ggsave(paste0("./Figures/optimisation/Fixing/After fitting fishing/YieldCurves ",i,".png"))
}


# ggplot() +
#   geom_line(data = res_all %>% filter(Description == "Plank.fish_landings_live_weight"),aes(x = Multiplier,y = Model_annual_flux))
################# DEFAULT BS ###################

# parallel_y_curve_NM <- function(Guild, mult, nyears) {
#   model <- e2ep_read("Barents_Sea", "2011-2019")
#   
#   # Apply multiplier based on guild
#   if (Guild == "PLANKTIV") {
#     model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- mult #pfish in first position
#     results <- e2ep_run(model = model, nyears = nyears)
#     
#     catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
#       filter(Description %in% c("Plank.fish_landings_live_weight",
#                                 "Plank.fish_discards")) %>% 
#       mutate(Multiplier = mult,
#              Model = "NM")
#     
#   } else if (Guild == "DEMERSAL") {
#     model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][2] <- mult #dfish in second position
#     results <- e2ep_run(model = model, nyears = nyears)
#     
#     catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
#       filter(Description %in% c("Dem.fish_landings_live_weight",
#                                 "Dem.fish_discards")) %>% 
#       mutate(Multiplier = mult,
#              Model = "NM")
#   }
#   
#   return(catch)
# }

# res_NM_pfish <- future_map(
#   .x = seq(0, 3, 0.1),
#   .f = ~ parallel_y_curve_NM(Guild = "PLANKTIV", mult = .x, nyears = 50)
# )
# 
# res_all_NM_pfish <- bind_rows(res_NM_pfish)
# 
# 
# res_NM_dfish <- future_map(
#   .x = seq(0, 3, 0.1),
#   .f = ~ parallel_y_curve_NM(Guild = "DEMERSAL", mult = .x, nyears = 50)
# )
# res_all_NM_dfish <- bind_rows(res_NM_dfish)




# decrease density dependent mortality of planktivorous fish and larvae to shift yield curve up to match Barents Sea NM

res_pfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_y_curve(Guild = "PLANKTIV", mult = .x, nyears = 50,ddmort_mult = 2)
)

# run dfish yield curve
res_dfish <- future_map(
  .x = seq(0, 3, 0.1),
  .f = ~ parallel_y_curve(Guild = "DEMERSAL", mult = .x, nyears = 50,ddmort_mult = 0.75)
)

pfish <- bind_rows(res_pfish) %>% 
  rbind(res_all_NM_pfish)
dfish <- bind_rows(res_dfish) %>% 
  rbind(res_all_NM_dfish)

# draw and save yield curves
p1 <- ggplot() +
  geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
            aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
  labs(title = "Planktivorous fish (DDMort x2)",y = "Catch")
p2 <- ggplot() +
  geom_line(data = dfish %>% filter(Description == "Dem.fish_landings_live_weight"),
            aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
  labs(title = "Demersal fish (DDMort x0.75)",y = "Catch")

p1 + p2 + plot_layout(guides = "collect")
ggsave(paste0("./Figures/optimisation/Fixing/YieldCurvesBest.png"))

## check ss
model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxpfish"]] * 2
model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxdfish"]] * 0.7

res <- e2ep_run(model = model,nyears = 50)
e2ep_plot_ts(model = model,results = res)


scale_vec <- seq(0,2,0.1)

for (i in scale_vec) {
  message(paste0("Multiplier: ",i))
  # run pfish yield curve
  res_pfish <- future_map(
    .x = seq(0, 3, 0.1),
    .f = ~ parallel_y_curve(Guild = "PLANKTIV", mult = .x, nyears = 50,ddmort_mult = 2,HRscale = i)
  )

  pfish <- bind_rows(res_pfish) %>% 
    rbind(res_all_NM_pfish)
  
  # draw and save yield curves
  p1 <- ggplot() +
    geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
              aes(x = Multiplier,y = Model_annual_flux,linetype = Model)) +
    labs(title = "Planktivorous fish",y = "Catch",caption = paste0("HR scale vector: ",i))
p1
ggsave(
  paste0(
    "./Figures/optimisation/Fixing/HRScale/",
    match(i, scale_vec),
    "_YieldCurves_HRScale_",
    i,
    ".png"
  )
)

}
