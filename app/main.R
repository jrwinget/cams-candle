box::use(
  bslib[page_fluid],
  glue[glue],
  lubridate[leap_year, year, ymd],
  shiny[actionButton, div, moduleServer, NS, observe, reactive],
)

box::use(
  app/logic/theme[cam_theme],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  page_fluid(
    theme = cam_theme,
    title = "Cam's Candle",
    div(
      class = "
        d-flex
        flex-column
        align-items-center
        justify-content-center
        memorial-container
      ",
      div(
        id = "candle-container",
        class = "
          d-flex
          flex-column
          align-items-center
          memorial-candle-container
        ",
        div(
          id = "flame",
          class = "memorial-flame",
          div(
            class = "flame-inner"
          )
        ),
        div(
          id = "candle",
          class = "memorial-candle",
          div(
            id = "wick",
            class = "memorial-wick"
          )
        ),
        div(
          class = "memorial-base-container",
          div(
            id = "candle-base",
            class = "memorial-candle-base",
            actionButton(
              ns("relight"),
              "",
              class = "relight-btn"
            )
          )
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    next_anniversary <- reactive({
      curr_date <- Sys.Date()
      curr_year <- year(curr_date)
      anniversary_this_year <- ymd(glue("{curr_year}-12-30"))

      if (curr_date > anniversary_this_year) {
        return(ymd(glue("{curr_year + 1}-12-30")))
      } else {
        return(anniversary_this_year)
      }
    })

    observe({
      curr_date <- Sys.Date()
      days_in_year <- if (leap_year(year(curr_date))) 366 else 365
      start_date <- ymd("2024-12-30")
      end_date <- next_anniversary()

      if (
        as.numeric(
          difftime(end_date, curr_date, units = "days")
        ) >= days_in_year - 1
      ) {
        percent_remaining <- 1
      } else {
        total_days <- as.numeric(
          difftime(end_date, start_date, units = "days")
        )

        days_remaining <- as.numeric(
          difftime(end_date, curr_date, units = "days")
        )

        percent_remaining <- max(0, days_remaining / total_days)
      }

      candle_height <- 350 * percent_remaining
      flame_position <- 350 - candle_height

      session$sendCustomMessage("updateCandle", list(
        candle_height = candle_height,
        flame_position = flame_position - 50,
        wick_height = 15
      ))
    })
  })
}
