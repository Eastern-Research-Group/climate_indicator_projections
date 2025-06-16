#' calc_diff_avs
#'
#' @param obs_mod_data Dataframe with both observed and modeled values
#' @param scenario1 String with the name of the first scenario to compare
#' @param scenario2 String with the name of the second scenario to compare
#' @param var_name Name of the variable to take the average of
#' @param start_year The start year to compare averages over
#' @param end_year The end year to compare averages over
#'
#' @description Calculate the difference between the long term averages of two scenarios
#'
#' @return The value of the average difference between the scenarios
#'
#' @noRd

calc_diff_avs = function(obs_mod_data, scenario1, scenario2, var_name, start_year, end_year){

  # First average
  av1 <- obs_mod_data %>%
    dplyr::filter(year >= start_year & year <= end_year) %>%
    dplyr::filter(scenario == scenario1) %>%
    dplyr::summarize(av = mean({{var_name}}))

  # Second average
  av2 <- obs_mod_data %>%
    dplyr::filter(year >= start_year & year <= end_year) %>%
    dplyr::filter(scenario == scenario2) %>%
    dplyr::summarize(av = mean({{var_name}}))

  # Actual difference
  av_dif <- av1$av - av2$av

  return(av_dif)

}
