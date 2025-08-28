## code to prepare `slr_map_inset_plot` dataset goes here

# Read in the data --------------------------------------------------------
slr_map_obs_stat_raw <- readr::read_csv(file.path(config::get("slr_path"), "9414290_meantrend.csv"), skip = 5)
slr_map_mod_stat_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean the observed data -------------------------------------------------
# TODO: Add a check that there are 12 months of data in each year

slr_map_obs_ann <- slr_map_obs_stat_raw %>%
  janitor::clean_names() %>%
  dplyr::filter(year >= 1960) %>%
  dplyr::mutate(monthly_msl = measurements::conv_unit(monthly_msl, "m", "in")) %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(rsl = mean(monthly_msl))

rsl_1960 <- slr_map_obs_ann %>%
  dplyr::filter(year == 1960) %>%
  dplyr::pull(rsl)

slr_map_obs_stat <- slr_map_obs_ann %>%
  dplyr::mutate(rsl_adj = rsl - rsl_1960)

# Clean the model average -------------------------------------------------

slr_map_mod_stat_cln <- slr_map_mod_stat_raw %>%
  clean_slr_mod_data() %>% # Initial clean of the modeled data
  dplyr::filter(noaa_name == "San Francisco") %>%
  dplyr::select(-lat, -long) %>%
  dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED"))

# Align projected with observed -------------------------------------------

slr_map_mod_stat_adj <- chain_slr_data(
  obs_data = slr_map_obs_stat,
  mod_data = slr_map_mod_stat_cln,
  obs_col = rsl_adj)

# Combine and process -----------------------------------------------------

slr_map_inset_plot <- slr_map_obs_stat %>%
  dplyr::rename(slr_in = rsl_adj) %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::select(-rsl) %>%
  rbind(slr_map_mod_stat_adj) %>%
  dplyr::mutate(station_name = "San Francisco") %>% # TODO FIX THISS!!!!!!
  dplyr::mutate(scenario = dplyr::case_when(
    scenario == "0.5 - MED" ~ "Lower sea level rise",
    scenario == "1.0 - MED" ~ "Higher sea level rise",
    TRUE ~ "Observations"
    ))


usethis::use_data(slr_map_inset_plot, overwrite = TRUE)
