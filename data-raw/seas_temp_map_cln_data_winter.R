## code to prepare `seas_temp_map_cln_data_winter` dataset goes here

# Process Winter seasonal temperature map data
seas_temp_map_cln_data_winter <- clean_seas_temp_map_mod(
  which_season = "Winter",
  seas_temp_obs_data = seas_temp_map_obs,
  conus_gdf = conus_cln)

usethis::use_data(seas_temp_map_cln_data_winter, overwrite = TRUE)

