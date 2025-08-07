#' grow_season_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_grow_season_map_ui <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(

      column(6,

             selectInput(ns("scenario_choice"),
                         label = "Choose a Scenario",
                         choices =  c("Observations, 1895–2023",
                                      "Low emissions (SSP1-2.6), 2024–2100",
                                      "Intermediate emissions (SSP2-4.5), 2024–2100",
                                      "High emissions (SSP3-7.0), 2024–2100",
                                      "Very high emissions (SSP5-8.5), 2024–2100")
             )

      ),

      column(6,

             selectInput(ns("scenario_choice_2"),
                         label = "Choose a Scenario",
                         choices =  c("Observations, 1895–2023",
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
    $('#mod_gs_map_comparison_slider').beforeAfter({
        introDelay: 2000,
        imagePath: 'img/',
        introDuration: 500,
        showFullLinks: false
    })
                });
    "),
    shinycssloaders::withSpinner(
      tags$div(
        id = "mod_gs_map_comparison_slider",
        plotOutput(ns("map"), width = "400px", height = "400px"),
        plotOutput(ns("map_2"), width = "400px", height = "400px"),
      )
    )

  )
}

#' grow_season_map Server Functions
#'
#' @noRd
mod_grow_season_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Make the maps ------------------------------------------------------------

    gs_colors <- c(

      "(-15,-1]" = "#DBC3AB",
      "(-1,1]" = "white",
      "(1,15]" = "#d1eac7",
      "(15,30]" = "#a9c99d",
      "(30,45]" = "#82a875",
      "(45,60]" = "#5b884e",
      "(60,75]" = "#346a29",
      "(75,90]"= "#004c00"

    )

    # Get all the scenarios in the data
    all_scenarios <- unique(grow_seas_map_cln_data$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values

    # Create a map for each scenario
    all_maps <- lapply(
      all_scenarios,
      create_static_map,
      grow_seas_map_cln_data,
      gs_colors,
      "Change in Length of Growing Season by State",
      "Change in length of\ngrowing season (days)")


# Make reactive -----------------------------------------------------------

    output$map <- renderPlot({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice,
                          "Observations, 1895–2023" = all_maps$observed,
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
                          "Observations, 1895–2023" = all_maps$observed,
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
# mod_grow_season_map_ui("grow_season_map_1")

## To be copied in the server
# mod_grow_season_map_server("grow_season_map_1")
