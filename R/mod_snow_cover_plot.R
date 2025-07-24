#' snow_cover_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_snow_cover_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("season_choice"),
                label = "Choose a Season",
                choices = c("Annual",
                            "Winter",
                            "Spring",
                            "Summer",
                            "Fall")),

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' snow_cover_plot Server Functions
#'
#' @noRd
mod_snow_cover_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Set year variables ------------------------------------------------------

    min_hind_yr <- 1950

# Read in data ------------------------------------------------------------

    # Set path
    sc_path <- "inst/extdata/snow_cover"

    # Annual snow cover
    sc_an_proj_av <- readr::read_csv(file.path(sc_path, "snc_annual_bayesian_average.csv"))
    sc_an_proj_mod <- readr::read_csv(file.path(sc_path, "snc_annual_all_models.csv"))

    # Seasonal snow cover
    sc_seas_proj_av <- readr::read_csv(file.path(sc_path, "snc_seasonal_bayesian_average.csv")) %>%
      dplyr::mutate(season = dplyr::case_when(
        season == 1 ~ "Winter",
        season == 2 ~ "Spring",
        season == 3 ~ "Summer",
        season == 4 ~ "Fall"
      ))
    sc_seas_proj_mod <- readr::read_csv(file.path(sc_path, "snc_seasonal_all_models.csv")) %>%
      dplyr::mutate(season = dplyr::case_when(
        season == 1 ~ "Winter",
        season == 2 ~ "Spring",
        season == 3 ~ "Summer",
        season == 4 ~ "Fall"
      ))


# Clean and process observed and projected data ---------------------------

    sc_out <- reactive({

      if (input$season_choice == "Annual") {

        sc_all <- process_sc(sc_an_proj_av, sc_an_proj_mod, min_hind_yr, input$season_choice)

      } else{

        sc_all <- process_sc(sc_seas_proj_av, sc_seas_proj_mod, min_hind_yr, input$season_choice)

      }

      return(sc_all)

    })

# Create the plot ---------------------------------------------------------

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(sc_out(),
                     sprintf("%s Snow-Covered Area in North America, 1950–2100", input$season_choice),
                     "Snow-covered area<br>(million square miles)",
                     " million square miles")

    })

  })
}

## To be copied in the UI
# mod_snow_cover_plot_ui("snow_cover_plot_1")

## To be copied in the server
# mod_snow_cover_plot_server("snow_cover_plot_1")
