## Initialise model

library(ggplot2)
source("./regionFile.R")

R.utils::copyDirectory(paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370"),# Copy example model 
                       paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/",start_year,"-",end_year,"-",forcing,"-SSP",ssp))    # Into new implementation
