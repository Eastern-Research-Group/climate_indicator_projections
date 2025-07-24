#' arctic_sea_ice_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_arctic_sea_ice_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot")))

  )
}

#' arctic_sea_ice_plot Server Functions
#'
#' @noRd
mod_arctic_sea_ice_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


# Set year variables ------------------------------------------------------

    min_hind_yr <- 1950 # first year of hindcast data
    base_yr_start <- 1979
    base_yr_end <- 2014

# Read in data ------------------------------------------------------------

    asi_path <- "inst/extdata/arctic_sea_ice"
    asi_obs <- readr::read_csv(file.path(asi_path, "arctic-sea-ice_fig-1.csv"), skip = 6)
    asi_proj_av <- readr::read_csv(file.path(asi_path, "siextent.north.1e6miles.bayesian_model_average.september.1850-2100.csv"))
    asi_proj_mod <- read_ssps('siextent\\.north\\.1e6miles\\.ssp.*\\.september\\..*\\.csv', asi_path, "si_extent")

# Clean observed data -----------------------------------------------------

    asi_obs_sept <- asi_obs %>%
      janitor::clean_names() %>%
      dplyr::select(year, september) %>%
      dplyr::rename(si_extent = september) %>%
      dplyr::mutate(scenario = "observed") %>%
      dplyr::mutate(si_extent_smooth = si_extent)

# Clean projected average -------------------------------------------------

    # convert to tidy format
    asi_proj_av_cln <- asi_proj_av %>%
      tidyr::pivot_longer(cols = tidyr::starts_with("SSP"), names_to = "scenario", values_to = "si_extent") %>%
      dplyr::filter(year >= min_hind_yr)

    # Add hindcast category
    asi_hindcast <- asi_proj_av_cln %>%
      dplyr::filter(scenario == "ssp126") %>%
      dplyr::filter(year <= 2014) %>%
      dplyr::mutate(scenario = "hindcast")

    # calculate rolling average
    asi_proj_av_all <- rbind(asi_proj_av_cln, asi_hindcast) %>%
      dplyr::group_by(scenario) %>%
      dplyr::mutate(si_extent_smooth = zoo::rollmean(si_extent, k = 11, fill = NA)) %>%
      dplyr::mutate(si_extent_smooth = ifelse(!scenario %in% c("nclimgrid", "hindcast") & year < 2014, NA, si_extent_smooth)) %>%
      rbind(asi_obs_sept)

# Conduct bias correction and process model range -------------------------

    # Combine observed and projected data mean
    process_sea_ice <- function(obs_proj_av, ssp_data, start_year, end_year, min_hind_yr){

      # filter to overlap between observed and hindcast
      for_av <- obs_proj_av %>%
        dplyr::filter(year >= start_year & year <= end_year)

      # Observed average
      av_obs <- for_av %>%
        dplyr::filter(scenario == "observed") %>%
        dplyr::summarize(av = mean(si_extent))

      # hindcast average
      av_hind <- for_av %>%
        dplyr::filter(scenario == "hindcast") %>%
        dplyr::summarize(av = mean(si_extent))

      # Ratio of observed to hindcast
      bias_ratio <- av_obs$av/av_hind$av

      # Adjust the data
      arct_si_adj <- obs_proj_av %>%
        dplyr::mutate(si_extent_adj = ifelse(scenario == "observed", si_extent, si_extent_smooth*bias_ratio))

      # calculate model range
      si_mod_range <- calc_model_range(ssp_data, si_extent) %>%
        dplyr::mutate(p10 = ifelse(scenario != "hindcast" & year < 2014, NA, p10),
                      p90 = ifelse(scenario != "hindcast" & year < 2014, NA, p90)) %>%
        dplyr::mutate(p10_adj = p10*bias_ratio,
                      p90_adj = p90*bias_ratio)


      # Combine range and average data
      si_adj_all <- dplyr::full_join(arct_si_adj, si_mod_range, by = c("year", "scenario")) %>%
        dplyr::filter(year >= min_hind_yr) %>%
        rename_scenarios()

      return(si_adj_all)

    }


    asi_adj_all <- process_sea_ice(asi_proj_av_all, asi_proj_mod, base_yr_start, base_yr_end, min_hind_yr) %>%
      # rename for highchart
      dplyr::rename(smoothed_anom_adj = si_extent_adj)


# Create the plot ---------------------------------------------------------


    output$plot <- highcharter::renderHighchart({

      create_hc_plot(asi_adj_all,
                     "September Monthly Average Arctic Sea Ice Extent, 1950–2100",
                     "Sea Ice Extent (million square miles)",
                     " million square miles")

    })

  })
}

## To be copied in the UI
# mod_arctic_sea_ice_plot_ui("arctic_sea_ice_plot_1")

## To be copied in the server
# mod_arctic_sea_ice_plot_server("arctic_sea_ice_plot_1")
