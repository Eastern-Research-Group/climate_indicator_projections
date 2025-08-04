## code to prepare `conus_cln` dataset goes here

us_states <- sf::read_sf('inst/extdata/map_boundaries/us_states.geojson')

conus_cln <- us_states %>%
  # Filter to CONUS
  dplyr::filter(!STUSPS %in% c("AK", "HI", "PR", "AS", "MP", "GU")) %>%
  # Simplify shapefile for faster processing
  sf::st_simplify(., dTolerance = 5000, preserveTopology = TRUE)

usethis::use_data(conus_cln, overwrite = TRUE)
