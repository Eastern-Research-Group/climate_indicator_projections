#' create_slr_plot
#'
#' @param slr_obs_cln Dataframe of observed slr data
#' @param slr_proj_all Dataframe of projected slr data
#' @param csiro_bounds Dataframe of CSIRO bounds for the observed slr data
#' @param vertical_legend TRUE or FALSE whether the legend should be vertical to the right of the plot. Default to TRUE.
#'
#' @returns
#' @export
#'
#' @examples
create_slr_plot <- function(slr_obs_cln, slr_proj_all, csiro_bounds, vertical_legend = TRUE){

  slr_plot <- highcharter::highchart() %>%
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
    highcharter::hc_add_series(data = slr_obs_cln,
                               type = "line",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year, y = slr_in),
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y} inches"
                               ),
                               color = c("purple", "black")
    ) %>%

    # Projected data
    highcharter::hc_add_series(data = slr_proj_all,
                               type = "line",
                               dashStyle = "shortdash",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year, y = slr_in),
                               tooltip = list(headerFormat = "<b>{series.name}</b>",
                                              pointFormat = "<br>{point.year}: {point.y} inches"
                               ),
                               color = c("orange", "blue")) %>%
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
    # Add tide gauge ranges
    highcharter::hc_add_series(data = csiro_bounds, type = "arearange",
                               highcharter::hcaes(name = scenario,
                                                  group = scenario,
                                                  x = year,
                                                  low = csiro_lower_error_bound_inches, high = csiro_upper_error_bound_inches),
                               lineColor = "transparent",
                               color = "black",
                               visible = FALSE,
                               fillOpacity = 0.3,
                               tooltip = list(headerFormat ="<b>{series.name}</b>",
                                              pointFormat =  "<br>{point.year}<br>Likely Range: {point.low} inches – {point.high} inches")) %>%
    # Projected data ranges
    highcharter::hc_add_series(data = slr_proj_all, type = "arearange",
                               highcharter::hcaes(name = scenario_area,
                                                  group = scenario_area,
                                                  x = year,
                                                  low = lower_bound, high = upper_bound),
                               lineColor = "transparent",
                               color = c("orange", "blue"),
                               visible = FALSE,
                               fillOpacity = 0.3,
                               tooltip = list(headerFormat ="<b>{series.name}</b>",
                                              pointFormat =  "<br>{point.year}<br>Likely Range: {point.low} inches – {point.high} inches")) %>%
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
                                arearange  = list(marker = list(enabled = FALSE)))

  if (vertical_legend) {

    slr_plot <- slr_plot %>%
      highcharter::hc_title(text = "Global Average Absolute and Projected Sea Level Change, 1880–2150") %>%
      highcharter::hc_legend(
        layout = "vertical",
        align = "right",
        verticalAlign = "middle",
        useHTML = TRUE,
        itemStyle = list(
          fontSize = "12px"
        )
      )

  } else{

    slr_plot <- slr_plot %>%
      highcharter::hc_legend(
        # layout = "vertical",
        # align = "center",
        # verticalAlign = "bottom",
        useHTML = TRUE,
        align = "left",
        # y = "10px",
        # verticalAlign = "bottom",
        # itemWidth = 200,
        # symbolWidth = 20,
        # width = 400,
        itemStyle = list(
          fontSize = "12px"
        )
      )

  }



  return(slr_plot)


}
