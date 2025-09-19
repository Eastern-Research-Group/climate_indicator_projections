#' slr_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_slr_map_ui <- function(id) {
  ns <- NS(id)
  render_map_page(
    map=
      shinycssloaders::withSpinner(
        tagList(
          tags$p("Relative Sea Level Change Along U.S. Coasts, 1960-2150", class="title"),
          leaflet::leafletOutput(
            ns("map"),
            width = "100%",
            height = 800
          ),
          absolutePanel(
            id = ns("overlay"),
            class = "panel panel-default map_overlay",
            top = 60,
            right = 20,
            width = 440,
            style="display:none;", # Start with it hidden, so it doesn't appear without the map
            fixed=TRUE,
            draggable = TRUE,
            height = "auto",
            tagList(
              tags$div(
                span(h5("Please select a location to view the sea level rise chart")),
                id=ns("no_data_selected")
              ),
              tags$div(
                tagList(
                  # Minimize button as an actionButton
                  actionButton(
                    inputId = ns("minimize_panel"),
                    label = HTML("&#8722;"),  # Minus sign
                    class = "btn btn-secondary btn-sm rounded-circle minimize-button"
                  ),
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

#' slr_map Server Functions
#'
#' @noRd
mod_slr_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Make sur it's read in as an sf
    cln_data <- sf::st_as_sf(slr_map_cln_data)

    # pull things out separately
    slr_map_obs_fnl <- cln_data %>% dplyr::filter(scenario == "observed")
    slr_map_lo_fnl <- cln_data %>% dplyr::filter(scenario == "Lower sea level rise")
    slr_map_hi_fnl <- cln_data %>% dplyr::filter(scenario == "Higher sea level rise")

    # Create the color palette
    pal <- leaflet::colorBin("RdYlBu", domain = cln_data$relative_sea_level_change, right = FALSE, reverse = TRUE)
    pal_legend <- leaflet::colorBin("RdYlBu", domain = cln_data$relative_sea_level_change, right = FALSE)

    leaflet_map <- leaflet::leaflet() %>%
      leaflet::addTiles(., urlTemplate = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png') %>%
      # Observed data
      leaflet::addCircleMarkers(data = slr_map_obs_fnl,
                                layerId = ~paste0(station_name, " Observations"),
                                radius = 6,
                                stroke = TRUE,
                                fillOpacity = 1,
                                group = "Observations (1960-2023)",
                                label = ~paste0(station_name, ": ", round(relative_sea_level_change,2), " ft"),
                                color = ~pal(relative_sea_level_change)
      ) %>%
      # Lower sea level rise
      leaflet::addCircleMarkers(data = slr_map_lo_fnl,
                                layerId =  ~paste0(station_name, " Lower SLR"),
                                radius = 6,
                                stroke = TRUE,
                                fillOpacity = 1,
                                group = "Lower sea level rise (2020-2150)",
                                label = ~paste0(station_name, ": ", round(relative_sea_level_change,2), " ft"),
                                color = ~pal(relative_sea_level_change)
      ) %>%
      # Higher sea level rise
      leaflet::addCircleMarkers(data = slr_map_hi_fnl,
                                layerId =  ~paste0(station_name, " Higher SLR"),
                                radius = 6,
                                stroke = TRUE,
                                fillOpacity = 1,
                                group = "Higher sea level rise (2020-2150)",
                                label = ~paste0(station_name, ": ", round(relative_sea_level_change,2), " ft"),
                                color = ~pal(relative_sea_level_change)
      ) %>%
      leaflet::setView(., lng = -99, lat = 39, zoom = 4) %>%
      leaflet::addLegend(pal = pal_legend,
                         values =  cln_data$relative_sea_level_change,
                         opacity = 1,
                         title = "Relative Sea<br>Level Change (ft)",
                         position = "topleft",
                         # labels =  c("-80 - -59",
                         #             "-60 - -39",
                         #             "-40 - -19",
                         #             "-20 - -1",
                         #             "0 - 19",
                         #             "20 - 39",
                         #             "40 - 59",
                         #             "60 - 79",
                         #             "80 - 99",
                         #             "100 - 120"
                         #             ),
                         labFormat = leaflet::labelFormat(transform = function(x) sort(x, decreasing = TRUE))
                         ) %>%
      leaflet::addLayersControl(
        baseGroups = c("Observations (1960-2023)", "Lower sea level rise (2020-2150)",  "Higher sea level rise (2020-2150)"),
        options = leaflet::layersControlOptions(collapsed = FALSE),
        position = "topleft"
      )

    # generatae leaflet map
    output$map <- leaflet::renderLeaflet(leaflet_map)
    outputOptions(output, "map", suspendWhenHidden = TRUE)

    city_selected <- reactiveVal(NULL)

    observeEvent(input$map_bounds, {
      # ONce the map is loaded (we know it is loaded if we get a "Map bounds" event)
      # Then show the side overlay
      shinyjs::show("overlay")
    })

    observeEvent(input$minimize_panel, {
      city_selected(NULL)
    })

    # Observe click event
    observeEvent(input$map_marker_click, {

      # Remove type from the ID
      remove_list <- c(" Observations", " Lower SLR", " Higher SLR")
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
      paste0(city_selected(), " Cumulative Sea Level Change\n(1960-2150)")
    })
    outputOptions(output, "plot_title", suspendWhenHidden = TRUE)



    # high chart to render
    output$plot <- highcharter::renderHighchart({

      # Filter here
      ## IF city_Selected() is null, that means nothing has been selected.

      create_slr_station_plot(slr_map_inset_plot, city_selected())


    })

    outputOptions(output, "plot", suspendWhenHidden = TRUE)

  })


}

## To be copied in the UI
# mod_slr_map_ui("slr_map_1")

## To be copied in the server
# mod_slr_map_server("slr_map_1")
