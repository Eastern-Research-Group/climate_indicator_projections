## code to prepare `seas_temp_plot_obs` dataset goes here

# Read in observed data
seas_temp_plot_obs <- readr::read_csv(file.path(config::get("seas_temp_path"), "seasonal-temperature_fig-1.csv"), skip = 6)

usethis::use_data(seas_temp_plot_obs, overwrite = TRUE)
