#' rename_stations
#'
#' @param proj_av The projected model average dataframe for ocean acidity
#'
#' @returns Dataframe with new column that gives the full station name for ocean acidity
#' @export
#'
#' @examples
rename_stations <- function(proj_av){

  proj_av_cln <- proj_av %>%
    dplyr::mutate(scenario = ifelse(scenario == "historical", "hindcast", scenario)) %>%
    dplyr::mutate(station_name = dplyr::case_when(

      station == "cariaco" ~ "Cariaco",
      station == "bats1" ~ "Bermuda",
      station == "bats2" ~ "Bermuda",
      station == "estoc" ~ "Canary Islands",
      station == "hot" ~ "Hawaii"

    ))

  return(proj_av_cln)

}
