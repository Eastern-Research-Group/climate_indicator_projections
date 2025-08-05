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
  tagList(

    fluidRow(

      column(4,

        selectInput(ns("scenario_choice"),
                    label = "Choose a Scenario",
                    choices = c("Observations",
                                "Low emissions (SSP1-2.6)",
                                "Intermediate emissions (SSP2-4.5)",
                                "High emissions (SSP3-7.0)",
                                "Very high emissions (SSP5-8.5)")
        )

      ),

      column(4,

        selectInput(ns("scenario_choice_2"),
                    label = "Choose a Scenario",
                    choices = c("Observations",
                                "Low emissions (SSP1-2.6)",
                                "Intermediate emissions (SSP2-4.5)",
                                "High emissions (SSP3-7.0)",
                                "Very high emissions (SSP5-8.5)"),
                    selected = "Very high emissions (SSP5-8.5)"
        )

      )

    ),

    # Before after slider
    tags$script("
              $(function() {
    $('#mod_av_temp_map_comparison_slider').beforeAfter({
        introDelay: 2000,
        imagePath: 'img/',
        introDuration: 500,
        showFullLinks: false
    })
                });
    "),
    shinycssloaders::withSpinner(
      tags$div(
        id = "mod_av_temp_map_comparison_slider",
        plotOutput(ns("map"), width = "400px", height = "400px"),
        plotOutput(ns("map_2"), width = "400px", height = "400px"),
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

    temp_colors <- c(
      "(-0.1,0]" = "#C7C7C7",
      "(0,0.1]" = "#C7C7C7",
      "(0.1,2]" = "#F0D7D6",
      "(2,4]" =  "#F1C1BE",
      "(4,6]" = "#EF9F9C",
      "(6,8]" = "#ED7974",
      "(8,10]" = "#E8413E",
      "(10,12]" = "#BD2B2D"
    )


  make_temp_map <- function(which_scenario, all_temps_df, which_colors){

    # Filter to the map
    which_map <- all_temps_df %>%
      dplyr::filter(scenario == which_scenario)

    temp_map <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets), color = "#88807F") +
      #  ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets, color = legend_buckets)) +
      ggplot2::scale_fill_manual(values = which_colors, drop = FALSE) +
      #  ggplot2::scale_color_manual(values = temp_colors, drop = FALSE) +
      ggplot2::geom_sf(data = conus_cln, fill = NA, color = "black") +
      ggplot2::labs(
        title = "Rate of Temperature Change in the United States, 2024–2100",
        fill = "Rate of temperature change\n(°F per century)"
      ) +
      ggthemes::theme_map() +
      ggplot2::theme(
        text = ggplot2::element_text(size = 12),
        plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
        #   legend.key.width = ggplot2::unit(2, 'cm'),
        legend.position = "bottom"
      )

    return(temp_map)

  }

  all_scenarios <- unique(av_temp_map_cln_data$scenario)
  names(all_scenarios) <- all_scenarios  # Set names to match values
  all_maps <- lapply(all_scenarios, make_temp_map, av_temp_map_cln_data, temp_colors)



# Make reactive -----------------------------------------------------------

  output$map <- renderPlot({

     # Map selection to file paths
    which_map <- switch(input$scenario_choice,
                        "Observations" = all_maps$observed,
                        "Low emissions (SSP1-2.6)" = all_maps$ssp126,
                        "Intermediate emissions (SSP2-4.5)" = all_maps$ssp245,
                        "High emissions (SSP3-7.0)" = all_maps$ssp370,
                        "Very high emissions (SSP5-8.5)" = all_maps$ssp585
                        )
    return(which_map)

  })

  output$map_2 <- renderPlot({

    # Map selection to file paths
    which_map <- switch(input$scenario_choice_2,
                        "Observations" = all_maps$observed,
                        "Low emissions (SSP1-2.6)" = all_maps$ssp126,
                        "Intermediate emissions (SSP2-4.5)" = all_maps$ssp245,
                        "High emissions (SSP3-7.0)" = all_maps$ssp370,
                        "Very high emissions (SSP5-8.5)" = all_maps$ssp585
    )
    return(which_map)

  })
})
}


## To be copied in the UI
# mod_av_temp_map_ui("av_temp_map_1")

## To be copied in the server
# mod_av_temp_map_server("av_temp_map_1")
