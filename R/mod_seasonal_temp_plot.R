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

    # Set years
    base_yr_start <- 1951
    base_yr_end <- 2000

    # Set path
    st_path <- "inst/extdata/seasonal_temp"

    # Read in observed data
    obs_raw <- readr::read_csv(file.path(st_path, "seasonal-temperature_fig-1.csv"), skip = 6)



    seas_proj_adj_out <- reactive({

      # Set variable values depending on which season is selected
      if (input$season_choice == "Fall") {

        proj_av_pattern <- "fall"
        proj_all_pattern <- "son"
        var_name <- "avg_son_temp_f"

      } else if (input$season_choice == "Winter"){

        proj_av_pattern <- "winter"
        proj_all_pattern <- "djf"
        var_name <-  "avg_djf_temp_f"
      } else if (input$season_choice == "Spring"){

        proj_av_pattern <- "spring"
        proj_all_pattern <- "mam"
        var_name <- "avg_mam_temp_f"

      } else if (input$season_choice == "Summer"){

        proj_av_pattern <- "summer"
        proj_all_pattern <- "jja"
        var_name <-"avg_jja_temp_f"

      }

      # read in the projections dataset for the chosen season
      proj_av <- readr::read_csv(file.path(st_path, sprintf('conus_avg_%s_temp.csv', proj_av_pattern))) # Average Conus
      proj_all <- vroom::vroom(list.files(path = st_path, pattern = sprintf('avg_%s_temp_conus_av_*', proj_all_pattern), full.names = TRUE)) %>% # model averages
        dplyr::rename("avg_temp_f" = {{var_name}})

      # Process the projections indicator
      seas_proj_adj <- process_seasons(
        which_season = tools::toTitleCase(proj_av_pattern),
        obs_data = obs_raw,
        proj_data = proj_av,
        ssp_data = proj_all,
        ssp_var = avg_temp_f,
        base_yr_start = base_yr_start,
        base_yr_end = base_yr_end
      )

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
