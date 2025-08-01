#' ocean_acidity_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ocean_acidity_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("station_choice"),
                label = "Choose a Station",
                choices = c("Hawaii",
                            "Canary Islands",
                            "Bermuda",
                            "Cariaco"
                            )),

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' ocean_acidity_plot Server Functions
#'
#' @noRd
mod_ocean_acidity_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # reactive part
    oa_proj_all_out <- reactive({

      filter_obs <- clean_oa_obs(input$station_choice, oa_plot_obs)

      oa_proj_mod_range_filt <- oa_plot_mod_all %>% dplyr::filter(station_name==input$station_choice)

      oa_proj_all <- oa_plot_mod_av %>%
        dplyr::filter(station_name==input$station_choice) %>%
        rbind(filter_obs) %>%
        dplyr::full_join(oa_proj_mod_range_filt, by = c("station_name", "scenario", "date")) %>%
        # rename for highchart function
        dplyr::mutate(year = as.Date(date, format = "%Y-%m-%d")) %>%
        dplyr::rename(smoothed_anom_adj = ph,
                      p10_adj = p10,
                      p90_adj = p90) %>%
        rename_scenarios()
      return(oa_proj_all)

    })


    ### Create the plot ###

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(oa_proj_all_out(),
                     sprintf("%s Ocean Acidity, 1950–2100", input$station_choice),
                     "pH",
                     "",
                     TRUE)

    })



  })
}

## To be copied in the UI
# mod_ocean_acidity_plot_ui("ocean_acidity_plot_1")

## To be copied in the server
# mod_ocean_acidity_plot_server("ocean_acidity_plot_1")
