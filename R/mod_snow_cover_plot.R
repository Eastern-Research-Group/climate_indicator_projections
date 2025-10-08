#' snow_cover_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_snow_cover_plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    selectInput(ns("season_choice"),
                label = "Choose a Season",
                choices = c("Annual",
                            "Winter",
                            "Spring",
                            "Summer",
                            "Fall")),

    render_timeseries_page(
      title="",
      timeseries=shinycssloaders::withSpinner(highcharter::highchartOutput(ns("plot"))),
      data_source=read_app_text("snow_cover/plot_caption_data_source.html"),
      caption=read_app_text("snow_cover/plot_caption_text.html")
    )

  )
}

#' snow_cover_plot Server Functions
#'
#' @noRd
mod_snow_cover_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns


# Reactive ---------------------------

    sc_out <- reactive({

      if (input$season_choice == "Fall") {

        sc_all <- sc_plot_fall

      } else if (input$season_choice == "Winter"){

        sc_all <- sc_plot_winter

      } else if (input$season_choice == "Spring"){

        sc_all <-  sc_plot_spring

      } else if (input$season_choice == "Summer"){

         sc_all <-  sc_plot_summer

      } else if (input$season_choice == "Annual"){

        sc_all <-  sc_plot_annual

    }

      return(sc_all)

    })

# Create the plot ---------------------------------------------------------

    output$plot <- highcharter::renderHighchart({

      create_hc_plot(sc_out(),
                     sprintf("%s Snow-Covered Area in North America, 1950–2100", input$season_choice),
                     "Snow-covered area<br>(million square miles)",
                     " million square miles")

    })
    outputOptions(output, "plot", suspendWhenHidden = TRUE)

  })
}

## To be copied in the UI
# mod_snow_cover_plot_ui("snow_cover_plot_1")

## To be copied in the server
# mod_snow_cover_plot_server("snow_cover_plot_1")
