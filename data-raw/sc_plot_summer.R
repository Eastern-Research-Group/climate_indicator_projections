## code to prepare `sc_plot_summer` dataset goes here

sc_plot_summer <- create_sc_seas(seas_num = 3,
                                 seas_name = "Summer",
                                 min_hind_yr = 1950)


usethis::use_data(sc_plot_summer, overwrite = TRUE)
