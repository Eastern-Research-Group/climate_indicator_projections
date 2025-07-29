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

    selectInput(ns("ghg_choice"),
                label = "Choose a Greenhouse Gas",
                choices = c("Carbon Dioxide",
                            "Methane",
                            "Nitrous Oxide")),

    checkboxInput(ns("check_all_years"),
                  label = "See 800,000 years of historical data",
                  value = FALSE, width = NULL),

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

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
  co2_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-1.csv"), skip = 6, col_types = readr::cols(.default = readr::col_character()))
  ch4_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-2.csv"), skip = 6, col_types= readr::cols(.default = readr::col_character()))
  n2o_obs <- readr::read_csv(file.path(ghg_path, "ghg-concentrations_fig-3.csv"), skip = 6, col_types= readr::cols(.default = readr::col_character()))

  # Projected data
  ghg_proj <- readr::read_csv(file.path(ghg_path, "ghg_concentrations_projections.csv"))


# Clean & Process data -----------------------------------------------------

  # Clean the projected data
  ghg_proj_cln <- ghg_proj %>%
    janitor::clean_names() %>%
    tidyr::pivot_longer(cols = tidyr::starts_with("ssp"),
                        names_to = "scenario",
                        values_to = "value") %>%
    dplyr::mutate(scenario = stringr::str_remove(scenario, "_")) %>%
    rename_scenarios() %>%
    dplyr::group_by(ghg)

  co2_obs_cln <- cln_ghg_obs(co2_obs)
  ch4_obs_cln <- cln_ghg_obs(ch4_obs, TRUE)
  n2o_obs_cln <- cln_ghg_obs(n2o_obs, TRUE)

# When a new ghg is chosen ------------------------------------------------


  # Do when the ghg is chosen
  ghg_conc_out <- reactive({

    # Set variable values depending on which greenhouse gas is selected
    if (input$ghg_choice == "Carbon Dioxide") {

      observed_data <- co2_obs_cln
      projected_data <- ghg_proj_cln %>% dplyr::filter(ghg == "co2")

    } else if (input$ghg_choice == "Methane") {

      observed_data <- ch4_obs_cln
      projected_data <- ghg_proj_cln %>% dplyr::filter(ghg == "ch4")

    } else if (input$ghg_choice == "Nitrous Oxide") {

       observed_data <- n2o_obs_cln
      projected_data <- ghg_proj_cln %>% dplyr::filter(ghg == "n2o")

    }

    # If don't check the box, filter to years to be more than 1850
    if (isFALSE(input$check_all_years)){
      observed_data <- observed_data %>%
        dplyr::filter(year >= 1850)
    }

    # Return list of dataframes
    list(observed_data = observed_data,
         projected_data = projected_data)


  })


# Create the plot ---------------------------------------------------------

  output$plot <- highcharter::renderHighchart({

    # Set plotting variables
    observed_data <- ghg_conc_out()$observed_data
    projected_data <- ghg_conc_out()$projected_data
    which_ghg <- input$ghg_choice
    unit <- ifelse(which_ghg == "Carbon Dioxide", "ppm", "ppb")

    # IPCC colors
    ssp126_col <- "#003466"
    ssp245_col <- "#f79420"
    ssp370_col <- "#e00101"
    ssp585_col <- "#990002"

    ipcc_colors <- c(ssp126_col, ssp245_col, ssp370_col, ssp585_col)

    # Reorder the levels of the scenario names
    projected_data$scenario_line <- factor(projected_data$scenario_line,
                                        levels = c(
                                          "Low emissions (SSP1-2.6)",
                                          "Intermediate emissions (SSP2-4.5)",
                                          "High emissions (SSP3-7.0)",
                                          "Very high emissions (SSP5-8.5)"
                                        ))
  # MAke the highchart plot
    create_ghg_plot(observed_data, projected_data, which_ghg, unit, ipcc_colors)


  })



  })
}

## To be copied in the UI
# mod_ghg_conc_plot_ui("ghg_conc_plot_1")

## To be copied in the server
# mod_ghg_conc_plot_server("ghg_conc_plot_1")
