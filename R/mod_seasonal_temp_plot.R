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

    # Read in data
    st_path <- "inst/extdata/seasonal_temp" # path to data
    obs_raw <- readr::read_csv(file.path(st_path, "seasonal-temperature_fig-1.csv"), skip = 6)
    fall_proj <- readr::read_csv(file.path(st_path,'conus_avg_fall_temp.csv')) # Average Conus
    fall_ssps <- vroom::vroom(list.files(path = st_path, pattern = 'avg_son_temp_conus_av_*', full.names = TRUE)) # model averages

    fall_test <- process_seasons(
      which_season = "Fall",
      obs_data = obs_raw,
      proj_data = fall_proj,
      ssp_data = fall_ssps,
      ssp_var = avg_son_temp_f,
      base_yr_start = base_yr_start,
      base_yr_end = base_yr_end
      )

    ### Create the plot ###
    st_hc <- create_hc_plot(fall_test,
                            "Average Fall Temperature in the Contiguous 48 States, 1895–2100",
                            "Temperature Anomaly (°F)",
                            "°F")

    output$plot <- highcharter::renderHighchart({

      st_hc

    })

    # reactive values
    st_plot <- reactiveVal()
    st_plot(st_hc)

    return(st_plot)

  })
}

## To be copied in the UI
# mod_seasonal_temp_plot_ui("seasonal_temp_plot_1")

## To be copied in the server
# mod_seasonal_temp_plot_server("seasonal_temp_plot_1")
