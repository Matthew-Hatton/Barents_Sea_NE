## Run batches of R scripts to build StrathE2EPolar West Greenland model
rm(list = ls()) #reset

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

#### Batch process scripts ####
len <- length(list.files("./R Scripts/NE.se2e/",full.names = T))
scripts <- list.files("./R Scripts/NE.se2e/",full.names = T)[3:len] %>% # all except first two (this one)
  map(MiMeMo.tools::execute) # Run the scripts