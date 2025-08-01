#' av_temp_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_av_temp_map_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("scenario_choice"),
                label = "Choose a Scenario",
                choices = c("Observations",
                            "Low emissions (SSP1-2.6)",
                            "Intermediate emissions (SSP2-4.5)",
                            "High emissions (SSP3-7.0)",
                            "Very high emissions (SSP5-8.5)))")
    ),

    shinycssloaders::withSpinner(plotOutput(ns("map")))

  )
}

#' av_temp_map Server Functions
#'
#' @noRd
mod_av_temp_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


# Read in data ------------------------------------------------------------

    clim_divs <- sf::read_sf('inst/extdata/map_boundaries/climate_divisions.geojson') %>% clean_climdiv() # Climate divisions
    us_states <- sf::read_sf('inst/extdata/map_boundaries/us_states.geojson')

# Bind together observed and projected and prepare for mapping ------------

    all_temps <- rbind(av_temp_map_obs, av_temp_map_mod) %>%
      dplyr::left_join(clim_divs, by = "climdiv") %>%
      sf::st_as_sf() %>%
      dplyr::filter(!is.na(rate_change_100)) %>%
      rename_scenarios(., TRUE) %>%
      dplyr::mutate(legend_buckets = cut(rate_change_100, breaks = seq(0, 16, by = 2))) %>%
      dplyr::mutate(legend_buckets_01 = cut(rate_change_100, breaks = c(-0.1, 0, 0.1, 2))) %>%
      dplyr::mutate(legend_buckets = ifelse(rate_change_100 <= 2, as.character(legend_buckets_01), as.character(legend_buckets)))

    all_temps$legend_buckets <- as.factor(all_temps$legend_buckets)
    all_temps$legend_buckets <- forcats::fct_relevel(all_temps$legend_buckets, c(
      "(-0.1,0]",
      "(0,0.1]" ,
      "(0.1,2]",
      "(2,4]",
      "(4,6]",
      "(6,8]",
      "(8,10]",
      "(10,12]",
      "(12,14]",
      "(14,16]"
    ))


# Make the maps ------------------------------------------------------------

    temp_colors <- c(
      "(-0.1,0]" = "#C7C7C7",
      "(0,0.1]" = "#C7C7C7",
      "(0.1,2]" = "#F0D7D6",
      "(2,4]" =  "#F1C1BE",
      "(4,6]" = "#EF9F9C",
      "(6,8]" = "#ED7974",
      "(8,10]" = "#E8413E",
      "(10,12]" = "#BD2B2D",
      "(12,14]" = "#A02725",
      "(14,16]" = "#780707"
    )


  make_temp_map <- function(which_scenario, all_temps_df, which_colors){

    # Filter to the map
    which_map <- all_temps_df %>%
      dplyr::filter(scenario == which_scenario)

    temp_map <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets), color = "#88807F") +
      #  ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets, color = legend_buckets)) +
      ggplot2::scale_fill_manual(values = which_colors, drop = FALSE) +
      #  ggplot2::scale_color_manual(values = temp_colors, drop = FALSE) +
      ggplot2::facet_wrap(~scenario_title, ncol = 2) +
      #  ggplot2::geom_sf(data = us_states %>% dplyr::filter(!STUSPS%in%c("AK", "HI", "PR", "AS", "MP", "GU")), color = "black", fill = NA) +
      ggplot2::labs(
        title = "Rate of Temperature Change in the United States, 2024–2100",
        fill = "Rate of temperature change\n(°F per century)"
      ) +
      ggthemes::theme_map() +
      ggplot2::theme(
        text = ggplot2::element_text(size = 12),
        plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
        #   legend.key.width = ggplot2::unit(2, 'cm'),
        legend.position = "bottom"
      )

    return(temp_map)

  }

  all_scenarios <- unique(all_temps$scenario)
  names(all_scenarios) <- all_scenarios  # Set names to match values
  all_maps <- lapply(all_scenarios, make_temp_map, all_temps, temp_colors)


# Make reactive -----------------------------------------------------------

  output$map <- renderPlot({

     # Map selection to file paths
    which_map <- switch(input$scenario_choice,
                        "Observations" = all_maps$observed,
                        "Low emissions (SSP1-2.6)" = all_maps$ssp126,
                        "Intermediate emissions (SSP2-4.5)" = all_maps$ssp245,
                        "High emissions (SSP3-7.0)" = all_maps$ssp370,
                        "Very high emissions (SSP5-8.5)))" = all_maps$ssp585
                        )
    return(which_map)

  })
})
}


## To be copied in the UI
# mod_av_temp_map_ui("av_temp_map_1")

## To be copied in the server
# mod_av_temp_map_server("av_temp_map_1")
