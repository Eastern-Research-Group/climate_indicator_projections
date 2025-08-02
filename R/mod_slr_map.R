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
  tagList(

    shinycssloaders::withSpinner(leaflet::leafletOutput(ns("map"),width = "100%", height = 800))

  )
}

#' slr_map Server Functions
#'
#' @noRd
mod_slr_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    slr_map_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-2.csv"), skip = 6)

    slr_map_mod_all_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

    # clean and process the data
    slr_map_obs <- slr_map_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::mutate(scenario = "observed") %>%
      sf::st_as_sf(coords = c("long", "lat"), crs = 4326, remove = FALSE)

    # Create the color palette
    pal <- leaflet::colorBin("RdYlBu", domain = slr_map_obs$relative_sea_level_change, reverse = TRUE)
    pal_legend <- leaflet::colorBin("RdYlBu", domain = slr_map_obs$relative_sea_level_change)

    # generatae leaflet map
    output$map <- leaflet::renderLeaflet({

      leaflet_map <- leaflet::leaflet() %>%
        leaflet::addTiles() %>%
        leaflet::addCircleMarkers(data = slr_map_obs,
                                  layerId = ~station_name,
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Observations",
                                  label = ~as.character(station_name),
                                  color = ~pal(relative_sea_level_change)
                                  ) %>%
        leaflet::setView(., lng = -99, lat = 39, zoom = 4) %>%
        leaflet::addLegend(pal = pal_legend, values =  slr_map_obs$relative_sea_level_change, opacity = 1,
                           title = "Relative Sea Level Change",
                           position = "topleft",
                           labFormat = leaflet::labelFormat(transform = function(x) sort(x, decreasing = TRUE))) %>%
        leaflet::addLayersControl(
          baseGroups = c("Observations"),
          options = leaflet::layersControlOptions(collapsed = FALSE),
          position = "topleft"
        )

        return(leaflet_map)

    })

  })
}

## To be copied in the UI
# mod_slr_map_ui("slr_map_1")

## To be copied in the server
# mod_slr_map_server("slr_map_1")
