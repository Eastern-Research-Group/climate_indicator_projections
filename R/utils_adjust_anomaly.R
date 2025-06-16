#' adjust_anomaly
#'
#' @param obs_mod_data
#' @param obs_proj_diff
#' @param obs_ncimgrid_diff
#' @param anom_var
#'
#' @description Adjust the modeled anomalies by the difference between observed and modled averages
#'
#' @return TDataframe with a new adjusted anomaly column that shifts the modeled data by the average
#'
#' @noRd

adjust_anomaly = function(obs_mod_data, obs_proj_diff, obs_ncimgrid_diff, anom_var){

  anom_adj <- obs_mod_data %>%
    mutate(smoothed_anom_adj = case_when(
      scenario %in% c("ssp126", "ssp245", "ssp370", "ssp585", "hindcast") ~ {{anom_var}} + obs_proj_diff,
      scenario == "nclimgrid" ~ {{anom_var}} + obs_ncimgrid_diff,
      scenario == "observed" ~ {{anom_var}}
    ))

  return(anom_adj)
}
