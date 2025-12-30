#' Generate and save static maps for each scenario (if not already saved)
#'
#' @param cln_data An `sf` object with a `scenario` column
#' @param module_id String, name of the module (used in file path)
#' @param create_static_map_fn Function to generate the map
#' @param width Width of image in pixels (default 1000)
#' @param height Height of image in pixels (default 600)
#' @param ... Additional arguments passed to `create_static_map_fn`
#'
#' @return Named list mapping scenario name → relative image path
generate_static_maps <- function(
    cln_data,
    module_id,
    create_static_map_fn = create_static_map,
    width = 1000,
    height = 600,
    ...
) {
  stopifnot("scenario" %in% colnames(cln_data))

  scenarios <- unique(cln_data$scenario)
  names(scenarios) <- scenarios

  # Define the output directory
  output_dir <- file.path(app_sys("app/www/images"), module_id)
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  # Define expected file paths
  img_paths <- vapply(scenarios, function(scenario) {
    file.path(output_dir, paste0(scenario, ".png"))
  }, FUN.VALUE = character(1))

  # Check if all images already exist
  if (all(file.exists(img_paths))) {
    message("[", module_id, "] All static maps already exist. Skipping generation.")
  } else {
    for (scenario in scenarios) {
      img_path <- file.path(output_dir, paste0(scenario, ".png"))
      if (!file.exists(img_path)) {
        message("[", module_id, "] Generating map for scenario: ", scenario)

        map <- create_static_map_fn(
          which_scenario = scenario,
          map_data = cln_data,
          ...
        )

        ggplot2::ggsave(
          filename = img_path,
          plot = map,
          width = width,
          height = height,
          units = "px",
          device = "png",
          dpi = 72
        )
      }
    }
  }

  # Return named list of relative paths (under /www)
  rel_paths <- vapply(scenarios, function(scenario) {
    file.path("www", "images", module_id, paste0(scenario, ".png"))
  }, FUN.VALUE = character(1))

  names(rel_paths) <- scenarios
  return(as.list(rel_paths))
}
