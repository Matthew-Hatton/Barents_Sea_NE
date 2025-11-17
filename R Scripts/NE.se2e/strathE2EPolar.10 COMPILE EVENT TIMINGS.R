rm(list = ls()) # reset
library(MiMeMo.tools) # everything we need

source("./R Scripts/regionFileWG.R")

# read template
event_timings <- read.csv("./Objects/events/event_timing_WG_2011-2019.csv")

write.csv(event_timings,file = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/event_timing_WG_2011-2019.csv"),
          row.names = F)