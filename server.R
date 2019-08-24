#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
source("data.R")
source("functions.R")


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
 # output$value <- renderPrint({ input$text })
 
 # printOutput <- reactive({
 #     textOutput <- input$text
 # })
 
 # output$x <- renderText({
 #     paste("Input is:", input$text)
 # })
 
 observe({
     iniTime <- Sys.time()
 
     textCleansed <- clean(input$text)
     if(textCleansed != " ") 
     {
         output$cleaned <- renderText({
             paste0("Cleansed text: [",textCleansed,"]")
         })
         
         textCleansed <- gsub(" \\* "," ",textCleansed)    # cleaning swear words
         predictWords <- predict_model(textCleansed)
         updateSelectInput(session = session, inputId = "predicts", choices = predictWords)
         
         endTime <- Sys.time()
         output$msg <- renderText({
             paste(msg, "\n", sprintf("- Total time processing = %6.3f msecs",1000*(endTime-iniTime)))
         })
         
         gc()
     }  
    })

})
