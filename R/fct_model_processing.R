#' model_processing
#'
#' @param mod_data SSP model averages
#' @param var_name The column to calculate the anomaly from
#' @param base_start The start year to calculate the base period
#' @param base_end The end year to calculate the base period
#' @param window_size The size of the window to calculate the rolling average
#' @param nclimgrid_smooth Whether to calculate smoothed values for nclimgrid
#' @param model_range True if calculating anomaly for model range
#' @param obs_mod_data Dataframe with both observed and modeled values
#' @param which_anom Name of the anomaly varaible to take the average of
#' @param min_obs_yr Minimum observed year
#'
#' @description A wrapper function that applies the model processing steps to calculate the model anomaly and range and align the data with the observed.
#'
#' @return Dataframe of modeled and observed data ready for plotting.
#'
#' @noRd

model_processing <- function(mod_data, var_name, base_start, base_end, window_size = 11, nclimgrid_smooth = FALSE, model_range = FALSE,
                             obs_mod_data, which_anom, min_obs_yr) {

  # Calculate the anomaly for the model range
  mod_range <- calc_anom(mod_data, {{var_name}}, base_start, base_end, window_size, nclimgrid_smooth, model_range) %>%
    calc_model_range(., anomaly)

  # Difference between the averages of the modeled and observed data
  obs_proj_diff <- calc_diff_avs(obs_mod_data, "observed", "hindcast", {{which_anom}}, min_obs_yr, 2014)

  # Align modeled data with observed data
  all_adj <- adjust_anomaly(obs_mod_data, obs_proj_diff, NA, mod_range, smoothed_anom) %>%
    rename_scenarios()

  return(all_adj)


}
