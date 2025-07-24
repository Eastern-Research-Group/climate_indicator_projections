#' clean_sc_data
#'
#' @param sc_df Dataframe with combined projected and observed snow cover data
#' @param min_hind_yr Minimum year we want the hindcast data to go to
#' @param years Years to feed into add_hind_data function
#'
#' @returns Dataframe of tidyed projected average and observed data and a new rolling average column
#' @export
#'
#' @examples clean_sc_data(sc_df, 1950, c(2009:2014))
clean_sc_data <- function(sc_df, min_hind_yr, years){

  # Clean the dataframe
  sc_df_cln <- sc_df %>%
    # only have hindcast back to the observed start
    dplyr::filter(year >= min_hind_yr) %>%
    # clean up categories
    dplyr::mutate(scenario = dplyr::case_when(
      scenario == "rutgers" ~ "observed",
      scenario == "historical" ~ "hindcast",
      TRUE ~ scenario
    ))

  # add hindcast data
  ssps_bind <- add_hind_data(sc_df_cln, years, is_date = FALSE)

  sc_df_cln <- sc_df_cln %>%
    # make the ssps start at 2015 so there's not a break in the data
    rbind(ssps_bind) %>%
    # MAke sure the data is arranged correctly before rolling ave
    dplyr::arrange(year) %>%
    # 11 year rolling average
    dplyr::mutate(smoothed = zoo::rollmean(snc_mile2, k = 11, fill = NA)) %>%
    # convert to million miles squared
    dplyr::mutate(snc_mil2mile = smoothed/10^6) %>%
    dplyr::mutate(snc_mil2mile = ifelse(scenario == "observed", snc_mile2/10^6, snc_mil2mile))

  return(sc_df_cln)

}
