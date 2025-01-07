library(shiny)
library(tidyverse)
library(shinydashboard)
library(rvest)

getdata <- function(x){
  myurl <- read_html("https://www.espn.com/mens-college-basketball/schedule/_/date/20250106") # read our webpage as html
  myurl <- html_table(myurl)  # convert to an html table for ease of use
  myurl
  
  to.parse <- myurl[[1]]  # pull the first item in the list
  df <- as.data.frame(to.parse)
  colnames(df)[1] <- "Away"
  colnames(df)[2] <- "Home"
  mydata <- df[-c(3:5)]
  mydata
  #df <- df %>%
  # separate(data = myurl,
  #           col = `ODDS BY`,
  #           into = c("Line", "OU"),
  #           sep = "O/U:",
  #           fill = "right") %>%
  #  mutate(
  #    Line = gsub("Line:", "", Line),  # Remove "Line:" text
  #    Line = trimws(Line),             # Remove extra whitespace
  #    OU = trimws(OU)                  # Remove extra whitespace from O/U
  #  )
  #df$`ODDS BY` <- gsub("%","",df$`ODDS BY`) # cleanup - remove non-characters
  #return(df)
}

getdata()

