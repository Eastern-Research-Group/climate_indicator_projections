test_that("calc_diff_av_works", {

  test_df <- data.frame(scenario =
                          c("a", "a", "a", "b", "b", "b"),
                        year = c(2020, 2021, 2023, 2020, 2021, 2023),
                        val = c(1, 2, 3, 4, 5, 6)
                        )

  expect_equal(
    calc_diff_avs(test_df, "b", "a", val, 2020, 2023),
    3
  )

})

test_that("calc_diff_av_year_filter", {

  test_df <- data.frame(scenario =
                          c("a", "a", "a", "b", "b", "b"),
                        year = c(2020, 2021, 2023, 2020, 2021, 2023),
                        val = c(2, 2, 4, 3, 3, 10)
  )

  expect_equal(
    calc_diff_avs(test_df, "a", "b", val, 2020, 2021),
    -1
  )

})

test_that("calc_diff_av_year_equal", {

  test_df <- data.frame(scenario =
                          c("a", "a", "a", "b", "b", "b"),
                        year = c(2020, 2021, 2023, 2020, 2021, 2023),
                        val = c(2, 6, 4, 4, 7, 10)
  )

  expect_equal(
    calc_diff_avs(test_df, "a", "b", val, 2020, 2020),
    -2
  )

})
