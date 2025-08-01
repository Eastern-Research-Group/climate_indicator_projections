## code to prepare `seas_temp_plot_mod_all_spring` dataset goes here

seas_temp_plot_mod_all_spring <- vroom::vroom(list.files(path = config::get("seas_temp_path"), pattern = 'avg_mam_temp_conus_av_*', full.names = TRUE)) %>%
  dplyr::rename(avg_temp_f = avg_mam_temp_f) %>%
  dplyr::filter(scenario != "hist")


usethis::use_data(seas_temp_plot_mod_all_spring, overwrite = TRUE)
