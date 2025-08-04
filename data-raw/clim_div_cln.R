## code to prepare `clim_div_cln` dataset goes here

clim_div_cln <- sf::read_sf('inst/extdata/map_boundaries/climate_divisions.geojson') %>%
  janitor::clean_names() %>%
  dplyr::select(climdiv, name) %>%
  dplyr::rename(climdiv_name = name)

usethis::use_data(clim_div_cln, overwrite = TRUE)
