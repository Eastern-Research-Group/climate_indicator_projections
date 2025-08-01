## code to prepare `oa_plot_mod_av` dataset goes here

# Read in the data
oa_plot_mod_av_raw <- readr::read_csv(file.path(config::get("oa_path"), "ph_bayesian_ave.csv"))

# tidy up the data
oa_plot_mod_av <- oa_plot_mod_av_raw %>%
  rename_stations() %>%
  dplyr::filter(year >= min_hind_yr) %>%
  # Create date column
  dplyr::mutate(date = lubridate::ymd(paste0(year, "-", month, "-01"))) %>%
  # average value betweeen the two Bermuda stations
  dplyr::group_by(station_name, scenario, date) %>%
  dplyr::mutate(ph = mean(ph)) %>%
  dplyr::slice(1) %>%
  dplyr::select(station_name, scenario, date, ph)

# Add 2009-2014 to the ssps so there isn't a gap when we smooth
oa_hind_years <- oa_plot_mod_av %>%
  dplyr::group_by(station_name) %>%
  add_hind_data(., c(2009:2014)) %>%
  dplyr::ungroup()

# Combine with hindcast data and add smoothing
oa_plot_mod_av <- rbind(oa_plot_mod_av, oa_hind_years) %>%
  dplyr::select(station_name, scenario, date, ph) %>%
  dplyr::group_by(station_name, scenario) %>%
  dplyr::arrange(date, .by_group = TRUE) %>%
  dplyr::mutate(ph = zoo::rollmean(ph, k = 132, fill = NA)) %>%
  dplyr::select(station_name, scenario, date, ph)

usethis::use_data(oa_plot_mod_av, overwrite = TRUE)
