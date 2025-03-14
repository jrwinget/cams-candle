box::use(
  bslib[bs_add_rules, bs_add_variables, bs_theme, font_collection, font_face],
  sass[sass_file],
)


#' @export
cam_theme <- bs_theme(
  bg = "#8c8c8c", 
  fg = "#f8f9fa", 
  primary = "#ffa500"
) |>
  bs_add_rules(sass_file("app/styles/main.scss"))