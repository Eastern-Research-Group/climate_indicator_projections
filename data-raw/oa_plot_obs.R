## code to prepare `oa_plot_obs` dataset goes here

# Read in the data
oa_plot_obs <- readr::read_csv(file.path(config::get("oa_path"), "ocean-acidity_fig-1.csv"), skip = 6)

usethis::use_data(oa_plot_obs, overwrite = TRUE)
