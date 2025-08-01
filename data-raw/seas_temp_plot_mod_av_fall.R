## code to prepare `seas_temp_plot_mod_av_fall` dataset goes here

seas_temp_plot_mod_av_fall <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_fall_temp.csv'))

usethis::use_data(seas_temp_plot_mod_av_fall, overwrite = TRUE)
