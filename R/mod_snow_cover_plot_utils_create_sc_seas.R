#' create_sc_seas
#'
#' @param seas_num The number for the season
#' @param seas_name String of the name of the season
#' @param min_hind_yr The minimum hindcast year
#'
#' @returns Snow cover dataframe ready for plotting
#' @export
#'
#' @examples create_sc_seas(seas_num = 2, seas_name = "Spring", min_hind_yr = 1950)

create_sc_seas <- function(seas_num, seas_name, min_hind_yr){

  # Read in data
  mod_av <- readr::read_csv(file.path(config::get("sc_path"), "snc_seasonal_bayesian_average.csv")) %>%
    dplyr::filter(season == {{seas_num}}) %>%
    dplyr::mutate(season = {{seas_name}})

  mod_all <- readr::read_csv(file.path(config::get("sc_path"), "snc_seasonal_all_models.csv")) %>%
    dplyr::filter(season == {{seas_num}}) %>%
    dplyr::mutate(season =  {{seas_name}})

  # Combine and process
  sc_plot_df <- process_sc(mod_av, mod_all, min_hind_yr, seas_name)

  return(sc_plot_df)

}

