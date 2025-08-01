## code to prepare `sc_plot_spring` dataset goes here

sc_plot_spring <- create_sc_seas(seas_num = 2,
                                 seas_name = "Spring",
                                 min_hind_yr = 1950)

usethis::use_data(sc_plot_spring, overwrite = TRUE)
