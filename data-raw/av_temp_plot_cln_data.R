## code to prepare `av_temp_plot_cln_data` dataset goes here

# Set the years -----------------------------------------------------------
  min_hind_yr <- 1955
  base_yr_start <- 1951
  base_yr_end <- 2000

# Read in the data --------------------------------------------------------
  av_temp_plot_obs_raw <- readr::read_csv(file.path(config::get("av_temp_path"), "temperature_fig-1.csv"), skip = 6)
  av_temp_plot_proj_av_raw <- readr::read_csv(file.path(config::get("av_temp_path"),'conus_AvgAnnualTemp.csv')) # Model average
  av_temp_plot_mod_all <- vroom::vroom(list.files(path = config::get("av_temp_path"), pattern = 'avg_ann_temp_conus_av_*', full.names = TRUE)) %>%  # Each model
    dplyr::filter(scenario != "hist")

# Clean the observed data -------------------------------------------------
  av_temp_plot_obs <- av_temp_plot_obs_raw %>%
    janitor::clean_names() %>%
    dplyr::select(year, earths_surface) %>%
    dplyr::rename(anomaly = earths_surface) %>%
    dplyr::mutate(scenario = "observed") %>%
    dplyr::mutate(smoothed_anom = anomaly) # rename to combine with projected data

# Clean the model average -------------------------------------------------
  av_temp_plot_proj_av <- av_temp_plot_proj_av_raw %>%
    dplyr::filter(!is.na(av_temp)) %>%
    calc_anom(., av_temp, base_yr_start, base_yr_end, 11, FALSE) %>% # calculate anomaly
    dplyr::select(year, scenario, anomaly, smoothed_anom) %>%
    dplyr::filter(scenario != "nclimgrid") # remove nclimgrid

# Combine and process -----------------------------------------------------

  # Combine observed and projected average
  av_temp_obs_proj_av <- rbind(av_temp_plot_obs, av_temp_plot_proj_av) # bind with observed data

  # Process and align the model data
  av_temp_plot_cln_data <- model_processing(
    mod_data = av_temp_plot_mod_all,
    var_name = avg_ann_temp_f,
    base_start = base_yr_start,
    base_end = base_yr_end,
    obs_mod_data = av_temp_obs_proj_av,
    which_anom = smoothed_anom,
    min_hind_yr = min_hind_yr)

usethis::use_data(av_temp_plot_cln_data, overwrite = TRUE)
