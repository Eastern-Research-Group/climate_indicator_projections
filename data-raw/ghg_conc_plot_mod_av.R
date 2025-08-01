## code to prepare `ghg_conc_plot_mod_av` dataset goes here

# Read in data data
ghg_conc_plot_mod_av_raw <- readr::read_csv(file.path(config::get("ghg_path"), "ghg_concentrations_projections.csv"))

# Clean the projected data
ghg_conc_plot_mod_av <- ghg_conc_plot_mod_av_raw %>%
  janitor::clean_names() %>%
  tidyr::pivot_longer(cols = tidyr::starts_with("ssp"),
                      names_to = "scenario",
                      values_to = "value") %>%
  dplyr::mutate(scenario = stringr::str_remove(scenario, "_")) %>%
  rename_scenarios() %>%
  dplyr::group_by(ghg)

usethis::use_data(ghg_conc_plot_mod_av, overwrite = TRUE)
