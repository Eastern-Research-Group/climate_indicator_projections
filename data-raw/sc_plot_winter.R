## code to prepare `sc_plot_winter` dataset goes here

sc_plot_winter <- create_sc_seas(seas_num = 1,
                                 seas_name = "Winter",
                                 min_hind_yr = 1950)


usethis::use_data(sc_plot_winter, overwrite = TRUE)
