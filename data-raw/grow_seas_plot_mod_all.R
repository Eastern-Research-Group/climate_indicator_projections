## code to prepare `grow_seas_plot_mod_all` dataset goes here

grow_seas_plot_mod_all <- vroom::vroom(list.files(path = config::get("grow_seas_path"), pattern = 'growing_seas_length_conus_av_*', full.names = TRUE)) %>% # model averages
  dplyr::filter(scenario != "hist")

usethis::use_data(grow_seas_plot_mod_all, overwrite = TRUE)
