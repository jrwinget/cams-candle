box::use(
  shiny[testServer],
  testthat[expect_equal, test_that],
)
box::use(
  app/main[server],
)

test_that("main server has correct title", {
  testServer(server, {
    expect_equal(output$title$html, "Cam's Candle")
  })
})
