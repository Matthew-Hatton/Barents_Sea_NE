
# Summarise the data extracted from NEMO-ERSEM, dealing with deep convection issues

#### Setup ####

rm(list=ls())                                                                   # Wipe the brain

Packages <- c("tidyverse", "data.table", "furrr")                               # List packages
lapply(Packages, library, character.only = TRUE)                                # Load packages
source("./regionFile.R")

plan(multisession,workers = availableCores() - 2)

deep_convection_is <- 0.14                                                      # Threshold above which vertical diffusivity = deep convection

#### Quantify the amount of deep convection ####
## For more discussion see the appropriate entry in ./Notes
total_mixing <- list.files("./Objects/vertical boundary/", full.names = T) %>%  # Import
  future_map(readRDS) %>% 
  rbindlist() %>% 
  group_by(Month) %>%   
  filter((SSP == paste0("ssp",as.character(ssp))|SSP == "hist") & Forcing == forcing & between(Year,start_year,end_year)) %>% 
  summarise(Deep_convection_proportion = mean(Vertical_diffusivity > deep_convection_is)) # What proportion of values are deep convection?

ggplot(total_mixing) +
  geom_line(aes(x = Month, y = Deep_convection_proportion)) +
  theme_minimal() +
  ylim(0,1) +
  labs(y = "Proportion of model domain as deep convection")

#### Mean vertical diffusivity ignoring deep convection ####

normal_mixing <- list.files("./Objects/vertical boundary/", full.names = T) %>% # Import data
  future_map(readRDS) %>% 
  rbindlist() %>% 
  dplyr::select(Vertical_diffusivity, Year, Month, Forcing, SSP) %>%                   # Discard excess variables
  filter(Vertical_diffusivity < deep_convection_is) %>%                         # Remove deep convection
  group_by(Year, Month, Forcing, SSP) %>%                                       # Create a monthly time series
  summarise(Vertical_diffusivity = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup()

#### Fix missing entries ####

runs <- expand.grid(Force = c("GFDL", "CNRM"), S = c("ssp370", "ssp126"))

fix <- pmap(runs, function(Force, S){

#  Force <- "GFDL" ; S <- "ssp370"
  
  data <- filter(normal_mixing, Forcing == Force, SSP != S)                 # Limit to combinations of historical and ssps under forcings (one time series)
  
  result <- expand.grid(Year = (min(normal_mixing$Year)-1):(max(normal_mixing$Year)+1),   # Make slightly larger because the missing values are at the end of the cycle for interpolation
            Month = 1:12) %>%
  full_join(data) %>% 
  arrange(Year, Month) %>%                                                  # Order by month to allow interpolation
  mutate(Vertical_diffusivity = zoo::na.spline(Vertical_diffusivity, na.rm = FALSE)) %>%                # Interpolate by cubic spline
  slice(13:(nrow(.)-12)) %>%                                                # Retrieve the completed cycle
  arrange(Year, Month)                                                      # Order for compiler
  }) %>% 
  rbindlist() %>% 
  distinct(Year, Month,Forcing, SSP, .keep_all = TRUE)

saveRDS(fix, "./Objects/chemistry/vertical diffusivity.rds")


