## code to prepare `coastal_flood_cln_data` dataset goes here

# Read in the data --------------------------------------------------------
cf_obs_raw <- readr::read_csv(file.path(config::get("cf_path"), "coastal-flooding_fig-2.csv"), skip = 6)
cf_mod_raw  <- readr::read_csv(file.path(config::get("cf_path"), "techrpt86_PaP_of_HTFlooding.csv"), skip = 10)

# Clean the observed data -------------------------------------------------
cf_obs_cln <- cf_obs_raw %>%
  tidyr::pivot_longer(cols = c("1950-1969", "1970-1989", "1990-2009", "2010-2023"),
                      names_to = "years", values_to = "av_fld_pyr") %>%
  dplyr::rename(station_name = `...1`)

obs_stations <- unique(cf_obs_cln$station_name)

# Clean the model average -------------------------------------------------
cf_mod_cln <- cf_mod_raw %>%
  dplyr::filter(!`Station Name` %in% c("Lat", "Long", "NOAA ID",
                                       "Derived' (1.04*GT + 0.5 m) High Tide Flood Threshold")) %>%
  dplyr::rename(year = `Station Name`) %>%
  dplyr::rename(flood_type = `...1`) %>%
  tidyr::pivot_longer(cols = !c("year", "flood_type"),
                      names_to = "station_name", values_to = "fld_days_pyr") %>%
  dplyr::filter(flood_type %in% c("floods_historical", "int", "int_high")) %>%
  dplyr::mutate(scenario =dplyr::case_when(

    flood_type == "floods_historical" ~ "Observed",
    flood_type == "int" ~ "Lower sea level rise",
    flood_type == "int_high" ~ "Higher sea level rise",

  )) %>%
  # Make decade columns
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::mutate(decade = (year %/% 10) * 10) %>%
  dplyr::group_by(station_name, scenario, decade) %>%
  dplyr::summarise(fld_days_pdec = mean(fld_days_pyr)) %>%
  dplyr::filter(decade >= 1950) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(fld_days_pdec = ifelse(scenario != "Observed" & decade < 2020, 9999, fld_days_pdec)) %>%
  dplyr::filter(fld_days_pdec < 9999) %>%
  dplyr::filter(station_name %in% obs_stations)


# Get the lat/lon from the model data -------------------------------------

station_loc <- cf_mod_raw %>%
  dplyr::filter(`Station Name` %in% c("Lat", "Long")) %>%
  dplyr::select(-`...1`) %>%
  tidyr::pivot_longer(cols = !`Station Name`,
                      names_to = "station_name", values_to = "loc") %>%
  tidyr::pivot_wider(names_from = `Station Name`, values_from = loc)

# Combine and process -----------------------------------------------------
coastal_flood_cln_data <- dplyr::left_join(cf_mod_cln, station_loc, by = "station_name") %>%
  sf::st_as_sf(coords = c("Long", "Lat"), crs = 4326)

usethis::use_data(coastal_flood_cln_data, overwrite = TRUE)
