create_map_legend <- function(
    range_colors,
    block_width = 40,
    block_height = 20,
    margin_left = 10,
    margin_top = 30,
    tick_length = 8,
    font_family = "inherit",
    font_color = "#143051",
    font_size_label = 14,
    font_size_ticks = 12,
    label_text = "Rate of temperature change (°F per century):",
    label_y = 20,
    line_stroke_width = 2,
    tick_stroke_width = 1
) {
  edges <- numeric()
  for (nm in names(range_colors)) {
    # Remove parentheses and brackets at the start/end
    clean_str <- gsub("^\\(|\\)$|\\[|\\]", "", nm)

    # Split by comma
    parts <- strsplit(clean_str, ",")[[1]]

    # Trim spaces and convert to numeric safely
    nums <- suppressWarnings(as.numeric(trimws(parts)))

    # Append valid numeric parts only
    edges <- c(edges, nums[!is.na(nums)])
  }
  edges <- sort(unique(edges))

  n_colors <- length(range_colors)

  svg_width <- margin_left * 2 + block_width * n_colors + 50
  svg_height <- margin_top + block_height + tick_length + font_size_ticks + 20

  rects <- lapply(seq_along(range_colors), function(i) {
    tags$rect(
      x = margin_left + (i - 1) * block_width,
      y = margin_top,
      width = block_width,
      height = block_height,
      fill = range_colors[i]
    )
  })

  ticks <- lapply(seq_along(edges), function(i) {
    x_pos <- margin_left + (i - 1) * block_width
    tags$line(
      x1 = x_pos,
      y1 = margin_top + block_height,
      x2 = x_pos,
      y2 = margin_top + block_height + tick_length,
      stroke = font_color,
      `stroke-width` = tick_stroke_width
    )
  })

  labels <- lapply(seq_along(edges), function(i) {
    x_pos <- margin_left + (i - 1) * block_width
    tags$text(
      edges[i],
      x = x_pos,
      y = margin_top + block_height + tick_length + font_size_ticks + 2,
      fill = font_color,
      `font-family` = font_family,
      `font-weight` = "bold",
      `font-size` = paste0(font_size_ticks, "px"),
      `text-anchor` = "middle"
    )
  })

  tags$svg(
    width = svg_width,
    height = svg_height,
    xmlns = "http://www.w3.org/2000/svg",
    tags$style(HTML(sprintf("
      .label {
        font-family: %s;
        font-weight: bold;
        fill: %s;
        font-size: %dpx;
      }
    ", font_family, font_color, font_size_label))),

    tags$text(
      label_text,
      x = margin_left,
      y = label_y,
      class = "label"
    ),

    rects,

    tags$line(
      x1 = margin_left,
      y1 = margin_top + block_height,
      x2 = margin_left + block_width * n_colors,
      y2 = margin_top + block_height,
      stroke = font_color,
      `stroke-width` = line_stroke_width
    ),

    tagList(ticks),
    tagList(labels)
  )
}
