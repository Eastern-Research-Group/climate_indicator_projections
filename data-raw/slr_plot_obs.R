## code to prepare `slr_plot_obs` dataset goes here

# Read in the data
slr_plot_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-1.csv"), skip = 6) %>%
  janitor::clean_names()

# Clean observed data
slr_plot_obs <- slr_plot_obs_raw %>%
  dplyr::select(-csiro_lower_error_bound_inches, -csiro_upper_error_bound_inches) %>%
  tidyr::pivot_longer(cols = c(csiro_adjusted_sea_level_inches, noaa_adjusted_sea_level_inches), names_to = "source", values_to = "slr_in") %>%
  dplyr::mutate(scenario = ifelse(source == "csiro_adjusted_sea_level_inches", "Tide gauge measurements", "Satellite measurements")) %>%
  dplyr::select(-source) %>%
  dplyr::filter(!is.na(slr_in)) %>%
  dplyr::mutate(year = as.numeric(year))

usethis::use_data(slr_plot_obs, overwrite = TRUE)
