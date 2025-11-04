#' create_static_map
#'
#' @param which_scenario String of the scenario to filter to (e.g. ssp585)
#' @param map_data The geodataframe to map
#' @param which_colors List of colors to use for each legend bucket
#' @param title String of the plot title
#' @param legend_title String of the legend title
#' @param state_color Color to have the state outline be
#'
#' @description Create a static map for the indicator
#'
#' @return A ggplot map
#'
#' @noRd
create_static_map <- function(which_scenario, map_data, which_colors, title, legend_title, state_color = "black"){

    # Filter to the scenario to map
    which_map <- map_data %>%
      dplyr::filter(scenario == which_scenario)

    # Create the map
    out_map <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets), color = "#88807F", show.legend = FALSE) +
      ggplot2::scale_fill_manual(
        values = which_colors,
        drop = FALSE) +
      ggplot2::geom_sf(data = conus_cln, fill = NA, color = state_color) +
      ggthemes::theme_map() +
      ggplot2::theme(
        text = ggplot2::element_text(size = 12),
        plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
        legend.position = "bottom"
      )

    return(out_map)


}
