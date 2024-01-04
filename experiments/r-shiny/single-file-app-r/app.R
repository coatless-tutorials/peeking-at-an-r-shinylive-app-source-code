# app.R: Single-file app version based on a modification of the two-file app
# https://shiny.posit.co/r/articles/build/two-file/

server = function(input, output) {
  output$distPlot = renderPlot({
    hist(rnorm(input$obs), col = 'darkgray', border = 'white')
  })
}

ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of observations:", min = 10, max = 500, value = 100)
    ),
    mainPanel(
      h1("One-file app"),
      plotOutput("distPlot"))
  )
)

shinyApp(ui = ui, server = server)
