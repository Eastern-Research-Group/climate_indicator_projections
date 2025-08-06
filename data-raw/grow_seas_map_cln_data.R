## code to prepare `grow_seas_map_cln_data` dataset goes here

# Set the years -----------------------------------------------------------
base_yr_start <- 1951
base_yr_end <- 2000
min_yr <- 2024

# Read in the data --------------------------------------------------------
gs_obs_raw <- readr::read_csv(file.path(config::get("grow_seas_path"), "growing-season_fig-3.csv"), skip = 6)
gs_mod_raw <- readr::read_csv(file.path(config::get("grow_seas_path"),"growing_seas_length_states.csv"))

# Clean the observed data -------------------------------------------------

gs_obs_cln <- gs_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::mutate(state = state.abb[match(state,state.name)]) %>%
  dplyr::rename(total_change = change_in_length_of_growing_season)

# Clean the model average, combine and process -------------------------------------------------

grow_seas_map_cln_data <- gs_mod_raw %>%
  janitor::clean_names() %>%
  calc_anom(.,
            var_name = growing_sea,
            base_start = base_yr_start,
            base_end = base_yr_end,
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
  rbind(gs_obs_cln) %>%
  # Combine with conus geospatial file
  dplyr::left_join(conus_cln, by = dplyr::join_by(state == stusps)) %>%
  sf::st_as_sf() %>%
  rename_scenarios(., TRUE) %>%
  # Create legend buckets
  dplyr::mutate(legend_buckets = cut(total_change,
                                     breaks=c(-15, -1,  1, 15, 30, 45, 60, 75, 90)))

# Set the factors
grow_seas_map_cln_data$legend_buckets <- as.factor(grow_seas_map_cln_data$legend_buckets)

usethis::use_data(grow_seas_map_cln_data, overwrite = TRUE)
