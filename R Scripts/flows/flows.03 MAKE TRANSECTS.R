rm(list=ls())                                                               # Wipe the brain
library(MiMeMo.tools) 
library(furrr)
source("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/@_Region file.R")                                       # Define project region 

plan(multisession)                                                          # Instruction for parallel processing

domains <- readRDS("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/Objects/Domains.rds")                                 # Load SF polygons of the MiMeMo model domains

#### Break up polygon ####

Edges <- st_cast(domains, "MULTILINESTRING", group_or_split = TRUE) %>%     # Simplify polygon to mutli-linestrings
  st_cast("LINESTRING", group_or_split = TRUE) %>%                          # Split line into it's own row 
  split(., f = list(.$Shore), ) %>%  #line doesn't work      # Break the linestrings of a domain into transects
  future_map(boundaries, crs = 4326, .progress = T)

ggplot(Edges[["Offshore"]]) +
  geom_sf()

ggplot() +                                                                  # Check we're getting the inshore edges correctly
  geom_sf(data = Inshore_ocean_boundaries, colour = "black", fill = "black") +                  
  geom_sf(data = Edges[["Inshore"]], colour = "red") +                  
  geom_sf(data = Edges[["Offshore"]], colour = "yellow") +                  
  theme_minimal() +
  viridis::scale_colour_viridis() +
  theme(legend.position = "none",
        axis.text = element_blank()) +
  labs(caption = paste0("Retain only the inshore transects at the Inshore-Ocean\n
                         boundaries (red, over black). Specify the sampling polygons in the region file")) +
  NULL
#ggsave_map("Inshore-Ocean boundary.png", last_plot())

#### Drop Inshore transects we don't need ####

# Inshore <- st_intersects(Edges[["Inshore"]] %>% st_transform(crs = st_crs(Inshore_ocean_boundaries)), Inshore_ocean_boundaries) %>%  # Which Inshore edges are against open ocean (Region file)
#   as.data.frame()
# 
# Edges[["Inshore"]] <- Edges[["Inshore"]][Inshore$row.id,]                   # Drop inshore transects which are on land, or duplicate offshore to inshore


Edges <- map2(Edges, names(Edges), ~{mutate(.x, Shore = .y)}) %>%           # Reset column names
  bind_rows() %>%                                                           # Combine
  mutate(Length = as.numeric(`.`)) %>%                                      # Fix column name
  dplyr::select(Shore, Length) %>%                                                 # Limit to useful info
  rownames_to_column("Segment")


saveRDS(Edges, "Objects/Split_boundary.rds")

