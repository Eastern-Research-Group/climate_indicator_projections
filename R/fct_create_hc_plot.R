#' create_hc_plot
#'
#' @param scenario_df Dataframe with observed and projected data and model range
#' @param plot_title String title
#' @param y_title String title
#' @param val_unit String unit of the value
#'
#' @description Create a highchart plot for the time series plot
#'
#' @return Highchart
#'
#' @noRd

create_hc_plot = function(scenario_df, plot_title, y_title, val_unit, is_oa = FALSE){

  # IPCC colors
  ssp126_col <- "#003466"
  ssp245_col <- "#f79420"
  ssp370_col <- "#e00101"
  ssp585_col <- "#990002"
  hindcast_col <- "#989898"

  ipcc_colors <- c(hindcast_col, ssp126_col, ssp245_col, ssp370_col, ssp585_col)

  scenario_df <- av_temp_plot_cln_data

  # Split up observed and modeled data
  obs_data <- scenario_df %>%
    dplyr::filter(scenario == "observed") %>%
    dplyr::select(year, scenario, scenario_line, smoothed_anom_adj)

  proj_line_data <- scenario_df %>%
    dplyr::filter(scenario != "observed")  %>%
    dplyr::select(year, scenario, scenario_line, smoothed_anom_adj)

  proj_range_data <- scenario_df %>%
    dplyr::filter(scenario != "observed")  %>%
    dplyr::select(year, scenario, scenario_ribbon, p10_adj, p90_adj)

  # Reorder the levels of the scenario names
  proj_line_data$scenario_line <- factor(proj_line_data$scenario_line,
                                    levels = c(
                                      "Model hindcast",
                                      "Low emissions (SSP1-2.6)",
                                      "Intermediate emissions (SSP2-4.5)",
                                      "High emissions (SSP3-7.0)",
                                      "Very high emissions (SSP5-8.5)"
                                    ))

  proj_range_data$scenario_ribbon <- factor(proj_range_data$scenario_ribbon,
                                      levels = c(
                                        "Model hindcast range",
                                        "Low emissions (SSP1-2.6) model range",
                                        "Intermediate emissions (SSP2-4.5) model range",
                                        "High emissions (SSP3-7.0) model range",
                                        "Very high emissions (SSP5-8.5) model range"
                                      ))

  # Make the highchart
  area_tooltip <- sprintf("<br>{point.year}<br>90th Percentile: {point.high}%s <br> 10th Percentile: {point.low}%s", val_unit, val_unit)

  hc_plot <- highcharter::highchart() %>%

    # Add dummy element to make legend group titles
    highcharter::hc_add_series(
      name = "<u><b style='font-size:13px;'>Average</b></u>",
      data = list(),
      showInLegend = TRUE,
      enableMouseTracking = FALSE,
      color = "transparent",
      marker = list(enabled = FALSE),
      states = list(hover = list(enabled = FALSE))
    ) %>%
    # Observed data
    highcharter::hc_add_series(data = obs_data, type = "line",
                               highcharter::hcaes(name = scenario_line,
                                                  group = scenario_line,
                                                  x = year, y = smoothed_anom_adj),
                               color = "black",
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = sprintf("<br>{point.year}: {point.y}%s", val_unit)
                               )) %>%
    # Projections data
    highcharter::hc_add_series(data = proj_line_data, type = "line",
                               highcharter::hcaes(name = scenario_line,
                                                  group = scenario_line,
                                                  x = year, y = smoothed_anom_adj),
                               dashStyle = "shortdash",
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = sprintf("<br>{point.year}: {point.y}%s", val_unit)
                               )) %>%
    # Add dummy element to make legend group titles
    highcharter::hc_add_series(
      name = "<u><b style='font-size:13px;'>Range</b></u>",
      data = list(),
      showInLegend = TRUE,
      enableMouseTracking = FALSE,
      color = "transparent",
      marker = list(enabled = FALSE),
      states = list(hover = list(enabled = FALSE))
    ) %>%
    # Add model ranges
    highcharter::hc_add_series(data = proj_range_data, type = "arearange",
                               highcharter::hcaes(name = scenario_ribbon,
                                                  group = scenario_ribbon,
                                                  x = year,
                                                  low = p10_adj, high = p90_adj),
                               lineColor = "transparent",
                               visible = FALSE,
                               fillOpacity = 0.3,
                               tooltip = list(headerFormat ="<b>{series.name}</b>",
                                              pointFormat = area_tooltip)) %>%
    # Plot aesthetics
    highcharter::hc_colors(ipcc_colors) %>%
    highcharter::hc_tooltip(crosshairs = TRUE, valueDecimals = 2) %>%
    highcharter::hc_yAxis(title = list(text = y_title, style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")

                          )) %>%
    highcharter::hc_title(text = plot_title) %>%
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

  if (is_oa) { # if it's the ocean acidity plot

    hc_plot <- hc_plot %>%
      highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                             type = "datetime",
                            labels = list(
                              style = list(fontSize = "14px"),
                                 format = "{value:%Y}"
                            )

      )

  }else{

    hc_plot <- hc_plot %>%
      highcharter::hc_xAxis(title = list(text = "Year", style = list(fontSize = "16px")),
                          labels = list(
                            style = list(fontSize = "14px")
                          )

    )

  }

  return(hc_plot)



}
