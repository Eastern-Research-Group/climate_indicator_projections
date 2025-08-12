#' precip_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_precip_map_ui <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(

      column(4,

             selectInput(ns("scenario_choice"),
                         label = "Choose a Scenario",
                         choices = c("Observations, 1901–2023",
                                     "Low emissions (SSP1-2.6), 2024–2100",
                                     "Intermediate emissions (SSP2-4.5), 2024–2100",
                                     "High emissions (SSP3-7.0), 2024–2100",
                                     "Very high emissions (SSP5-8.5), 2024–2100")
             )

      ),

      column(4,

             selectInput(ns("scenario_choice_2"),
                         label = "Choose a Scenario",
                         choices = c("Observations, 1901–2023",
                                     "Low emissions (SSP1-2.6), 2024–2100",
                                     "Intermediate emissions (SSP2-4.5), 2024–2100",
                                     "High emissions (SSP3-7.0), 2024–2100",
                                     "Very high emissions (SSP5-8.5), 2024–2100"),
                         selected = "Very high emissions (SSP5-8.5), 2024–2100"
             )

      )

    ),

    # Before after slider
    tags$script("
              $(function() {
    $('#mod_precip_map_comparison_slider').beforeAfter({
        introDelay: 2000,
        imagePath: 'img/',
        introDuration: 500,
        showFullLinks: false
    })
                });
    "),
    shinycssloaders::withSpinner(
      tags$div(
        id = "mod_precip_map_comparison_slider",
        plotOutput(ns("map"), width = "400px", height = "400px"),
        plotOutput(ns("map_2"), width = "400px", height = "400px"),
      )
    )

  )
}

#' precip_map Server Functions
#'
#' @noRd
mod_precip_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Make the maps ------------------------------------------------------------

    precip_colors <- c(
      "(-30,-20]" = "#D9B651",
      "(-20,-10]" = "#E6CD8F",
      "(-10,-2]" = "#EFE2C7",
      "(-2,2]" = "#C7C7C7",
      "(2,10]" = "#91BBE1",
      "(10,20]" = "#4781D2",
      "(20,30]" = "#3466AC"
    )

    # Get all the scenarios in the data
    all_scenarios <- unique(precip_map_cln_data$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values
    # Create a map for each scenario
    all_maps <- lapply(
      all_scenarios,
      create_static_map,
      precip_map_cln_data,
      precip_colors,
      "Change in Precipitation in the United States",
      "Percent change in precipitation")

# Make reactive -----------------------------------------------------------

    output$map <- renderPlot({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice,
                          "Observations, 1901–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      return(which_map)

    })

    output$map_2 <- renderPlot({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice_2,
                          "Observations, 1901–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      return(which_map)

    })

  })
}

## To be copied in the UI
# mod_precip_map_ui("precip_map_1")

## To be copied in the server
# mod_precip_map_server("precip_map_1")
