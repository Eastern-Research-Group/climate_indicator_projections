#' cln_ghg_obs
#'
#' @param raw_obs Dataframe of raw observed ghg concentration
#' @param rename_yr True if the year column is called `Year (negative values = BC)`
#'
#' @returns Clean dataframe of observed ghg data
#' @export
#'
#' @examples
cln_ghg_obs <- function(raw_obs, rename_yr=FALSE){

  if (rename_yr) {
    raw_obs <- raw_obs %>%
      dplyr::rename(Year = `Year (negative values = BC)`)
  }

  # Clean observed data
  cln_obs <- raw_obs %>%
    dplyr::rename(year = Year) %>%
    dplyr::filter(year != "Ice core measurements") %>%
    tidyr::pivot_longer(cols = c(-year),
                        names_to = "source",
                        values_to = "value") %>%
    # Datasets use , as thousands separator, so cannot convert directly to number. Remove comma first to avoid generating NAs
    dplyr::mutate(value = stringr::str_remove(value, ",")) %>%
    # Convert columns to numeric
    dplyr::mutate(value = as.numeric(value)) %>%
    dplyr::mutate(year = as.numeric(year)) %>%
    dplyr::filter(value != 0) %>%
    dplyr::filter(!is.na(value))

  return(cln_obs)

}
