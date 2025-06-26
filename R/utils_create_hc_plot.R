#' create_hc_plot
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

create_hc_plot = function(scenario_df, plot_title, y_title){

  # IPCC colors
  ssp126_col <- "#003466"
  ssp245_col <- "#f79420"
  ssp370_col <- "#e00101"
  ssp585_col <- "#990002"
  hindcast_col <- "darkgrey"

  ipcc_colors <- c(hindcast_col, ssp126_col, ssp245_col, ssp370_col, ssp585_col)

  obs_data <- scenario_df %>%
    dplyr::filter(scenario == "observed") %>%
    dplyr::filter(!is.na(smoothed_anom_adj))

  proj_data <- scenario_df %>%
    dplyr::filter(scenario != "observed") %>%
    dplyr::filter(!is.na(smoothed_anom_adj))

  proj_data$scenario_line <- factor(proj_data$scenario_line,
                                    levels = c(
                                      "Model hindcast",
                                      "Low emissions (SSP1-2.6)",
                                      "Intermediate emissions (SSP2-4.5)",
                                      "High emissions (SSP3-7.0)",
                                      "Very high emissions (SSP5-8.5)"
  ))

  proj_data$scenario_ribbon <- factor(proj_data$scenario_ribbon,
                                    levels = c(
                                      "Model hindcast range",
                                      "Low emissions (SSP1-2.6) model range",
                                      "Intermediate emissions (SSP2-4.5) model range",
                                      "High emissions (SSP3-7.0) model range",
                                      "Very high emissions (SSP5-8.5) model range"
                                    ))

  # make the highchart
  area_tooltip <- "<br> 90th Percentile: {point.high} <br> 10th Percentile: {point.low}"

  hc_plot <- highcharter::highchart() %>%
    highcharter::hc_add_series(data = proj_data, type = "arearange",
                               highcharter::hcaes(name = scenario_ribbon,
                                                  group = scenario_ribbon,
                                                  x = year,
                                                  low = p10_adj, high = p90_adj),
                               lineColor = "transparent",
                               visible = FALSE,
                               fillOpacity = 0.3,
                               tooltip = list(headerFormat ="<b>{series.name}</b>",
                                              pointFormat = area_tooltip)) %>%
    highcharter::hc_add_series(data = obs_data, type = "line",
                               highcharter::hcaes(name = scenario_line,
                                                  group = scenario_line,
                                                  x = year, y = smoothed_anom_adj),
                               color = "black",
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y}"
                               )) %>%

    highcharter::hc_add_series(data = proj_data, type = "line",
                               highcharter::hcaes(name = scenario_line,
                                                  group = scenario_line,
                                                  x = year, y = smoothed_anom_adj),
                               dashStyle = "shortdash",
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y}"
                               )) %>%
    highcharter::hc_colors(ipcc_colors) %>%
    highcharter::hc_tooltip(crosshairs = TRUE, valueDecimals = 2) %>%
    highcharter::hc_yAxis(title = list(text = y_title, style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")
                          )) %>%
    highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")
                          )) %>%
    highcharter::hc_title(text = plot_title) %>%
    highcharter::hc_plotOptions(line = list(marker = list(enabled = FALSE)))

  return(hc_plot)



}
