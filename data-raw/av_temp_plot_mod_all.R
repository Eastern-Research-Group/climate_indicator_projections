## code to prepare `av_temp_plot_mod_all` dataset goes here

# Read in and filter
av_temp_plot_mod_all <- vroom::vroom(list.files(path = config::get("av_temp_path"), pattern = 'avg_ann_temp_conus_av_*', full.names = TRUE)) %>%  # Each model
  dplyr::filter(scenario != "hist")

usethis::use_data(av_temp_plot_mod_all, overwrite = TRUE)
