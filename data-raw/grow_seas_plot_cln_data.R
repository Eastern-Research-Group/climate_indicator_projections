## code to prepare `grow_seas_plot_cln_data` dataset goes here

# read in the data
grow_seas_plot_mod_all <- vroom::vroom(list.files(path = config::get("grow_seas_path"), pattern = 'growing_seas_length_conus_av_*', full.names = TRUE)) %>% # model averages
  dplyr::filter(scenario != "hist")
grow_seas_plot_mod_av_raw <- readr::read_csv(file.path(config::get("grow_seas_path"), "GrowingSeasonLength_USav.csv"))
grow_seas_plot_obs_raw <- readr::read_csv(file.path(config::get("grow_seas_path"), "growing-season_fig-1.csv"), skip = 6)

# Set year
min_hind_yr <- 1955
base_yr_start <- 1951
base_yr_end <- 2000

# Calculate anomalies and moving average
grow_seas_plot_mod_av <- grow_seas_plot_mod_av_raw %>%
  calc_anom(., GrowingSeasonLength, base_yr_start, base_yr_end, 11) %>%
  dplyr::select(year, scenario, smoothed_anom) %>%
  dplyr::filter(scenario != "nclimgrid")

# Clean observed
grow_seas_plot_obs <- grow_seas_plot_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::rename(smoothed_anom = deviation_from_average_length_of_growing_season) %>%
  dplyr::mutate(scenario = "observed")

# Combine model average with observed data
gs_obs_mod_av <- rbind(grow_seas_plot_obs, grow_seas_plot_mod_av)

# Process and align the model data
grow_seas_plot_cln_data <- model_processing(
  mod_data = grow_seas_plot_mod_all,
  var_name = growing_seas_length_days,
  base_start = base_yr_start,
  base_end = base_yr_end,
  obs_mod_data = gs_obs_mod_av,
  which_anom = smoothed_anom,
  min_hind_yr = min_hind_yr)

usethis::use_data(grow_seas_plot_cln_data, overwrite = TRUE)
