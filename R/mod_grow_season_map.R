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
    ),
    data_source=read_app_text("grow_season/map_caption_data_source.html"),
    caption=read_app_text("grow_season/map_caption_text.html")
  )

}

#' grow_season_map Server Functions
#'
#' @noRd
mod_grow_season_map_server <- function(id){

  all_maps <- generate_static_maps(
    sf::st_as_sf(grow_seas_map_cln_data),
    id,
    which_colors=GROW_SEASON_MAP_COLORS,
    title="Change in Length of Growing Season by State",
    legend_title="Change in length of\ngrowing season (days)"
  )

  obs_alt = "Map of the contiguous United States showing the observed change in length of the growing season from 1895 to 2023 by state."
  low_alt = "Map of the contiguous United States showing the projected change in length of the growing season from 2024 to 2100 under the low emissions scenario (SSP1-2.6) by state."
  intmd_alt = "Map of the contiguous United States showing the projected change in length of the growing season from 2024 to 2100 under the intermediate emissions scenario (SSP2-4.5) by state."
  high_alt = "Map of the contiguous United States showing the projected change in length of the growing season from 2024 to 2100 under the high emissions scenario (SSP3-7.0) by state."
  v_high_alt = "Map of the contiguous United States showing the projected change in length of the growing season from 2024 to 2100 under the very high emissions scenario (SSP5-8.5) by state."

  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Make reactive -----------------------------------------------------------

    output$map <- renderUI({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice,
                          "Observations, 1895–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      # Alt text for each map
      alt_text <- switch(input$scenario_choice,
                         "Observations, 1895–2023" = obs_alt,
                         "Low emissions (SSP1-2.6), 2024–2100" = low_alt,
                         "Intermediate emissions (SSP2-4.5), 2024–2100" = intmd_alt,
                         "High emissions (SSP3-7.0), 2024–2100" = high_alt,
                         "Very high emissions (SSP5-8.5), 2024–2100" = v_high_alt
      )

      return(
        tags$img(
          src = which_map,
          width = "1000px",
          height="600px",
          alt=alt_text
        )
      )

    })

    output$map_2 <- renderUI({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice_2,
                          "Observations, 1895–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      # Alt text for each map
      alt_text <- switch(input$scenario_choice_2,
                         "Observations, 1895–2023" = obs_alt,
                         "Low emissions (SSP1-2.6), 2024–2100" = low_alt,
                         "Intermediate emissions (SSP2-4.5), 2024–2100" = intmd_alt,
                         "High emissions (SSP3-7.0), 2024–2100" = high_alt,
                         "Very high emissions (SSP5-8.5), 2024–2100" = v_high_alt
      )

      return(
        tags$img(
          src = which_map,
          width = "1000px",
          height="600px",
          alt=alt_text
        )
      )

    })
    outputOptions(output, "map", suspendWhenHidden = TRUE)
    outputOptions(output, "map_2", suspendWhenHidden = TRUE)

  })
}

## To be copied in the UI
# mod_grow_season_map_ui("grow_season_map_1")

## To be copied in the server
# mod_grow_season_map_server("grow_season_map_1")
