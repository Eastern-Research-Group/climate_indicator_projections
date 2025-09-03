#' create_slr_station_plot
#'
#' @param slr_stations_all df of all the slr stations and scenarios
#' @param which_station string of which station to plot
#'
#' @returns
#' @export
#'
#' @examples
create_slr_station_plot <- function(slr_stations_all, which_station){

  # Filter to the station to plot
  slr_station_data <- slr_stations_all %>%
    dplyr::filter(station_name == which_station)


  # Make the plot
  highcharter::highchart() %>%
    highcharter::hc_add_series(data = slr_station_data %>% dplyr::filter(scenario=="Observations"),
                               type = "line",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year, y = slr_in),
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y} inches"
                               ),
                               connectNulls = FALSE,
                               color = c("black")) %>%
    # Projected data
    highcharter::hc_add_series(data = slr_station_data %>% dplyr::filter(scenario!="Observations"),
                               type = "line",
                               dashStyle = "shortdash",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year, y = slr_in),
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y} inches"
                               ),
                               color = c("orange", "blue")) %>%
    # Plot aesthetics
    highcharter::hc_tooltip(crosshairs = TRUE, valueDecimals = 2) %>%
    highcharter::hc_yAxis(title = list(
      text = "Sea level change (inches)",
      style = list(fontSize = "16px")),
      labels = list(
        style = list(fontSize = "14px")
      )) %>%
    highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")
                          )) %>%
    highcharter::hc_plotOptions(line = list(marker = list(enabled = FALSE)),
                                arearange  = list(marker = list(enabled = FALSE))) %>%
    highcharter::hc_legend(
      useHTML = TRUE,
     # align = "middle",
      itemStyle = list(
        fontSize = "12px"
      )
    )




}
