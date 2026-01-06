rm(list = ls())
library(StrathE2EPolar)
library(furrr)
source("./R Scripts/optimisation/parallel_y_curve.R")
plan(multisession,workers = availableCores()-2)

# model_NE <- e2ep_read("Barents_Sea","2011-2019-CNRM-ssp370")
# results_NE <- e2ep_run(model = model_NE,nyears = 50)

# e2ep_plot_ts(model = model_NE,results = results_NE)

res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds")
idx <- 1   # counter for plot numbering
for (i in seq(0.105,0.11,0.0005)) {
  message(paste0("Multiplier: ",i))
  hr_mult <- seq(0,6,0.25)
  results <- future_map(
    .x = seq(0,6,0.25),
    .f = ~ parallel_y_curve(
      Guild      = "PLANKTIV",
      mult       = .x,
      nyears     = 50,
      ddmort_mult = i,
      hsat_mult   = 1,
      maxup_mult  = 1,
      HRscale     = 1
    )
    ,.progress = T)

  pfish <- bind_rows(results) %>%
    subset(select = -c(HalfSatMult,MaxUpMult)) %>% 
    rbind(res_all_NM_pfish)
  
  ggplot() +
    geom_line(data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
              aes(x = Multiplier, y = Model_annual_flux, linetype = Model)) +
    labs(caption = paste0("DDmort Mult: ",i))
  
  ggsave(paste0("./Figures/optimisation/Fixing/Final/Third Iteration/",idx,". DDmort Mults.png"))
  idx <- idx + 1 # for file naming
}



model_NM <- e2ep_read("Barents_Sea","2011-2019")
results_NM <- e2ep_run(model = model_NM,nyears = 1)

NM <- e2ep_extract_hr(model = model_NM,results = results_NM)
NE <- e2ep_extract_hr(model = model_NE,results = results_NE)

NM$Whole_domain_harvest_ratio[1] * 360
NE$Whole_domain_harvest_ratio[1] * 360

NM$Whole_domain_harvest_ratio[1] * 360 - NE$Whole_domain_harvest_ratio[1] * 360
