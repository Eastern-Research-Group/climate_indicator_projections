## code to prepare `precip_plot_cln_data` dataset goes here

# Set the years -----------------------------------------------------------
base_yr_start <- 1951
base_yr_end <- 2000
min_hind_yr <- 1955

# Read in the data --------------------------------------------------------
precip_obs_raw <- readr::read_csv(file.path(config::get("precip_path"), "precipitation_fig-1.csv"), skip = 6)
precip_proj_raw <- readr::read_csv(file.path(config::get("precip_path"), "conus_TotalAnnualPr.csv"))
precip_ssps <- readr::read_csv(file.path(precip_path, "conus_TotalAnnualPr_models.csv"))

# Clean the observed data -------------------------------------------------
precip_obs_clean <- precip_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::mutate(scenario = "observed") %>%
  dplyr::rename(smoothed_anom = anomaly)  # rename to bind with projected data

# Clean the model average -------------------------------------------------
precip_all_data <- precip_proj_raw %>%
  calc_anom(., precip_in, base_yr_start, base_yr_end, 11, nclimgrid_smooth = FALSE) %>%
  dplyr::select(year, scenario, smoothed_anom) %>%
  # remove nclimgrid
  dplyr::filter(scenario != "nclimgrid") %>%
  rbind(precip_obs_clean) # combine with observed

# Align and process -----------------------------------------------------
precip_all_adj <- model_processing(
  mod_data = precip_ssps,
  var_name = total_pr,
  base_start = base_yr_start,
  base_end = base_yr_end,
  model_range = TRUE,
  obs_mod_data = precip_all_data,
  which_anom = smoothed_anom,
  min_hind_yr = min_hind_yr)

usethis::use_data(precip_plot_cln_data, overwrite = TRUE)
