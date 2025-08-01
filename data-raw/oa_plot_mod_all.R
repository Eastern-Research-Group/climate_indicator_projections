## code to prepare `oa_plot_mod_all` dataset goes here

# Set years
min_hind_yr <- 1950

# Read in the data
oa_plot_mod_all_raw <- readr::read_csv(file.path(config::get("oa_path"), "ph_monthly_by_station_and_model.csv"))

# Initial clean
oa_plot_mod_all <- oa_plot_mod_all_raw %>%
  dplyr::rename(station = station_name,
                ph = data) %>%
  rename_stations() %>%
  dplyr::filter(year >= min_hind_yr) %>%
  dplyr::mutate(date = lubridate::ymd(paste0(year, "-", month, "-01")))

# add 2014 to the ssps so there's no gap
oa_hind_14 <- oa_plot_mod_all %>%
  dplyr::ungroup() %>%
  dplyr::group_by(model, station_name) %>%
  add_hind_data(., c(2014)) %>%
  dplyr::ungroup() %>%
  dplyr::filter(date >= "2014-12-01")

oa_plot_mod_all <- rbind(oa_plot_mod_all, oa_hind_14) %>%
  dplyr::select(station_name, model, scenario, date, ph) %>%
  dplyr::group_by(station_name, scenario, date) %>%
  dplyr::summarize(p10 = quantile(ph, probs=c(0.1), na.rm=T),
                   p90 = quantile(ph, probs=c(0.9), na.rm=T))

usethis::use_data(oa_plot_mod_all, overwrite = TRUE)
