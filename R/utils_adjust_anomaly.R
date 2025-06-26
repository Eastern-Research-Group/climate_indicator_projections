#' adjust_anomaly
#'
#' @param obs_mod_data Dataframe with observed and modeled anomalies
#' @param obs_proj_diff Value of the average difference between observed and modeled
#' @param obs_ncimgrid_diff Value of the average difference between observed and nclimgrid
#' @param mod_range_data Dataframe of the 10th and 90th percentiles of the models
#' @param anom_var Column name
#'
#' @description Adjust the modeled anomalies by the difference between observed and moddled averages
#'
#' @return Dataframe with a new adjusted anomaly column that shifts the modeled data by the average
#'
#' @noRd

adjust_anomaly = function(obs_mod_data, obs_proj_diff, obs_ncimgrid_diff, mod_range_data, anom_var){

  # Adjust the anomaly for the bayesian average
  anom_adj <- obs_mod_data %>%
    mutate(smoothed_anom_adj = case_when(
      scenario %in% c("ssp126", "ssp245", "ssp370", "ssp585", "hindcast") ~ {{anom_var}} + obs_proj_diff,
      scenario == "nclimgrid" ~ {{anom_var}} + obs_ncimgrid_diff,
      scenario == "observed" ~ {{anom_var}}
    ))

  # Adjust the anomalies for the model range
  mod_range <- anom_adj %>%
    full_join(mod_range_data, by = c("year", "scenario")) %>%
    mutate(p10_adj = p10 + obs_proj_diff,
           p90_adj = p90 + obs_proj_diff)

  return(mod_range)
}
