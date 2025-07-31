#' av_temp_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_av_temp_map_ui <- function(id) {
  ns <- NS(id)
  tagList(

  )
}

#' av_temp_map Server Functions
#'
#' @noRd
mod_av_temp_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


# Read in data ------------------------------------------------------------

    av_temp_path <- "inst/extdata/av_temp" # path to data
    temp_obs_raw <- readr::read_csv(file.path(av_temp_path, "temperature_fig-3.csv"), skip = 6) # Observed
    temp_model_av <- readr::read_csv(file.path(av_temp_path,'climdiv_AvgAnnualTemp.csv')) # Model average
    clim_divs <- sf::read_sf('inst/extdata/map_boundaries/climate_divisions.geojson') %>% clean_climdiv() # Climate divisions
    us_states <- sf::read_sf('inst/extdata/map_boundaries/us_states.geojson')

# Clean observed data -----------------------------------------------------

    temp_obs_cln <- temp_obs_raw %>%
      janitor::clean_names() %>%
      dplyr::rename(climdiv = climate_division) %>%
      dplyr::rename(rate_change_100 = temperature_change_1901_2000_denominator) %>%
      dplyr::select(climdiv, rate_change_100) %>%
      dplyr::mutate(scenario = "observed")

# Clean and process projections data --------------------------------------

    min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data

    temp_model_av_cln <- temp_model_av %>%
      dplyr::filter(scenario != "nclimgrid") %>%
      dplyr::filter(year >= min_yr) %>%
      dplyr::group_by(climdiv, scenario) %>%
      dplyr::mutate(rate_change = lm(av_temp ~ year)$coefficients[[2]]) %>%
      dplyr::mutate(rate_change_100 = rate_change*100) %>%
      dplyr::slice(1) %>%
      dplyr::select(climdiv, scenario, rate_change_100)

# Bind together observed and projected and prepare for mapping ------------

    all_temps <- rbind(temp_obs_cln, temp_model_av_cln) %>%
      dplyr::left_join(clim_divs, by = "climdiv") %>%
      sf::st_as_sf() %>%
      dplyr::filter(!is.na(rate_change_100)) %>%
      rename_scenarios(., TRUE) %>%
      dplyr::mutate(legend_buckets = cut(rate_change_100, breaks = seq(0, 16, by = 2))) %>%
      dplyr::mutate(legend_buckets_01 = cut(rate_change_100, breaks = seq(-0.1, 0.1, by = 0.1))) %>%
      dplyr::mutate(legend_buckets = ifelse(rate_change_100 <= 0.1, as.character(legend_buckets_01), as.character(legend_buckets)))

    all_temps$legend_buckets <- as.factor(all_temps$legend_buckets)
    all_temps$legend_buckets <- forcats::fct_relevel(all_temps$legend_buckets, c(
      "(-0.1,0]",
      "(0,0.1]" ,
      "(0,2]",
      "(2,4]",
      "(4,6]",
      "(6,8]",
      "(8,10]",
      "(10,12]",
      "(12,14]",
      "(14,16]"
    ))


# Make the map ------------------------------------------------------------

    temp_colors <- c(
      "(-0.1,0]" = "#C7C7C7",
      "(0,0.1]" = "#C7C7C7",
      "(0,2]" = "#F0D7D6",
      "(2,4]" =  "#F1C1BE",
      "(4,6]" = "#EF9F9C",
      "(6,8]" = "#ED7974",
      "(8,10]" = "#E8413E",
      "(10,12]" = "#BD2B2D",
      "(12,14]" = "#A02725",
      "(14,16]" = "#780707"
    )

    which_map <- all_temps %>%
      dplyr::filter(scenario == "ssp370")



    temp_map <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets), color = "#88807F") +
    #  ggplot2::geom_sf(data = which_map, ggplot2::aes(fill = legend_buckets, color = legend_buckets)) +
      ggplot2::scale_fill_manual(values = temp_colors, drop = FALSE) +
    #  ggplot2::scale_color_manual(values = temp_colors, drop = FALSE) +
     # ggplot2::facet_wrap(~scenario_title, ncol = 2) +
      ggplot2::geom_sf(data = us_states %>% dplyr::filter(!STUSPS%in%c("AK", "HI", "PR", "AS", "MP", "GU")), color = "black", fill = NA) +
      ggplot2::labs(
        title = "Rate of Temperature Change in the United States, 2024–2100",
        fill = "Rate of temperature change\n(°F per century)"
      ) +
      ggthemes::theme_map() +
      ggplot2::theme(
        text = ggplot2::element_text(size = 12),
        plot.title = ggplot2::element_text(size = 14),
     #   legend.key.width = ggplot2::unit(2, 'cm'),
        legend.position = "bottom"
      )
    temp_map

  })
}

## To be copied in the UI
# mod_av_temp_map_ui("av_temp_map_1")

## To be copied in the server
# mod_av_temp_map_server("av_temp_map_1")
