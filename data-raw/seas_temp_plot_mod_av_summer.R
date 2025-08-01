## code to prepare `seas_temp_plot_mod_av_summer` dataset goes here

seas_temp_plot_mod_av_summer <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_summer_temp.csv'))

usethis::use_data(seas_temp_plot_mod_av_summer, overwrite = TRUE)
