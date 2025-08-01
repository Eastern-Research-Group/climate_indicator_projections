## code to prepare `sst_plot_cln_data` dataset goes here

# first year of observed data
min_hind_yr <- 1880
base_yr_start <- 1971
base_yr_end <- 2000

# Read in data
# path to data
obs_sst <- readr::read_csv(file.path(config::get("sst_path"), "sea-surface-temp_fig-1.csv"), skip = 6)
proj_sst <- readr::read_csv(file.path(config::get("sst_path"), "sst.global_average.bayesian_model_average.annual.degF.1850-2100.csv"))
ssps_sst <- read_ssps('sst\\.global_average\\.ssp.*\\.csv', config::get("sst_path"), "sst") %>% dplyr::filter(scenario !="hindcast") %>%
  dplyr::filter(year >= min_hind_yr)

# observed
obs_sst_cln <- obs_sst %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::select(year, scenario, annual_anomaly) %>%
  dplyr::rename(smoothed_anom = annual_anomaly)

# Combine with projected
proj_obs_sst <- proj_sst %>%
  dplyr::filter(year >= min_hind_yr) %>%
  tidyr::pivot_longer(cols = starts_with("SSP"), names_to = "scenario", values_to = "sst") %>%
  calc_anom(., sst, base_yr_start, base_yr_end, 11) %>%
  dplyr::select(year, scenario, smoothed_anom) %>%
  dplyr::filter(year >= min_hind_yr) %>%
  rbind(obs_sst_cln) %>%
  dplyr::filter(!is.na(smoothed_anom))

# Process and align the model data
sst_plot_cln_data <- model_processing(
  mod_data = ssps_sst,
  var_name = sst,
  base_start = base_yr_start,
  base_end = base_yr_end,
  obs_mod_data = proj_obs_sst,
  which_anom = smoothed_anom,
  min_hind_yr = min_hind_yr) %>%
  dplyr::arrange(year, scenario)

usethis::use_data(sst_plot_cln_data, overwrite = TRUE)
