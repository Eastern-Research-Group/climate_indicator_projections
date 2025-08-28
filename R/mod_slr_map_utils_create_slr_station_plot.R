
create_slr_station_plot <- function(slr_station_data){


  highcharter::highchart() %>%
    highcharter::hc_add_series(data = slr_station_data %>% dplyr::filter(scenario=="Observations"),
                               type = "line",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year, y = slr_in),
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = sprintf("<br>{point.year}: {point.y}%s", "inches")
                               ),
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
