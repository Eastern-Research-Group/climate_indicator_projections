## code to prepare `seas_temp_map_cln_data_spring` dataset goes here

# Process seasonal temperature map data
seas_temp_map_cln_data_spring <- clean_seas_temp_map_mod(
  which_season = "Spring",
  seas_temp_obs_data = seas_temp_map_obs,
  conus_gdf = conus_cln)

usethis::use_data(seas_temp_map_cln_data_spring, overwrite = TRUE)
