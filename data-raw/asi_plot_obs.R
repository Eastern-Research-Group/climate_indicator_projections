## code to prepare `asi_plot_obs` dataset goes here

# Read in data
asi_plot_obs_raw <- readr::read_csv(file.path(config::get("asi_path"), "arctic-sea-ice_fig-1.csv"), skip = 6)

# Clean the data
asi_plot_obs <- asi_plot_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::select(year, september) %>%
  dplyr::rename(si_extent = september) %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::mutate(si_extent_smooth = si_extent)

usethis::use_data(asi_plot_obs, overwrite = TRUE)
