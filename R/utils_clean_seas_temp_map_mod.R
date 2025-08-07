#' clean_seas_temp_map_mod
#'
#' @param which_season String of which season (e.g. Fall, Winter, etc.)
#' @param seas_temp_obs_data The observed data
#' @param conus_gdf The conus geodataframe
#'
#' @description Clean and prepare the seasonal temperature map data
#'
#' @return Dataframe of seasonal temperature map data
#'
#' @noRd

clean_seas_temp_map_mod <- function(which_season, seas_temp_obs_data, conus_gdf){

  # Read in the data --------------------------------------------------------
  seas_temp_map_raw <- readr::read_csv(file.path(config::get("seas_temp_path"), sprintf("states_avg_%s_temp.csv", stringr::str_to_lower(which_season))))

  # Clean the observed data -------------------------------------------------
  obs_filter <- seas_temp_obs_data %>%
    dplyr::filter(season == which_season) %>%
    dplyr::select(-season)

  # Clean the model average ------------------------------------------------
  seas_temp_map_cln_data <- seas_temp_map_raw %>%
    # Calculate the anomaly for each state
    calc_anom(mod_data = .,
              var_name = av_temp,
              base_start = 1951,
              base_end = 2000,
              window_size = 11,
              nclimgrid_smooth = TRUE,
              model_range = FALSE,
              for_maps = TRUE) %>%
    # Calculate total change from 2024 through 2100
    calc_total_change(anom_data = .,
                      var_name = anomaly,
                      start_yr = 2024,
                      climdiv_map = FALSE
    ) %>%
    # Combine with observed data
    rbind(obs_filter) %>%
    # Combine with conus geospatial file
    dplyr::left_join(conus_gdf, by = dplyr::join_by(state == stusps)) %>%
    sf::st_as_sf() %>%
    rename_scenarios(., TRUE) %>%
    # Create legend buckets
    dplyr::mutate(legend_buckets = cut(total_change,
                                       breaks=c(-2, -0.1, 0.1, 2, 4, 6, 8, 10, 12, 14)))

    # Set the factors
  seas_temp_map_cln_data$legend_buckets <- as.factor(seas_temp_map_cln_data$legend_buckets)

  return(seas_temp_map_cln_data)

}
