#' precip_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_precip_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' precip_plot Server Functions
#'
#' @noRd
mod_precip_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Read in data
    precip_path <- "inst/extdata/precip" # path to data
    precip_obs_raw <- readr::read_csv(file.path(precip_path, "precipitation_fig-1.csv"), skip = 6)
    precip_proj_raw <- readr::read_csv(file.path(precip_path, "conus_TotalAnnualPr.csv"))
    precip_ssps <- readr::read_csv(file.path(precip_path, "conus_TotalAnnualPr_models.csv"))

    # Years
    base_yr_start <- 1951
    base_yr_end <- 2000
    min_hind_yr <- 1955

    # Clean up the observed data
    precip_obs_clean <- precip_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::rename(smoothed_anom = anomaly)  # rename to bind with projected data

    # Calculate anomalies and moving average and Combine with observed data
    precip_all_data <- precip_proj_raw %>%
      calc_anom(., total_pr, base_yr_start, base_yr_end, 11, nclimgrid_smooth = FALSE) %>%
      dplyr::select(year, scenario, smoothed_anom) %>%
      rbind(precip_obs_clean) %>%
      # remove nclimgrid
      dplyr::filter(scenario != "nclimgrid")

    # Process and align the model data
    precip_all_adj <- model_processing(
      mod_data = precip_ssps,
      var_name = total_pr,
      base_start = base_yr_start,
      base_end = base_yr_end,
      model_range = TRUE,
      obs_mod_data = precip_all_data,
      which_anom = smoothed_anom,
      min_hind_yr = min_hind_yr)

    ### Create the plot ###
    precip_hc <- create_hc_plot(precip_all_adj,
                                 "Precipitation in the Contiguous 48 States, 1901–2100",
                                 "Precipitation Anomaly (inches)",
                                 " in.")

    output$plot <- highcharter::renderHighchart({

      precip_hc

    })

    # reactive values
    precip_plot <- reactiveVal()
    precip_plot(precip_hc)

    return(precip_plot)


  })
}

## To be copied in the UI
# mod_precip_plot_ui("precip_plot_1")

## To be copied in the server
# mod_precip_plot_server("precip_plot_1")
