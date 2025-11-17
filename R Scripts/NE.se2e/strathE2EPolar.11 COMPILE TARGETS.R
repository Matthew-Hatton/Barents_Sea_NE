rm(list = ls()) # reset
message("Compiling Targets")

library(MiMeMo.tools) # everything we need

source("./R Scripts/regionFileWG.R")

# read template
targets <- read.csv("./Objects/target/annual_observed_WG_2011-2019.csv")

fishing <- readRDS("./Objects/fishing/Target/Landings_by_guild.RDS")

## LONG WAY, BUT SAFER ##

targets <- targets %>%
  mutate(
    Annual_measure = case_when(
      Name == "Obs_Pland_livewt" ~ fishing %>% filter(Guild == "Planktivore") %>% pull(Landings),
      Name == "Obs_Dland_livewt" ~ fishing %>% filter(Guild == "Demersal") %>% pull(Landings),
      Name == "Obs_Mland_livewt" ~ fishing %>% filter(Guild == "Migratory") %>% pull(Landings),
      Name == "Obs_Bsland_livewt" ~ fishing %>% filter(Guild == "Benthos filter/deposit feeder") %>% pull(Landings),
      Name == "Obs_Bcland_livewt" ~ fishing %>% filter(Guild == "Benthos carnivore/scavenge feeder") %>% pull(Landings),
      Name == "Obs_Zcland_livewt" ~ fishing %>% filter(Guild == "Zooplankton carnivore") %>% pull(Landings),
      Name == "Obs_Slland_livewt" ~ fishing %>% filter(Guild == "Pinnipeds") %>% pull(Landings),
      Name == "Obs_Ctland_livewt" ~ fishing %>% filter(Guild == "Cetacean") %>% pull(Landings),
      TRUE ~ Annual_measure
    )
  )
targets[68,3] <- 0 # switch for Demersal fish discards
targets[87,3] <- 0 # switch for Obs_AMJJAS_offshore_ice_alg
targets[88,3] <- 0 # switch for Obs_AMJJAS_inshore_ice_alg

## calculate SD as 75% of target value
target_new <- targets %>%
  mutate(SD_of_measure = Annual_measure * 0.75)

## input primary production
pp <- read.csv("./Objects/target/PP_target_West_Greenland.csv")
target_new$Annual_measure[1] <- pp$Annual_measure[1]
target_new$SD_of_measure[1] <- pp$SD_of_measure[1]
target_new$Region[1] <- pp$Region
target_new$Source[1] <- pp$Source[1]
  
write.csv(target_new, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"/2011-2019/Target/annual_observed_WG_2011-2019.csv"),
          row.names = F)
write.csv(target_new, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Target/annual_observed_WG_2011-2019.csv"),
          row.names = F)
