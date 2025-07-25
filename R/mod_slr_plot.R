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
    dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
    dplyr::filter(noaa_name == "GMSL") %>%
    dplyr::select(scenario, tidyr::starts_with("rsl"), -rsl_grid_num, -rsl_contribution_from_vlm_trend_cm_year) %>%
    dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise")) %>%
    tidyr::pivot_longer(cols = tidyr::starts_with("rsl"), names_to = "year", values_to = "slr_cm") %>%
    dplyr::mutate(year = stringr::str_replace_all(year, "[^0-9]", "")) %>%
    dplyr::mutate(slr_in = measurements::conv_unit(slr_cm, "cm", "inch")) %>%
    dplyr::mutate(slr_in = slr_in + noaa_2005) %>%  # add noaa 2005 offset
    dplyr::select(-slr_cm) %>%
    dplyr::mutate(year = as.numeric(year))

  # model hindcast
  slr_hindcast <- slr_proj_cln %>%
    dplyr::filter(year <= 2020) %>%
    dplyr::mutate(scenario = "Model Hindcast") %>%
    dplyr::distinct()

  # add model hindcast back into slr proj
  slr_proj_cln <- slr_proj_cln %>%
    dplyr::filter(year >= 2020) %>%
    rbind(., slr_hindcast)


# Create the plot ---------------------------------------------------------

  output$plot <- highcharter::renderHighchart({

    hc_plot <- highcharter::highchart() %>%
      # Observed data
      highcharter::hc_add_series(data = slr_obs_cln,
                                 type = "line",
                                 highcharter::hcaes(name = scenario,
                                                    group = scenario,
                                                    x = year, y = slr_in),
                                 tooltip = list(headerFormat = "<b>{series.name}</b>",
                                                pointFormat = sprintf("<br>{point.year}: {point.y}%s", "inches")
                                 ),
                                 color = c("purple", "black")
                                 ) %>%
      # Add tide gauge ranges
      highcharter::hc_add_series(data = csiro_bounds, type = "arearange",
                                 highcharter::hcaes(name = scenario,
                                                    group = scenario,
                                                    x = year,
                                                    low = csiro_lower_error_bound_inches, high = csiro_upper_error_bound_inches),
                                 lineColor = "transparent",
                                 color = "black",
                                 visible = FALSE,
                                 fillOpacity = 0.3,
                                 tooltip = list(headerFormat ="<b>{series.name}</b>",
                                                pointFormat =  "<br>{point.year}<br>Likely Range: {point.low} inches – {point.high} inches")) %>%
      # Projected data
      highcharter::hc_add_series(data = slr_proj_cln,
                                 type = "line",
                                 dashStyle = "shortdash",
                                 highcharter::hcaes(name = scenario,
                                                    group = scenario,
                                                    x = year, y = slr_in),
                                 tooltip = list(headerFormat = "<b>{series.name}</b>",
                                                pointFormat = sprintf("<br>{point.year}: {point.y}%s", "inches")
                                 ),
                                 color = c("orange", "blue", "grey")) %>%
      # Plot aesthetics
      highcharter::hc_tooltip(crosshairs = TRUE, valueDecimals = 2) %>%
      highcharter::hc_yAxis(title = list(
        text = "Cumulative sea level change (inches)",
        style = list(fontSize = "16px")),
        labels = list(
          style = list(fontSize = "14px")
                            )) %>%
      highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                            labels = list(
                              style = list(fontSize = "14px")
                            )) %>%
      highcharter::hc_title(text = "Global Average Absolute and Projected Sea Level Change, 1880–2150") %>%
      highcharter::hc_plotOptions(line = list(marker = list(enabled = FALSE)),
                                  arearange  = list(marker = list(enabled = FALSE))) %>%
      highcharter::hc_legend(
        layout = "vertical",
        align = "right",
        verticalAlign = "middle",
        useHTML = TRUE,
        itemStyle = list(
          fontSize = "12px"
        )
      )

    hc_plot



  })

  })
}

## To be copied in the UI
# mod_slr_plot_ui("slr_plot_1")

## To be copied in the server
# mod_slr_plot_server("slr_plot_1")
