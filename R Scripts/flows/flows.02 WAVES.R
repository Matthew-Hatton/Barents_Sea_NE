
# Extract monthly significant wave height

#### Setup ####

rm(list=ls())

Packages <- c("MiMeMo.tools", "exactextractr", "raster")                    #list packages
lapply(Packages, library, character.only = TRUE)                            #load packages
source("./Objects/@_Region file.R")

domains <- readRDS("./Objects/Domains.rds") %>%                             #import inshore polygon
  filter(Shore == "Inshore") %>% 
  st_transform(crs = "WGS84")

nc <- brick("./Objects/RAW/ecmwf.nc") %>% 
  as.data.frame() #data is already cropped so just load it in
colnames(nc) <- as.Date(as.POSIXct(as.numeric(gsub("X", "", colnames(nc))), origin = "1970-01-01"), format="%Y-%m-%d") #convert columns to readable form
nc_long <- nc %>%
  pivot_longer(cols = everything(), names_to = "date", values_to = "wave_height")%>% #convert to long form
  mutate(year = year(date), month = month(date)) #add years and month
mean_wave_height <- nc_long %>%
  group_by(year, month) %>%
  summarise(mean_height = mean(wave_height, na.rm = TRUE)) %>% #calculate means
  mutate(Date = as.Date(paste(year, month, "01", sep = "-"))) #add in date column to allow for time series plot
saveRDS(mean_wave_height, "./Objects/Significant wave height.rds")

ggplot(mean_wave_height) +
  geom_line(aes(x = Date, y = mean_height)) +
  theme_bw() +
  theme(axis.title.x = element_blank()) +
  labs(y = "Mean significant wave height (m)", x = "Month", caption = "Data from ECMWF-ERA5") +
  NULL
ggsave("./Figures/flows/Significant wave height.png", width = 16, height = 8, units = "cm")

