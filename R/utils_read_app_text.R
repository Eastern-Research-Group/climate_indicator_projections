#' read_app_text
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

read_app_text <- function(filename) {
  path <- file.path(config::get("app_text_path"), filename)
  return(HTML(paste(readLines(path, warn = FALSE), sep="\n", collapse="\n")))
}
