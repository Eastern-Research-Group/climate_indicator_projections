## code to prepare `av_temp_map_cln_data` dataset goes here

# Set the years -----------------------------------------------------------
min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data

# Read in the data --------------------------------------------------------
av_temp_map_obs_raw <- readr::read_csv(file.path(config::get("av_temp_path"), "temperature_fig-3.csv"), skip = 6) # Observed
av_temp_map_mod_raw <- readr::read_csv(file.path(config::get("av_temp_path"), 'climdiv_AvgAnnualTemp.csv'))

# Clean the observed data -------------------------------------------------
av_temp_map_obs <- av_temp_map_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::rename(climdiv = climate_division) %>%
  dplyr::rename(rate_change_100 = temperature_change_1901_2000_denominator) %>%
  dplyr::select(climdiv, rate_change_100) %>%
  dplyr::mutate(scenario = "observed")

# Clean the model average -------------------------------------------------
av_temp_map_mod <- av_temp_map_mod_raw %>%
  dplyr::filter(scenario != "nclimgrid") %>%
  dplyr::filter(year >= min_yr) %>%
  dplyr::group_by(climdiv, scenario) %>%
  dplyr::mutate(rate_change = lm(av_temp ~ year)$coefficients[[2]]) %>%
  dplyr::mutate(rate_change_100 = rate_change*100) %>%
  dplyr::slice(1) %>%
  dplyr::select(climdiv, scenario, rate_change_100)

# Combine and process -----------------------------------------------------
av_temp_map_cln_data <- rbind(av_temp_map_obs, av_temp_map_mod) %>%
  dplyr::left_join(clim_div_cln, by = "climdiv") %>%
  sf::st_as_sf() %>%
  dplyr::filter(!is.na(rate_change_100)) %>%
  rename_scenarios(., TRUE) %>%
  dplyr::mutate(legend_buckets = cut(rate_change_100, breaks = seq(0, 16, by = 2))) %>%
  dplyr::mutate(legend_buckets_01 = cut(rate_change_100, breaks = c(-0.1, 0, 0.1, 2))) %>%
  dplyr::mutate(legend_buckets = ifelse(rate_change_100 <= 2, as.character(legend_buckets_01), as.character(legend_buckets)))

av_temp_map_cln_data$legend_buckets <- as.factor(av_temp_map_cln_data$legend_buckets)
av_temp_map_cln_data$legend_buckets <- forcats::fct_relevel(
  av_temp_map_cln_data$legend_buckets, c(
    "(-0.1,0]",
    "(0,0.1]" ,
    "(0.1,2]",
    "(2,4]",
    "(4,6]",
    "(6,8]",
    "(8,10]",
    "(10,12]",
    "(12,14]",
    "(14,16]"
))

usethis::use_data(av_temp_map_cln_data, overwrite = TRUE)
