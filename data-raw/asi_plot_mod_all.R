## code to prepare `asi_plot_mod_all` dataset goes here

asi_plot_mod_all <- read_ssps('siextent\\.north\\.1e6miles\\.ssp.*\\.september\\..*\\.csv', config::get("asi_path"), "si_extent")

usethis::use_data(asi_plot_mod_all, overwrite = TRUE)
