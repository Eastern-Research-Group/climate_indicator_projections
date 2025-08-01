## code to prepare `ghg_conc_plot_obs_ch4` dataset goes here

ghg_conc_plot_obs_ch4 <- readr::read_csv(file.path(config::get("ghg_path"), "ghg-concentrations_fig-2.csv"), skip = 6,
                                         col_types= readr::cols(.default = readr::col_character())) %>%
  cln_ghg_obs(., TRUE)

usethis::use_data(ghg_conc_plot_obs_ch4, overwrite = TRUE)
