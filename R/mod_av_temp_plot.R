#' av_temp_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_av_temp_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

  )
}

#' av_temp_plot Server Functions
#'
#' @noRd
mod_av_temp_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Read in data
    av_temp_path <- "inst/extdata/av_temp" # path to data
    temp_obs_raw <- readr::read_csv(file.path(av_temp_path, "temperature_fig-1.csv"), skip = 6) # Observed
    temp_model_av <- readr::read_csv(file.path(av_temp_path,'conus_AvgAnnualTemp.csv')) # Model average
    temp_model_all <- vroom::vroom(list.files(path = av_temp_path, pattern = 'avg_ann_temp_conus_av_*', full.names = TRUE)) # Each model

    # Set years for calculating anomalies
    base_yr_start <- 1951
    base_yr_end <- 2000

    # Clean data
    temp_obs_cln <- temp_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::select(year, earths_surface) %>%
      dplyr::rename(anomaly = earths_surface) %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::mutate(smoothed_anom = anomaly) # this anomaly is already smoothed so rename

    temp_model_av_cln <- temp_model_av %>%
      dplyr::filter(!is.na(av_temp)) %>%
      calc_anom(., av_temp, base_yr_start, base_yr_end, 11, FALSE) %>% # calculate anomaly
      dplyr::select(year, scenario, anomaly, smoothed_anom) %>%
      dplyr::filter(scenario != "nclimgrid") %>%  # remove nclimgrid
      rbind(obs_cln) # bind with observed data

    # Calculate the model range
    temp_mod_range <- calc_anom(temp_model_all, avg_ann_temp_f, base_yr_start, base_yr_end, 11, FALSE, TRUE) %>%
      calc_model_range(., anomaly)

    # Align modeled data with observed data
    obs_proj_diff <- calc_diff_avs(temp_model_av_cln, "observed", "hindcast", anomaly, 1950, 2014) # av diff value
    temp_all_adj <- adjust_anomaly(temp_model_av_cln, obs_proj_diff, NA, smoothed_anom) %>%
      adj_mod_range(., temp_mod_range, obs_proj_diff)

  })
}

## To be copied in the UI
# mod_av_temp_plot_ui("av_temp_plot_1")

## To be copied in the server
# mod_av_temp_plot_server("av_temp_plot_1")
