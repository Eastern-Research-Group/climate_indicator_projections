## code to prepare `seas_temp_plot_mod_av_winter` dataset goes here

seas_temp_plot_mod_av_winter <- readr::read_csv(file.path(config::get("seas_temp_path"), 'conus_avg_winter_temp.csv'))

usethis::use_data(seas_temp_plot_mod_av_winter, overwrite = TRUE)
