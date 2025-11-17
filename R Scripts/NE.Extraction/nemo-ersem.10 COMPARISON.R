TS_MEDUSA <- readRDS("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/Objects/TS.rds") %>% 
  subset(select = c(date,Temperature_avg,Compartment)) %>% 
  mutate(model = "NEMO-MEDUSA (RCP 8.5)")
TS_ERSEM <- readRDS("./Objects/TS.rds") %>% 
  filter(SSP == "ssp370" | SSP == "hist") %>% 
  subset(select = c(date,Temperature_avg,Compartment)) %>% 
  mutate(model = "NEMO-ERSEM (SSP370)")

TS <- rbind(TS_MEDUSA,TS_ERSEM)

TS_temp <- ggplot(data = TS,aes(x = date,y = Temperature_avg,color = model)) +
  geom_line() +
  facet_wrap(~Compartment,ncol = 1,strip.position = "right") +
  labs(color = "Climate Model") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10,face = "bold"),
        axis.text = element_text(size = 8),
        legend.title = element_text(size = 10,face = "bold"),
        legend.text = element_text(size = 8),
        legend.position = "top",
        strip.background = element_rect(color = "black",fill = "white"),
        strip.text = element_text(size = 12,face = "bold")) +
  guides(color = guide_legend(title.hjust = 0.5, title.position = "top",
                                title.theme = element_text(angle = 0, size = 14,face = "bold"),
                                label.theme = element_text(size = 12), 
                                barheight = 0.25, barwidth = 1))
ggsave("./Figures/temperature_NM_NE.tiff",
       dpi = 500,width = 30,unit = "cm",height = 29.7,
       plot = TS_temp)


TS_MEDUSA <- readRDS("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/Objects/TS.rds") %>% 
  subset(select = c(date,Detritus_avg,Compartment)) %>% 
  mutate(model = "NEMO-MEDUSA (RCP 8.5)")
TS_ERSEM <- readRDS("./Objects/TS.rds") %>% 
  filter(SSP == "ssp370" | SSP == "hist") %>% 
  subset(select = c(date,Detritus_avg,Compartment)) %>% 
  mutate(model = "NEMO-ERSEM (SSP370)")

TS <- rbind(TS_MEDUSA,TS_ERSEM)

TS_det <- ggplot(data = TS,aes(x = date,y = Detritus_avg,color = model)) +
  geom_line() +
  facet_wrap(~Compartment,ncol = 1,strip.position = "right") +
  labs(color = "Climate Model") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10,face = "bold"),
        axis.text = element_text(size = 8),
        legend.title = element_text(size = 10,face = "bold"),
        legend.text = element_text(size = 8),
        legend.position = "top",
        strip.background = element_rect(color = "black",fill = "white"),
        strip.text = element_text(size = 12,face = "bold")) +
  guides(color = guide_legend(title.hjust = 0.5, title.position = "top",
                              title.theme = element_text(angle = 0, size = 14,face = "bold"),
                              label.theme = element_text(size = 12), 
                              barheight = 0.25, barwidth = 1))
ggsave("./Figures/detritus_NM_NE.tiff",
       dpi = 500,width = 30,unit = "cm",height = 29.7,
       plot = TS_det)
