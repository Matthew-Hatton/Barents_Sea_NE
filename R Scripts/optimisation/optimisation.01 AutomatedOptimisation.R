## Script runs simulated annealing process in parallel for different rounds.
## Each round takes the previous rounds highest likelihood and continues running.
## Simulation time can be very long.

rm(list = ls()) # reset

library(StrathE2EPolar)
library(furrr)
library(purrr)
library(future)
library(tictoc)
library(tidyverse)

future:::ClusterRegistry("stop") # make sure all additional clusters are closed

tic()
## Initialise ##
n_runs <- availableCores() - 2
n_iter <- 500
rounds <- seq(1,5)
n_years <- 50
fishing <- TRUE # switch for optimising fishing parameters
## ########## ##


plan(multisession,workers = n_runs)

parallel_optimise <- function(n_iter,n_years){
  model <- e2ep_read("Barents_Sea","2011-2019-CNRM-SSP370")
  opt_eco <- e2ep_optimize_eco(model,nyears = n_years,n_iter = n_iter,quiet = T,start_temperature = 1,cooling = 1)
  return(opt_eco)
}

## -- Optimise fishing? -- ##
fishing_targets <- c("Proportion_discards_in_diet_of_birds",
                     
                     "Annual_planktivorous_fish_landings_(live_weight)",
                     
                     "Annual_demersal_fish_landings_(live_weight)",
                     
                     "Annual_migratory_fish_landings_(live_weight)",
                     
                     "Annual_susp/dep_benthos_landings_(live_weight)",
                     
                     "Annual_carn/scav_benthos_landings_(live_weight)",
                     
                     "Annual_carn_zooplankton_landings_(live_weight)",
                     
                     "Annual_macrophyte_landings_(live_weight)",
                     
                     "Proportion_of_demersal_fish_catch_discarded",
                     
                     "Annual_bycatch_of_birds",
                     
                     "Annual_bycatch_of_pinnipeds",
                     
                     "Annual_bycatch_of_cetaceans",
                     
                     "Obs_cetacean_landings_by_whale_hunters"
                     
)

annual_targets <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Target/annual_observed_BS_2011-2019.csv")

if (fishing) {
   annual_targets <- annual_targets %>%
    mutate(Use1_0 = if_else(Description %in% fishing_targets, 1, Use1_0))
  
  write.csv(annual_targets, "C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Target/annual_observed_BS_2011-2019.csv", row.names = FALSE)
} else if(fishing == FALSE){
  annual_targets <- annual_targets %>%
    mutate(Use1_0 = if_else(Description %in% fishing_targets, 0, Use1_0))
  
  write.csv(annual_targets, "C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Target/annual_observed_BS_2011-2019.csv", row.names = FALSE)
  
}

likelihoods <- list()

message(paste0("ETC: ",round((n_iter * n_years * length(rounds))/(3600/2.17),digits = 1), " Hours.\n",round((n_iter * n_years * length(rounds))/(1800*24),digits = 1)," Days.")) ## 2.17s per optimisation year per iteration

for (round in rounds) {
  # debug
  # round = 2
  message(paste0("Round: ",round))
  opt_eco <- future_map(1:n_runs, ~ parallel_optimise(n_iter,n_years),.progress = F, .options = furrr_options(seed = TRUE)) # run parallel optimise
  saveRDS(opt_eco,paste0("./Objects/Optimisation/AutoOptimise/Experiment 4/BS.NE.round.",round,".RDS")) # save it out (incase we need it again)
  
  ## initialise data storage
  likelihood <- data.frame(Accepted = numeric(),
                            Model = character(),
                            Iteration = numeric(),
                            Round = character())
  
  for (i in 1:n_runs) { # build up current likelihoods df
    tmp <- data.frame(Accepted = opt_eco[[i]][["parameter_accepted_history"]][["annual_obj"]],
                      Model = i,
                      Iteration = seq(((round-1)*n_iter),(round*n_iter)-1), # so we don't start at 0
                      Round = round)
    likelihood <- rbind(likelihood,tmp)
  }
  
  likelihoods <- append(likelihoods,list(likelihood))
  
  if (round != rounds[1]) { #store the previous results
    lks_prev <- do.call(rbind, likelihoods[1:(round - 1)]) %>% 
      as.data.frame()
    plt <- ggplot() +
      geom_line(data = lks_prev,
                aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      geom_line(data = likelihood,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      NULL
    ggsave(plot = plt,paste0("./Figures/optimisation/Trajectories/Experiment 4/Trajectories.Round.",round,".png"),width = 1920,height = 1080,units = "px")
  } else{
    plt <- ggplot() +
      geom_line(data = likelihood,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      NULL
    ggsave(plot = plt,paste0("./Figures/optimisation/Trajectories/Experiment 4/Trajectories.Round.",round,".png"),width = 1920,height = 1080,units = "px")
  }
  
  

  largest <- likelihood %>% filter(Iteration == (round * n_iter)-1) %>% arrange(-Accepted) %>% slice(1) %>% .$Model
  
  ## Save the new values
  new_pref <- opt_eco[[largest]][["new_parameter_data"]][["new_preference_matrix"]]
  new_uptake_mort <- opt_eco[[largest]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
  new_microbiology <- opt_eco[[largest]][["new_parameter_data"]][["new_microbiology_parameters"]]
  
  write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Param/fitted_preference_matrix_new.csv")
  write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Param/fitted_uptake_mort_rates_new.csv")
  write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019-CNRM-SSP370/Param/fitted_microbiology_others_new.csv")
  # 
  # ## Check Diagnostics
  model <- e2ep_read("Barents_Sea",
                     "2011-2019-CNRM-SSP370") ## error in reading in the model...
  results <- e2ep_run(model,nyears = n_years)
  # 
  # jpeg(paste0("./Figures/optimisation/Diagnostic Plots/Experiment 3/Biomass.Round.",round,".jpeg"),units = "px",width = 1920,height = 1080)
  # e2ep_plot_biomass(model,results = results)
  # dev.off()
  # 
  jpeg(paste0("./Figures/optimisation/Diagnostic Plots/Experiment 4/TS.Round.",round,".jpeg"),units = "px",width = 1920,height = 1080)
  e2ep_plot_ts(model,results = results)
  dev.off()
  # 
  # jpeg(paste0("./Figures/optimisation/Diagnostic Plots/Experiment 3/CompareObs.Round.",round,".jpeg"),units = "px",width = 1920,height = 1080)
  # e2ep_compare_obs(model = model,results = results,selection = "ANNUAL",)
  # dev.off()
  # 
  # jpeg(paste0("./Figures/optimisation/Diagnostic Plots/Experiment 3/OptDiagnostics.Round.",round,".jpeg"),units = "px",width = 1920,height = 1080)
  # e2ep_plot_opt_diagnostics(model = model,results = opt_eco[[largest]],selection = "ECO")
  # dev.off()
}

future:::ClusterRegistry("stop") # make sure all additional clusters are closed
toc()

