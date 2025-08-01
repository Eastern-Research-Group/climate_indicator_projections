## code to prepare `grow_seas_plot_mod_av` dataset goes here

# read in the data
grow_seas_plot_mod_av_raw <- readr::read_csv(file.path(config::get("grow_seas_path"), "GrowingSeasonLength_USav.csv"))

# Set year
base_yr_start <- 1951
base_yr_end <- 2000

# Calculate anomalies and moving average
grow_seas_plot_mod_av <- grow_seas_plot_mod_av_raw %>%
  calc_anom(., GrowingSeasonLength, base_yr_start, base_yr_end, 11) %>%
  dplyr::select(year, scenario, smoothed_anom) %>%
  dplyr::filter(scenario != "nclimgrid")

usethis::use_data(grow_seas_plot_mod_av, overwrite = TRUE)
