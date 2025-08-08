## code to prepare `precip_map_cln_data` dataset goes here

# Set the years -----------------------------------------------------------

# Read in the data --------------------------------------------------------
precip_map_obs_raw <- readr::read_csv(file.path(config::get("precip_path"), "precipitation_fig-3.csv"), skip = 6)

# Clean the observed data -------------------------------------------------
precip_map_obs_cln <- precip_map_obs_raw %>%
  # Clean up the names
  janitor::clean_names() %>%
  dplyr::select(-precipitation_change_1925_2000_denominator) %>%
  dplyr::rename(climdiv = climate_division_id) %>%
  dplyr::rename(perc_change = precipitation_change_1901_2000_denominator)  %>%
  dplyr::mutate(scenario = "observed") %>%
  # Make percent change numeric
  dplyr::mutate(perc_change = stringr::str_remove(perc_change, "%")) %>%
  dplyr::mutate(perc_change = as.numeric(perc_change)) %>%
  dplyr::filter(!is.na(perc_change))


# Clean the model average -------------------------------------------------

# Combine and process -----------------------------------------------------

precip_map_cln_data <- precip_map_obs_cln %>%  # FIX THIS WHEN GET PROJECTIONS DATA
  rename_scenarios(., TRUE) %>%
  # Create legend buckets
  dplyr::mutate(legend_buckets = cut(perc_change,
                                     breaks=c(-30, -20, -10, -2, 2, 10, 20, 30))) %>%
  # Make geospatial with climate division file
  dplyr::left_join(clim_div_cln, by = "climdiv") %>%
  sf::st_as_sf()


usethis::use_data(precip_map_cln_data, overwrite = TRUE)
