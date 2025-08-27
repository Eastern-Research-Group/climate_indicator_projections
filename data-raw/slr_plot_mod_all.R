## code to prepare `slr_plot_mod_all` dataset goes here

# Read in the data
slr_plot_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-1.csv"), skip = 6) %>%
  janitor::clean_names()
slr_plot_mod_all_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)


# Clean projected data ----------------------------------------------------

slr_plot_mod_cln <- slr_plot_mod_all_raw %>%
  clean_slr_mod_data() %>%
  dplyr::filter(noaa_name == "GMSL") %>%
  dplyr::select(-noaa_name, -lat, -long)

# Align projected with observed -------------------------------------------

# get the NOAA observed 2020 value to offset the projections data
noaa_2020 <- slr_plot_obs_raw %>%
  dplyr::filter(year == 2020) %>%
  dplyr::pull(noaa_adjusted_sea_level_inches)

# Get the projected 2020 value
slr_plot_mod_2020 <- slr_plot_mod_cln %>%
  dplyr::filter(year == 2020) %>%
  dplyr::mutate(shift_noaa_2020 = noaa_2020 - slr_in) %>%
  dplyr::select(-slr_in, -year)

slr_plot_mod_all <- dplyr::left_join(slr_plot_mod_cln, slr_plot_mod_2020, by = c("scenario")) %>%
  dplyr::mutate(slr_old = slr_in) %>%
  dplyr::mutate(slr_in = slr_in + shift_noaa_2020) %>%
  dplyr::select(scenario, year, slr_in)

# SLR proj mid
slr_proj_mid <- slr_plot_mod_all %>%
  dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
  dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise"))

# SLR proj range
slr_proj_range <- slr_plot_mod_all %>%
  dplyr::filter(scenario %in% c("0.5 - LOW", "0.5 - HIGH", "1.0 - LOW", "1.0 - HIGH")) %>%
  dplyr::mutate(bound = ifelse(stringr::str_detect(scenario, "LOW"), "lower_bound", "upper_bound")) %>%
  dplyr::mutate(scenario = ifelse(stringr::str_detect(scenario, "0.5"), "Lower sea level rise",
                                  "Higher sea level rise")) %>%
  tidyr::pivot_wider(names_from = bound, values_from = slr_in)

# Combine back together
slr_plot_mod_all <- dplyr::left_join(slr_proj_mid, slr_proj_range, by = c("year", "scenario"))

# model hindcast
slr_hindcast <- slr_plot_mod_all %>%
  dplyr::filter(year <= 2020) %>%
  dplyr::mutate(scenario = "Model Hindcast") %>%
  dplyr::distinct()

# add model hindcast back into slr proj
slr_plot_mod_all <- slr_plot_mod_all %>%
  dplyr::filter(year >= 2020) %>%
  rbind(., slr_hindcast) %>%
  dplyr::mutate(scenario_area = paste(scenario, " range"))

usethis::use_data(slr_plot_mod_all, overwrite = TRUE)
