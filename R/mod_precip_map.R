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
    ),
    data_source=read_app_text("total_precip/map_caption_data_source.html"),
    caption=read_app_text("total_precip/map_caption_text.html")
  )

}

#' precip_map Server Functions
#'
#' @noRd
mod_precip_map_server <- function(id){

  all_maps <- generate_static_maps(
    sf::st_as_sf(precip_map_cln_data),
    id,
    which_colors=PRECIP_MAP_COLORS,
    title="Change in Precipitation in the United States",
    legend_title="Percent change in precipitation"
  )

  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Make reactive -----------------------------------------------------------

    output$map <- renderUI({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice,
                          "Observations, 1901–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      return(
        tags$img(
          src = which_map,
          width = "1000px",
          height="600px",
        )
      )

    })

    output$map_2 <- renderUI({

      # Map selection to file paths
      which_map <- switch(input$scenario_choice_2,
                          "Observations, 1901–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      return(
        tags$img(
          src =  which_map,
          width = "1000px",
          height="600px",
        )
      )

    })
    outputOptions(output, "map", suspendWhenHidden = TRUE)
    outputOptions(output, "map_2", suspendWhenHidden = TRUE)

  })
}

## To be copied in the UI
# mod_precip_map_ui("precip_map_1")

## To be copied in the server
# mod_precip_map_server("precip_map_1")
