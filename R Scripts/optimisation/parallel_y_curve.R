parallel_y_curve <- function(Guild, mult, nyears,ddmort_mult,hsat_mult,maxup_mult,HRscale) {
  model <- e2ep_read("Barents_Sea", "2011-2019-CNRM-SSP370")
  
  # Apply multiplier based on guild
  if (Guild == "PLANKTIV") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- mult #pfish in first position
    model[["data"]][["fitted.parameters"]][["xxpfish"]] <- model[["data"]][["fitted.parameters"]][["xxpfish"]] * ddmort_mult
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] <- model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][1] * HRscale
    model[["data"]][["fitted.parameters"]][["h_fishp"]] <- model[["data"]][["fitted.parameters"]][["h_fishp"]] * hsat_mult
    model[["data"]][["fitted.parameters"]][["u_fishp"]] <- model[["data"]][["fitted.parameters"]][["u_fishp"]] * maxup_mult
    
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Plank.fish_landings_live_weight",
                                "Plank.fish_discards")) %>% 
      mutate(Multiplier = mult,
             HalfSatMult = hsat_mult,
             MaxUpMult = maxup_mult,
             Model = "NE")
    
  } else if (Guild == "DEMERSAL") {
    model[["data"]][["fleet.model"]][["HRscale_vector_multiplier"]][2] <- mult #dfish in second position
    model[["data"]][["fitted.parameters"]][["xxdfish"]] <- model[["data"]][["fitted.parameters"]][["xxdfish"]] * ddmort_mult
    results <- e2ep_run(model = model, nyears = nyears)
    
    catch <- results[["final.year.outputs"]][["annual_flux_results_wholedomain"]] %>% 
      filter(Description %in% c("Dem.fish_landings_live_weight",
                                "Dem.fish_discards")) %>% 
      mutate(Multiplier = mult,
             Model = "NE")
  }
  
  return(catch)
}