#' process_sea_ice
#'
#'
#' @param obs_proj_av Dataframe with observed and projected average
#' @param ssp_data Dataframe with all the projected models
#' @param start_year Year the overlap between the hindcast and observed data started
#' @param end_year Year the overlap between the hindcast and observed data ended
#' @param min_hind_yr The minimum year we want the hindcst
#'
#' @returns Dataframe ready for plotting
#' @export
#'
#' @examples asi_adj_all <- process_sea_ice(asi_proj_av_all, asi_proj_mod, base_yr_start, base_yr_end, min_hind_yr)
process_sea_ice <- function(obs_proj_av, ssp_data, start_year, end_year, min_hind_yr){

  # filter to overlap between observed and hindcast
  for_av <- obs_proj_av %>%
    dplyr::filter(year >= start_year & year <= end_year)

  # Observed average
  av_obs <- for_av %>%
    dplyr::filter(scenario == "observed") %>%
    dplyr::summarize(av = mean(si_extent))

  # hindcast average
  av_hind <- for_av %>%
    dplyr::filter(scenario == "hindcast") %>%
    dplyr::summarize(av = mean(si_extent))

  # Ratio of observed to hindcast
  bias_ratio <- av_obs$av/av_hind$av

  # Adjust the data
  arct_si_adj <- obs_proj_av %>%
    dplyr::mutate(si_extent_adj = ifelse(scenario == "observed", si_extent, si_extent_smooth*bias_ratio))

  # calculate model range
  si_mod_range <- calc_model_range(ssp_data, si_extent) %>%
    dplyr::mutate(p10 = ifelse(scenario != "hindcast" & year < 2014, NA, p10),
                  p90 = ifelse(scenario != "hindcast" & year < 2014, NA, p90)) %>%
    dplyr::mutate(p10_adj = p10*bias_ratio,
                  p90_adj = p90*bias_ratio)


  # Combine range and average data
  si_adj_all <- dplyr::full_join(arct_si_adj, si_mod_range, by = c("year", "scenario")) %>%
    dplyr::filter(year >= min_hind_yr) %>%
    rename_scenarios()

  return(si_adj_all)

}
