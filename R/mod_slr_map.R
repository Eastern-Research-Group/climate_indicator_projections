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

    # Read in data
    slr_map_obs_raw <- readr::read_csv(file.path(config::get("slr_path"), "sea-level_fig-2.csv"), skip = 6)
    slr_map_mod_raw <- readr::read_csv(file.path(config::get("slr_path"), "SLR_TF U.S. Sea Level Projections.csv"), skip = 17)

    # clean and process the data
    slr_map_obs <- slr_map_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::select(-state)

  # Clean and process the modeled data
    slr_map_mod_cln <- slr_map_mod_raw %>%
      clean_slr_mod_data() %>% # Initial clean of the modeled data
      dplyr::filter(noaa_name != "GMSL") %>% # don't need GMSL
      # Make a column of station names that will match the observations station names
      dplyr::mutate(station_name = dplyr::case_when(
        noaa_name == "Baltimore, Fort McHenry, Patapsco River" ~ "Baltimore",
        noaa_name == "Beaufort, Duke Marine Lab" ~ "Beaufort",
        noaa_name == "Charleston, Cooper River Entrance" ~ "Charleston",
        noaa_name == "Freeport" ~ "Freeport Harbor",
        noaa_name == "Hilo, Hilo Bay, Kuhio Bay" ~ "Hilo",
        noaa_name == "Kahului, Kahului Harbor" ~ "Kahului",
        noaa_name == "Kwajalein, Marshall Islands" ~ "Kwajalein",
        noaa_name == "Mayport (Bar Pilots Dock)" ~ "Mayport",
        noaa_name == "San Diego, San Diego Bay" ~ "San Diego",
        noaa_name == "Skagway, Taiya Inlet" ~ "Skagway",
        noaa_name == "St. Petersburg, Tampa Bay" ~ "St. Petersburg",
        noaa_name == "Virginia Key, Biscayne Bay" ~ "Virginia Key",
        noaa_name == "Wake Island, Pacific Ocean" ~ "Wake Island",
        TRUE ~ noaa_name
      )) %>%
      dplyr::filter(year > 2005) %>%
      dplyr::group_by(station_name, scenario) %>%
      dplyr::mutate(rate_change = lm(slr_in ~ year)$coefficients[[2]]) %>%
      dplyr::mutate(relative_sea_level_change = rate_change*(2150-2020)) %>%
      dplyr::slice(1) %>%
      dplyr::select(station_name, scenario, relative_sea_level_change, lat, long) %>%
      # for now filter to just the medium scenarios
      dplyr::filter(scenario %in% c("0.5 - MED", "1.0 - MED")) %>%
      dplyr::mutate(scenario = ifelse(scenario == "0.5 - MED", "Lower sea level rise", "Higher sea level rise"))

    ## TODO: Do I need to adjust for NOAA 2005 offset
    # dplyr::mutate(slr_in = slr_in + noaa_2005)

    ## TODO: observed data is from 1960 to 2023 but can only use projections that start at 2020 or 2030

    # Filter to just the stations that are in bo
    obs_stations <- unique(slr_map_obs$station_name)
    mod_stations <- unique(slr_map_mod_cln$station_name)
    wanted_stations <- intersect(obs_stations, mod_stations)

    ## TODO: MEED TO DECIDE WHAT TO DO HERE:
    #"Galveston Bay Entrance" / "Galveston Pleasure Pier" & "Galveston Pier 21"

    # combine with observed data and final processing
    slr_map_cln_data <- rbind(slr_map_obs, slr_map_mod_cln) %>%
      dplyr::filter(station_name %in% wanted_stations) %>%  #filter to just stations that have both modeled and observed data
      sf::st_as_sf(coords = c("long", "lat"), crs = 4326) # make geospatial

    # pull things out separately
    slr_map_obs_fnl <- slr_map_cln_data %>% dplyr::filter(scenario == "observed")
    slr_map_lo_fnl <- slr_map_cln_data %>% dplyr::filter(scenario == "Lower sea level rise")
    slr_map_hi_fnl <- slr_map_cln_data %>% dplyr::filter(scenario == "Higher sea level rise")

    # Create the color palette
    pal <- leaflet::colorBin("RdYlBu", domain = slr_map_cln_data$relative_sea_level_change, reverse = TRUE)
    pal_legend <- leaflet::colorBin("RdYlBu", domain = slr_map_cln_data$relative_sea_level_change)

    # generatae leaflet map
    output$map <- leaflet::renderLeaflet({

      leaflet_map <- leaflet::leaflet() %>%
        leaflet::addTiles() %>%
        # Observed data
        leaflet::addCircleMarkers(data = slr_map_obs_fnl,
                                  layerId = ~station_name,
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Observations",
                                  label = ~as.character(station_name),
                                  color = ~pal(relative_sea_level_change)
                                  ) %>%
        # Lower sea level rise
        leaflet::addCircleMarkers(data = slr_map_lo_fnl,
                                  layerId = ~station_name,
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Lower sea level rise",
                                  label = ~as.character(station_name),
                                  color = ~pal(relative_sea_level_change)
        ) %>%
        # Higher sea level rise
        leaflet::addCircleMarkers(data = slr_map_hi_fnl,
                                  layerId = ~station_name,
                                  radius = 6,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  group = "Higher sea level rise",
                                  label = ~as.character(station_name),
                                  color = ~pal(relative_sea_level_change)
        ) %>%
        leaflet::setView(., lng = -99, lat = 39, zoom = 4) %>%
        leaflet::addLegend(pal = pal_legend, values =  slr_map_cln_data$relative_sea_level_change, opacity = 1,
                           title = "Relative Sea Level Change",
                           position = "topleft",
                           labFormat = leaflet::labelFormat(transform = function(x) sort(x, decreasing = TRUE))) %>%
        leaflet::addLayersControl(
          overlayGroups  = c("Observations","Lower sea level rise",  "Higher sea level rise"),
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
