#' process_oa_station
#'
#' @param which_station String of which ocean acidity station
#' @param obs_data Dataframe of observed data
#' @param mod_av Dataframe of model average data
#' @param mod_all Dataframe of all modeled data
#'
#' @returns
#' @export
#'
#' @examples
process_oa_station <- function(which_station, obs_data, mod_av, mod_all){

  filter_obs <- clean_oa_obs(which_station, obs_data)

  oa_proj_mod_range_filt <- mod_all %>%
    dplyr::filter(station_name=={{which_station}})

  oa_proj_all <- mod_av %>%
    dplyr::filter(station_name=={{which_station}}) %>%
    rbind(filter_obs) %>%
    dplyr::full_join(oa_proj_mod_range_filt, by = c("station_name", "scenario", "date")) %>%
    # rename for highchart function
    dplyr::mutate(year = as.Date(date, format = "%Y-%m-%d")) %>%
    dplyr::rename(smoothed_anom_adj = ph,
                  p10_adj = p10,
                  p90_adj = p90) %>%
    rename_scenarios()

  return(oa_proj_all)

}
