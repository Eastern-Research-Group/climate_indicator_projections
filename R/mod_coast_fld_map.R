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

  return(
      render_map_page(
        map=
          shinycssloaders::withSpinner(
            tagList(
              tags$p("Average Number of Coastal Flood Events per Year, 1950-2100", class="title"),
              sliderInput(ns("decade"), "Select Decade:",
                          min = 1950,
                          max = 2100,
                          value = 2020,
                          step = 10,
                          #   animate = animationOptions(interval = 1000),
                          sep = "",
                          post = "s",
                          width = "40%"),
              leaflet::leafletOutput(
                ns("map"),
                width = "100%",
                height = 800
              )
            )
          )
      )
    )

}

#' coast_fld_map Server Functions
#'
#' @noRd
mod_coast_fld_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

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
                                  layerId =  ~paste0(station_name, "Lower SLR"),
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Lower sea level rise",
                                  label = ~paste0(station_name, ": ", round(fld_days_pdec,2), " days"),
                                  color = ~pal(fld_days_pdec)
        ) %>%
        # Higher sea level rise
        leaflet::addCircleMarkers(data = higher_slr_filt,
                                  layerId =  ~paste0(station_name, " Higher SLR"),
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Higher sea level rise",
                                  label = ~paste0(fld_days_pdec, ": ", round(fld_days_pdec,2), " days"),
                                  color = ~pal(fld_days_pdec)
        )
    })

  })
}

## To be copied in the UI
# mod_coast_fld_map_ui("coast_fld_map_1")

## To be copied in the server
# mod_coast_fld_map_server("coast_fld_map_1")
