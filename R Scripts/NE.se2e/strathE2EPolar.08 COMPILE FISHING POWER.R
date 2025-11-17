## Aggregate fishing powers using the fishing functions - This file needs to change to have West Greenland files.

#### Setup ####
rm(list=ls())                                                                               # Wipe the brain
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

power_template <- read.csv("./Objects/fishing/Power/fishing_power_WG_2011-2019.csv") %>% 
  subset(select = -c(X)) # fix saving mistake

write.csv(power_template, file =  paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_power_WG_2011-2019.csv"),
          row.names = F)

#Remove old
fn <- "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_power_BS_2011-2019.csv"
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}