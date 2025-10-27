## code to prepare `av_temp_obs_hind_map` dataset goes here

# Set the years -----------------------------------------------------------
min_yr <- 2024 # first year to start the rate of change on - the year after the end of the observed data
base_yr_start <- 1951
base_yr_end <- 2000

# Read in the data --------------------------------------------------------
av_obs_raw <- readr::read_csv(file.path(config::get("av_temp_path"), "temperature_fig-3_val_raw.csv")) # Observed
av_temp_map_mod_raw <- readr::read_csv(file.path(config::get("av_temp_path"), 'climdiv_AvgAnnualTemp.csv'))

# Clean the observed data -------------------------------------------------
av_temp_obs <- av_obs_raw %>%
  janitor::clean_names() %>%
  dplyr::rename(climdiv = location_id) %>%
  dplyr::mutate(
    year = substr(date, 1, 4),
    month = substr(date, 5, 6)
  ) %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::group_by(climdiv, year) %>%
  dplyr::summarize(
    av_temp = mean(value)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(year >= 1950 & year <= 2014) %>%
  dplyr::mutate(scenario = "observed")

# Calculate the average value for the base period
av_val <- av_temp_obs %>%
  dplyr::filter(year >= base_yr_start) %>%
  dplyr::filter(year <= base_yr_end) %>%
  dplyr::group_by(climdiv) %>%
  dplyr::summarize(mean_val = mean(av_temp)) %>%
  dplyr::ungroup()

# Calculate the anomaly
av_temp_map_obs <- dplyr::left_join(av_temp_obs, av_val, by = "climdiv") %>%
  dplyr::mutate(anomaly = av_temp - mean_val) %>%
  dplyr::ungroup() %>%
  # Calculate the rate of change of the anomalies
  dplyr::group_by(climdiv) %>%
  dplyr::mutate(rate_change = lm(anomaly ~ year)$coefficients[[2]]) %>%
  dplyr::slice(1) %>%
  dplyr::select(climdiv, scenario, rate_change) %>%
  dplyr::ungroup()

# Clean the model average -------------------------------------------------
av_temp_map_mod <- av_temp_map_mod_raw %>%
  # Calculate the anomaly for each climate division
  calc_anom(.,
            var_name = av_temp,
            base_start = base_yr_start,
            base_end = base_yr_end,
            window_size = 11,
            nclimgrid_smooth = TRUE,
            model_range = FALSE,
            for_maps = TRUE) %>%
  dplyr::ungroup() %>%
  dplyr::select(-smoothed_anom) %>%
  dplyr::filter(scenario %in% c("ssp126")) %>%
  dplyr::filter(year <= 2014) %>%
  # Calculate the rate of change of the anomalies
  dplyr::group_by(climdiv) %>%
  dplyr::mutate(rate_change = lm(anomaly ~ year)$coefficients[[2]]) %>%
  dplyr::slice(1) %>%
  dplyr::select(climdiv, scenario, rate_change) %>%
  dplyr::mutate(climdiv = as.character(climdiv)) %>%
  plyr::mutate(scenario = "hindcast")

# Combine and process -----------------------------------------------------
av_temp_map_cln_data <- rbind(av_temp_map_obs, av_temp_map_mod) %>%
  dplyr::mutate(climdiv = as.integer(climdiv)) %>%
  dplyr::left_join(clim_div_cln, by = "climdiv") %>%
  sf::st_as_sf() %>%
  rename_scenarios(., TRUE) %>%
  dplyr::mutate(rate_change_100 = rate_change*100) %>%
  dplyr::mutate(legend_buckets = cut(rate_change_100, breaks = seq(0, 5, by = 1))) %>%
  dplyr::mutate(legend_buckets_01 = cut(rate_change_100, breaks = c(-0.1, 0.1, 1))) %>%
  dplyr::mutate(legend_buckets = ifelse(rate_change_100 <= 1, as.character(legend_buckets_01), as.character(legend_buckets)))

test <- av_temp_map_cln_data %>%
  tidyr::pivot_wider(names_from = scenario, values_from = rate_change) %>%
  dplyr::mutate(diff = (observed - hindcast)*100)

av_temp_map_cln_data$legend_buckets <- as.factor(av_temp_map_cln_data$legend_buckets)
av_temp_map_cln_data$legend_buckets <- forcats::fct_relevel(
  av_temp_map_cln_data$legend_buckets, c(
    "(0.1,1]",
    "(1,2]",
    "(2,3]",
    "(3,4]",
    "(4,5]"
  ))

# Create the map -----------------------------------------------------
obs_hind_map_colors <- c(
  "(0.1,1]"= "#C7C7C7",
  "(1,2]"= "#F0D7D6",
  "(2,3]"= "#EF9F9C",
  "(3,4]"= "#E8413E",
  "(4,5]" = "#A02725"
)

obs_hind_map <- ggplot2::ggplot() +
  ggplot2::geom_sf(data = av_temp_map_cln_data,
                   ggplot2::aes(fill = legend_buckets), color = "#88807F", show.legend = TRUE) +
  ggplot2::scale_fill_manual(
    values = obs_hind_map_colors) +
  ggplot2::geom_sf(data = conus_cln, fill = NA, color = "white") +
  ggplot2::facet_wrap(~scenario_title) +
  ggthemes::theme_map() +
  ggplot2::theme(
    text = ggplot2::element_text(size = 12),
    plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
    legend.position = "bottom",
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = 14, face = "bold")
  )
obs_hind_map


obs_hind_map <- ggplot2::ggplot() +
  ggplot2::geom_sf(data = av_temp_map_cln_data,
                   ggplot2::aes(fill = rate_change_100), color = "#88807F", show.legend = TRUE) +
  ggplot2::geom_sf(data = conus_cln, fill = NA, color = "white") +
  viridis::scale_fill_viridis(option="magma") +
  ggplot2::labs(
    title = "Rate of Temperature Change 1950–2014\nBaseline period: 1951–2000",
    fill = "Rate of temperature\nchange(°F per century)"
  ) +
  ggplot2::facet_wrap(~scenario_title) +
  ggthemes::theme_map() +
  ggplot2::theme(
    text = ggplot2::element_text(size = 12),
    plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
    legend.position = "bottom",
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = 14, face = "bold")
  )
obs_hind_map

usethis::use_data(av_temp_obs_hind_map, overwrite = TRUE)
