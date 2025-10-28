# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.packages('attachment') # if needed.
attachment::att_amend_desc()
usethis::use_pipe()

## Add modules ----
## Create a module infrastructure in R/
# Average Temperature
golem::add_module(name = "av_temp_plot", with_test = TRUE)
golem::add_module(name = "av_temp_map", with_test = TRUE)
# Seasonal Temperature
golem::add_module(name = "seasonal_temp_plot", with_test = TRUE)
golem::add_module(name = "seasonal_temp_map", with_test = TRUE)
# Growing Season
golem::add_module(name = "grow_season_plot", with_test = TRUE)
golem::add_module(name = "grow_season_map", with_test = TRUE)
# Annual Total Precipitation
golem::add_module(name = "precip_plot", with_test = TRUE)
golem::add_module(name = "precip_map", with_test = TRUE)
# Coastal flooding
golem::add_module(name = "coast_fld_map", with_test = TRUE)
# Sea Level Rise
golem::add_module(name = "slr_plot", with_test = TRUE)
golem::add_module(name = "slr_map", with_test = TRUE)
golem::add_module(name = "slr_map_inset_plot", with_test = TRUE)
# Plots
golem::add_module(name = "sst_plot", with_test = TRUE) # Sea surface temperature
golem::add_module(name = "ocean_acidity_plot", with_test = TRUE) # Ocean Acidity
golem::add_module(name = "arctic_sea_ice_plot", with_test = TRUE) # Arctic Sea Ice
golem::add_module(name = "snow_cover_plot", with_test = TRUE) # Snow Cover
golem::add_module(name = "ghg_conc_plot", with_test = TRUE) # GHG concentrations
# About pages
golem::add_module(name = "about")

## Add helper functions ----
## Creates fct_* and utils_*
golem::add_fct("helpers", with_test = TRUE)
golem::add_fct("model_processing", with_test = TRUE)
golem::add_fct("create_hc_plot", with_test = TRUE)
golem::add_fct("create_static_map", with_test = TRUE)
golem::add_fct("render_page", with_test = TRUE)
golem::add_fct("create_static_map_ui", with_test = TRUE)
golem::add_fct("generate_static_maps", with_test = TRUE)
golem::add_utils("calc_anom", with_test = TRUE)
golem::add_utils("calc_model_range", with_test = TRUE)
golem::add_utils("calc_diff_avs", with_test = TRUE)
golem::add_utils("adjust_anomaly", with_test = TRUE)
golem::add_utils("rename_scenarios", with_test = TRUE)
golem::add_utils("read_ssps", with_test = TRUE)
golem::add_utils("process_seasons", module = "seasonal_temp_plot", with_test = TRUE)
golem::add_utils("rename_stations", module = "ocean_acidity_plot", with_test = TRUE)
golem::add_utils("add_hind_data", module = "ocean_acidity_plot", with_test = TRUE)
golem::add_utils("clean_oa_obs", module = "ocean_acidity_plot", with_test = TRUE)
golem::add_utils("process_oa_station", module = "ocean_acidity_plot", with_test = TRUE)
golem::add_utils("process_sea_ice", module = "arctic_sea_ice_plot", with_test = TRUE)
golem::add_utils("clean_sc_data", module = "snow_cover_plot", with_test = TRUE)
golem::add_utils("process_sc", module = "snow_cover_plot", with_test = TRUE)
golem::add_utils("create_sc_seas", module = "snow_cover_plot", with_test = TRUE)
golem::add_utils("create_slr_plot", module = "slr_plot", with_test = TRUE)
golem::add_utils("create_slr_station_plot", module = "slr_map", with_test = TRUE)
golem::add_utils("cln_ghg_obs", module = "ghg_conc_plot", with_test = TRUE)
golem::add_utils("create_ghg_plot", module = "ghg_conc_plot", with_test = TRUE)
golem::add_utils("clean_climdiv", with_test = TRUE)
golem::add_utils("calc_total_change", with_test = TRUE)
golem::add_utils("clean_seas_temp_map_mod", with_test = TRUE)
golem::add_utils("clean_slr_mod_data", with_test = TRUE)
golem::add_utils("chain_slr_data", with_test = TRUE)
golem::add_utils("align_slr_station_names", with_test = TRUE)
golem::add_utils("create_map_legend", with_test = TRUE)
golem::add_utils("read_app_text", with_test = TRUE)

## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file("script")
golem::add_js_file("js/leaflet_accesibility")
golem::add_js_file("js/a11y_fixes")
golem::add_js_file("js/before_after_slider")
golem::add_js_handler("handlers")
golem::add_css_file("custom")
golem::add_css_file("css/before_after_slider")
golem::add_sass_file("custom")
golem::add_any_file("file.json")

## Add internal datasets ----
## If you have data in your package
# Arctic Sea Ice: Plots
usethis::use_data_raw(name = "asi_plot_cln_data", open = rlang::is_interactive())

# Average temperature:
usethis::use_data_raw(name = "av_temp_plot_cln_data", open = rlang::is_interactive()) # Plots
usethis::use_data_raw(name = "av_temp_map_cln_data", open = rlang::is_interactive()) # Maps
usethis::use_data_raw(name = "av_temp_obs_hind_map", open = rlang::is_interactive())

# Precipitation
usethis::use_data_raw(name = "precip_plot_cln_data", open = rlang::is_interactive()) # Plots
usethis::use_data_raw(name = "precip_map_cln_data", open = rlang::is_interactive()) # Maps

# Greenhouse Gas Concentrations: Plots
usethis::use_data_raw(name = "ghg_conc_plot_obs_co2", open = rlang::is_interactive())
usethis::use_data_raw(name = "ghg_conc_plot_obs_ch4", open = rlang::is_interactive())
usethis::use_data_raw(name = "ghg_conc_plot_obs_n2o", open = rlang::is_interactive())
usethis::use_data_raw(name = "ghg_conc_plot_mod_av", open = rlang::is_interactive())

# Growing Season
usethis::use_data_raw(name = "grow_seas_plot_cln_data", open = rlang::is_interactive()) # plots
usethis::use_data_raw(name = "grow_seas_map_cln_data", open = rlang::is_interactive()) # map

# Ocean acidity: Plots
usethis::use_data_raw(name = "oa_plot_obs", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_mod_av", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_mod_all", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_cln_data_hawaii", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_cln_data_canary_islands", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_cln_data_bermuda", open = rlang::is_interactive())
usethis::use_data_raw(name = "oa_plot_cln_data_cariaco", open = rlang::is_interactive())

# Seasonal Temperature: Plots
usethis::use_data_raw(name = "seas_temp_plot_obs", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_plot_cln_data_fall", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_plot_cln_data_winter", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_plot_cln_data_spring", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_plot_cln_data_summer", open = rlang::is_interactive())

# Seasonal Temperature: Maps
usethis::use_data_raw(name = "seas_temp_map_obs", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_map_cln_data_fall", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_map_cln_data_winter", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_map_cln_data_spring", open = rlang::is_interactive())
usethis::use_data_raw(name = "seas_temp_map_cln_data_summer", open = rlang::is_interactive())

# Sea Level Rise: Plots
usethis::use_data_raw(name = "slr_plot_obs", open = rlang::is_interactive())
usethis::use_data_raw(name = "slr_plot_obs_csiro_bounds", open = rlang::is_interactive())
usethis::use_data_raw(name = "slr_plot_mod_all", open = rlang::is_interactive())
usethis::use_data_raw(name = "slr_map_cln_data", open = rlang::is_interactive())
usethis::use_data_raw(name = "slr_map_inset_plot", open = rlang::is_interactive())

# Coastal Flooding: Map
usethis::use_data_raw(name = "coastal_flood_cln_data", open = rlang::is_interactive())

# Snow Cover: Plots
usethis::use_data_raw(name = "sc_plot_winter", open = rlang::is_interactive())
usethis::use_data_raw(name = "sc_plot_spring", open = rlang::is_interactive())
usethis::use_data_raw(name = "sc_plot_summer", open = rlang::is_interactive())
usethis::use_data_raw(name = "sc_plot_fall", open = rlang::is_interactive())
usethis::use_data_raw(name = "sc_plot_annual", open = rlang::is_interactive())

# Sea Surface Temperature: Plots
usethis::use_data_raw(name = "sst_plot_cln_data", open = rlang::is_interactive())

# Geospatial Files
usethis::use_data_raw(name = "clim_div_cln", open = rlang::is_interactive())
usethis::use_data_raw(name = "conus_cln", open = rlang::is_interactive())



## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

## Vignette ----
usethis::use_vignette("climate_indicator_projections")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
