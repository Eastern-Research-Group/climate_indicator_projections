#' seasonal_temp_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_seasonal_temp_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("season_choice"),
                label = "Choose a Season",
                choices = c("Fall",
                            "Winter",
                            "Spring",
                            "Summer")),

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' seasonal_temp_plot Server Functions
#'
#' @noRd
mod_seasonal_temp_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Set years ---------------------------------------------------------------

    base_yr_start <- 1951
    base_yr_end <- 2000

# Reactive ------------------------------------------------------------

    seas_proj_adj_out <- reactive({

      # Set variable values depending on which season is selected
      if (input$season_choice == "Fall") {

        seas_proj_adj <- seas_temp_plot_cln_data_fall

      } else if (input$season_choice == "Winter"){

        seas_proj_adj <- seas_temp_plot_cln_data_winter

      } else if (input$season_choice == "Spring"){

        seas_proj_adj <- seas_temp_plot_cln_data_spring

      } else if (input$season_choice == "Summer"){

        seas_proj_adj <- seas_temp_plot_cln_data_summer

      }

      return(seas_proj_adj)

    })



    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(seas_proj_adj_out(),
                              sprintf("Average %s Temperature in the Contiguous 48 States, 1896–2100", input$season_choice),
                              "Temperature Anomaly (°F)",
                              "°F")

    })


  })
}

## To be copied in the UI
# mod_seasonal_temp_plot_ui("seasonal_temp_plot_1")

## To be copied in the server
# mod_seasonal_temp_plot_server("seasonal_temp_plot_1")
