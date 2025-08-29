## code to prepare `slr_map_inset_plot` dataset goes here

# Read in the data --------------------------------------------------------

# Read in all the observed stations
station_files <- list.files(path = file.path(config::get("slr_path"), "all_stations"), pattern = "\\.csv$", full.names = TRUE) # Get list of CSV files
slr_map_obs_stat_raw <- vroom::vroom(station_files, id = "source_file", skip = 5) # Read and combine with vroom, adding filename column
slr_map_obs_stat_raw$source_file <- basename(slr_map_obs_stat_raw$source_file)

# Projections data
slr_map_mod_stat_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean the observed data -------------------------------------------------

# TODO: Add a check that there are 12 months of data in each year

slr_map_obs_month <- slr_map_obs_stat_raw %>%
  janitor::clean_names() %>%
  dplyr::filter(year >= 1960) %>%
  dplyr::mutate(monthly_msl = measurements::conv_unit(monthly_msl, "m", "in")) %>%
  dplyr::mutate(station_name = stringr::str_remove(source_file, ".csv")) %>%
  dplyr::mutate(station_name = stringr:: str_extract(station_name, "(?<=_).*")) %>%
  dplyr::mutate(station_id = stringr:: str_extract(source_file, "\\d+"))

# check the number of years each station has data for
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


# FOR THE PLOT ------------------------------------------------------------




usethis::use_data(slr_map_inset_plot, overwrite = TRUE)
