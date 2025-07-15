#' process_seasons
#'
#' @param which_season Which season to filter to (e.g. "Fall", "Spring". etc.)
#' @param obs_data Dataframe of observed data
#' @param proj_data Dataframe of projected average data
#' @param ssp_data Dataframe of all projected models
#' @param ssp_var Column name of the temperature variable for the all project models dataframe
#' @param base_yr_start Baseline start year
#' @param base_yr_end Baseline end year
#'
#' @returns Adjusted model projections and observed dataframe for selected season
#' @export
#'
#' @examples seas_proj_adj <- process_seasons(which_season = "Fall",obs_data = obs_raw,proj_data = proj_av,ssp_data = proj_all,ssp_var = avg_temp_f,base_yr_start = base_yr_start,base_yr_end = base_yr_end)
process_seasons = function(which_season, obs_data, proj_data, ssp_data, ssp_var, base_yr_start, base_yr_end){

  # filter observed data
  seas_obs <- obs_data %>%
    dplyr::select(Year, {{which_season}}) %>%
    dplyr::mutate(scenario = "observed") %>%
    dplyr::rename(smoothed_anom = {{which_season}}) %>%
    janitor::clean_names()

  # calculate projected data anomalies
  seas_temp_anom <- proj_data %>%
    dplyr::select(-...1) %>%
    dplyr::filter(!is.na(av_temp)) %>%
    calc_anom(., av_temp, base_yr_start, base_yr_end, 11, FALSE) %>%
    dplyr::select(year, scenario, anomaly, smoothed_anom) %>%
    dplyr::filter(scenario != "nclimgrid") %>%  # remove nclimgrid to bind with observed data
    rbind(seas_obs)

  # Adjust projected data to fit observed data
  if (which_season == "Winter") {

    minyr <- 1956

  } else {

    minyr <- 1955

  }

  # Process and align the model data
  seas_adj <- model_processing(
    mod_data = ssp_data,
    var_name = {{ssp_var}},
    base_start = base_yr_start,
    base_end = base_yr_end,
    obs_mod_data = seas_temp_anom,
    which_anom = smoothed_anom,
    min_hind_yr = minyr)

  return(seas_adj)


}
