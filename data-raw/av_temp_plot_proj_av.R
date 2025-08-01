## code to prepare `av_temp_plot_proj_av` dataset goes here

# Read in the data
av_temp_plot_proj_av_raw <- readr::read_csv(file.path(config::get("av_temp_path"),'conus_AvgAnnualTemp.csv')) # Model average

# Set years for calculating anomalies
base_yr_start <- 1951
base_yr_end <- 2000

# Clean the data
av_temp_plot_proj_av <- av_temp_plot_proj_av_raw %>%
  dplyr::filter(!is.na(av_temp)) %>%
  calc_anom(., av_temp, base_yr_start, base_yr_end, 11, FALSE) %>% # calculate anomaly
  dplyr::select(year, scenario, anomaly, smoothed_anom) %>%
  dplyr::filter(scenario != "nclimgrid") # remove nclimgrid

usethis::use_data(av_temp_plot_proj_av, overwrite = TRUE)
