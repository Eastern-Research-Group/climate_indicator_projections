render_tab_option <- function(
    id,
    name,
    active=FALSE
) {
  return(
    tags$li(
      tags$a(
        name,
        href="#",
        id=id,
        class=ifelse(active, "active", "")
      )
    )
  )
}

render_indicator_page <- function(
    title,
    maps=NULL,
    timeseries=NULL,
    summary=NULL,
    tech_doc=NULL
) {

  if (is.null(maps) & is.null(timeseries)) {
    stop("Must provide at least one of Maps or Timeseries")
  }

  panels <- list()

  idx <- 1

  if (!is.null(maps)) {
    panels[[idx]] <- tabPanel("Maps", maps)
    idx <- idx + 1
  }

  if (!is.null(timeseries)) {
    panels[[idx]] <-
      tabPanel("Timeseries Graphs", timeseries)
    idx <- idx + 1
  }

  if (!is.null(summary)) {
    panels[[idx]] <-
      tabPanel("Summary", summary)
    idx <- idx + 1
  }

  if (!is.null(tech_doc)) {
    panels[[idx]] <-
      tabPanel("Technical Documentation", tech_doc)
    idx <- idx + 1
  }

  return(
    tagList(
      tags$h2(title),
      do.call(tabsetPanel, panels)
    )

  )

}


# render_indicator_page <- function(
#     prefix,
#     title,
#     maps=NULL,
#     timeseries=NULL
#   ) {
#
#   if (is.null(maps) & is.null(timeseries)) {
#     stop("Must provide at least one of Maps or Timeseries")
#   }
#
#   navlist <- tagList()
#
#
#   if (!is.null(maps)) {
#     navlist <- tagAppendChild(navlist,
#       render_tab_option(
#         id=paste0(prefix, "-tab-maps"),
#         name="Maps",
#         active=TRUE
#       )
#     )
#   }
#
#   if (!is.null(timeseries)) {
#     navlist <- tagAppendChild(navlist,
#       render_tab_option(
#         id=paste0(prefix, "-tab-timeseries"),
#         name="Timeseries Graphs",
#         active=is.null(timeseries)
#       )
#     )
#   }
#
#   return(
#     htmlTemplate(
#       app_sys("app/www/indicator_mod.html"),
#       title=title,
#       navlist=tagList(navlist),
#       prefix=prefix,
#       maps=ifelse(is.null(maps), "", maps),
#       timeseries=ifelse(is.null(timeseries), "", timeseries),
#     )
#   )
#
# }

render_map_page <- function(
  map,
  data_source="XXXX",
  caption="Lorem ipsum dolor sit amet..."
) {
  return(
    htmlTemplate(
      app_sys("app/www/maps_mod.html"),
      map=map,
      data_source=data_source,
      caption=caption
    )
  )
}

render_timeseries_page <- function(
    title,
    timeseries,
    data_source="XXXX",
    caption="Lorem ipsum dolor sit amet..."
) {
  return(
    htmlTemplate(
      app_sys("app/www/timeseries_mod.html"),
      title=title,
      timeseries=timeseries,
      data_source=data_source,
      caption=caption
    )
  )
}

render_summary <- function(
    intro="Some text",
    background="Some background",
    key_points="Some key points",
    sources_and_methods="Some sources"
) {
  return(
    htmlTemplate(
      app_sys("app/www/summary_mod.html"),
      intro=intro,
      background=background,
      key_points=key_points,
      sources_and_methods=sources_and_methods
    )
  )
}

render_tech_doc <- function(
    identification="Some text goes here...",
    data_sources="Some text goes here...",
    methodology="Some text goes here...",
    analysis="Some text goes here...",
    references="Some text goes here..."
) {
  return(
    htmlTemplate(
      app_sys("app/www/techdoc_mod.html"),
      identification=identification,
      data_sources=data_sources,
      methodology=methodology,
      analysis=analysis,
      references=references
    )
  )
}

