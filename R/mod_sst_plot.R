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
  render_timeseries_page(
    title="",
    timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
  )
}

#' sst_plot Server Functions
#'
#' @noRd
mod_sst_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(sst_plot_cln_data,
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
