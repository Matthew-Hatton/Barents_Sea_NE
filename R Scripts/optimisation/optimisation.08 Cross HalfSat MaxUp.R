rm(list = ls()) # reset

library(tidyverse)
library(StrathE2EPolar)
library(furrr)
library(purrr)
library(patchwork)

source("./R Scripts/optimisation/parallel_y_curve.R")

plan(multisession,workers = availableCores() - 1)

## -- Part 1: Checks -- ##
# let's check that a change in the half saturation coefficients and the maximum uptake rates actually make a difference
# to the yield curves

# mort_mults <- seq(0,2,0.1)
# # read BS NM values
# res_all_NM_dfish <- readRDS("./Objects/Optimisation/DFISH_BS_NM_yield.rds")
# res_all_NM_pfish <- readRDS("./Objects/Optimisation/PFISH_BS_NM_yield.rds")
# 
# idx <- 1   # counter for plot numbering
# for (i in seq(0.25, 3, 0.25)) {
#   
#   message(i)
#   
#   res_pfish <- future_map(
#     .x = seq(0, 3, 0.1),
#     .f = ~ parallel_y_curve(
#       Guild = "PLANKTIV", 
#       mult = .x, 
#       nyears = 50,
#       ddmort_mult = 1,
#       HRscale = 1,
#       hsat_mult = i,
#       maxup_mult = i
#     )
#   )
#   
#   pfish <- bind_rows(res_pfish) %>% 
#     rbind(res_all_NM_pfish)
#   
#   p1 <- ggplot() +
#     geom_line(
#       data = pfish %>% filter(Description == "Plank.fish_landings_live_weight"),
#       aes(x = Multiplier, y = Model_annual_flux, linetype = Model)
#     ) +
#     scale_x_continuous(breaks = c(seq(0, 3, 1), 0.33, 1)) +
#     scale_y_continuous(
#       breaks = c(seq(0, 0.2, 0.05)),
#       labels = c(seq(0, 0.2, 0.05)),
#       limits = c(0, 0.2)
#     ) +
#     labs(
#       title = "Planktivorous fish",
#       y = "Catch",
#       caption = paste0(
#         "Planktivorous fish DDMort: 1x, HR Scale: 1x, ",
#         "Max Uptake Rate: ", i, "x, HSat: ", i, "x"
#       )
#     )
#   
#   filename <- paste0(
#     "./Figures/optimisation/Fixing/After fitting fishing/Hsat MaxUp/",idx,". PFish_",i,"x_hsat_maxup.png"
#   )
#   
#   ggsave(plot = p1, filename = filename, width = 7, height = 5, dpi = 300)
#   
#   idx <- idx + 1 # for file naming
# }

## -- Part 2 -- ##
# Now we will call the paralel y curve function with combinations from the gridded dataframe
gridded <- expand.grid(
  hsat_mult  = seq(0.25, 6, 0.25),
  maxup_mult = seq(0.25, 6, 0.25),
  HRmult    = seq(0, 10, 0.1)
)

results <- future_pmap_dfr(
  gridded,
  .f = function(hsat_mult, maxup_mult, HRmult) {
    parallel_y_curve(
      Guild      = "PLANKTIV",
      mult       = HRmult,
      nyears     = 50,
      ddmort_mult = 1,
      hsat_mult   = hsat_mult,
      maxup_mult  = maxup_mult,
      HRscale     = 1
    )
  }
,.progress = T)

saveRDS(results,"./Objects/Optimisation/YieldCurve_hsat_maxup.RDS")

## take point before max and take point after max and then calc diffs from max to see if there is a sign change.
## That will tell us if we have gone over the peek