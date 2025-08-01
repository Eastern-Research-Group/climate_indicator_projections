## code to prepare `sc_plot_fall` dataset goes here

sc_plot_fall <- create_sc_seas(seas_num = 4,
                                 seas_name = "Fall",
                                 min_hind_yr = 1950)

usethis::use_data(sc_plot_fall, overwrite = TRUE)
