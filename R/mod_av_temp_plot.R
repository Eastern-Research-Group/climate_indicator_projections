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

    # Set years for calculating anomalies
    min_hind_yr <- 1955
    base_yr_start <- 1951
    base_yr_end <- 2000

    # Combine observed and projected average
    av_temp_obs_proj_av <- rbind(av_temp_plot_obs, av_temp_plot_proj_av) # bind with observed data

    # Process and align the model data
    temp_all_adj <- model_processing(
      mod_data = av_temp_plot_mod_all,
      var_name = avg_ann_temp_f,
      base_start = base_yr_start,
      base_end = base_yr_end,
      obs_mod_data = av_temp_obs_proj_av,
      which_anom = smoothed_anom,
      min_hind_yr = min_hind_yr)

    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(temp_all_adj,
                     "Temperatures in the Contiguous 48 States, 1901–2100",
                     "Temperature Anomaly (°F)",
                     "°F")

    })


  })
}

## To be copied in the UI
# mod_av_temp_plot_ui("av_temp_plot_1")

## To be copied in the server
# mod_av_temp_plot_server("av_temp_plot_1")
