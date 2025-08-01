## code to prepare `av_temp_map_mod` dataset goes here

# Read in the data
av_temp_map_mod_raw <- readr::read_csv(file.path(config::get("av_temp_path"), 'climdiv_AvgAnnualTemp.csv'))

# Clean the data
min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data

av_temp_map_mod <- av_temp_map_mod_raw %>%
  dplyr::filter(scenario != "nclimgrid") %>%
  dplyr::filter(year >= min_yr) %>%
  dplyr::group_by(climdiv, scenario) %>%
  dplyr::mutate(rate_change = lm(av_temp ~ year)$coefficients[[2]]) %>%
  dplyr::mutate(rate_change_100 = rate_change*100) %>%
  dplyr::slice(1) %>%
  dplyr::select(climdiv, scenario, rate_change_100)

usethis::use_data(av_temp_map_mod, overwrite = TRUE)
