## Overwrite example driving data (boundaries and physics)

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)

source("./regionFile.R")

Physics_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Driving/physics_BS_2011-2019-CNRM-SSP370.csv") # Read in example Physical drivers

#### Last minute data manipulation ####

My_scale <- readRDS("./Objects/domain/Domains.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = c(T, T),
         D = c(F, T)) %>% 
  gather(key = "slab_layer", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = c(Elevation[1], -60, Elevation[3] + 60)) %>% 
  mutate(Volume = area * abs(Elevation)) %>% 
  dplyr::select(Shore, slab_layer, Volume)

My_light <- readRDS("./Objects/physics/light.rds") %>% 
  filter(Forcing == forcing & SSP == paste0("ssp",ssp) & between(Year,start_year,end_year)) %>%               # Limit to reference period and variable
  group_by(Month,SSP,Forcing) %>%                                                       # Average across months
  summarise(Measured = mean(Light, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                            # Order to match template

# Uses temperature at ice surface
My_AirTemp <- readRDS(paste0("./Objects/physics/",forcing,".ssp",ssp,".Ice.and.Air.Summary.rds")) %>%
  filter(between(Year, start_year, end_year)) %>%                 # Limit to reference period and variable
  subset(select = c(Month,Shore,Air_Temperature)) %>% 
  group_by(Month, Shore) %>%                                                # Average across months
  summarise(Measured = mean(Air_Temperature, na.rm = T)) %>%
  ungroup() %>%
  arrange(Month)                                                            # Order to match template

My_H_Flows <- readRDS("./Objects/physics/H-Flows.rds") %>% 
  filter(between(Year, start_year, end_year), Forcing == forcing, SSP == paste0("ssp",ssp)) %>%             # Limit to outputs from a specific run and time
  group_by(across(-c(Year, Forcing, SSP,Flow))) %>%                                      # Group over everything except year, run, and variable of interest
  summarise(Flow = mean(Flow, na.rm = T)) %>%                               # Average flows by month over years
  ungroup() %>% 
  group_by(Shore, slab_layer, Neighbour) %>%                                # Add in missing months
  complete(Month, Direction, fill = list(Flow = 0)) %>%                     # By making sure all months are represented in both directions
  ungroup() %>% 
  left_join(My_scale) %>%                                                   # Attach compartment volumes
  mutate(Flow = Flow/Volume) %>%                                            # Scale flows by compartment volume
  mutate(Flow = abs(Flow * 86400)) %>%                                      # Multiply for total daily from per second, and correct sign for "out" flows
  arrange(Month)
  
My_V_Flows <- readRDS("./Objects/physics/vertical diffusivity.rds") %>%
  filter(between(Year, start_year, end_year) & SSP %in% c("hist",paste0("ssp",ssp)) & Forcing == forcing) %>%                                     # Limit to reference period
  group_by(Month) %>% 
  summarise(V_diff = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

My_volumes <- readRDS(paste0("./Objects/physics/",forcing,".",paste0("ssp",ssp),".TS.rds")) %>% 
  filter(between(Year, start_year, end_year)) %>%                                     # Limit to reference period
  group_by(Compartment, Month) %>%                                          # By compartment and month
  summarise(across(c(Diatoms_avg,Other_phytoplankton_avg,Detritus_avg,Temperature_avg), mean, na.rm = T)) %>%         # Average across years for multiple columns
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

# My_SPM <- readRDS("./Objects/physics/Suspended particulate matter.rds") %>%
#   filter(between(Year, start_year, end_year)) %>%                                     # Limit to reference period
#   group_by(Shore, Month) %>%
#   summarise(SPM = mean(SPM, na.rm = T)) %>%                                 # Average by month across years
#   ungroup() %>%
#   arrange(Month)                                                            # Order by month to match template

My_Rivers <- readRDS("./Objects/physics/NE River input.rds") %>%
  filter(between(Year, start_year, end_year)) %>%                                     # Limit to reference period
  mutate(Month = month(Date)) %>% 
  group_by(Month) %>%
  summarise(Runoff = mean(Runoff, na.rm = T)) %>%                           # Average by month across years
  ungroup() %>%
  arrange(as.numeric(Month))                                                # Order by month to match template

#### Ice ####
My_ice <- readRDS(paste0("./Objects/physics/",forcing,".",paste0("ssp",ssp),".Ice.and.Air.Summary.rds")) %>% 
  filter(Shore %in% c("Inshore","Offshore")) %>%  # Remove Buffer Zone
  filter(between(Year, start_year, end_year)) %>%  # Filter down to just the target year
  group_by(Month,Shore) %>% 
  summarise(Ice_Pres = mean(Ice_pres),
            Snow_Thickness = mean(Snow_Thickness),
            Ice_Thickness = mean(Ice_Thickness),
            Ice_Conc = mean(Ice_conc))
#### Create new file ####
Physics_new <- mutate(Physics_template,
                      SLight = My_light$Measured,
                      ## Flows, should be proportions of volume per day
                      SO_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      D_OceanIN = filter(My_H_Flows, slab_layer == "D", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      SI_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      SI_OceanOUT = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "Out")$Flow,
                      SO_SI_flow = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Inshore", Direction == "Out")$Flow,
                      Upwelling = 0, # Nominal value   
                      ## log e transformed suspended particulate matter concentration in zones
                      # SO_LogeSPM = log(filter(My_SPM, Shore == "Offshore")$SPM),
                      # SI_LogeSPM = log(filter(My_SPM, Shore == "Inshore")$SPM),
                      ## Temperatures in volumes for each zone
                      SO_temp = filter(My_volumes, Compartment == "Offshore S")$Temperature_avg,
                      D_temp = filter(My_volumes, Compartment == "Offshore D")$Temperature_avg,
                      SI_temp = filter(My_volumes, Compartment == "Inshore S")$Temperature_avg,
                      ## River inflow,
                      Rivervol_SI = My_Rivers$Runoff / filter(My_scale, Shore == "Inshore")$Volume, # Scale as proportion of inshore volume
                      ## Vertical diffusivity
                      log10Kvert = log10(My_V_Flows$V_diff),
                      # mixLscale = mixLscale, # Length scale over which vertical diffusion acts, nominal
                      # mixLscale = Physics_template$mixLscale, # Length scale over which vertical diffusion acts, nominal
                      ## Daily proportion disturbed by natural bed shear stress
                      # habS1_pdist = My_stress$habS1_pdist,
                      # habS2_pdist = My_stress$habS2_pdist,
                      # habS3_pdist = My_stress$habS3_pdist,
                      # habD1_pdist = My_stress$habD1_pdist,
                      # habD2_pdist = My_stress$habD2_pdist,
                      # habD3_pdist = My_stress$habD3_pdist,
                      ## Monthly mean significant wave height inshore                     
                      # Inshore_waveheight = My_Waves$mean_height,
                      ## cryo variables
                      SO_IceFree = 1 - filter(My_ice, Shore == "Offshore")$Ice_Pres,
                      SI_IceFree = 1 - filter(My_ice, Shore == "Inshore")$Ice_Pres,
                      SO_IceCover = filter(My_ice, Shore == "Offshore")$Ice_Conc,
                      SI_IceCover = filter(My_ice, Shore == "Inshore")$Ice_Conc,
                      SO_IceThickness = filter(My_ice, Shore == "Offshore")$Ice_Thickness,
                      SI_IceThickness = filter(My_ice, Shore == "Inshore")$Ice_Thickness,
                      SO_SnowThickness = filter(My_ice, Shore == "Offshore")$Snow_Thickness,
                      SI_SnowThickness = filter(My_ice, Shore == "Inshore")$Snow_Thickness,
                      SO_AirTemp = filter(My_AirTemp, Shore == "Offshore")$Measured,
                      SI_AirTemp = filter(My_AirTemp, Shore == "Inshore")$Measured
                      )

write.csv(Physics_new, file = paste0(paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/",start_year,"-",end_year,"-",forcing,"-SSP",ssp,"/Driving/physics_BS_",start_year,"-",end_year,"-",forcing,"-SSP",ssp,".csv")),
                                     row.names = F)
