## code to prepare `slr_map_inset_plot` dataset goes here

# Read in the data --------------------------------------------------------

# Read in all the observed stations
station_files <- list.files(path = file.path(config::get("slr_path"), "all_stations"), pattern = "\\.csv$", full.names = TRUE) # Get list of CSV files
slr_map_obs_stat_raw <- vroom::vroom(station_files, id = "source_file", skip = 5) # Read and combine with vroom, adding filename column
slr_map_obs_stat_raw$source_file <- basename(slr_map_obs_stat_raw$source_file)

# Projections data
slr_map_mod_stat_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean the observed data -------------------------------------------------

slr_map_obs_month <- slr_map_obs_stat_raw %>%
  janitor::clean_names() %>%
  dplyr::filter(year >= 1960) %>%
  dplyr::mutate(monthly_msl = measurements::conv_unit(monthly_msl, "m", "in")) %>%
  dplyr::mutate(station_name = stringr::str_remove(source_file, ".csv")) %>%
  dplyr::mutate(station_name = stringr:: str_extract(station_name, "(?<=_).*")) %>%
  dplyr::mutate(station_id = stringr:: str_extract(source_file, "\\d+"))

# check the number of months each station has data for
slr_map_obs_check <- slr_map_obs_month %>%
  dplyr::group_by(station_name) %>%
  dplyr::count(year) %>%
  dplyr::filter(n < 6) %>%
  dplyr::mutate(qc = "not complete") %>%
  dplyr::ungroup()

# join back
slr_map_obs_ann <- dplyr::left_join(slr_map_obs_month, slr_map_obs_check, by = c("station_name", "year")) %>%
  dplyr::filter(is.na(qc)) %>%
  dplyr::group_by(station_name, station_id, year) %>%
  dplyr::summarize(rsl = mean(monthly_msl)) %>%
  dplyr::ungroup()

# Adjust so that 1960 is 0
rsl_1960 <- slr_map_obs_ann %>%
  dplyr::filter(year == 1960) %>%
  dplyr::select(station_name, rsl_1960 = rsl)

slr_map_obs_stat <- dplyr::left_join(slr_map_obs_ann, rsl_1960, by = c("station_name")) %>%
  dplyr::mutate(rsl_adj = rsl - rsl_1960) %>%
  dplyr::select(station_name, year, rsl_adj) %>%
  dplyr::group_by(station_name) %>%
  tidyr::complete(year = seq(min(year), max(year), by = 1)) %>% # Fill in NAs for missing years
  dplyr::ungroup() %>%
  # rename galveston bay entrance to just galveston
  dplyr::mutate(station_name = ifelse(station_name == "Galveston Bay Entrance", "Galveston", station_name))

# Clean the model average -------------------------------------------------

slr_map_mod_stat_cln <- slr_map_mod_stat_raw %>%
  clean_slr_mod_data() %>% # Initial clean of the modeled data
  dplyr::select(-lat, -long) %>%
  dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
  dplyr::filter(noaa_name != "GMSL") %>%
  align_slr_station_names()

# Align projected with observed -------------------------------------------

# get the average observed from 2005 to 2020 value to offset the projections data
obs_av_05_20 <- slr_map_obs_stat %>%
  dplyr::filter(year %in% c(2005:2020)) %>%
  dplyr::group_by(station_name) %>%
  dplyr::summarize(obs_av = mean(rsl_adj, na.rm=TRUE))

# Get the projected 2020 value
mod_2020 <- slr_map_mod_stat_cln %>%
  dplyr::filter(year == 2020) %>%
  dplyr::mutate(slr_in_av = slr_in/2) %>%  # get the average of 2005 (0) and 2020
  dplyr::left_join(., obs_av_05_20, by = "station_name") %>%
  dplyr::mutate(shift_obs_2020 = obs_av - slr_in_av) %>%
  dplyr::select(station_name, scenario, shift_obs_2020)

slr_map_mod_stat_adj <- dplyr::left_join(slr_map_mod_stat_cln, mod_2020, by = c("station_name", "scenario")) %>%
  dplyr::mutate(slr_in = slr_in + shift_obs_2020) %>%
  dplyr::select(station_name, scenario, year, slr_in)


# Combine and process -----------------------------------------------------

slr_map_inset_plot <- slr_map_obs_stat %>%
  dplyr::rename(slr_in = rsl_adj) %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::select(station_name, scenario, year, slr_in) %>%
  rbind(slr_map_mod_stat_adj) %>%
  dplyr::mutate(scenario = dplyr::case_when(
    scenario == "0.5 - MED" ~ "Lower sea level rise",
    scenario == "1.0 - MED" ~ "Higher sea level rise",
    TRUE ~ "Observations"
    ))

usethis::use_data(slr_map_inset_plot, overwrite = TRUE)
