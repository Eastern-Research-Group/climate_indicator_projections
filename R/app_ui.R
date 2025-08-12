#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(

      theme = shinythemes::shinytheme("flatly"),

      navlistPanel(
        widths = c(2, 10),  # Sidebar width, content width
        tabPanel("Average Temperature",
                 mod_av_temp_plot_ui("av_temp_plot_1")
        ),
        tabPanel("Average Temperature Map",
                 mod_av_temp_map_ui("av_temp_map_1")
        ),
        tabPanel("Growing Season",
                 mod_grow_season_plot_ui("grow_season_plot_1")
        ),
        tabPanel("Growing Map",
                 mod_grow_season_map_ui("grow_season_map_1")
        ),
        tabPanel("Sea Surface Temperature",
                 mod_sst_plot_ui("sst_plot_1")
        ),
        tabPanel("Annual Total Precipitation",
                 mod_precip_plot_ui("precip_plot_1")
        ),
        tabPanel("Annual Total Precipitation Map",
                 mod_precip_map_ui("precip_map_1")
        ),
        tabPanel("Seasonal Temperature",
                 mod_seasonal_temp_plot_ui("seasonal_temp_plot_1")
        ),
        tabPanel("Seasonal Temperature Maps",
                 mod_seasonal_temp_map_ui("seasonal_temp_map_1")
        ),
        tabPanel("Ocean Acidity",
                 mod_ocean_acidity_plot_ui("ocean_acidity_plot_1")
        ),
        tabPanel("Arctic Sea Ice",
                 mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1")
        ),
        tabPanel("Snow Cover",
                 mod_snow_cover_plot_ui("snow_cover_plot_1")
        ),
        tabPanel("Sea Level Rise",
                 mod_slr_plot_ui("slr_plot_1")
        ),
        tabPanel("Sea Level Rise Map",
                 mod_slr_map_ui("slr_map_1")
        ),
        tabPanel("Greenhouse Gas Concentrations",
                 mod_ghg_conc_plot_ui("ghg_conc_plot_1")
        ),

      )


    )
)

}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "climate_indicator_projections"
    ),
    shinyjs::useShinyjs(),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
