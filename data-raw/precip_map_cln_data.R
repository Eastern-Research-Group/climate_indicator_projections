## code to prepare `precip_map_cln_data` dataset goes here

# Set the years -----------------------------------------------------------
min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data
base_yr_start <- 1951
base_yr_end <- 2000

# Read in the data --------------------------------------------------------
precip_map_obs_raw <- readr::read_csv(file.path(config::get("precip_path"), "precipitation_fig-3_1951-2000_baseline.csv"))
precip_map_proj_raw <- readr::read_csv(file.path(config::get("precip_path"), "climdiv_TotalAnnualPr.csv"))

# Clean the observed data -------------------------------------------------
precip_map_obs_cln <- precip_map_obs_raw %>%
  # Clean up the names
  janitor::clean_names() %>%
  dplyr::rename(climdiv = climate_division_id) %>%
  dplyr::rename(perc_change = precipitation_change_1951_2000_denominator)  %>%
  dplyr::mutate(scenario = "observed")

# Clean the model average -------------------------------------------------

# calculate the average for each scenario 1951-2000
proj_51_00_av <- precip_map_proj_raw %>%
  sf::st_drop_geometry() %>%
  dplyr::filter(scenario != "nclimgrid") %>%
  dplyr::filter(!is.na(total_pr)) %>%
  dplyr::filter(year >= base_yr_start & year <= base_yr_end) %>%
  dplyr::group_by(climdiv, scenario) %>%
  dplyr::summarize(base_precip = mean(total_pr))

precip_map_proj_cln <- precip_map_proj_raw %>%
  dplyr::filter(scenario != "nclimgrid") %>%
  dplyr::left_join(proj_51_00_av, by = c("climdiv", "scenario")) %>%
  dplyr::filter(year >= min_yr) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(climdiv, scenario) %>%
  dplyr::mutate(rate_change = lm(total_pr ~ year)$coefficients[[2]]) %>%
  dplyr::mutate(ttl_change = rate_change*(2100-min_yr)) %>%
  dplyr::mutate(perc_change = (ttl_change/base_precip)*100) %>%
  dplyr::select(climdiv, scenario, perc_change)

# Combine and process -----------------------------------------------------

precip_map_cln_data <- precip_map_obs_cln %>%
  rbind(precip_map_proj_cln) %>%
  rename_scenarios(., TRUE) %>%
  # Create legend buckets
  dplyr::mutate(legend_buckets = cut(perc_change,
                                     breaks=c(-30, -20, -10, -2, 2, 10, 20, 30))) %>%
  # Make geospatial with climate division file
  dplyr::left_join(clim_div_cln, by = "climdiv") %>%
  sf::st_as_sf()

usethis::use_data(precip_map_cln_data, overwrite = TRUE)
