## code to prepare `av_temp_map_obs` dataset goes here

# Read in the data
av_temp_map_obs_raw <- readr::read_csv(file.path(config::get("av_temp_path"), "temperature_fig-3.csv"), skip = 6) # Observed

# Clean the data
av_temp_map_obs <- av_temp_map_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::rename(climdiv = climate_division) %>%
  dplyr::rename(rate_change_100 = temperature_change_1901_2000_denominator) %>%
  dplyr::select(climdiv, rate_change_100) %>%
  dplyr::mutate(scenario = "observed")

usethis::use_data(av_temp_map_obs, overwrite = TRUE)
