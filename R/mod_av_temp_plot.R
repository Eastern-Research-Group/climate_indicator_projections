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
  render_timeseries_page(
    title="",
    timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
  )
}

#' av_temp_plot Server Functions
#'
#' @noRd
mod_av_temp_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({
      print("Rendering plot for av_temp_plot")
      create_hc_plot(av_temp_plot_cln_data,
                     "Temperatures in the Contiguous 48 States, 1901-2100",
                     "Temperature Anomaly (°F)",
                     "°F")

    })
    outputOptions(output, "plot", suspendWhenHidden = TRUE)


  })
}

## To be copied in the UI
# mod_av_temp_plot_ui("av_temp_plot_1")

## To be copied in the server
# mod_av_temp_plot_server("av_temp_plot_1")
