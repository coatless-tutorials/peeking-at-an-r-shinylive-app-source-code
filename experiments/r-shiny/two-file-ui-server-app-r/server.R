# server.R: required for a two-file shiny app
# Based on example: https://shiny.posit.co/r/articles/build/two-file/

server <- function(input, output) {
  output$distPlot = renderPlot({
    hist(rnorm(input$obs), col = 'darkgray', border = 'white')
  })
}
