#' calc_total_change
#'
#' @param anom_data Dataframe of anomalies to calculate total change from
#' @param var_name The variable name to calculate total change of
#' @param start_yr Start year to calculate total change over
#' @param climdiv_map TRUE if calculating total change for climate divisions and false if for states
#' @param end_yr End year to calculate total change over. Default is 2100.
#'
#' @description A utils function to calculate total change of a variable
#'
#' @return Dataframe with total change calculated
#'
#' @noRd

calc_total_change = function(anom_data, var_name, start_yr, climdiv_map, end_yr = 2100){

  if (climdiv_map) {

    grouping_var <- c("climdiv", "scenario")

  } else{

    grouping_var <- c("state", "scenario")

  }

  # Clean up data and calculate total change
  ttlchng <- anom_data %>%
    dplyr::ungroup()  %>%
    dplyr::filter(scenario != "nclimgrid") %>% # not making a map for nclimgrid
    dplyr::filter(year >= start_yr) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_var))) %>%
    dplyr::mutate(change = trend::sens.slope({{var_name}})[[1]]) %>% # calculate sens slope
    dplyr::mutate(total_change = change * (end_yr-start_yr+1)) %>%
    dplyr::slice(1) %>%
    dplyr::select(state, scenario, total_change) %>%
    dplyr::ungroup()

  return(ttlchng)
}
