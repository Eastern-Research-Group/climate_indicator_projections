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

    ### Create the plot ###
    output$plot <- highcharter::renderHighchart({

      create_hc_plot(precip_plot_cln_data,
                     "Precipitation in the Contiguous 48 States, 1901–2100",
                     "Precipitation Anomaly (inches)",
                     " in.")

    })


  })
}

## To be copied in the UI
# mod_precip_plot_ui("precip_plot_1")

## To be copied in the server
# mod_precip_plot_server("precip_plot_1")
