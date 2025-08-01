#' grow_season_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_grow_season_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' grow_season_plot Server Functions
#'
#' @noRd
mod_grow_season_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Create the plot ###
    output$plot <- highcharter::renderHighchart({

      create_hc_plot(grow_seas_plot_cln_data,
                     "Length of Growing Season in the Contiguous 48 States, 1895–2100",
                     "Deviation from average (days)",
                     "days")

    })

  })
}

## To be copied in the UI
# mod_grow_season_plot_ui("grow_season_plot_1")

## To be copied in the server
# mod_grow_season_plot_server("grow_season_plot_1")
