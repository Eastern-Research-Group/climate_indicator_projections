#' about UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$h2("About the Explorer"),
    tabsetPanel(
      tabPanel(
        "Tool Overview",
        read_app_text("about/tool.html")
      ),
      tabPanel(
        "General Technical Documentation",
        read_app_text("about/gen_tech_doc.html")
      )
    )

  )
}

#' about Server Functions
#'
#' @noRd
mod_about_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_about_ui("about_1")

## To be copied in the server
# mod_about_server("about_1")
