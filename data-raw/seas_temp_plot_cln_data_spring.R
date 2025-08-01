## code to prepare `seas_temp_plot_cln_data_spring` dataset goes here

# Set the years -----------------------------------------------------------
base_yr_start <- 1951
base_yr_end <- 2000

# Read in the data --------------------------------------------------------
seas_temp_plot_mod_av_spring <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_spring_temp.csv'))
seas_temp_plot_mod_all_spring <- vroom::vroom(list.files(path = config::get("seas_temp_path"), pattern = 'avg_mam_temp_conus_av_*', full.names = TRUE)) %>%
  dplyr::rename(avg_temp_f = avg_mam_temp_f) %>%
  dplyr::filter(scenario != "hist")

# Combine and process -----------------------------------------------------
seas_temp_plot_cln_data_spring <- process_seasons(
  which_season = "Spring",
  obs_data = seas_temp_plot_obs,
  proj_data = seas_temp_plot_mod_av_spring,
  ssp_data = seas_temp_plot_mod_all_spring,
  ssp_var = avg_temp_f,
  base_yr_start = base_yr_start,
  base_yr_end = base_yr_end
)

usethis::use_data(seas_temp_plot_cln_data_spring, overwrite = TRUE)
