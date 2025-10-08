#' slr_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_slr_plot_ui <- function(id) {
  ns <- NS(id)
  render_timeseries_page(
    title="",
    timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
    data_source=read_app_text("sea_level/plot_caption_data_source.html"),
    caption=read_app_text("sea_level/plot_caption_text.html")
  )
}

#' slr_plot Server Functions
#'
#' @noRd
mod_slr_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Create the plot ---------------------------------------------------------

  output$plot <- highcharter::renderHighchart({

    create_slr_plot(slr_plot_obs,
                    slr_plot_mod_all,
                    slr_plot_obs_csiro_bounds)

  })
  outputOptions(output, "plot", suspendWhenHidden = TRUE)
  })
}

## To be copied in the UI
# mod_slr_plot_ui("slr_plot_1")

## To be copied in the server
# mod_slr_plot_server("slr_plot_1")
