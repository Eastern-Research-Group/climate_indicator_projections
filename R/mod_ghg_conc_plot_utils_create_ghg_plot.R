#' create_ghg_plot
#'
#' @param observed_data Dataframe of observed ghg data filtered to which ghg type to plot
#' @param projected_data Dataframe of projected ghg data filtered to which ghg type to plot
#' @param which_ghg String of which ghg type to plot
#' @param unit String of the unit of ghg type
#' @param which_colors List of the colors to use for plotting the projected data
#'
#' @returns Highchart plot
#' @export
#'
#' @examples
create_ghg_plot <- function(observed_data, projected_data, which_ghg, unit, which_colors){

  ghg_plot <- highcharter::highchart() %>%

    # Add dummy element to make legend group titles
    highcharter::hc_add_series(
      name = "<u><b style='font-size:13px;'>Observed</b></u>",
      data = list(),
      showInLegend = TRUE,
      enableMouseTracking = FALSE,
      color = "transparent",
      marker = list(enabled = FALSE),
      states = list(hover = list(enabled = FALSE)),
      events = list(legendItemClick = highcharter::JS("function () { return false; }"))
    ) %>%
    # Observed data
    highcharter::hc_add_series(data = observed_data, type = "line",
                               highcharter::hcaes(name = source,
                                                  group = source,
                                                  x = year, y = value),
                               color = "black"
    ) %>%
    # Add dummy element to make legend group titles
    highcharter::hc_add_series(
      name = "<u><b style='font-size:13px;'>Projections</b></u>",
      data = list(),
      showInLegend = TRUE,
      enableMouseTracking = FALSE,
      color = "transparent",
      marker = list(enabled = FALSE),
      states = list(hover = list(enabled = FALSE)),
      events = list(legendItemClick = highcharter::JS("function () { return false; }"))
    ) %>%
    # Projections data
    highcharter::hc_add_series(data = projected_data, type = "line",
                               highcharter::hcaes(name = scenario_line,
                                                  group = scenario_line,
                                                  x = year, y = value),
                               dashStyle = "shortdash"
    ) %>%
    # Plot aesthetics
    highcharter::hc_colors(which_colors) %>%
    highcharter::hc_tooltip(crosshairs = TRUE,
                            valueDecimals = 2,
                            useHTML = TRUE,
                            formatter = htmlwidgets::JS(sprintf("
                                    function () {
                                      return '<b>' + this.series.name + '</b><br>' +
                                             Math.round(this.point.year) + ': ' + this.point.y.toFixed(2) + ' %s';
                                    }
                                  ", unit))
    ) %>%
    highcharter::hc_yAxis(title = list(text = sprintf("%s concentration (%s)", stringr::str_to_sentence(which_ghg), unit),
                                       style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")

                          )) %>%
    highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")
                          )) %>%
    highcharter::hc_title(text = sprintf("Global Atmospheric Concentrations of %s Over Time", which_ghg)) %>%
    highcharter::hc_plotOptions(line = list(marker = list(enabled = FALSE)),
                                arearange  = list(marker = list(enabled = FALSE))) %>%
    highcharter::hc_legend(
      layout = "vertical",
      align = "right",
      verticalAlign = "middle",
      useHTML = TRUE,
      itemStyle = list(
        fontSize = "12px"
      )
    )

  return(ghg_plot)


}
