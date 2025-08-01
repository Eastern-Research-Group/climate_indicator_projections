## code to prepare `seas_temp_plot_mod_all_summer` dataset goes here

seas_temp_plot_mod_all_summer <- vroom::vroom(list.files(path = config::get("seas_temp_path"), pattern = 'avg_jja_temp_conus_av_*', full.names = TRUE)) %>%
  dplyr::rename(avg_temp_f = avg_jja_temp_f) %>%
  dplyr::filter(scenario != "hist")


usethis::use_data(seas_temp_plot_mod_all_summer, overwrite = TRUE)
