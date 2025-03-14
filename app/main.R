box::use(
  bslib[card, card_body, page_fluid],
  glue[glue],
  janitor[round_half_up],
  lubridate[ymd, year, leap_year],
  shiny[bootstrapPage, div, moduleServer, NS, actionButton, tags, observe, reactive],
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
      style = "
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 500px;
      ",
      div(
        id = "candle-container",
        style = "
          position: relative;
          width: 150px;
          height: 400px;
          display: flex;
          flex-direction: column;
          align-items: center;
        ",
        # Flame
        div(
          id = "flame",
          style = "
            position: absolute;
            top: 0; z-index: 2;
            transition: all 0.3s;
          ",
          div(
            class = "flame-inner",
            style = "
              width: 30px;
              height: 60px;
              background: linear-gradient(to bottom, #ffa500, #ff4500);
              border-radius: 50% 50% 20% 20%;
              box-shadow: 0 0 20px #ffa500, 0 0 40px #ff4500;
              animation: flicker 0.5s infinite alternate;
            "
          )
        ),
        # Candle
        div(
          id = "candle",
          style = "
            position: absolute;
            bottom: 0;
            width: 80px;
            background-color: #f8e4b7;
            border-radius: 10px 10px 0 0;
            transition: height 1s ease-in-out;
          ",
          div(
            id = "wick",
            style = "
              position: absolute;
              top: 0; left: 50%;
              transform: translateX(-50%);
              width: 4px; height: 15px;
              background-color: #333;
              z-index: 1;
            "
          )
        ),
        # Base with integrated relight button
        div(
          style = "
            position: absolute;
            bottom: 0;
            width: 100px;
            height: 30px;
            cursor: pointer;
          ",
          div(
            id = "candle-base",
            style = "
              width: 100%;
              height: 100%;
              background-color: #cd853f;
              border-radius: 5px;
              display: flex;
              align-items: center;
              justify-content: center;
            ",
            actionButton(
              "relight",
              "", 
              style = "
                background: none;
                border: none;
                width: 100%;
                height: 100%;
                position: absolute;
                top: 0;
                left: 0;
                opacity: 0;
                cursor: pointer;
              "
            )
          )
        )
      ),
      div(
        id = "candle-info",
        style = "margin-top: 20px; text-align: center;"
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    memorial_date <- reactive({
      if (!is.null(input$relight)) {
        relight_count <- input$relight
        return(ymd(glue("{year(Sys.Date())}-01-01")))
      } else {
        return(ymd(glue("{year(Sys.Date())}-01-01")))
      }
    })
    
    next_anniversary <- reactive({
      curr_date <- Sys.Date()
      curr_year <- year(curr_date)
      anniv_this_year <- ymd(glue("{curr_year}-01-01"))
      
      if (curr_date > anniv_this_year) {
        return(ymd(glue("{curr_year + 1}-01-01")))
      } else {
        return(anniv_this_year)
      }
    })
    
    observe({
      curr_date <- Sys.Date()
      days_in_year <- if(leap_year(year(curr_date))) 366 else 365
      start_date <- memorial_date()
      end_date <- next_anniversary()
      
      if (
        as.numeric(
          difftime(end_date, curr_date, units = "days")
        ) >= days_in_year - 1
      ) {
        percent_remaining <- 1
      } else {
        total_days <- as.numeric(difftime(end_date, start_date, units = "days"))
        days_remaining <- as.numeric(difftime(end_date, curr_date, units = "days"))
        percent_remaining <- max(0, days_remaining / total_days)
      }
      
      candle_height <- 350 * percent_remaining
      flame_position <- 350 - candle_height
      
      session$sendCustomMessage("updateCandle", list(
        candle_height = candle_height,
        flame_position = flame_position - 50,
        wick_height = 15,
        days_remaining = round_half_up(days_remaining)
      ))
    })
  })
}
