## code to prepare `seas_temp_plot_mod_av_spring` dataset goes here

seas_temp_plot_mod_av_spring <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_spring_temp.csv'))

usethis::use_data(seas_temp_plot_mod_av_spring, overwrite = TRUE)
