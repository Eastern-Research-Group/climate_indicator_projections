#' calc_anom
#'
#' @param mod_data SSP model averages
#' @param var_name The column to calculate the anomaly from
#' @param base_start The start year to calculate the base period
#' @param base_end The end year to calculate the base period
#' @param window_size The size of the window to calculate the rolling average
#' @param nclimgrid_smooth Whether to calculate smoothed values for nclimgrid
#' @param model_range True if calculating anomaly for model range
#'
#' @description Function to calculate smoothed anomalies for the model averages
#'
#' @return Dataframe that returns the mean value for the base period, the anomaly, and smoothed anomalies
#'
#' @noRd

calc_anom = function(mod_data, var_name, base_start, base_end, window_size, nclimgrid_smooth = TRUE, model_range = FALSE){

  # Set grouping variables depending on data

  if (model_range) {

    grouping_var <- c("scenario", "model")

  } else{

    grouping_var <- c("scenario")

  }

  # Calculate the average value for the base period
  av_val <- mod_data %>%
    dplyr::filter(year >= base_start) %>%
    dplyr::filter(year <= base_end) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_var))) %>%
    dplyr::summarize(mean_val = mean({{var_name}})) %>%
    dplyr::ungroup()

  # Calculate the anomaly
  anom <- dplyr::left_join(mod_data, av_val, by = grouping_var) %>%
    dplyr::mutate(anomaly = {{var_name}} - mean_val) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_var))) %>%
    dplyr::mutate(smoothed_anom = zoo::rollmean(anomaly, k = window_size, fill = NA))

  #Add  a hindcast scenario
  hindcast <- anom %>%
    dplyr::filter(scenario == "ssp126") %>%
    dplyr::filter(year <= 2014) %>%
    dplyr::mutate(scenario = "hindcast")

  anom <- rbind(anom, hindcast) %>%
    dplyr::mutate(smoothed_anom = ifelse(!scenario %in% c("nclimgrid", "hindcast") & year < 2014, NA, smoothed_anom))

  # simplify if for model range
  if (model_range) {

    anom <- anom %>%
      dplyr::filter(!scenario %in% c("hindcast", "hind")) %>%
      dplyr::filter(year >= 2014) %>%
      rbind(hindcast)

  }

  # Don't smooth nclimgrid if the indicator doesn't
  if (isFALSE(nclimgrid_smooth)) {

    anom <- anom %>%
      dplyr:: mutate(smoothed_anom = ifelse(scenario == "nclimgrid", anomaly, smoothed_anom))

  }

  return(anom)
}
