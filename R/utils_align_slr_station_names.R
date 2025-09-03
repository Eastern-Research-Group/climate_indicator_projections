#' align_slr_station_names
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

align_slr_station_names <- function(slr_station_mod_data){

  slr_station_mod_data_rename <- slr_station_mod_data %>%
    dplyr::mutate(station_name = dplyr::case_when(
      noaa_name == "Baltimore, Fort McHenry, Patapsco River" ~ "Baltimore",
      noaa_name == "Beaufort, Duke Marine Lab" ~ "Beaufort",
      noaa_name == "Charleston, Cooper River Entrance" ~ "Charleston",
      noaa_name == "Freeport" ~ "Freeport Harbor",
      noaa_name == "Hilo, Hilo Bay, Kuhio Bay" ~ "Hilo",
      noaa_name == "Kahului, Kahului Harbor" ~ "Kahului",
      noaa_name == "Kwajalein, Marshall Islands" ~ "Kwajalein",
      noaa_name == "Mayport (Bar Pilots Dock)" ~ "Mayport",
      noaa_name == "San Diego, San Diego Bay" ~ "San Diego",
      noaa_name == "Skagway, Taiya Inlet" ~ "Skagway",
      noaa_name == "St. Petersburg, Tampa Bay" ~ "St. Petersburg",
      noaa_name == "Virginia Key, Biscayne Bay" ~ "Virginia Key",
      noaa_name == "Wake Island, Pacific Ocean" ~ "Wake Island",
      noaa_name == "Galveston Pleasure Pier" ~ "Galveston",
      TRUE ~ noaa_name
    )) %>%

  return(slr_station_mod_data_rename)

}
