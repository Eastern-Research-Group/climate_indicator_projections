## code to prepare `asi_plot_mod_av` dataset goes here

# Read in the data
asi_plot_mod_av_raw <- readr::read_csv(file.path(config::get("asi_path"), "siextent.north.1e6miles.bayesian_model_average.september.1850-2100.csv"))

# Set years
min_hind_yr <- 1950 # first year of hindcast data
base_yr_start <- 1979
base_yr_end <- 2014

# convert to tidy format
asi_plot_mod_av <- asi_plot_mod_av_raw %>%
  tidyr::pivot_longer(cols = tidyr::starts_with("SSP"), names_to = "scenario", values_to = "si_extent") %>%
  dplyr::filter(year >= min_hind_yr)

# Add hindcast category
asi_hindcast <- asi_plot_mod_av %>%
  dplyr::filter(scenario == "ssp126") %>%
  dplyr::filter(year <= 2014) %>%
  dplyr::mutate(scenario = "hindcast")

# calculate rolling average
asi_plot_mod_av <- rbind(asi_plot_mod_av, asi_hindcast) %>%
  dplyr::group_by(scenario) %>%
  dplyr::mutate(si_extent_smooth = zoo::rollmean(si_extent, k = 11, fill = NA)) %>%
  dplyr::mutate(si_extent_smooth = ifelse(!scenario %in% c("nclimgrid", "hindcast") & year < 2014, NA, si_extent_smooth))

usethis::use_data(asi_plot_mod_av, overwrite = TRUE)
