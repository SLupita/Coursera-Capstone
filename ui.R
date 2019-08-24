library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Predictive text output"),
  sidebarLayout(
      sidebarPanel(
            textInput("text", label = h3("Enter text"), value = ""),
            submitButton("Predict"),
            HTML('<script type="text/javascript">document.getElementById("text").focus();</script>')
            ),
  # hr(),
  # fluidRow(column(3, verbatimTextOutput("value"))),
    
    # Show a list of predicted words
    mainPanel(
        # tabsetPanel(
        #     
        #     tabPanel("Result", 
                     conditionalPanel(condition = "input.text != ''",
                                      verbatimTextOutput("text"),
                                      verbatimTextOutput("cleaned"), 
                                      verbatimTextOutput("msg"),
                                      selectInput("predicts","Word predictions:",choices=c(""))
                     )
            )                
            # tabPanel("Documentation", htmlOutput("help"),
                     # tags$div(id="help", 
                              # HTML("<iframe id='ifrHelp' src='help.html' height='550' width='650'></iframe>")
                     # )
            # )
        )
  #   )
  # )
))
