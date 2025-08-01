#' arctic_sea_ice_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_arctic_sea_ice_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' arctic_sea_ice_plot Server Functions
#'
#' @noRd
mod_arctic_sea_ice_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


# Set year variables ------------------------------------------------------

    min_hind_yr <- 1950 # first year of hindcast data
    base_yr_start <- 1979
    base_yr_end <- 2014

# Process the data --------------------------------------------------------

    # Combine observed and model average
    asi_obs_mod_av <- rbind(asi_plot_obs, asi_plot_mod_av)

    # Conduct bias correction and process model range
    asi_adj_all <- process_sea_ice(asi_obs_mod_av, asi_plot_mod_all, base_yr_start, base_yr_end, min_hind_yr) %>%
      dplyr::rename(smoothed_anom_adj = si_extent_adj) # rename for highchart


# Create the plot ---------------------------------------------------------

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(asi_adj_all,
                     "September Monthly Average Arctic Sea Ice Extent, 1950–2100",
                     "Sea Ice Extent (million square miles)",
                     " million square miles")

    })

  })
}

## To be copied in the UI
# mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1")

## To be copied in the server
# mod_arctic_sea_ice_plot_server("arctic_sea_ice_plot_1")
