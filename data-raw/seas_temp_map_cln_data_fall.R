## code to prepare `seas_temp_map_cln_data_fall` dataset goes here

# Process Fall seasonal temperature map data
seas_temp_map_cln_data_fall <- clean_seas_temp_map_mod(
  which_season = "Fall",
  seas_temp_obs_data = seas_temp_map_obs,
  conus_gdf = conus_cln)

usethis::use_data(seas_temp_map_cln_data_fall, overwrite = TRUE)
