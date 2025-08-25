#' create_static_map_ui
#'
#' @param ns name space
#' @param obs_dates string of dates for observed data title
#' @param proj_dates string of dates for projected data title
#' @param title title of map
#'
#' @description A fct function that creates the map UI
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
create_static_map_ui <- function(ns, obs_dates, proj_dates, title) {

  map_id <- ns("map_comparison")

  tagList(
      tags$p("Choose two scenarios to compare using the slider."),

    fluidRow(

      column(5,

             selectInput(ns("scenario_choice"),
                         label = "Left Map",
                         choices = c(sprintf("Observations, %s", obs_dates),
                                     sprintf("Low emissions (SSP1-2.6), %s", proj_dates),
                                     sprintf("Intermediate emissions (SSP2-4.5), %s", proj_dates),
                                     sprintf("High emissions (SSP3-7.0), %s", proj_dates),
                                     sprintf("Very high emissions (SSP5-8.5), %s", proj_dates)),
                         width="500px"
             )

      ),

      column(5,

             selectInput(ns("scenario_choice_2"),
                         label = "Right Map",
                         choices = c(sprintf("Observations, %s", obs_dates),
                                     sprintf("Low emissions (SSP1-2.6), %s", proj_dates),
                                     sprintf("Intermediate emissions (SSP2-4.5), %s", proj_dates),
                                     sprintf("High emissions (SSP3-7.0), %s", proj_dates),
                                     sprintf("Very high emissions (SSP5-8.5), %s", proj_dates)),
                         selected = sprintf("Very high emissions (SSP5-8.5), %s", proj_dates),
                         width="500px"
             )

      )

    ),

    # Before after slider
    tags$script(sprintf("
              $(function() {
    $('#%s').beforeAfter({
        introDelay: 2000,
        imagePath: 'img/',
        introDuration: 500,
        showFullLinks: false
    })
                });
    ", map_id)),
    tags$p(title, class="title"),
    shinycssloaders::withSpinner(
      tags$div(
        id = map_id,
        plotOutput(ns("map"), width = "600px", height = "600px"),
        plotOutput(ns("map_2"), width = "600px", height = "600px"),
      )
    )

  )
}
