#' clean_slr_mod_data
#'
#' @param slr_mod_raw_data The raw slr modeled data
#'
#' @description A utils function to do initial data cleaning which is used for both the slr map and plot
#'
#' @return Cleaned dataframe
#'
#' @noRd

clean_slr_mod_data <- function(slr_mod_raw_data){

  slr_mod_cln_data <- slr_mod_raw_data %>%
    janitor::clean_names() %>% # clean column names
    dplyr::select(noaa_name, scenario, long, lat, tidyr::starts_with("rsl"), -rsl_grid_num, -rsl_contribution_from_vlm_trend_cm_year) %>% # just grab the columns we want
    tidyr::pivot_longer(cols = tidyr::starts_with("rsl"), names_to = "year", values_to = "slr_cm") %>% # Make tidy format
    dplyr::mutate(year = stringr::str_replace_all(year, "[^0-9]", "")) %>% # pull out the letters from the year column
    dplyr::mutate(year = as.numeric(year)) %>%  # make years numeric
    dplyr::mutate(slr_in = measurements::conv_unit(slr_cm, "cm", "inch")) %>% # convert to inches
    dplyr::select(-slr_cm) %>% # get rid of cm column


  return(slr_mod_cln_data)

}

