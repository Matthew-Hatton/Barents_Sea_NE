## script to check difference between NE drivers and NM drivers

rm(list = ls())

library(tidyverse)

## Read in NM
chemistry_NM <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/chemistry_BS_2011-2019.csv") %>% 
  mutate(Marker = "NEMO-MEDUSA",
         File = "Chemistry") %>% 
  pivot_longer(cols = SO_nitrate:SO_other_ammonia_flux,names_to = "Variable",values_to = "Measured")

physics_NM <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  mutate(Marker = "NEMO-MEDUSA",
         File = "Physics") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "Measured")

## Read in NE
chemistry_NE <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Driving/chemistry_BS_2011-2019-CNRM-SSP370.csv") %>% 
  mutate(Marker = "NEMO-ERSEM",
         File = "Chemistry") %>% 
  pivot_longer(cols = SO_nitrate:SO_other_ammonia_flux,names_to = "Variable",values_to = "Measured")
physics_NE <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Driving/physics_BS_2011-2019-CNRM-SSP370.csv") %>% 
  mutate(Marker = "NEMO-ERSEM",
         File = "Physics") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "Measured")

## Bind
master <- rbind(chemistry_NM,physics_NM,
                chemistry_NE,physics_NE)

master_con <- master %>% 
  filter(!Variable %in% c("habD1_pdist","habD2_pdist","habD3_pdist","habS1_pdist","habS2_pdist","habS3_pdist",
                          "Inshore_waveheight","mixLscale","RIV_detritus","SI_AirTemp","SI_LogeSPM","SI_other_ammonia_flux",
                          "SI_other_nitrate_flux","SO_AirTemp","SO_LogeSPM","SO_other_ammonia_flux","SO_other_nitrate_flux",
                          "Upwelling"))

physics <- master_con %>% filter(File == "Physics")
chemistry <- master_con %>% filter(File == "Chemistry")

ggplot() +
  geom_line(data = physics,aes(x = Month,y = Measured,color = Marker)) +
  facet_wrap(~Variable,scales = "free_y") +
  scale_x_continuous(breaks = seq(1,12),labels = seq(1,12)) +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.x = element_text(size = 6)) +
  labs(color = "",title = "Physics") +
  NULL
ggsave("./Figures/Physics Comparison.png",bg = "white")

ggplot() +
  geom_line(data = chemistry,aes(x = Month,y = Measured,color = Marker)) +
  facet_wrap(~Variable,scales = "free_y") +
  scale_x_continuous(breaks = seq(1,12),labels = seq(1,12)) +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.x = element_text(size = 6)) +
  labs(color = "",title = "Chemistry") +
  NULL
ggsave("./Figures/Chemistry Comparison.png",bg = "white")


ggplot() +
  geom_line(data = master_con,aes(x = Month,y = Measured,color = Marker)) +
  facet_wrap(~Variable,scales = "free_y") +
  scale_x_continuous(breaks = seq(1,12),labels = seq(1,12)) +
  theme_minimal()
