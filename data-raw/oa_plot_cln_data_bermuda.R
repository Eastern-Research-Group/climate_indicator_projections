## code to prepare `oa_plot_cln_data_bermuda` dataset goes here

oa_plot_cln_data_bermuda <- process_oa_station(

  which_station = "Bermuda",
  obs_data = oa_plot_obs,
  mod_av = oa_plot_mod_av,
  mod_all = oa_plot_mod_all

)

usethis::use_data(oa_plot_cln_data_bermuda, overwrite = TRUE)

