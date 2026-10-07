# Future tests should source R modules or use the project test harness.
testthat::test_that("episode spine has the documented column names and types", {
  # TODO: Check episode_id, title, season, episode_number, series_order,
  # air_date, runtime_minutes, rating, vote_count, and rating provenance.
  testthat::skip("Not implemented yet")
})

testthat::test_that("episode spine has nonmissing unique episode identifiers", {
  # TODO: Use synthetic valid and duplicate-ID fixtures; check canonical coverage.
  testthat::skip("Not implemented yet")
})
