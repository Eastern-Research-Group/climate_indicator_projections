
AV_TEMP_MAP_COLORS <- c(
  "(-0.1,0.1]" = "#C7C7C7",
  "(0.1,2]" = "#F0D7D6",
  "(2,4]" =  "#F1C1BE",
  "(4,6]" = "#EF9F9C",
  "(6,8]" = "#ED7974",
  "(8,10]" = "#E8413E",
  "(10,12]" = "#BD2B2D",
  "(12,14]" = "#A02725",
  "(14,16]" = "#780707"
)

#' av_temp_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_av_temp_map_ui <- function(id) {
  ns <- NS(id)

  render_map_page(

    map=create_static_map_ui(
      ns,
      obs_dates="1901–2023",
      proj_dates="2024–2100",
      title="Rate of Temperature Change in the United States",
      legend=create_map_legend(
        AV_TEMP_MAP_COLORS
      )
    )
  )

}

#' av_temp_map Server Functions
#'
#' @noRd
mod_av_temp_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Make the maps ------------------------------------------------------------

  # Get all the scenarios in the data
  all_scenarios <- unique(av_temp_map_cln_data$scenario)
  names(all_scenarios) <- all_scenarios  # Set names to match values
  # Create a map for each scenario
  all_maps <- lapply(
    all_scenarios,
    create_static_map,
    av_temp_map_cln_data,
    AV_TEMP_MAP_COLORS,
    "Rate of Temperature Change in the United States",
    "Rate of temperature change\n(°F per century)")

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
# mod_av_temp_map_ui("av_temp_map_1")

## To be copied in the server
# mod_av_temp_map_server("av_temp_map_1")
