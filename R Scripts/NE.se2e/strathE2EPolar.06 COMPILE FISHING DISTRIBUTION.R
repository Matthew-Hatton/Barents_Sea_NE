#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

# File is already created elsewhere so just copy it into the correct directory

dist <- read.csv("./Objects/fishing/Distribution/fishing_distribution_WG_2011-2019.csv") %>% 
  subset(select = -c(X)) # clean saving mistake

dist$Gear_name[dist$Gear_name == "Recreational"] <- "Subsistence" #change recreational to subsistence
dist$Gear_code[dist$Gear_code == "Rec"] <- "Sub"                  #and the code

write.csv(dist, file = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_distribution_WG_2011-2019.csv"),
          row.names = F)
