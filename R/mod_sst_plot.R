#' sst_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_sst_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' sst_plot Server Functions
#'
#' @noRd
mod_sst_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Get data ready for plotting ###

    # Read in data
    sst_path <- "inst/extdata/sea_surface_temp" # path to data
    obs_sst <- readr::read_csv(file.path(sst_path, "sea-surface-temp_fig-1.csv"), skip = 6)
    proj_sst <- readr::read_csv(file.path(sst_path, "sst.global_average.bayesian_model_average.annual.degF.1850-2100.csv"))
    ssps_sst <- read_ssps('sst\\.global_average\\.ssp.*\\.csv', sst_path, "sst")

    # first year of observed data
    min_obs_yr <- 1880

    # Years for anomaly
    base_yr_start <- 1971
    base_yr_end <- 2000

    # observed
    obs_sst_cln <- obs_sst %>%
      janitor::clean_names() %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::select(year, scenario, annual_anomaly) %>%
      dplyr::rename(smoothed_anom = annual_anomaly)

    # Combine with projected
    proj_obs_sst <- proj_sst %>%
      tidyr::pivot_longer(cols = starts_with("SSP"), names_to = "scenario", values_to = "sst") %>%
      calc_anom(., sst, base_yr_start, base_yr_end, 11) %>%
      dplyr::select(year, scenario, smoothed_anom) %>%
      dplyr::filter(year >= min_obs_yr) %>%
      rbind(obs_sst_cln)

    # Calculate the anomaly for the model range
    sst_mod_range <- calc_anom(ssps_sst, sst, base_yr_start, base_yr_end, 11, FALSE, TRUE) %>%
      calc_model_range(., anomaly)

    # Difference between the averages of the modeled and observed data
    sst_obs_proj_diff <- calc_diff_avs(proj_obs_sst, "observed", "hindcast", smoothed_anom, min_obs_yr, 2014)

    # Align modeled data with observed data
    sst_all_adj <- adjust_anomaly(proj_obs_sst, sst_obs_proj_diff, NA, sst_mod_range, smoothed_anom) %>%
      rename_scenarios()

    ### Create the plot ###
    sst_hc <- create_hc_plot(sst_all_adj,
                            "Average Global Sea Surface Temperature, 1880–2100",
                            "Temperature anomaly (°F)",
                            "°F")

    output$plot <- highcharter::renderHighchart({

      sst_hc

    })

    # reactive values
    sst_plot <- reactiveVal()
    sst_plot(sst_hc)

    return(sst_plot)


  })
}

## To be copied in the UI
# mod_sst_plot_ui("sst_plot_1")

## To be copied in the server
# mod_sst_plot_server("sst_plot_1")
