#' rename_scenarios
#'
#' @param scenario_df Dataframe that has a column called scenario
#' @param is_map True if renaming a dataframe for creating a map. Default is False.
#'
#' @description A utils function
#'
#' @return Dataframe with two new columns renaming the scenarios for plotting
#'
#' @noRd

rename_scenarios = function(scenario_df, is_map = FALSE){

  scenario_rename <- scenario_df %>%
    dplyr::mutate(scenario_line = dplyr::case_when(
      scenario == "observed" ~ "Observations",
      scenario == "nclimgrid" ~ "nClimGrid",
      scenario == "ssp126" ~ "Low emissions (SSP1-2.6)",
      scenario == "ssp245" ~ "Intermediate emissions (SSP2-4.5)",
      scenario == "ssp370" ~ "High emissions (SSP3-7.0)",
      scenario == "ssp585" ~ "Very high emissions (SSP5-8.5)",
      scenario == "hindcast" ~ "Model hindcast"
    )) %>%
    dplyr::mutate(scenario_ribbon = dplyr::case_when(
      stringr::str_detect(scenario, "ssp") ~ paste0(scenario_line, " model range"),
      scenario == "hindcast" ~ paste0(scenario_line, " range"),
      TRUE ~ NA
    ))

  if (is_map) {

    scenario_rename <- scenario_rename %>%
      dplyr::select(-scenario_ribbon) %>%
      dplyr::rename(scenario_title = scenario_line) %>%
      dplyr::mutate(scenario_title = forcats::fct_relevel(scenario_title, c(
        "Observations",
        "Model hindcast",
        "Low emissions (SSP1-2.6)",
        "Intermediate emissions (SSP2-4.5)",
        "High emissions (SSP3-7.0)",
        "Very high emissions (SSP5-8.5)"

      )))

  }

  return(scenario_rename)

}
