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

    # Set years
    min_hind_yr <- 1950

    oa_path <- "inst/extdata/ocean_acidity"
    oa_obs <- readr::read_csv(file.path(oa_path, "ocean-acidity_fig-1.csv"), skip = 6)
    oa_proj_av <- readr::read_csv(file.path(oa_path, "ph_bayesian_ave.csv"))
    oa_proj_mod <- readr::read_csv(file.path(oa_path, "ph_monthly_by_station_and_model.csv"))


# Clean Projected Average Data --------------------------------------------

    # tidy up the data
    oa_proj_av_cln <- oa_proj_av %>%
      rename_stations() %>%
      dplyr::filter(year >= min_hind_yr) %>%
      # Create date column
      dplyr::mutate(date = lubridate::ymd(paste0(year, "-", month, "-01"))) %>%
      # average value betweeen the two Bermuda stations
      dplyr::group_by(station_name, scenario, date) %>%
      dplyr::mutate(ph = mean(ph)) %>%
      dplyr::slice(1) %>%
      dplyr::select(station_name, scenario, date, ph)

    # Add 2009-2014 to the ssps so there isn't a gap when we smooth
    oa_hind_years <- oa_proj_av_cln %>%
      dplyr::group_by(station_name) %>%
      add_hind_data(., c(2009:2014)) %>%
      dplyr::ungroup()

    # Combine with hindcast data and add smoothing
    oa_proj_av_smth <- rbind(oa_proj_av_cln, oa_hind_years) %>%
      dplyr::select(station_name, scenario, date, ph) %>%
      dplyr::group_by(station_name, scenario) %>%
      dplyr::arrange(date, .by_group = TRUE) %>%
      dplyr::mutate(ph = zoo::rollmean(ph, k = 132, fill = NA)) %>%
      dplyr::select(station_name, scenario, date, ph)


# Clean Projected All Model Data ------------------------------------------

    oa_proj_mod_cln <- oa_proj_mod %>%
      dplyr::rename(station = station_name,
             ph = data) %>%
      rename_stations() %>%
      dplyr::filter(year >= min_hind_yr) %>%
      dplyr::mutate(date = lubridate::ymd(paste0(year, "-", month, "-01")))


    # add 2014 to the ssps so there's no gap
    oa_hind_14 <- oa_proj_mod_cln %>%
      dplyr::ungroup() %>%
      dplyr::group_by(model, station_name) %>%
      add_hind_data(., c(2014)) %>%
      dplyr::ungroup() %>%
      dplyr::filter(date >= "2014-12-01")

    oa_proj_mod_range <- rbind(oa_proj_mod_cln, oa_hind_14) %>%
      dplyr::select(station_name, model, scenario, date, ph) %>%
      dplyr::group_by(station_name, scenario, date) %>%
      dplyr::summarize(p10 = quantile(ph, probs=c(0.1), na.rm=T),
                       p90 = quantile(ph, probs=c(0.9), na.rm=T))


# Clean the Observed Data and Combine with Projected -------------------------------------------------

    # reactive part
    oa_proj_all_out <- reactive({

      filter_obs <- clean_oa_obs(input$station_choice, oa_obs)

      oa_proj_mod_range_filt <- oa_proj_mod_range %>% dplyr::filter(station_name==input$station_choice)

      oa_proj_all <- oa_proj_av_smth %>%
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
