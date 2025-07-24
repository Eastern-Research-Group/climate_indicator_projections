#' process_sc
#'
#' @param model_av_raw Dataframe of projected and observed data
#' @param all_model_raw Dataframe with all of the models
#' @param min_hind_yr Minimum year to filter the hindcast data to
#' @param which_season String of the season to filter the data to
#'
#' @returns
#' @export
#'
#' @examples ann_sc_all <- process_sc(sc_an_proj_av, sc_an_proj_mod, min_hind_yr)
process_sc <- function(model_av_raw, all_model_raw, min_hind_yr, which_season){

  if (which_season != "Annual") {

    model_av_raw <- model_av_raw %>%
      dplyr::filter(season == {{which_season}}) %>%
      dplyr::select(-season)

    all_model_raw <- all_model_raw  %>%
      dplyr::filter(season == {{which_season}}) %>%
      dplyr::select(-season)

  }

  # clean up model average and observed data
  model_av_cln <- model_av_raw %>%
    dplyr::group_by(scenario) %>%
    clean_sc_data(., min_hind_yr, c(2009:2014))  %>%
    dplyr::select(year, scenario, snc_mile2, snc_mil2mile)

  # clean all models data
  all_mods <- all_model_raw %>%
    dplyr::filter(model != "rutgers" ) %>%
    dplyr::mutate(scenario = ifelse(scenario == "historical", "hindcast", scenario)) %>%
    dplyr::filter(year >= min_hind_yr)

  # calculate model bounds
  mod_range <- calc_model_range(all_mods, snc_mile2)

  # combine with projected data
  sc_all <- dplyr::full_join(model_av_cln, mod_range, by = c("year", "scenario"))

  # make the ssps model bounds start at 2014 so there's not a break in the data
  ssps_bind <- add_hind_data(sc_all, 2014, is_date = FALSE)

  # Calculate difference between modeled and observed data
  obs_proj_diff <- calc_diff_avs(model_av_raw, "rutgers", "historical", snc_mile2, 1981, 2014) / 10^6

  # combine everything into one dataframe
  sc_all <- sc_all %>%
    rbind(ssps_bind) %>%
    dplyr::mutate(p10 = p10/10^6,
                  p90 = p90/10^6) %>%
    dplyr::mutate(p10_adj = ifelse(scenario != "observed", p10 + obs_proj_diff, p10)) %>%
    dplyr::mutate(p90_adj = ifelse(scenario != "observed", p90 + obs_proj_diff, p90)) %>%
    dplyr::mutate(snc_mil2mile_adj = ifelse(scenario != "observed", snc_mil2mile + obs_proj_diff, snc_mil2mile)) %>%
    # rename for highchart plot
    dplyr::rename(smoothed_anom_adj = snc_mil2mile_adj) %>%
    rename_scenarios() %>%
    dplyr::arrange(scenario, year)

  return(sc_all)
}
