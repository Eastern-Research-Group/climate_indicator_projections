#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
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
        content = content <- tabsetPanel(
          id = "main_tabs",
          type = "hidden",  # Hide default tab headers (you use a custom sidebar)
          selected="about",
          tabPanel("About", value = "about",
                   mod_about_ui("about_1")
          ),
          tabPanel("Greenhouse Gas Concentrations", value = "ghg_conc",
                   render_indicator_page(
                     title = "Greenhouse Gas Concentrations",
                     timeseries = mod_ghg_conc_plot_ui("ghg_conc_plot_1"),
                     # INSET SUMMARY INFO
                     summary = render_summary(
                       intro=read_app_text("ghg_conc/text_intro.html"),
                       background=read_app_text("ghg_conc/text_background.html"),
                       key_points=read_app_text("ghg_conc/text_key_points.html"),
                       sources_and_methods=read_app_text("ghg_conc/text_sources.html")
                     ),
                     # INSERT TECH DOC INFO
                     tech_doc = render_tech_doc(
                       identification=read_app_text("ghg_conc/td_identification.html"),
                       data_sources=read_app_text("ghg_conc/td_data_sources.html"),
                       methodology=read_app_text("ghg_conc/td_methodology.html"),
                       analysis=read_app_text("ghg_conc/td_analysis.html"),
                       references=""
                     )
                   )
          ),

          tabPanel("Average Temperature", value = "av_temp",
                   render_indicator_page(
                     title = "Average Temperature",
                     maps = mod_av_temp_map_ui("av_temp_map_1"),
                     timeseries = mod_av_temp_plot_ui("av_temp_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("av_temp/text_intro.html"),
                       background=read_app_text("av_temp/text_background.html"),
                       key_points=read_app_text("av_temp/text_key_points.html"),
                       sources_and_methods=read_app_text("av_temp/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("av_temp/td_identification.html"),
                       data_sources=read_app_text("av_temp/td_data_sources.html"),
                       methodology=read_app_text("av_temp/td_methodology.html"),
                       analysis=read_app_text("av_temp/td_analysis.html"),
                       references=read_app_text("av_temp/td_references.html")
                     )
                   )
          ),

          tabPanel("Length of Growing Season", value = "length_of_growing_season",
                   render_indicator_page(
                     title = "Length of Growing Season",
                     maps = mod_grow_season_map_ui("grow_season_map_1"),
                     timeseries = mod_grow_season_plot_ui("grow_season_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("grow_season/text_intro.html"),
                       background=read_app_text("grow_season/text_background.html"),
                       key_points=read_app_text("grow_season/text_key_points.html"),
                       sources_and_methods=read_app_text("grow_season/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("grow_season/td_identification.html"),
                       data_sources=read_app_text("grow_season/td_data_sources.html"),
                       methodology=read_app_text("grow_season/td_methodology.html"),
                       analysis=read_app_text("grow_season/td_analysis.html"),
                       references=read_app_text("grow_season/td_references.html")
                     )
                   )
          ),

          tabPanel("Seasonal Temperature", value = "seasonal_temp",
                   render_indicator_page(
                     title = "Seasonal Temperature",
                     maps = mod_seasonal_temp_map_ui("seasonal_temp_map_1"),
                     timeseries = mod_seasonal_temp_plot_ui("seasonal_temp_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("seasonal_temp/text_intro.html"),
                       background=read_app_text("seasonal_temp/text_background.html"),
                       key_points=read_app_text("seasonal_temp/text_key_points.html"),
                       sources_and_methods=read_app_text("seasonal_temp/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("seasonal_temp/td_identification.html"),
                       data_sources=read_app_text("seasonal_temp/td_data_sources.html"),
                       methodology=read_app_text("seasonal_temp/td_methodology.html"),
                       analysis=read_app_text("seasonal_temp/td_analysis.html"),
                       references=read_app_text("seasonal_temp/td_references.html")
                     )
                   )
          ),

          tabPanel("Total Precipitation", value = "total_precip",
                   render_indicator_page(
                     title = "Total Precipitation",
                     maps = mod_precip_map_ui("precip_map_1"),
                     timeseries = mod_precip_plot_ui("precip_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("total_precip/text_intro.html"),
                       background=read_app_text("total_precip/text_background.html"),
                       key_points=read_app_text("total_precip/text_key_points.html"),
                       sources_and_methods=read_app_text("total_precip/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                         identification=read_app_text("total_precip/td_identification.html"),
                         data_sources=read_app_text("total_precip/td_data_sources.html"),
                         methodology=read_app_text("total_precip/td_methodology.html"),
                         analysis=read_app_text("total_precip/td_analysis.html"),
                         references=read_app_text("total_precip/td_references.html")
                     )
                   )
          ),

          tabPanel("Sea Surface Temperature", value = "sst",
                   render_indicator_page(
                     title = "Sea Surface Temperature",
                     timeseries = mod_sst_plot_ui("sst_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("sst/text_intro.html"),
                       background=read_app_text("sst/text_background.html"),
                       key_points=read_app_text("sst/text_key_points.html"),
                       sources_and_methods=read_app_text("sst/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("sst/td_identification.html"),
                       data_sources=read_app_text("sst/td_data_sources.html"),
                       methodology=read_app_text("sst/td_methodology.html"),
                       analysis=read_app_text("sst/td_analysis.html"),
                       references=read_app_text("sst/td_references.html")
                     )
                   )
          ),

          tabPanel("Sea Level", value = "slr",
                   render_indicator_page(
                     title = "Sea Level",
                     maps = mod_slr_map_ui("slr_map_1"),
                     timeseries = mod_slr_plot_ui("slr_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("sea_level/text_intro.html"),
                       background=read_app_text("sea_level/text_background.html"),
                       key_points=read_app_text("sea_level/text_key_points.html"),
                       sources_and_methods=read_app_text("sea_level/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("sea_level/td_identification.html"),
                       data_sources=read_app_text("sea_level/td_data_sources.html"),
                       methodology=read_app_text("sea_level/td_methodology.html"),
                       analysis=read_app_text("sea_level/td_analysis.html"),
                       references=read_app_text("sea_level/td_references.html")
                     )
                   )
          ),

          tabPanel("Coastal Flooding", value = "coast_flood",
                   render_indicator_page(
                     title = "Coastal Flooding",
                     maps = mod_coast_fld_map_ui("coast_fld_map_1"),
                     summary = render_summary(
                       intro=read_app_text("coastal_flooding/text_intro.html"),
                       background=read_app_text("coastal_flooding/text_background.html"),
                       key_points=read_app_text("coastal_flooding/text_key_points.html"),
                       sources_and_methods=read_app_text("coastal_flooding/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("coastal_flooding/td_identification.html"),
                       data_sources=read_app_text("coastal_flooding/td_data_sources.html"),
                       methodology=read_app_text("coastal_flooding/td_methodology.html"),
                       analysis=read_app_text("coastal_flooding/td_analysis.html"),
                       references=read_app_text("coastal_flooding/td_references.html")
                     )
                   )
          ),

          tabPanel("Ocean Acidity", value = "ocean_acid",
                   render_indicator_page(
                     title = "Ocean Acidity",
                     timeseries = mod_ocean_acidity_plot_ui("ocean_acidity_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("ocean_acidity/text_intro.html"),
                       background=read_app_text("ocean_acidity/text_background.html"),
                       key_points=read_app_text("ocean_acidity/text_key_points.html"),
                       sources_and_methods=read_app_text("ocean_acidity/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("ocean_acidity/td_identification.html"),
                       data_sources=read_app_text("ocean_acidity/td_data_sources.html"),
                       methodology=read_app_text("ocean_acidity/td_methodology.html"),
                       analysis=read_app_text("ocean_acidity/td_analysis.html"),
                       references=read_app_text("ocean_acidity/td_references.html")
                     )
                   )
          ),

          tabPanel("Arctic Sea Ice", value = "arctic_sea_ice",
                   render_indicator_page(
                     title = "Arctic Sea Ice",
                     timeseries = mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("arctic_sea_ice/text_intro.html"),
                       background=read_app_text("arctic_sea_ice/text_background.html"),
                       key_points=read_app_text("arctic_sea_ice/text_key_points.html"),
                       sources_and_methods=read_app_text("arctic_sea_ice/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("arctic_sea_ice/td_identification.html"),
                       data_sources=read_app_text("arctic_sea_ice/td_data_sources.html"),
                       methodology=read_app_text("arctic_sea_ice/td_methodology.html"),
                       analysis=read_app_text("arctic_sea_ice/td_analysis.html"),
                       references=read_app_text("arctic_sea_ice/td_references.html")
                     )
                   )
          ),

          tabPanel("Snow Cover", value = "snow_cover",
                   render_indicator_page(
                     title = "Snow Cover",
                     timeseries = mod_snow_cover_plot_ui("snow_cover_plot_1"),
                     summary = render_summary(
                       intro=read_app_text("snow_cover/text_intro.html"),
                       background=read_app_text("snow_cover/text_background.html"),
                       key_points=read_app_text("snow_cover/text_key_points.html"),
                       sources_and_methods=read_app_text("snow_cover/text_sources.html")
                     ),
                     tech_doc = render_tech_doc(
                       identification=read_app_text("snow_cover/td_identification.html"),
                       data_sources=read_app_text("snow_cover/td_data_sources.html"),
                       methodology=read_app_text("snow_cover/td_methodology.html"),
                       analysis=read_app_text("snow_cover/td_analysis.html"),
                       references=read_app_text("snow_cover/td_references.html")
                     )
                   )
          )
        )
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
