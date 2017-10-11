library(shinythemes)

shinyUI(
  navbarPage(title = "Airbnb New York City 2017", 
             id ="nav",
             theme = shinytheme("darkly"),
             
#### Overview ##########        
    tabPanel("Overview",
             br(),
             #img(src = "airbnb_newyork.jpg", height = 600, weight =700, align="center"),
             HTML('<center><img src="airbnb_newyork.jpg", height = 300, weight =1000 ></center>'),
             HTML("<h1 color=\"black\"><center>Dynamics of</center></h1>"),
             HTML("<h1 color=\"black\"><center>Neighborhoods, Crime & Subways</center></h1>"),
             HTML("<h1 color=\"black\"><center>for Airbnb NYC 2017</center></h1>")
             ),

#### Map ##########      
    tabPanel("NYC Map",
      div(class="outer",
          tags$head(includeCSS("styles.css")),
          
      leafletOutput("map", width="100%", height="100%"),
                          
      # Options: borough, Subway Distance
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                   top = 80, left = "auto", right = 20, bottom = "auto",
                   width = 320, height = "auto",
                                        
      h2("Airbnb in NYC"),
      
      radioButtons("radio", label = h2("Filter by"), inline = TRUE,
                    choices = list("Borough" = 1, "Subway Line" = 2), 
                    selected = 1),
      checkboxGroupInput(inputId = "select_boro", label = h4("Borough"),
                        choices = boro, selected = 'Queens'),
      selectInput("select_line", label = h2("Subway Lines"), 
                  choices = line, 
                  selected = "Crosstown"),
      sliderInput(inputId = "slider_distance", label = h4("Distance to Subway(m)"), min = 0, max = 2000, step=100,
                  value = c(0, 100)),
      sliderInput(inputId = "slider_price", label = h4("Price"), min = 1, max = 1500,step=10,
                  pre = "$", sep = ",", value = c(0, 80)) #animate=TRUE
      )
      )),

#### Price Profiles of Boroughs ##########               
    tabPanel("Price",    
             fluidRow(
                      column(5, plotOutput("graph_violin", width = "100%", height = "450px")),
                      column(5, plotOutput("graph_diverbar", width = "125%", height = "450px"))
             ),       
             fluidRow(
                      column(5,radioButtons("price_room", label = h3("Select Room Type"),inline = TRUE, 
                                   choices = list("Private room" = "Private room",
                                                  "Entire home/apt" = "Entire home/apt",
                                                  "Shared room" = "Shared room"), selected = "Private room")),
                      column(5,radioButtons("boro_bar", label = h3("Select Borough"), inline=TRUE,
                                   choices = boro, selected = "Queens"))
               )#fuildrow
             ),#tabpanel2
tabPanel("Subway Distance",    
         fluidRow(
           column(5, plotOutput("graph_density", width = "120%", height = "450px")),
           column(5,offset=1, 
                 checkboxGroupInput(inputId = "select_density", label = h2("Borough"),inline=TRUE,
                                       choices = boro, selected = boro[-5])),
           column(5,offset=1,
                      sliderInput(inputId = "slider_density", label = h2("Zoom (Distance(m))"), min = 1, max = 20000,
                      pre = "m", sep = ",", value = c(0, 10000)) #animate=TRUE)
          )
          )#fluidrow
         ),
# tabPanel("Crime Density",    
#          fluidRow(
#            column(6, plotOutput("graph_waffle", width = "100%", height = "400px"))
#          )#fluidrow
# ),
tabPanel("Combined Factors",    
         fluidRow(
           column(3),
           column(9,
                  br(),
                  column(6, htmlOutput("graph_bubble"))
           )#fuildrow
         )
)
))
