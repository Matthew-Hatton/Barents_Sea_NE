# Script to plot the effects of scaling phytoplankton maximum uptake rate

rm(list = ls()) # reset

library(tidyverse)
library(StrathE2EPolar)

# Read in Chi
chi_NE <- readRDS("./Objects/Optimisation/MaximumUptakeScaled2.RDS")
# Take phytoplankton
phyt_NE <- chi_NE %>% 
  filter(Description == "Annual net primary production by phytoplankton")

# Get BS NM chi
model <- e2ep_read("Barents_Sea",
                   "2011-2019")
results <- e2ep_run(model = model,nyears = 1)
chi_NM <- results[["final.year.outputs"]][["opt_results"]]
phyt_NM <- chi_NM[["Model_data"]][1]

percentage_decrease <- seq(0.6, 1.2, 0.01)

ggplot() +
  geom_line(data = phyt_NE,aes(x = scalar,y = Model_data)) +
  geom_hline(yintercept = phyt_NM,linetype = "dashed") +
  geom_vline(xintercept = 0.97,alpha = 0.6) +
  scale_x_continuous(labels = percentage_decrease,
                     breaks = percentage_decrease)



# # intersects at ~0.965, so change that in the model
# model <- e2ep_read("Barents_Sea",
#                    "2011-2019-CNRM-SSP370")
# # Scale max uptake rate
# model[["data"]][["fitted.parameters"]][["u_phyt"]] <- model[["data"]][["fitted.parameters"]][["u_phyt"]] * 0.965
# 
# results <- e2ep_run(model = model,
#                     nyears = 50)
