#' clean_oa_obs
#'
#' @param which_station String of the station chosen
#' @param obs_raw Raw ocean acidity observed data
#'
#' @returns Clean dataframe of the ocean acidity observed data
#' @export
#'
#' @examples
clean_oa_obs <- function(which_station, obs_raw){

  obs_select <- oa_obs %>%
    dplyr::select(tidyselect::starts_with(which_station)) %>%
    dplyr::select(tidyselect::contains(c("Year", "pH"))) %>%
    dplyr::select(!tidyselect::contains(c("pCO2"))) %>%
    dplyr::mutate(station_name = which_station) %>%
    dplyr::rename(ph = sprintf('%s pH', which_station))  %>%
    dplyr::rename(date = ifelse(which_station == "Cariaco",
                                sprintf('%s Year (pH)', which_station),
                                sprintf('%s Year', which_station))) %>%
    dplyr::mutate(date = lubridate::date_decimal(date)) %>%
    dplyr::mutate(scenario = "observed")

  return(obs_select)
}
