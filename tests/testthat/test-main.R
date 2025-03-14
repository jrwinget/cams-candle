box::use(
  shiny[testServer],
  testthat[expect_true, test_that, expect_equal],
)
box::use(
  app/main[server],
)

test_that("main server has correct title", {
  testServer(server, {
    expect_equal(output$title$html, "Cam's Candle")
  })
})
