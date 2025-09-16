## code to prepare `ghg_conc_plot_obs_co2` dataset goes here
ghg_conc_plot_obs_co2 <- readr::read_csv(file.path(config::get("ghg_path"), "ghg-concentrations_fig-1.csv"), skip = 6,
                                         col_types = readr::cols(.default = readr::col_character())) %>%
  cln_ghg_obs() %>%
  # Change name for consistency with a change we made to another EPA indicator recently
  dplyr::mutate(source = ifelse(source == "Barrow", "Utqiagvik (Barrow)", source))

usethis::use_data(ghg_conc_plot_obs_co2, overwrite = TRUE)
