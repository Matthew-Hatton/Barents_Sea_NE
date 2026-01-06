## Run batches of R scripts to build StrathE2EPolar Barents Sea model
rm(list = ls()) #reset

library(MiMeMo.tools)
source("./regionFile.R")

library(furrr)

availableCores()
plan(multisession,workers = availableCores()-2)

#### Batch process scripts ####

len <- length(list.files("./R Scripts/NE.se2e/",full.names = T))
scripts <- list.files("./R Scripts/NE.se2e/",full.names = T)[c(2,3,4,13)] %>% # Just what changes through the decades
  map(MiMeMo.tools::execute) # Run the scripts