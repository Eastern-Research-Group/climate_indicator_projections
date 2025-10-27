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
                        font-weight: bold !important;
                        color: white !important;
                        background: #162E51 !important;
                      }
                      .irs-bar {
                        background-color: transparent !important;
                        border-color: transparent !important;
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
              # Accessibility enhancement for keyboard navigation
              tags$script(HTML("")
              ),
              # Inset plot
              absolutePanel(
                id = ns("overlay"),
                class = "panel panel-default map_overlay",
                top = 200,
                right = 20,
                width = 450,
                style="display:none;", # Start with it hidden, so it doesn't appear without the map
                fixed=TRUE,
                draggable = TRUE,
                height = "auto",
                tagList(
                  tags$div(
                    span(strong("Please select a location to view coastal flooding plot.")),
                    id=ns("no_data_selected"),
                    style="min-height: 2rem; padding-top: 0.3rem;"
                  ),
                  tags$div(
                    tagList(
                      # Minimize button as an actionButton
                      actionButton(
                        inputId = ns("minimize_panel"),
                        label = HTML("&#8722;"),  # Minus sign
                        class = "btn btn-secondary btn-sm rounded-circle minimize-button"
                      ),
                      highcharter::highchartOutput(ns("plot")),
                      checkboxInput(ns("check"),
                                    label = HTML("Zoom to <b>observed</b> data."),
                                    value = FALSE, width = NULL)
                    ),
                    id=ns("graph_container"),
                    style="display:none"
                  )

                )
              )
            ),
          ),
        data_source=read_app_text("coastal_flooding/map_caption_data_source.html"),
        caption=read_app_text("coastal_flooding/map_caption_text.html")
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
    pal_legend <- leaflet::colorBin("RdYlBu", domain = c(0,366))

    # Initialize the map
    output$map <- leaflet::renderLeaflet({
        lmap <- leaflet::leaflet() %>%
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

      # Add title to the layer groups
      htmlwidgets::onRender(lmap, "
            function(el, x) {
              var control = el.querySelector('.leaflet-control-layers');
              if (control) {
                var title = document.createElement('div');
                title.innerHTML = '<strong>Projections</strong>';
                title.style.padding = '4px 4px';
                title.style.fontSize = '13px';
                title.style.borderBottom = '1px solid #ccc';
                control.insertBefore(title, control.firstChild);
              }
            }
          "
      )

    })

    # Reactive map ------------------------------------------------------------

    # Get the scenarios pre filtered
    lower_slr <- coastal_flood_cln_data %>%
      dplyr::filter(scenario %in% c("Observed", "Lower sea level rise"))

    higher_slr <- coastal_flood_cln_data %>%
      dplyr::filter(scenario %in% c("Observed", "Higher sea level rise"))

    render <- reactiveVal(FALSE)

    # Observe changes in the slider and update markers
    observe({
      req(input$decade)
      req(render())
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
                                  color = ~pal(fld_days_pdec),
                                  options=leaflet::pathOptions(className="circle_tabbable")
        ) %>%
        # Higher sea level rise
        leaflet::addCircleMarkers(data = higher_slr_filt,
                                  layerId =  ~paste0(station_name, " Higher SLR"),
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Higher sea level rise",
                                  label = ~paste0(station_name, ": ", round(fld_days_pdec,0), " days"),
                                  color = ~pal(fld_days_pdec),
                                  options=leaflet::pathOptions(className="circle_tabbable")
        )



    })


    # Inset Plot --------------------------------------------------------------

    city_selected <- reactiveVal(NULL)


    observeEvent(input$map_bounds, {
      # ONce the map is loaded (we know it is loaded if we get a "Map bounds" event)
      # Then show the side overlay
      shinyjs::show("overlay")
      render(TRUE)
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

    observeEvent(input$minimize_panel, {
      city_selected(NULL)
    })

    # Colors
    obs_col <- "black"
    hi_slr_col <- "orange"
    low_slr_col<- "blue"

    cf_colors <- c(hi_slr_col, low_slr_col, obs_col)

    # Filter the data
     observe({
       req(city_selected())

       # Filter to the chosen location
       filtered_loc <- coastal_flood_cln_data %>%
         dplyr::filter(station_name == city_selected())


       #maximum y axis
       max_y <- 370

       # zoom to observed data
       if (isTRUE(input$check)){

         filtered_loc <- filtered_loc %>%
           dplyr::filter(scenario == "Observed")

         #maximum y axis
         max_y <- NA

       }

       # render the plot
       output$plot <- highcharter::renderHighchart({

         filtered_data <- filtered_loc %>%
           sf::st_drop_geometry() %>%
           dplyr::mutate(decade = as.character(decade)) %>%
           dplyr::arrange(decade)

         decade_categories <- as.character(unique(filtered_data$decade))

         inset_plot <- highcharter::highchart() %>%
           highcharter::hc_add_series(data = filtered_data,
                                      type = "column",
                                      highcharter::hcaes(x = decade, y = fld_days_pdec, group = scenario),
                                      tooltip = list(headerFormat = "<b>{series.name}</b>",
                                                     pointFormat = "<br>{point.decade}: {point.y} days"
                                      )
           ) %>%
           highcharter::hc_plotOptions(bar = list(animation = FALSE)) %>%
           highcharter::hc_tooltip(valueDecimals = 0) %>%
           highcharter::hc_title(text = sprintf("Average Flood Days per Year Each Decade in %s", city_selected())) %>%
           highcharter::hc_xAxis(title = list(text = "Decade"), categories = decade_categories) %>%
           highcharter::hc_yAxis(title = list(text = "Average Flood Days"), max = max_y)

         if (isTRUE(input$check)){

           inset_plot %>%
             highcharter::hc_colors("black")

         } else{

           inset_plot %>%
             highcharter::hc_colors(cf_colors)

         }

       })

     })
     outputOptions(output, "map", suspendWhenHidden = TRUE)




  })
}

## To be copied in the UI
# mod_coast_fld_map_ui("coast_fld_map_1")

## To be copied in the server
# mod_coast_fld_map_server("coast_fld_map_1")
