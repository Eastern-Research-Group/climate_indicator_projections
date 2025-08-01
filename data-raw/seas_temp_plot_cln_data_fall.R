## code to prepare `seas_temp_plot_cln_data_fall` dataset goes here

# Set the years -----------------------------------------------------------
base_yr_start <- 1951
base_yr_end <- 2000

# Read in the data --------------------------------------------------------

seas_temp_plot_mod_av_fall <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_fall_temp.csv'))
seas_temp_plot_mod_all_fall <- vroom::vroom(list.files(path = config::get("seas_temp_path"), pattern = 'avg_son_temp_conus_av_*', full.names = TRUE)) %>%
  dplyr::rename(avg_temp_f = avg_son_temp_f) %>%
  dplyr::filter(scenario != "hist")

# Combine and process -----------------------------------------------------

seas_temp_plot_cln_data_fall <- process_seasons(
  which_season = "Fall",
  obs_data = seas_temp_plot_obs,
  proj_data = seas_temp_plot_mod_av_fall,
  ssp_data = seas_temp_plot_mod_all_fall,
  ssp_var = avg_temp_f,
  base_yr_start = base_yr_start,
  base_yr_end = base_yr_end
)

usethis::use_data(seas_temp_plot_cln_data_fall, overwrite = TRUE)
