## code to prepare `slr_plot_mod_all` dataset goes here

# Read in the data
slr_plot_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-1.csv"), skip = 6) %>%
  janitor::clean_names()
slr_plot_mod_all_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean projected data ----------------------------------------------------

slr_plot_mod_cln <- slr_plot_mod_all_raw %>%
  clean_slr_mod_data() %>%
  dplyr::filter(noaa_name == "GMSL")

# Align projected with observed -------------------------------------------

# get the average observed from 2005 to 2020 value to offset the projections data
obs_av_05_20 <- slr_plot_obs_raw %>%
  dplyr::select(year, noaa_adjusted_sea_level_inches) %>%
  dplyr::filter(year %in% c(2005:2020)) %>%
  dplyr::summarize(obs_av = mean(noaa_adjusted_sea_level_inches)) %>%
  dplyr::pull()

# Get the projected 2020 value
mod_2020 <- slr_plot_mod_cln %>%
  dplyr::filter(year == 2020) %>%
  dplyr::mutate(slr_in_av = slr_in/2) %>%  # get the average of 2005 (0) and 2020
  dplyr::mutate(shift_obs_2020 = obs_av_05_20 - slr_in_av) %>%
  dplyr::select(scenario, shift_obs_2020)

slr_plot_mod_adj <- dplyr::left_join(slr_plot_mod_cln, mod_2020, by = c("scenario")) %>%
  dplyr::mutate(slr_in = slr_in + shift_obs_2020) %>%
  dplyr::select(scenario, year, slr_in)


# Add model ranges --------------------------------------------------------

# SLR proj mid
slr_proj_mid <- slr_plot_mod_adj %>%
  dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
  dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise"))

# SLR proj range
slr_proj_range <- slr_plot_mod_adj %>%
  dplyr::filter(scenario %in% c("0.5 - LOW", "0.5 - HIGH", "1.0 - LOW", "1.0 - HIGH")) %>%
  dplyr::mutate(bound = ifelse(stringr::str_detect(scenario, "LOW"), "lower_bound", "upper_bound")) %>%
  dplyr::mutate(scenario = ifelse(stringr::str_detect(scenario, "0.5"), "Lower sea level rise",
                                  "Higher sea level rise")) %>%
  tidyr::pivot_wider(names_from = bound, values_from = slr_in)

# Combine back together
slr_plot_mod_all <- dplyr::left_join(slr_proj_mid, slr_proj_range, by = c("year", "scenario"))

# add model hindcast back into slr proj
slr_plot_mod_all <- slr_plot_mod_all %>%
  dplyr::mutate(scenario_area = paste(scenario, " range"))

usethis::use_data(slr_plot_mod_all, overwrite = TRUE)
