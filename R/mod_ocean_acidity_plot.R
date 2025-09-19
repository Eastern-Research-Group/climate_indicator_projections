#' ocean_acidity_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ocean_acidity_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("station_choice"),
                label = "Choose a Station",
                choices = c("Hawaii",
                            "Canary Islands",
                            "Bermuda",
                            "Cariaco"
                            )),

    render_timeseries_page(
      title="",
      timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
    )

  )
}

#' ocean_acidity_plot Server Functions
#'
#' @noRd
mod_ocean_acidity_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # reactive part
    oa_proj_all_out <- reactive({
      req(input$station_choice)
      oa_proj_all <- switch(
        input$station_choice,
        "Hawaii" = oa_plot_cln_data_hawaii,
        "Canary Islands" = oa_plot_cln_data_canary_islands,
        "Bermuda" = oa_plot_cln_data_bermuda,
        "Cariaco" = oa_plot_cln_data_cariaco
      )
      return(oa_proj_all)

    })


    ### Create the plot ###
    output$plot <- highcharter::renderHighchart({
      p <- create_hc_plot(oa_proj_all_out(),
                     sprintf("%s Ocean Acidity, 1950–2100", input$station_choice),
                     "pH (lower pH = more acidic)",
                     "",
                     TRUE)
      return(p)

    })

    outputOptions(output, "plot", suspendWhenHidden = TRUE)

  })
}

## To be copied in the UI
# mod_ocean_acidity_plot_ui("ocean_acidity_plot_1")

## To be copied in the server
# mod_ocean_acidity_plot_server("ocean_acidity_plot_1")
