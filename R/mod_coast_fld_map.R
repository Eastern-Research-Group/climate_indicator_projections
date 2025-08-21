#' coast_fld_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_coast_fld_map_ui <- function(id) {
  ns <- NS(id)

      render_map_page(
        map=
          shinycssloaders::withSpinner(
            tagList(
              tags$p("Average Number of Coastal Flood Days per Year, 1950-2099", class="title"),
              tags$p("Observed period: 1950s to 2010s | Projected period: 2020s to 2090s", class="subtitle"),
              tags$style(HTML("
                      .irs-grid-text {
                        font-size: 12px;
                      }
                      .irs--shiny .irs-min,.irs--shiny .irs-max {
                        font-size: 12px;
                      }
                      .irs--shiny .irs-from,.irs--shiny .irs-to,.irs--shiny .irs-single {
                        font-size: 14px;
                      }
                      ")),
              # Decade slider
              sliderInput(inputId = ns("decade"),
                          label = "Select Decade:",
                          min = 1950,
                          max = 2090,
                          value = 2020,
                          step = 10,
                          #   animate = animationOptions(interval = 1000),
                          sep = "",
                          post = "s",
                          width = "100%"),
              # Leaflet map
              leaflet::leafletOutput(
                ns("map"),
                width = "100%",
                height = 800
              ),
              # Inset plot
              absolutePanel(
                id = ns("overlay"),
                class = "panel panel-default map_overlay",
                top = 90,
                right = 40,
                width = 440,
                style="display:none;", # Start with it hidden, so it doesn't appear without the map
                fixed=TRUE,
                draggable = TRUE,
                height = "auto",
                tagList(
                  tags$div(
                    span(h4("Please select a location to view coastal flooding plot.")),
                    id=ns("no_data_selected")
                  ),
                  tags$div(
                    tagList(
                      h5(textOutput(ns("plot_title"))),
                      highcharter::highchartOutput(ns("plot"))
                    ),
                    id=ns("graph_container"),
                    style="display:none"
                  )

                )
              )
            ),
          )
      )


}

#' coast_fld_map Server Functions
#'
#' @noRd
mod_coast_fld_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


    # Create the base map -----------------------------------------------------

    # Create the color palette
    pal <- leaflet::colorBin("RdYlBu", domain = coastal_flood_cln_data$fld_days_pdec, reverse = TRUE)
    pal_legend <- leaflet::colorBin("RdYlBu", domain = coastal_flood_cln_data$fld_days_pdec)

    # Initialize the map
    output$map <- leaflet::renderLeaflet({
      leaflet::leaflet() %>%
        leaflet::addTiles(., urlTemplate = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png') %>%
        leaflet::setView(., lng = -99, lat = 39, zoom = 4) %>%
        leaflet::addLegend(pal = pal_legend, values =  coastal_flood_cln_data$fld_days_pdec, opacity = 1,
                           title = "Average number of<br>flood days per year",
                           position = "topleft",
                           labFormat = leaflet::labelFormat(transform = function(x) sort(x, decreasing = TRUE))) %>%

        leaflet::addLayersControl(
          baseGroups = c("Lower sea level rise",  "Higher sea level rise"),
          options = leaflet::layersControlOptions(collapsed = FALSE),
          position = "topleft"
        )
    })


    # Reactive map ------------------------------------------------------------

    # Get the scenarios pre filtered
    lower_slr <- coastal_flood_cln_data %>%
      dplyr::filter(scenario %in% c("Observed", "Lower sea level rise"))

    higher_slr <- coastal_flood_cln_data %>%
      dplyr::filter(scenario %in% c("Observed", "Higher sea level rise"))

    # Observe changes in the slider and update markers
    observe({

      # Filter to the right decade
      lower_slr_filt <- lower_slr %>%
        dplyr::filter(decade == input$decade)

      higher_slr_filt <- higher_slr %>%
        dplyr::filter(decade == input$decade)

      # Update map
      leaflet::leafletProxy("map") %>%
        leaflet::clearMarkers() %>%
        # Lower sea level rise
        leaflet::addCircleMarkers(data = lower_slr_filt,
                                  layerId =  ~paste0(station_name, " Lower SLR"),
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Lower sea level rise",
                                  label = ~paste0(station_name, ": ", round(fld_days_pdec,0), " days"),
                                  color = ~pal(fld_days_pdec)
        ) %>%
        # Higher sea level rise
        leaflet::addCircleMarkers(data = higher_slr_filt,
                                  layerId =  ~paste0(station_name, " Higher SLR"),
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Higher sea level rise",
                                  label = ~paste0(station_name, ": ", round(fld_days_pdec,0), " days"),
                                  color = ~pal(fld_days_pdec)
        )
    })


    # Inset Plot --------------------------------------------------------------

    city_selected <- reactiveVal(NULL)

    observeEvent(input$map_bounds, {
      # ONce the map is loaded (we know it is loaded if we get a "Map bounds" event)
      # Then show the side overlay
      shinyjs::show("overlay")
    })

    # Observe click event
    observeEvent(input$map_marker_click, {

      # Remove type from the ID
      remove_list <- c(" Lower SLR", " Higher SLR")
      pattern <- paste(remove_list, collapse = "|")

      click <- stringr::str_remove_all(input$map_marker_click$id, pattern)

      city_selected(click)

    })

    observe({
      if (is.null(city_selected())) {
        shinyjs::show("no_data_selected")
        shinyjs::hide("graph_container")
      } else {
        shinyjs::show("graph_container")
        shinyjs::hide("no_data_selected")
      }
    })

    # high chart title
    output$plot_title <- renderText({
      paste0(city_selected(), " Coastal Flooding Days")
    })


    # high chart to render
    output$plot <- highcharter::renderHighchart({

      # Filter here
      ## IF city_Selected() is null, that means nothing has been selected.

      create_slr_plot(slr_plot_obs,
                      slr_plot_mod_all,
                      slr_plot_obs_csiro_bounds,
                      FALSE)


    })


  })
}

## To be copied in the UI
# mod_coast_fld_map_ui("coast_fld_map_1")

## To be copied in the server
# mod_coast_fld_map_server("coast_fld_map_1")
