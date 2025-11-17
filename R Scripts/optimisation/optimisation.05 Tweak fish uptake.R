## Change fish uptake rate to drive down consumption of omnivorous zooplankton

rm(list = ls())

library(StrathE2EPolar)
library(dplyr)
library(ggplot2)
library(furrr)
library(purrr)

model <- e2ep_read("Barents_Sea",
                   "2011-2019-CNRM-SSP370")

# start by decreasing all fish and larvae by a quarter to see what happens
model[["data"]][["fitted.parameters"]][["u_fishd"]] <- model[["data"]][["fitted.parameters"]][["u_fishd"]] * 0.9
model[["data"]][["fitted.parameters"]][["u_fishd"]] <- model[["data"]][["fitted.parameters"]][["u_fishp"]] * 0.9
model[["data"]][["fitted.parameters"]][["u_fishd"]] <- model[["data"]][["fitted.parameters"]][["u_fishdlar"]] * 0.9
model[["data"]][["fitted.parameters"]][["u_fishd"]] <- model[["data"]][["fitted.parameters"]][["u_fishplar"]] * 0.9

# run and compare to NM BS
results <- e2ep_run(model = model,
                    nyears = 50)


df <- data.frame(Description = results_NM[["final.year.outputs"]][["opt_results"]]$Description,
                 NM_chi = results_NM[["final.year.outputs"]][["opt_results"]]$Chi,
                 NE_chi = results[["final.year.outputs"]][["opt_results"]]$Chi,
                 chi_ratio = results[["final.year.outputs"]][["opt_results"]]$Chi/results_NM[["final.year.outputs"]][["opt_results"]]$Chi,
                 modelDiff_NE = results[["final.year.outputs"]][["opt_results"]]$Annual_measure - results[["final.year.outputs"]][["opt_results"]]$Model_data,
                 modelDiff_NM = results_NM[["final.year.outputs"]][["opt_results"]]$Annual_measure - results_NM[["final.year.outputs"]][["opt_results"]]$Model_data) %>% 
  arrange(desc(chi_ratio)) %>% 
  mutate(modelDiff = modelDiff_NE - modelDiff_NM)

## -- Notes -- ##
# - start - #
# top 6:
# 1                       Annual_water_and_sediment_denitrification
# 2       Annual_average_nitrate_conc_in_porewater_of_mud_gs_0.12mm
# 3 Annual_consumption_of_omniv_zooplankton_by_fish_and_fish_larvae
# 4                  Annual net primary production by phytoplankton
# 5               Proportion_omni_and_carn_zoo_in_diet_of_cetaceans
# 6                       Annual_net_production_of_maritime_mammals

# Model data off by ~ 12

# Lower by 25% (*0.75)

# - Experiment 1 - #
# decreasing the uptake rate by 25% did lower that chi value, however it has thrown everything out of whack
# Big increases in chi ratios,
# top 6 are now:
# 1                     Annual_consumption_of_benthos_by_fish
# 2                 Annual_water_and_sediment_denitrification
# 3 Annual_average_nitrate_conc_in_porewater_of_mud_gs_0.12mm
# 4                  Annual_gross_PB_ratio_planktivorous_fish
# 5                     Annual_demersal_fish_gross_production
# 6            Annual net primary production by phytoplankton

# Model data off by ~ 5

# Now, lower by 10% instead (*0.9)

# - Experiment 2 - #
# Don't think it's enough
# Top 6:
# 1                     Annual_consumption_of_benthos_by_fish
# 2                 Annual_water_and_sediment_denitrification
# 3 Annual_average_nitrate_conc_in_porewater_of_mud_gs_0.12mm
# 4                  Annual_gross_PB_ratio_planktivorous_fish
# 5            Annual net primary production by phytoplankton
# 6             Proportion_demersal_fish_in_diet_of_pinnipeds

# Model data off by ~ 15 - chi ratio has come down though

#####################
uptake_mult <- seq(0.7, 1.5, 0.05)

monitored <- c(
  "Annual_gross_PB_ratio_larvae_of_demersal_fish",
  "Annual_gross_PB_ratio_demersal_fish",
  "Annual_gross_PB_ratio_larvae_of_planktivorous_fish",
  "Annual_gross_PB_ratio_planktivorous_fish",
  "Annual_consumption_of_omniv_zooplankton_by_carn_zooplankton",
  "Annual_carn/scan_benthos_gross_production",
  "Annual_demersal_fish_gross_production",
  "Annual_consumption_of_benthos_by_fish",
  "Annual_consumption_of_demersal_fish_by_fish",
  "Annual net primary production by phytoplankton",
  "Annual_net_production_of_maritime_mammals",
  "Proportion_demersal_fish_in_diet_of_pinnipeds",
  "Annual_consumption_of_omniv_zooplankton_by_fish_and_fish_larvae",
  "Annual_planktivorous_fish_gross_production",
  "Proportion_demersal_fish_in_diet_of_birds",
  "Proportion_demersal_fish_in_diet_of_pinnipeds",
  "Proportion_demersal_fish_in_diet_of_cetaceans",
  "Proportion_omni_and_carn_zoo_in_diet_of_cetaceans"
)

