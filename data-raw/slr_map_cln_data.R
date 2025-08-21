## code to prepare `slr_map_cln_data` dataset goes here

# Read in the data --------------------------------------------------------
slr_map_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-2.csv"), skip = 6)
slr_map_mod_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

# Clean and process -------------------------------------------------------

# Observed data
slr_map_obs <- slr_map_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::select(-state)

# modeled data
slr_map_mod_cln <- slr_map_mod_raw %>%
  clean_slr_mod_data() %>% # Initial clean of the modeled data
  dplyr::filter(noaa_name != "GMSL") %>% # don't need GMSL
  # Make a column of station names that will match the observations station names
  dplyr::mutate(station_name = dplyr::case_when(
    noaa_name == "Baltimore, Fort McHenry, Patapsco River" ~ "Baltimore",
    noaa_name == "Beaufort, Duke Marine Lab" ~ "Beaufort",
    noaa_name == "Charleston, Cooper River Entrance" ~ "Charleston",
    noaa_name == "Freeport" ~ "Freeport Harbor",
    noaa_name == "Hilo, Hilo Bay, Kuhio Bay" ~ "Hilo",
    noaa_name == "Kahului, Kahului Harbor" ~ "Kahului",
    noaa_name == "Kwajalein, Marshall Islands" ~ "Kwajalein",
    noaa_name == "Mayport (Bar Pilots Dock)" ~ "Mayport",
    noaa_name == "San Diego, San Diego Bay" ~ "San Diego",
    noaa_name == "Skagway, Taiya Inlet" ~ "Skagway",
    noaa_name == "St. Petersburg, Tampa Bay" ~ "St. Petersburg",
    noaa_name == "Virginia Key, Biscayne Bay" ~ "Virginia Key",
    noaa_name == "Wake Island, Pacific Ocean" ~ "Wake Island",
    TRUE ~ noaa_name
  )) %>%
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

## TODO: Do I need to adjust for NOAA 2005 offset
# dplyr::mutate(slr_in = slr_in + noaa_2005)

## TODO: observed data is from 1960 to 2023 but can only use projections that start at 2020 or 2030

# Filter to just the stations that are in both
obs_stations <- unique(slr_map_obs$station_name)
mod_stations <- unique(slr_map_mod_cln$station_name)
wanted_stations <- intersect(obs_stations, mod_stations)

## TODO: MEED TO DECIDE WHAT TO DO HERE:
#"Galveston Bay Entrance" / "Galveston Pleasure Pier" & "Galveston Pier 21"


# Combine and final processing --------------------------------------------

slr_map_cln_data <- rbind(slr_map_obs, slr_map_mod_cln) %>%
  dplyr::filter(station_name %in% wanted_stations) %>%  #filter to just stations that have both modeled and observed data
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) # make geospatial


usethis::use_data(slr_map_cln_data, overwrite = TRUE)
