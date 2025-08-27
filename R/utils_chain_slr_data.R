#' chain_slr_data
#'
#' @param obs_data Dataframe of observed slr data
#' @param mod_data Dataframe of modeled slr data
#' @param obs_col Column name of the observed data slr
#'
#' @description A utils function
#'
#' @return The adjusted dataframe of modeled slr
#'
#' @noRd

chain_slr_data <- function(obs_data, mod_data, obs_col){

  # get the observed 2020 value to offset the projections data
  obs_2020 <- obs_data %>%
    dplyr::filter(year == 2020) %>%
    dplyr::pull({{obs_col}})

  # Get the projected 2020 value
  mod_2020 <- mod_data %>%
    dplyr::filter(year == 2020) %>%
    dplyr::mutate(shift_obs_2020 = obs_2020 - slr_in) %>%
    dplyr::select(-slr_in, -year)

  mod_adj <- dplyr::left_join(mod_data, mod_2020, by = c("scenario")) %>%
    dplyr::mutate(slr_in = slr_in + shift_obs_2020) %>%
    dplyr::select(scenario, year, slr_in)

  return(mod_adj)

}
