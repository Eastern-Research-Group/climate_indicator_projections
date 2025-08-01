## code to prepare `grow_seas_plot_obs` dataset goes here

# Read in data
grow_seas_plot_obs_raw <- readr::read_csv(file.path(config::get("grow_seas_path"), "growing-season_fig-1.csv"), skip = 6)

# Clean data
grow_seas_plot_obs <- grow_seas_plot_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::rename(smoothed_anom = deviation_from_average_length_of_growing_season) %>%
  dplyr::mutate(scenario = "observed")

usethis::use_data(grow_seas_plot_obs, overwrite = TRUE)
