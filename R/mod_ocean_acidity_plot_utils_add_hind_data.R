#' add_hind_data
#' Add some of the hindcast years to the ssps so that the rolling average includes those years
#'
#' @param proj_av Projected model average
#' @param years years to add for hindcast
#'
#' @returns Dataframe of projected model averages with extra hindcast data for the ssps
#' @export
#'
#' @examples oa_hind_years <- oa_proj_av_cln %>% dplyr::group_by(station_name) %>% add_hind_data(., c(2004:2014))
add_hind_data <- function(proj_av, years, is_date = TRUE){

  if (is_date) {

    proj_av <- proj_av %>%
      dplyr::mutate(year = lubridate::year(date))

  }

  hind_yrs <- proj_av %>%
    dplyr::filter(scenario == "hindcast") %>%
    dplyr::filter(year %in% years) %>%
    dplyr::rename(index = scenario)

  ssps_bind <- data.frame(index = "hindcast",
                          scenario = c("ssp126", "ssp245", "ssp370", "ssp585"))

  ssps_bind <- dplyr::left_join(hind_yrs, ssps_bind, by = "index") %>%
    dplyr::ungroup() %>%
    dplyr::select(-index)

  return(ssps_bind)

}
