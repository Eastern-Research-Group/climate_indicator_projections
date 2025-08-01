## code to prepare `ghg_conc_plot_obs_n2o` dataset goes here

ghg_conc_plot_obs_n2o <- readr::read_csv(file.path(config::get("ghg_path"), "ghg-concentrations_fig-3.csv"), skip = 6,
                                         col_types= readr::cols(.default = readr::col_character())) %>%
  cln_ghg_obs(., TRUE)

usethis::use_data(ghg_conc_plot_obs_n2o, overwrite = TRUE)
