## code to prepare `slr_plot_obs_csiro_bounds` dataset goes here

# Read in the data
slr_plot_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-1.csv"), skip = 6) %>%
  janitor::clean_names()

# Get CSIRO bounds
slr_plot_obs_csiro_bounds <- slr_plot_obs_raw %>%
  dplyr::select(year, csiro_lower_error_bound_inches, csiro_upper_error_bound_inches) %>%
  dplyr::mutate(scenario = "Tide gauge range") %>%
  dplyr::mutate(year = as.numeric(year))

usethis::use_data(slr_plot_obs_csiro_bounds, overwrite = TRUE)
