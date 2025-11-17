rm(list = ls()) #reset

#average files based on zone and forcing/ssp data
packages <- c("tidyverse", "nemoRsem", "furrr", "ncdf4","tictoc")                                 # List packages
lapply(packages, library, character.only = TRUE)   
plan(multisession)

ssp <- "ssp370"
Force <- "CNRM"
#load in a temporary file
temp <- readRDS(paste0("./Objects/NE_Ice/NE.ICE.",Force,".hist.1976.01.rds")) %>% 
  group_by(Shore) %>% 
  summarise(Ice_presence = mean(Ice_pres,na.rm = T),
            Ice_Thickness = mean(Ice_Thickness,na.rm = T),
            Snow_Thickness = mean(Snow_Thickness,na.rm = T),
            Ice_concentration = mean(Ice_conc),
            Air_Temperature = mean(Air_Temperature))

all_files <- list.files("./Objects/NE_Ice/", pattern = ".rds", full.names = TRUE) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  setNames("FullPath") %>%
  mutate(
    Path = paste0(dirname(FullPath), "/"),
    File = basename(FullPath)
  ) %>%
  separate(File, into = c("Region", "Variable", "Model", "Scenario", "Year", "Month", "Ext"), sep = "\\.", remove = FALSE) %>%
  select(Path, File, Model, Scenario, Year, Month) %>%
  mutate(
    Year = as.integer(Year),
    Month = as.integer(Month)
  ) %>% 
  filter(Scenario == ssp | Scenario == "hist" & Model == Force)

# Read each file in parallel and summarise by Year, Shore, Month, Model, and Scenario
summary_data <- all_files %>%
  mutate(data = future_map(paste0(Path,File), ~ readRDS(.x), .progress = TRUE)) %>%
  unnest(data) %>%
  group_by(Year, Shore, Month, Model, Scenario) %>%
  summarize(across(everything(), mean, na.rm = TRUE))

saveRDS(summary_data,paste0("./Objects/physics/",Force,".",ssp,".Ice.and.Air.Summary.rds"))

## check
NE <- readRDS("./Objects/physics/CNRM.ssp370.Ice.Summary.rds")
ggplot() +
  geom_line(data = NE %>% filter(Year == 2060 & Shore == "Inshore"),aes(x = Month,y = Air_Temperature,color = Model))
