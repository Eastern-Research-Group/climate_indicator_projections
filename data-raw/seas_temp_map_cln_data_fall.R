## code to prepare `seas_temp_map_cln_data_fall` dataset goes here

# Set the years -----------------------------------------------------------
min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data
base_yr_start <- 1951
base_yr_end <- 2000

# Read in the data --------------------------------------------------------
seas_temp_map_fall_raw <- readr::read_csv(file.path(config::get("seas_temp_path"), "states_avg_fall_temp.csv"))

# Clean the observed data -------------------------------------------------
# Get fall observed data
fall_obs <- seas_temp_map_obs %>%
  dplyr::filter(season == "Fall") %>%
  dplyr::select(-season)

# Clean the model average -------------------------------------------------

seas_temp_map_cln_data_fall <- seas_temp_map_fall_raw %>%
  # Calculate the anomaly for each state
  calc_anom(mod_data = .,
            var_name = av_temp,
            base_start = base_yr_start,
            base_end = base_yr_end,
            window_size = 11,
            nclimgrid_smooth = TRUE,
            model_range = FALSE,
            for_maps = TRUE) %>%
  # Calculate total change from 2024 through 2100
  calc_total_change(anom_data = .,
                      var_name = anomaly,
                      start_yr = min_yr,
                      climdiv_map = FALSE
  ) %>%
  # Combine with observed data
  rbind(fall_obs) %>%
  # Combine with conus geospatial file
  dplyr::left_join(conus_cln, by = dplyr::join_by(state == stusps)) %>%
  sf::st_as_sf() %>%
  # Create legend buckets
  dplyr::mutate(legend_buckets = cut(total_change,
                                     breaks=c(-2, -0.1, 0.1, 2, 4, 6, 8, 10, 12))) %>%
  rename_scenarios(., TRUE)

# Set the factors
seas_temp_map_cln_data_fall$legend_buckets <- as.factor(seas_temp_map_cln_data_fall$legend_buckets)

usethis::use_data(seas_temp_map_cln_data_fall, overwrite = TRUE)
