require(data.table)
require(rCharts)
require(reshape2)
require(shiny)
require(stringr)

# Read and prepare data...

data <- fread("02520078-eng.csv", showProgress=FALSE, verbose=FALSE, stringsAsFactors=TRUE)
setnames(data, "Geographical classification", "GeoClass")

# ... factorize columns with lots of repeated values ...

data$Ref_Date <- as.factor(data$Ref_Date)
data$GEO <- as.factor(data$GEO)
data$GeoClass <- as.factor(data$GeoClass)
data$VIOLATIONS <- as.factor(data$VIOLATIONS)
data$STA <- as.factor(data$STA)
data$Coordinate <- as.factor(data$Coordinate)

# ... format the locations to something more amenable to drop down selection.

newLevels <- sapply(levels(data$GEO), function(x) {
  
  strings <- strsplit(x, ",")[[1]]
  paste(str_trim(strings[1]),
        " (",
        str_trim(strings[[length(strings)]]),
        ")",
        sep = "")
  
})

names(newLevels) <- levels(data$GEO)
levels(data$GEO) <- newLevels
levels(data$GEO)[63] <- "*** Manitoba (all) ***"
levels(data$GEO)[64] <- "*** Manitoba (rural) ***"

shinyServer(function(input, output) {
  
  # Populate lists for dropdowns / checklists
  
  output$geographies <- renderUI({
    selectInput("geography",
                "Geography:",
                choices=sort(levels(data$GEO)),
                selected=63,
                multiple=FALSE)
  })
    
  output$violations <- renderUI({
    selectInput("violation",
                "Violation:",
                choices = sort(levels(data$VIOLATIONS)),
                multiple = TRUE)
  })
  
  output$statistic <- renderUI({
    selectInput("statistic",
                "Statistic:",
                choices=sort(levels(data$STA)),
                multiple=FALSE)
  })

  # Render a plot of the selected data
  
  output$chart <- renderChart({
    
    subset <- data[data$GEO == input$geography &
                     data$VIOLATIONS %in% input$violation &
                     data$STA == input$statistic, ]
    setnames(subset, 
             c("Ref_Date", "VIOLATIONS", "STA"), 
             c("Year", "Violation", "Statistic"))
    chart <- rPlot(Value ~ Year, color="Violation", data=subset, type="point")
    chart$layer(Value ~ Year, color="Violation", data=subset, type="line")
    chart$addParams(dom="chart")
    return(chart)

  })
    
})


