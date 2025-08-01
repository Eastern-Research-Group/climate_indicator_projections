## code to prepare `ghg_conc_plot_obs_co2` dataset goes here
ghg_conc_plot_obs_co2 <- readr::read_csv(file.path(config::get("ghg_path"), "ghg-concentrations_fig-1.csv"), skip = 6,
                                         col_types = readr::cols(.default = readr::col_character())) %>%
  cln_ghg_obs()

usethis::use_data(ghg_conc_plot_obs_co2, overwrite = TRUE)
