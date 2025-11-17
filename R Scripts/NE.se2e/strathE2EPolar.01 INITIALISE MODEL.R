## Initialise model

library(ggplot2)
source("./regionFile.R")
implementation <- "Barents_Sea"

R.utils::copyDirectory("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea",              # Copy example model 
                       stringr::str_glue("./StrathE2EPolar_Implementation/{implementation}/2011-2019-{ssp}/"))    # Into new implementation

dir.create("./StrathE2EPolar_Implementation/Results")   
