#' seasonal_temp_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_seasonal_temp_map_ui <- function(id) {
  ns <- NS(id)
  render_map_page(
    map=tagList(

    radioButtons(
      inputId = ns("seasonRadioButtons"),
      label = "Choose a season:",
      choices = c("Winter", "Spring", "Summer", "Fall"),
      selected = "Fall",
      inline = TRUE
    ),

    fluidRow(

      column(6,

             selectInput(ns("scenario_choice"),
                         label = "Choose a Scenario",
                         choices = c("Observations, 1896–2023",
                                     "Low emissions (SSP1-2.6), 2024–2100",
                                     "Intermediate emissions (SSP2-4.5), 2024–2100",
                                     "High emissions (SSP3-7.0), 2024–2100",
                                     "Very high emissions (SSP5-8.5), 2024–2100"),
                         width = "500px"
             )

      ),

      column(6,

             selectInput(ns("scenario_choice_2"),
                         label = "Choose a Scenario",
                         choices = c("Observations, 1896–2023",
                                     "Low emissions (SSP1-2.6), 2024–2100",
                                     "Intermediate emissions (SSP2-4.5), 2024–2100",
                                     "High emissions (SSP3-7.0), 2024–2100",
                                     "Very high emissions (SSP5-8.5), 2024–2100"),
                         selected = "Very high emissions (SSP5-8.5), 2024–2100",
                         width = "500px"
             )

      )

    ),

    # Before after slider
    tags$script("
              $(function() {
    $('#mod_seas_temp_map_comparison_slider').beforeAfter({
        introDelay: 2000,
        imagePath: 'img/',
        introDuration: 500,
        showFullLinks: false
    })
                });
    "),
    shinycssloaders::withSpinner(
      tags$div(
        id = "mod_seas_temp_map_comparison_slider",
        plotOutput(ns("map"), width = "600px", height = "600px"),
        plotOutput(ns("map_2"), width = "600px", height = "600px"),
      )
    )
)
  )
}

#' seasonal_temp_map Server Functions
#'
#' @noRd
mod_seasonal_temp_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Make the maps ------------------------------------------------------------

    seas_temp_colors <- c(
      "(-2,-0.1]" = "#D1D5EC",
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

    # Get all the scenarios in the data
    all_scenarios <- unique(seas_temp_map_cln_data_fall$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values

    # Create a map for each scenario and season
    fall_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_fall,
      seas_temp_colors,
      "Change in Fall Temperatures by State",
      "Total temperature change (°F)",
      "white")

    winter_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_winter,
      seas_temp_colors,
      "Change in Winter Temperatures by State",
      "Total temperature change (°F)",
      "white")

    spring_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_spring,
      seas_temp_colors,
      "Change in Spring Temperatures by State",
      "Total temperature change (°F)",
      "white")

    summer_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_summer,
      seas_temp_colors,
      "Change in Summer Temperatures by State",
      "Total temperature change (°F)",
      "white")


# Make reactive -----------------------------------------------------------

    output$map <- renderPlot({

      if (input$seasonRadioButtons == "Fall") {

        all_maps <- fall_maps

      } else if (input$seasonRadioButtons == "Winter"){

        all_maps <- winter_maps

      } else if (input$seasonRadioButtons == "Spring"){

        all_maps <- spring_maps

      } else if (input$seasonRadioButtons == "Summer"){

        all_maps <- summer_maps

      }

      # Map selection to file paths
      which_map <- switch(input$scenario_choice,
                          "Observations, 1896–2023" = all_maps$observed,
                          "Low emissions (SSP1-2.6), 2024–2100" = all_maps$ssp126,
                          "Intermediate emissions (SSP2-4.5), 2024–2100" = all_maps$ssp245,
                          "High emissions (SSP3-7.0), 2024–2100" = all_maps$ssp370,
                          "Very high emissions (SSP5-8.5), 2024–2100" = all_maps$ssp585
      )
      return(which_map)

    })

    output$map_2 <- renderPlot({

      if (input$seasonRadioButtons == "Fall") {

        all_maps <- fall_maps

      } else if (input$seasonRadioButtons == "Winter"){

        all_maps <- winter_maps

      } else if (input$seasonRadioButtons == "Spring"){

        all_maps <- spring_maps

      } else if (input$seasonRadioButtons == "Summer"){

        all_maps <- summer_maps

      }

      # Map selection to file paths
      which_map <- switch(input$scenario_choice_2,
                          "Observations, 1896–2023" = all_maps$observed,
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
# mod_seasonal_temp_map_ui("seasonal_temp_map_1")

## To be copied in the server
# mod_seasonal_temp_map_server("seasonal_temp_map_1")
