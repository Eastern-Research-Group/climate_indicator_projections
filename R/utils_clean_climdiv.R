#' clean_climdiv
#'
#' @param clim_div_raw sf dataframe of raw climate division data
#'
#' @description Cleans the climate division data for easier use.
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

clean_climdiv <- function(clim_div_raw){

  clim_div_cln <- clim_div_raw %>%
    janitor::clean_names() %>%
    dplyr::select(climdiv, name) %>%
    dplyr::rename(climdiv_name = name)

  return(clim_div_cln)

}
