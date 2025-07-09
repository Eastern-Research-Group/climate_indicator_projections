#' av_temp_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_av_temp_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' av_temp_plot Server Functions
#'
#' @noRd
mod_av_temp_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Get data ready for plotting ###

    # Read in data
    av_temp_path <- "inst/extdata/av_temp" # path to data
    temp_obs_raw <- readr::read_csv(file.path(av_temp_path, "temperature_fig-1.csv"), skip = 6) # Observed
    temp_model_av <- readr::read_csv(file.path(av_temp_path,'conus_AvgAnnualTemp.csv')) # Model average
    temp_model_all <- vroom::vroom(list.files(path = av_temp_path, pattern = 'avg_ann_temp_conus_av_*', full.names = TRUE)) %>%  # Each model
      dplyr::filter(scenario != "hist")

    # Set years for calculating anomalies
    min_obs_yr <- 1950
    base_yr_start <- 1951
    base_yr_end <- 2000

    # Clean data
    temp_obs_cln <- temp_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::select(year, earths_surface) %>%
      dplyr::rename(anomaly = earths_surface) %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::mutate(smoothed_anom = anomaly) # this anomaly is already smoothed so rename

    temp_model_av_cln <- temp_model_av %>%
      dplyr::filter(!is.na(av_temp)) %>%
      calc_anom(., av_temp, base_yr_start, base_yr_end, 11, FALSE) %>% # calculate anomaly
      dplyr::select(year, scenario, anomaly, smoothed_anom) %>%
      dplyr::filter(scenario != "nclimgrid") %>%  # remove nclimgrid
      rbind(temp_obs_cln) # bind with observed data

    # Process and align the model data
    temp_all_adj <- model_processing(
      mod_data = temp_model_all,
      var_name = avg_ann_temp_f,
      base_start = base_yr_start,
      base_end = base_yr_end,
      model_range = TRUE,
      obs_mod_data = temp_model_av_cln,
      which_anom = anomaly,
      min_obs_yr = min_obs_yr)

    ### Create the plot ###
    av_temp_hc <- create_hc_plot(temp_all_adj,
                                 "Temperatures in the Contiguous 48 States, 1901–2100",
                                 "Temperature Anomaly (°F)",
                                 "°F")

    output$plot <- highcharter::renderHighchart({

      av_temp_hc

    })

    # reactive values
    av_temp_plot <- reactiveVal()
    av_temp_plot(av_temp_hc)

    return(av_temp_plot)



  })
}

## To be copied in the UI
# mod_av_temp_plot_ui("av_temp_plot_1")

## To be copied in the server
# mod_av_temp_plot_server("av_temp_plot_1")
