## code to prepare `slr_map_cln_data` dataset goes here

# Read in the data --------------------------------------------------------
slr_map_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-2.csv"), skip = 6)
slr_map_mod_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean the observed data -------------------------------------------------
slr_map_obs <- slr_map_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::select(-state) %>%
  # rename galveston bay entrance to just galveston
  dplyr::mutate(station_name = ifelse(station_name == "Galveston Bay Entrance", "Galveston", station_name))

# Clean the model average -------------------------------------------------

slr_map_mod_cln <- slr_map_mod_raw %>%
  clean_slr_mod_data() %>% # Initial clean of the modeled data
  dplyr::filter(noaa_name != "GMSL") %>% # don't need GMSL
  # Make a column of station names that will match the observations station names
  align_slr_station_names() %>%
  dplyr::filter(year > 2005) %>%
  dplyr::group_by(station_name, scenario) %>%
  dplyr::mutate(rate_change = lm(slr_in ~ year)$coefficients[[2]]) %>%
  dplyr::mutate(relative_sea_level_change = rate_change*(2150-2020)) %>%
  dplyr::slice(1) %>%
  dplyr::select(station_name, scenario, relative_sea_level_change, lat, long) %>%
  # for now filter to just the medium scenarios
  dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
  dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise")) %>%
  # fix the points in marshall islands and wake island so that they show up in the same view on leaflet
  dplyr::mutate(long = ifelse(long > 0, long - 360, long))

# Filter to just the stations that are in both
obs_stations <- unique(slr_map_obs$station_name)
mod_stations <- unique(slr_map_mod_cln$station_name)
wanted_stations <- intersect(obs_stations, mod_stations)

# Combine and final processing --------------------------------------------
slr_map_cln_data <- rbind(slr_map_obs, slr_map_mod_cln) %>%
  dplyr::filter(station_name %in% wanted_stations) %>%  #filter to just stations that have both modeled and observed data
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) %>%
  dplyr::mutate(relative_sea_level_change = measurements::conv_unit(relative_sea_level_change, "in", "ft"))

usethis::use_data(slr_map_cln_data, overwrite = TRUE)
