## code to prepare `sc_plot_annual` dataset goes here

# Read in data
sc_an_proj_av <- readr::read_csv(file.path(sc_path, "snc_annual_bayesian_average.csv"))
sc_an_proj_mod <- readr::read_csv(file.path(sc_path, "snc_annual_all_models.csv"))

# Process data
sc_plot_annual <- process_sc(sc_an_proj_av, sc_an_proj_mod, 1950, "Annual")

usethis::use_data(sc_plot_annual, overwrite = TRUE)
