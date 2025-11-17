## Various files stay the same between models, but the names of the files don't. Let's change them here.

#### Setup ####

rm(list=ls())                                                                               # Wipe the brain
message("Renaming Reusables")
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")
#This will throw a warning and FALSE if the file doesn't exist (because it's already been renamed)

## Fishing Fleet
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_fleet_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_fleet_WG_2011-2019.csv"))

## Fishing Processing
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_processing_BS.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_processing_WG.csv"))

## Fitted microbiology others
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fitted_microbiology_others_BS.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fitted_microbiology_others_WG.csv"))

## Fitted preference matrix
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fitted_preference_matrix_BS.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fitted_preference_matrix_WG.csv"))

## Fitted uptake mortality rates
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/fitted_uptake_mort_rates_BS.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fitted_uptake_mort_rates_WG.csv"))

## Fixed Consumers
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fixed_consumers_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fixed_consumers_WG_2011-2019.csv"))

## Target
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Target/region_harvest_r_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Target/region_harvest_r_WG_2011-2019.csv"))
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Target/zonal_harvest_r_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Target/zonal_harvest_r_WG_2011-2019.csv"))