# Run baseline once
model_NM <- e2ep_read("Barents_Sea", "2011-2019")
results_NM <- e2ep_run(model_NM, nyears = 1)

# chi_NM <- results_NM[["final.year.outputs"]][["opt_results"]] %>%
#   filter(Description %in% monitored)
chi_NM <- results_NM[["final.year.outputs"]][["opt_results"]]

plan(multisession,workers = availableCores() - 2)

parallel_results <- future_map(uptake_mult, function(i) {
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Modify uptake parameters
  # model[["data"]][["fitted.parameters"]][["u_fishd"]]   <- model[["data"]][["fitted.parameters"]][["u_fishd"]]   * i
  model[["data"]][["fitted.parameters"]][["u_fishp"]]   <- model[["data"]][["fitted.parameters"]][["u_fishp"]]   * i
  # model[["data"]][["fitted.parameters"]][["u_fishdlar"]] <- model[["data"]][["fitted.parameters"]][["u_fishdlar"]] * i
  model[["data"]][["fitted.parameters"]][["u_fishplar"]] <- model[["data"]][["fitted.parameters"]][["u_fishplar"]] * i
  # model[["data"]][["fitted.parameters"]][["u_phyt"]] <- 2.4##
  
  # Run model
  results <- e2ep_run(model = model, nyears = 50)
  NE_chi <- results[["final.year.outputs"]][["opt_results"]]
  
  # png(filename=paste0("./Figures/Optimisation/Fixing/",match(i,uptake_mult),". Pfish Mult ",i,".png"))
  # e2ep_plot_ts(model = model,
  #              results = results)
  # dev.off()
  
  # Chi results
  chi_df <- NE_chi %>%
    select(Name = Description, Value = Chi, Model_data) %>%
    #filter(Name %in% monitored) %>%
    mutate(Multiplier = i,
           BS_value = chi_NM$Chi,
           BS_Model = chi_NM$Model_data)
  
  return(chi_df)
})

chi_master <- bind_rows(parallel_results) %>% 
  filter(Name %in% monitored)

ggplot(chi_master) +
  geom_line(aes(x = Multiplier, y = Value, color = "NE BS")) +
  geom_line(aes(x = Multiplier, y = BS_value, color = "NM BS")) +
  facet_wrap(~ Name, scales = "free_y") +
  theme_minimal() +
  labs(y = "Chi", x = "Fish Uptake Multiplier", color = "",
       caption = "Uptake rates scaled are Demersal fish, Planktivorous fish, and their larvae.") +
  theme(strip.text = element_text(size = 4)) +
  NULL
ggsave("./Figures/optimisation/Fixing/MaxUptake.01 Chi Values.png")

ggplot(chi_master) +
  geom_line(aes(x = Multiplier, y = Model_data, color = "NE BS")) +
  geom_line(aes(x = Multiplier, y = BS_Model, color = "NM BS")) +
  facet_wrap(~ Name, scales = "free_y") +
  theme_minimal() +
  labs(y = "Model Value", x = "Fish Uptake Multiplier", color = "",
       caption = "Uptake rates scaled are Demersal fish, Planktivorous fish, and their larvae.") +
  theme(strip.text = element_text(size = 4)) +
  NULL
ggsave("./Figures/optimisation/Fixing/MaxUptake.02 Model Values.png")

## Let's alter by * 0.95
saveRDS(chi_master, "./Objects/Optimisation/MaximumUptakeScaled_fish.rds")

## where does BS NM TS lie?
e2ep_plot_ts(model = model_NM,results = results_NM)

## seems to match
model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
model[["data"]][["fitted.parameters"]][["u_fishp"]] <- model[["data"]][["fitted.parameters"]][["u_fishp"]] * 1.5 # increase by *1.5
model[["data"]][["fitted.parameters"]][["u_fishplar"]] <- model[["data"]][["fitted.parameters"]][["u_fishplar"]] * 1.5
results <- e2ep_run(model = model,nyears = 50)
init_con <- e2ep_extract_start(model = model,results = results)
model[["data"]][["initial.state"]][1:nrow(init_con)] <- e2ep_extract_start(model = model,results = results,
                                                                           csv.output = F)[,1]
results <- e2ep_run(model = model,nyears = 1)
png(filename=paste0("./Figures/Optimisation/Fixing/NE.FinalYearTS.png"),width = 15.85,height = 15.85,units = "cm",res = 150)
e2ep_plot_ts(model = model,
             results = results)
dev.off()

png(filename=paste0("./Figures/Optimisation/Fixing/NM.FinalYearTS.png"),width = 15.85,height = 15.85,units = "cm",res = 150)
e2ep_plot_ts(model = model_NM,
             results = results_NM)
dev.off()

