#' ghg_conc_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ghg_conc_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

  )
}

#' ghg_conc_plot Server Functions
#'
#' @noRd
mod_ghg_conc_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

# Read in data ------------------------------------------------------------

  # Set path
  ghg_path <- "inst/extdata/ghg_conc"

  # Observed data
  co2_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-1.csv"), skip = 6)
  ch4_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-2.csv"), skip = 6)
  n2o_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-3.csv"), skip = 6)


# Clean observed data -----------------------------------------------------

  co2_obs_cln <- co2_obs %>%
    dplyr::filter(Year != "Ice core measurements") %>%
    tidyr::pivot_longer(cols = c(-Year),
                     names_to = "source",
                     values_to = "ppm")


  ch4_obs_cln <- ch4_obs %>%
    dplyr::filter(`Year (negative values = BC)` != "Ice core measurements") %>%
    tidyr::pivot_longer(cols = c(-"Year (negative values = BC)"),
                        names_to = "source",
                        values_to = "ppb") %>%
    dplyr::rename(Year = `Year (negative values = BC)`)

  n2o_obs_cln <- n2o_obs %>%
    tidyr::pivot_longer(cols = c(-"Year (negative values = BC)"),
                        names_to = "source",
                        values_to = "ppb") %>%
    dplyr::rename(Year = `Year (negative values = BC)`)


  })
}

## To be copied in the UI
# mod_ghg_conc_plot_ui("ghg_conc_plot_1")

## To be copied in the server
# mod_ghg_conc_plot_server("ghg_conc_plot_1")
