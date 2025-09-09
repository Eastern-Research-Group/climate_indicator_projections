GROW_SEASON_MAP_COLORS <- c(

  "(-15,-1]" = "#DBC3AB",
  "(-1,1]" = "white",
  "(1,15]" = "#d1eac7",
  "(15,30]" = "#a9c99d",
  "(30,45]" = "#82a875",
  "(45,60]" = "#5b884e",
  "(60,75]" = "#346a29",
  "(75,90]"= "#004c00"

)
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

  render_map_page(

    map=create_static_map_ui(
      ns,
      obs_dates="1895–2023",
      proj_dates="2024–2100",
      title="Change in Length of Growing Season by State",
      legend=create_map_legend(
        GROW_SEASON_MAP_COLORS,
        label_text = "Change in length of growing season (days)"
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

    # Get all the scenarios in the data
    all_scenarios <- unique(grow_seas_map_cln_data$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values

    # Create a map for each scenario
    all_maps <- lapply(
      all_scenarios,
      create_static_map,
      grow_seas_map_cln_data,
      GROW_SEASON_MAP_COLORS,
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

    }, width = 1000, height = 600)

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

    }, width = 1000, height = 600)

  })
}

## To be copied in the UI
# mod_grow_season_map_ui("grow_season_map_1")

## To be copied in the server
# mod_grow_season_map_server("grow_season_map_1")
