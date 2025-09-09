PRECIP_MAP_COLORS <- c(
  "(-30,-20]" = "#D9B651",
  "(-20,-10]" = "#E6CD8F",
  "(-10,-2]" = "#EFE2C7",
  "(-2,2]" = "#C7C7C7",
  "(2,10]" = "#91BBE1",
  "(10,20]" = "#4781D2",
  "(20,30]" = "#3466AC"
)
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

  render_map_page(

    map=create_static_map_ui(
      ns,
      obs_dates="1901–2023",
      proj_dates="2024–2100",
      title="Change in Precipitation in the United States",
      legend=create_map_legend(
        PRECIP_MAP_COLORS,
        label_text = "Percent change in precipitation"
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

    # Get all the scenarios in the data
    all_scenarios <- unique(precip_map_cln_data$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values
    # Create a map for each scenario
    all_maps <- lapply(
      all_scenarios,
      create_static_map,
      precip_map_cln_data,
      PRECIP_MAP_COLORS,
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

    }, width = 1000, height = 600)

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

    }, width = 1000, height = 600)

  })
}

## To be copied in the UI
# mod_precip_map_ui("precip_map_1")

## To be copied in the server
# mod_precip_map_server("precip_map_1")
