## Overwrite example fishing activity data - This is just moving of a file

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

fishing_activity_path <- read.csv("./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv")

# Write it to the destination
write.csv(fishing_activity_path,paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"/2011-2019/Param/fishing_activity_WG_2011-2019.csv"),
          row.names = FALSE)
