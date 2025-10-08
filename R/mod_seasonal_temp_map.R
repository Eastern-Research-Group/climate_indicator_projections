SEASONAL_TEMP_MAP_COLORS <- c(
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
  return(
    tagList(
      radioButtons(
        inputId = ns("seasonRadioButtons"),
        label = "Choose a season:",
        choices = c("Winter", "Spring", "Summer", "Fall"),
        selected = "Fall",
        inline = TRUE
      ),

      render_map_page(

        map=create_static_map_ui(
          ns,
          obs_dates="1896–2023",
          proj_dates="2024–2100",
          title=tagList(
            tags$p("Change in "),
            textOutput(ns("selected_text")),
            tags$p(" Temperatures by State")
          ),
          legend=create_map_legend(
            SEASONAL_TEMP_MAP_COLORS,
            label_text = "Total temperature change (°F)"
          )
        ),
        data_source=read_app_text("seasonal_temp/map_caption_data_source.html"),
        caption=read_app_text("seasonal_temp/map_caption_text.html")
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

    cln_data <- sf::st_as_sf(seas_temp_map_cln_data_fall)
    # Get all the scenarios in the data
    all_scenarios <- unique(cln_data$scenario)
    names(all_scenarios) <- all_scenarios  # Set names to match values

    # Create a map for each scenario and season
    fall_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_fall,
      SEASONAL_TEMP_MAP_COLORS,
      "Change in Fall Temperatures by State",
      "Total temperature change (°F)")

    winter_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_winter,
      SEASONAL_TEMP_MAP_COLORS,
      "Change in Winter Temperatures by State",
      "Total temperature change (°F)")

    spring_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_spring,
      SEASONAL_TEMP_MAP_COLORS,
      "Change in Spring Temperatures by State",
      "Total temperature change (°F)")

    summer_maps <- lapply(
      all_scenarios,
      create_static_map,
      seas_temp_map_cln_data_summer,
      SEASONAL_TEMP_MAP_COLORS,
      "Change in Summer Temperatures by State",
      "Total temperature change (°F)")


# Make reactive -----------------------------------------------------------

    output$selected_text <- renderText({
      input$seasonRadioButtons  # This returns the selected value from the radio button
    })

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

    }, width = 1000, height = 600)

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

    }, width = 1000, height = 600)

    outputOptions(output, "map", suspendWhenHidden = TRUE)
    outputOptions(output, "map_2", suspendWhenHidden = TRUE)

  })
}

## To be copied in the UI
# mod_seasonal_temp_map_ui("seasonal_temp_map_1")

## To be copied in the server
# mod_seasonal_temp_map_server("seasonal_temp_map_1")
