## code to prepare `seas_temp_map_obs` dataset goes here

seas_temp_map_obs_raw <- readr::read_csv(file.path(config::get("seas_temp_path"), "seasonal-temperature_fig-2.csv"), skip = 6)

seas_temp_map_obs <- seas_temp_map_obs_raw %>%
  tidyr::pivot_longer(cols = Winter:Fall, values_to = "total_change", names_to = "season") %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed")

usethis::use_data(seas_temp_map_obs, overwrite = TRUE)
