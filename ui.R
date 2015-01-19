require(rCharts)
require(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Manitoba Crime Data Explorer"),
  
  # Sidebar with inputs for model predictors
  sidebarLayout(
    sidebarPanel(
      htmlOutput("geographies"),
      htmlOutput("violations"),
      htmlOutput("statistic")
    ),
    
    mainPanel(
      showOutput("chart", "polycharts")
    )
  )
))

