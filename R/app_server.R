#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  mod_sst_plot_server("sst_plot_1")
  mod_grow_season_plot_server("grow_season_plot_1")
  mod_grow_season_map_server("grow_season_map_1")
  mod_av_temp_plot_server("av_temp_plot_1")
  mod_av_temp_map_server("av_temp_map_1")
  mod_precip_plot_server("precip_plot_1")
  mod_precip_map_server("precip_map_1")
  mod_seasonal_temp_plot_server("seasonal_temp_plot_1")
  mod_seasonal_temp_map_server("seasonal_temp_map_1")
  mod_ocean_acidity_plot_server("ocean_acidity_plot_1")
  mod_arctic_sea_ice_plot_server("arctic_sea_ice_plot_1")
  mod_snow_cover_plot_server("snow_cover_plot_1")
  mod_slr_plot_server("slr_plot_1")
  mod_slr_map_server("slr_map_1")
  mod_ghg_conc_plot_server("ghg_conc_plot_1")
}
