## Calculate chi ratios of new model and compare with old model
## should allow us to see what is pulling the likelihood down

rm(list = ls())

library(StrathE2EPolar)
library(tidyverse)
model <- e2ep_read("Barents_Sea",
                   "2011-2019-CNRM-SSP370")

model_NM <- e2ep_read("Barents_Sea",
                      "2011-2019")
results_NM <- e2ep_run(model_NM,nyears = 1)
results <- e2ep_run(model = model,nyears = 50)

df <- data.frame(Description = results_NM[["final.year.outputs"]][["opt_results"]]$Description,
                 NM_chi = results_NM[["final.year.outputs"]][["opt_results"]]$Chi,
                 NE_chi = results[["final.year.outputs"]][["opt_results"]]$Chi,
                 chi_ratio = results[["final.year.outputs"]][["opt_results"]]$Chi/results_NM[["final.year.outputs"]][["opt_results"]]$Chi,
                 modelDiff_NE = results[["final.year.outputs"]][["opt_results"]]$Annual_measure - results[["final.year.outputs"]][["opt_results"]]$Model_data,
                 modelDiff_NM = results_NM[["final.year.outputs"]][["opt_results"]]$Annual_measure - results_NM[["final.year.outputs"]][["opt_results"]]$Model_data) %>% 
  arrange(desc(chi_ratio))

#68.1

#chi ratio of 6.713544e+02