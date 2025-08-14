#' arctic_sea_ice_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_arctic_sea_ice_plot_ui <- function(id) {
  ns <- NS(id)
  render_timeseries_page(
    title="",
    timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
  )
}

#' arctic_sea_ice_plot Server Functions
#'
#' @noRd
mod_arctic_sea_ice_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Create the plot ---------------------------------------------------------

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(asi_plot_cln_data,
                     "September Monthly Average Arctic Sea Ice Extent, 1950–2100",
                     "Sea Ice Extent (million square miles)",
                     " million square miles")

    })

  })
}

## To be copied in the UI
# mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1")

## To be copied in the server
# mod_arctic_sea_ice_plot_server("arctic_sea_ice_plot_1")
