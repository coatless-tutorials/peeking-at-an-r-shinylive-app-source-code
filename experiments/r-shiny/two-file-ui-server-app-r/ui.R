# server.R: required for a two-file shiny app
# Based on example: https://shiny.posit.co/r/articles/build/two-file/

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of observations:", min = 10, max = 500, value = 100)
    ),
    mainPanel(
      h1("Two-file app"),
      plotOutput("distPlot")
    )
  )
)