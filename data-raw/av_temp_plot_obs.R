## code to prepare `av_temp_plot_obs` dataset goes here

# Read in data
av_temp_plot_obs_raw <- readr::read_csv(file.path(config::get("av_temp_path"), "temperature_fig-1.csv"), skip = 6)

# Clean data
av_temp_plot_obs <- av_temp_plot_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::select(year, earths_surface) %>%
  dplyr::rename(anomaly = earths_surface) %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::mutate(smoothed_anom = anomaly) # rename to combine with projected data

usethis::use_data(av_temp_plot_obs, overwrite = TRUE)
