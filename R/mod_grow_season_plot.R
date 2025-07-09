#' grow_season_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_grow_season_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' grow_season_plot Server Functions
#'
#' @noRd
mod_grow_season_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    ### Get data ready for plotting ###
    min_obs_yr <- 1955
    base_yr_start <- 1951
    base_yr_end <- 2000

    # read in the data
    gs_path <- "inst/extdata/grow_season" # path to data
    gs_obs_length_raw <- readr::read_csv(file.path(gs_path, "growing-season_fig-1.csv"), skip = 6) # observed data
    gs_length <- readr::read_csv(file.path(gs_path, "GrowingSeasonLength_USav.csv"))
    length_ssps <- vroom::vroom(list.files(path = gs_path, pattern = 'growing_seas_length_conus_av_*', full.names = TRUE)) # model averages

    # Clean data
    gs_obs_length <- gs_obs_length_raw %>%
      janitor::clean_names() %>%
      dplyr::rename(smoothed_anom = deviation_from_average_length_of_growing_season) %>%
      dplyr::mutate(scenario = "observed")

    # Calculate anomalies and moving average
    gs_proj_length_anom <- calc_anom(gs_length, GrowingSeasonLength, base_yr_start, base_yr_end, 11)

    # Combine with observed data
    gs_length_all <- gs_proj_length_anom %>%
      dplyr::select(year, scenario, smoothed_anom) %>%
      rbind(gs_obs_length) %>%
      dplyr::filter(scenario != "nclimgrid")

    # Process and align the model data
    gs_all_adj <- model_processing(
      mod_data = length_ssps,
      var_name = growing_seas_length_days,
      base_start = base_yr_start,
      base_end = base_yr_end,
      model_range = TRUE,
      obs_mod_data = gs_length_all,
      which_anom = smoothed_anom,
      min_obs_yr = min_obs_yr)

    ### Create the plot ###
    gs_hc <- create_hc_plot(gs_all_adj,
                                 "Length of Growing Season in the Contiguous 48 States, 1895–2100",
                                 "Deviation from average (days)",
                                 "days")

    output$plot <- highcharter::renderHighchart({

      gs_hc

    })

    # reactive values
    gs_plot <- reactiveVal()
    gs_plot(gs_hc)

    return(gs_plot)

  })
}

## To be copied in the UI
# mod_grow_season_plot_ui("grow_season_plot_1")

## To be copied in the server
# mod_grow_season_plot_server("grow_season_plot_1")
