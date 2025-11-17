## Input values for the Physical Parameter Parametrisation file

#### Setup ####
rm(list=ls())                                                                               # Wipe the brain
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

#Read in example physical parameters file
Physical_parameters <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Param/physical_parameters_BS.csv")
Domains <- readRDS("./Objects/domain/domainWG.RDS") %>%  #read domain file
  st_transform(crs = crs)

#### Layer Thickness ####
My_space <- readRDS("./Objects/domain/domainWG.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = T,
         D = case_when(Shore == "Inshore" ~ F,
                       Shore == "Offshore" ~ T)) %>% 
  gather(key = "Depth", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = case_when(Shore == "Inshore" ~ Elevation,
                               Shore == "Offshore" & Depth == "D" ~ Elevation + s_depth,
                               Shore == "Offshore" & Depth == "S" ~ -s_depth,)) %>% 
  mutate(Volume = area * abs(Elevation))

Physical_parameters[1,"Value"] <- filter(My_space, Shore == "Offshore", Depth == "S")$Elevation * -1 # Offshore_Shallow_layer_thickness_(m)
Physical_parameters[3,"Value"] <- filter(My_space, Shore == "Inshore", Depth == "S")$Elevation * -1  # Inshore_Shallow_layer_thickness_(m)

#### Sediment ####
# Read in Sediment Proportions
in_sed_prop <- readRDS("./Objects/physical/sediment proportions.RDS") %>% 
  filter(Zone == "Inshore") %>% 
  mutate(Name = factor(Name, levels = c("Rock", "Mud", "Sand", "Gravel"))) %>%
  arrange(Name)

off_sed_prop <- readRDS("./Objects/physical/sediment proportions.RDS") %>% 
  filter(Zone == "Offshore") %>% 
  mutate(Name = factor(Name, levels = c("Rock", "Mud", "Sand", "Gravel"))) %>%
  arrange(Name)

# Order of the parameter file won't change so can hard code in changes
Physical_parameters$Value[5:8] <- in_sed_prop$prop #Inshore
Physical_parameters$Value[9:12] <- off_sed_prop$prop #Offshore


# Physical_parameters[33,"Value"] <- 0                       # 1 to use the following porosity values, 0 calculates using the relationship above
# 
# Physical_parameters[40,"Value"] <- 0                     # 1 to use the following permeability values, 0 calculates using the relationship above
# 
# Physical_parameters[47,"Value"] <- 0                     # 1 to use the following nitrogen values, 0 calculates using the relationship above

#Remove old
fn <-  paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/physical_parameters_BS.csv")
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}
## final check
sediment <- in_sed_prop %>% rbind(.,off_sed_prop)
if (sum(sediment$prop) == 1) {
  write.csv(Physical_parameters,
            file =  paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/physical_parameters_WG.csv"),
            row.names = F)
} else{
  message("Your sediment proportions don't add up to 1! Failed to save.")
}
