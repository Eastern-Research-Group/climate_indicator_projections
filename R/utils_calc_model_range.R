#' calc_model_range
#'
#' @param ssp_df Model dataframe that has all the models for each scenario
#' @param var_name The column to calculate percentiles from
#'
#' @description Get the 10th and 90th percentiles of the model values to create a model range
#'
#' @return A dataframe with the scenario, year, and 10th and 90th percentiles of the models.
#'
#' @noRd

calc_model_range = function(ssp_df, var_name){

  p_all <- ssp_df %>%
    dplyr::ungroup() %>%
    dplyr::group_by(scenario, year) %>%
    dplyr::summarize(p10 = stats::quantile({{var_name}}, probs=c(0.1), na.rm=T),
              p90 = stats::quantile({{var_name}}, probs=c(0.9), na.rm=T))

  return(p_all)
}
