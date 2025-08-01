## code to prepare `asi_plot_cln_data` dataset goes here


# Set the years -----------------------------------------------------------
  min_hind_yr <- 1950 # first year of hindcast data
  base_yr_start <- 1979
  base_yr_end <- 2014

# Read in the data --------------------------------------------------------
  asi_plot_obs_raw <- readr::read_csv(file.path(config::get("asi_path"), "arctic-sea-ice_fig-1.csv"), skip = 6)
  asi_plot_mod_av_raw <- readr::read_csv(file.path(config::get("asi_path"), "siextent.north.1e6miles.bayesian_model_average.september.1850-2100.csv"))
  asi_plot_mod_all <- read_ssps('siextent\\.north\\.1e6miles\\.ssp.*\\.september\\..*\\.csv', config::get("asi_path"), "si_extent")

# Clean the observed data -------------------------------------------------
  asi_plot_obs <- asi_plot_obs_raw %>%
    janitor::clean_names() %>%
    dplyr::select(year, september) %>%
    dplyr::rename(si_extent = september) %>%
    dplyr::mutate(scenario = "observed") %>%
    dplyr::mutate(si_extent_smooth = si_extent)


# Clean the model average data --------------------------------------------
  # convert to tidy format
  asi_plot_mod_av <- asi_plot_mod_av_raw %>%
    tidyr::pivot_longer(cols = tidyr::starts_with("SSP"), names_to = "scenario", values_to = "si_extent") %>%
    dplyr::filter(year >= min_hind_yr)

  # Add hindcast category
  asi_hindcast <- asi_plot_mod_av %>%
    dplyr::filter(scenario == "ssp126") %>%
    dplyr::filter(year <= 2014) %>%
    dplyr::mutate(scenario = "hindcast")

  # calculate rolling average
  asi_plot_mod_av <- rbind(asi_plot_mod_av, asi_hindcast) %>%
    dplyr::group_by(scenario) %>%
    dplyr::mutate(si_extent_smooth = zoo::rollmean(si_extent, k = 11, fill = NA)) %>%
    dplyr::mutate(si_extent_smooth = ifelse(!scenario %in% c("nclimgrid", "hindcast") & year < 2014, NA, si_extent_smooth))

# Process the data --------------------------------------------------------

  # Combine observed and model average
  asi_obs_mod_av <- rbind(asi_plot_obs, asi_plot_mod_av)

  # Conduct bias correction and process model range
  asi_plot_cln_data <- process_sea_ice(asi_obs_mod_av, asi_plot_mod_all, base_yr_start, base_yr_end, min_hind_yr) %>%
    dplyr::rename(smoothed_anom_adj = si_extent_adj) # rename for highchart

usethis::use_data(asi_plot_cln_data, overwrite = TRUE)
