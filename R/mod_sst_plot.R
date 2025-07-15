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
    min_hind_yr <- 1880

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
      dplyr::filter(year >= min_hind_yr) %>%
      rbind(obs_sst_cln)

    # Process and align the model data
    sst_all_adj <- model_processing(
      mod_data = ssps_sst,
      var_name = sst,
      base_start = base_yr_start,
      base_end = base_yr_end,
      obs_mod_data = proj_obs_sst,
      which_anom = smoothed_anom,
      min_hind_yr = min_hind_yr)

    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(sst_all_adj,
                     "Average Global Sea Surface Temperature, 1880–2100",
                     "Temperature anomaly (°F)",
                     "°F")

    })


  })
}

## To be copied in the UI
# mod_sst_plot_ui("sst_plot_1")

## To be copied in the server
# mod_sst_plot_server("sst_plot_1")
