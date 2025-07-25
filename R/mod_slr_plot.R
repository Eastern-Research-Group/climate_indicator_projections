#' slr_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_slr_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' slr_plot Server Functions
#'
#' @noRd
mod_slr_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Read in data ------------------------------------------------------------

  # Set path
  slr_path <- "inst/extdata/slr"

  # Observed and projected data
  slr_obs <- readr::read_csv(file.path(slr_path, "sea-level_fig-1.csv"), skip = 6) %>%
    janitor::clean_names()
  slr_proj <- readr::read_csv(file.path(slr_path, "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Process observed data ---------------------------------------------------

  csiro_bounds <- slr_obs %>%
    dplyr::select(year, csiro_lower_error_bound_inches, csiro_upper_error_bound_inches) %>%
    dplyr::mutate(scenario = "Tide gauge range") %>%
    dplyr::mutate(year = as.numeric(year))

  slr_obs_cln <- slr_obs %>%
    dplyr::select(-csiro_lower_error_bound_inches, - csiro_upper_error_bound_inches) %>%
    tidyr::pivot_longer(cols = c(csiro_adjusted_sea_level_inches, noaa_adjusted_sea_level_inches), names_to = "source", values_to = "slr_in") %>%
    dplyr::mutate(scenario = ifelse(source == "csiro_adjusted_sea_level_inches", "Tide gauge measurements", "Satellite measurements")) %>%
    dplyr::select(-source) %>%
    dplyr::filter(!is.na(slr_in)) %>%
    dplyr::mutate(year = as.numeric(year))

# Process projections data ------------------------------------------------

  # get the NOAA observed 2005 value to offset the projections data
  noaa_2005 <- slr_obs %>%
    dplyr::filter(year == 2005) %>%
    dplyr::pull(noaa_adjusted_sea_level_inches)

  # Clean up projected data
  slr_proj_cln <- slr_proj %>%
    janitor::clean_names() %>%
    dplyr::filter(noaa_name == "GMSL") %>%
    dplyr::select(scenario, tidyr::starts_with("rsl"), -rsl_grid_num, -rsl_contribution_from_vlm_trend_cm_year) %>%
    tidyr::pivot_longer(cols = tidyr::starts_with("rsl"), names_to = "year", values_to = "slr_cm") %>%
    dplyr::mutate(year = stringr::str_replace_all(year, "[^0-9]", "")) %>%
    dplyr::mutate(slr_in = measurements::conv_unit(slr_cm, "cm", "inch")) %>%
    dplyr::mutate(slr_in = slr_in + noaa_2005) %>%  # add noaa 2005 offset
    dplyr::select(-slr_cm) %>%
    dplyr::mutate(year = as.numeric(year))

  # SLR proj mid
  slr_proj_mi <- slr_proj_cln %>%
    dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
    dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise"))

  # SLR proj range
  slr_proj_range <- slr_proj_cln %>%
    dplyr::filter(scenario %in% c("0.5 - LOW", "0.5 - HIGH", "1.0 - LOW", "1.0 - HIGH")) %>%
    dplyr::mutate(bound = ifelse(stringr::str_detect(scenario, "LOW"), "lower_bound", "upper_bound")) %>%
    dplyr::mutate(scenario = ifelse(stringr::str_detect(scenario, "0.5"), "Lower sea level rise",
                                                                   "Higher sea level rise")) %>%
    tidyr::pivot_wider(names_from = bound, values_from = slr_in)

  # Combine back together
  slr_proj_all <- dplyr::left_join(slr_proj_mi, slr_proj_range, by = c("year", "scenario"))

  # model hindcast
  slr_hindcast <- slr_proj_all %>%
    dplyr::filter(year <= 2020) %>%
    dplyr::mutate(scenario = "Model Hindcast") %>%
    dplyr::distinct()

  # add model hindcast back into slr proj
  slr_proj_all <- slr_proj_all %>%
    dplyr::filter(year >= 2020) %>%
    rbind(., slr_hindcast) %>%
    dplyr::mutate(scenario_area = paste(scenario, " range"))


# Create the plot ---------------------------------------------------------

  output$plot <- highcharter::renderHighchart({

    create_slr_plot(slr_obs_cln,
                    slr_proj_all,
                    csiro_bounds)

  })
  })
}

## To be copied in the UI
# mod_slr_plot_ui("slr_plot_1")

## To be copied in the server
# mod_slr_plot_server("slr_plot_1")
