#' read_ssps
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

clean_ssps <- function(chosen_file, value_name){

  which_ssp <- stringr::str_extract(chosen_file, "(ssp[0-9]*).*", group = 1)

  ssps <- readr::read_csv(chosen_file) %>%
    tidyr::pivot_longer(cols = -year, names_to = "model", values_to = value_name) %>%
    dplyr::mutate(scenario = which_ssp)

  #Add hindcast category to go on top of SSPs
  hindcast <- ssps %>%
    dplyr::filter(scenario == "ssp126") %>%
    dplyr::filter(year <= 2014) %>%
    dplyr::mutate(scenario = "hindcast")

  ssps <- rbind(ssps, hindcast)

  return(ssps)
}

read_ssps <- function(file_pattern, raw_data, value_name){

  ssps_files <- list.files(path = raw_data, pattern = file_pattern, full.names = TRUE)
  ssps_list <- lapply(ssps_files, clean_ssps, value_name)
  ssps <- do.call(rbind, ssps_list)

  return(ssps)
}
