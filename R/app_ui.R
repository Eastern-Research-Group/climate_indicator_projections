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
      htmlTemplate(
        app_sys("app/www/landing.html"),
        content = tagList(
          # Greenhouse Gas Concentrations -------------------------------------------
          conditionalPanel(
            "input.selected_tab=='ghg_conc'",
            render_indicator_page(
              title="Greenhouse Gas Concentrations",
              timeseries=mod_ghg_conc_plot_ui("ghg_conc_plot_1"),
              summary=render_summary(
              ),
              tech_doc=render_tech_doc(

              )
            )
          ),
          # Average Temperature -----------------------------------------------------
          conditionalPanel(
            "input.selected_tab == null || input.selected_tab=='annual_total_temp'",
            render_indicator_page(
              title="Annual Total Temperature",
              maps=mod_av_temp_map_ui("av_temp_map_1"),
              timeseries=mod_av_temp_plot_ui("av_temp_plot_1"),
              summary=render_summary(
              ),
              tech_doc=render_tech_doc(

              )
            )
          ),

          # Growing season ----------------------------------------------------------
          conditionalPanel(
            "input.selected_tab=='length_of_growing_season'",
            render_indicator_page(
              title="Length of Growing Season",
              maps=mod_grow_season_map_ui("grow_season_map_1"),
              timeseries=mod_grow_season_plot_ui("grow_season_plot_1"),
              summary=render_summary(

              ),
              tech_doc=render_tech_doc(

              )
            )
          ),

          # Seasonal Temperature ----------------------------------------------------
          conditionalPanel(
            "input.selected_tab=='seasonal_temp'",
            render_indicator_page(
              title="Seasonal Temperature",
              maps=mod_seasonal_temp_map_ui("seasonal_temp_map_1"),
              timeseries=mod_seasonal_temp_plot_ui("seasonal_temp_plot_1"),
              summary=render_summary(

              ),
              tech_doc=render_tech_doc(

              )
            )
          ),

          # Precipitation -----------------------------------------------------------
          conditionalPanel(
            "input.selected_tab=='total_precip'",
            render_indicator_page(
              title="Annual Total Precipitation",
              maps=mod_precip_map_ui("precip_map_1"),
              timeseries=mod_precip_plot_ui("precip_plot_1"),
              summary=render_summary(

              ),
              tech_doc=render_tech_doc(

              )
            )
          ),

        # Sea Surface Temperature -------------------------------------------------
        conditionalPanel(
          "input.selected_tab=='sst'",
          render_indicator_page(
            title="Sea Surface Temperature",
            timeseries=mod_sst_plot_ui("sst_plot_1"),
            summary=render_summary(

            ),
            tech_doc=render_tech_doc(

            )
          )
        ),

        # Sea Level Change --------------------------------------------------------
        conditionalPanel(
          "input.selected_tab=='slr'",
          render_indicator_page(
            title="Sea Level",
            maps=
                mod_slr_map_ui("slr_map_1"),
            timeseries=mod_slr_plot_ui("slr_plot_1"),
            summary=render_summary(

            ),
            tech_doc=render_tech_doc(

            )


          )
        ),


        # Coastal Flooding --------------------------------------------------------
        conditionalPanel(
          "input.selected_tab=='coast_flood'",
          render_indicator_page(
            title="Coastal Flooding",
            maps= mod_coast_fld_map_ui("coast_fld_map_1"),
            summary=render_summary(

            ),
            tech_doc=render_tech_doc(

            )


          )
        ),


        # Ocean Acidity -----------------------------------------------------------
        conditionalPanel(
          "input.selected_tab=='ocean_acid'",
          render_indicator_page(
            title="Ocean Acidity",
            timeseries=mod_ocean_acidity_plot_ui("ocean_acidity_plot_1"),
            summary=render_summary(

            ),
            tech_doc=render_tech_doc(

            )
          )
        ),

        # Arctic Sea Ice Cover --------------------------------------------------------
        conditionalPanel(
          "input.selected_tab=='arctic_sea_ice'",
          render_indicator_page(
            title="Arctic Sea Ice",
            timeseries=mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1"),
            summary=render_summary(

            ),
            tech_doc=render_tech_doc(

            )
          )
        ),

      # Snow Cover --------------------------------------------------------------
      conditionalPanel(
        "input.selected_tab=='snow_cover'",
        render_indicator_page(
          title="Snow Cover",
          timeseries=mod_snow_cover_plot_ui("snow_cover_plot_1"),
          summary=render_summary(

          ),
          tech_doc=render_tech_doc(

          )
        )
      ),



        )
      ),
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
  golem::add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys("app/www"),
      app_title = "climate_indicator_projections"
    ),
    shinyjs::useShinyjs(),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
