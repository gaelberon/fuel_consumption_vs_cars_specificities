library(shiny)
library(shinydashboard)
library(DT)

### Header
header <- dashboardHeader(title = "Fuel consumption Vs cars specificities",
                          titleWidth = 400)

### SideBar
sidebar <- dashboardSidebar(
        width = 230,
        sidebarMenu(
                menuItem("Graphs", tabName = "graphs"),
                menuItem("Raw Data", tabName = "data"),
                menuItem("Help", tabName = "help"),
                menuItem("Credits", tabName = "credits")
        ),
        # Chose your x_var
        box(width = 12,
            title = "Parameters",
            solidHeader = TRUE,
            status = "primary",
            
            radioButtons(inputId = "x_var",
                         label = HTML("<FONT color='#3c8dbc'>Select x variable:</FONT>"),
                         choices = c("Nb of cylinders" = "nb_cylinders",
                                     "Displacement (cu.in.)" = "displacement",
                                     "Horsepower" = "horsepower",
                                     "Rear Axle Ratio" = "rear_axle_ratio",
                                     "Weight (x1000 lbs)" = "weight",
                                     "Quarter mile (in sec)" = "quarter_mile_sec",
                                     "Engine Type (V/S)" = "vs_engine_type",
                                     "Transmission Type" = "transmission",
                                     "Nb of gears" = "nb_gears",
                                     "Nb of carburators" = "nb_carburators"),
                         selected = "weight"))
)

### Body
body <- dashboardBody(
        tags$head(tags$style(HTML('.skin-blue .main-header .logo {
                                   #font-family: "Georgia", Times, "Times New Roman", serif;
                                   #font-weight: bold;
                                   font-size: 20px;
                                   background-color: #3c8dbc;}
                                   .skin-blue .main-header .logo:hover {
                                   background-color: #3c8dbc;}
                                   .radio label:first-child {
                                   #font-weight: bold;
                                   #font-size: 20px;
                                   color: #3c8dbc;}
                                   #.box.box-solid.box-primary>.box-header {
                                   #color:#fff;
                                   #background:#666666}
                                   #.box.box-solid.box-primary{
                                   #border-bottom-color:#666666;
                                   #border-left-color:#666666;
                                   #border-right-color:#666666;
                                   #border-top-color:#666666;}
                                  '))),
        ### Tabitems
        tabItems(
                
                ### TAB 1 = dashboard
                tabItem(tabName = "graphs",
                        
                        fluidRow(
                                
                                # Output slope
                                box(width = 3,
                                    height = 80,
                                    solidHeader = FALSE,
                                    
                                    h4("Slope:"),
                                    textOutput("slopeOut")),
                                
                                # Output intercept
                                box(width = 3,
                                    height = 80,
                                    solidHeader = FALSE,
                                    
                                    h4("Intercept:"),
                                    textOutput("intOut"))),
                        fluidRow(
                                box(width = 5,
                                    height = 500,
                                    title = "MPG Vs X variable and linear regression",
                                    solidHeader = TRUE,
                                    status = "primary",
                                    plotOutput(outputId = "reg")),
                                
                                box(width = 7,
                                    height = 500,
                                    title = "Sums of Squares Graphs",
                                    solidHeader = TRUE,
                                    status = "primary",
                                    tabsetPanel(type = "tabs",
                                                tabPanel("Total",
                                                         plotOutput("total")),
                                                tabPanel("Regression",
                                                         plotOutput("regression")),
                                                tabPanel("Error",
                                                         plotOutput("error")),
                                                tabPanel("Variance Partition",
                                                         plotOutput(("variance")))))),
                        fluidRow(
                                
                                box(width = 5,
                                    title = "Coefficients",
                                    solidHeader = FALSE,
                                    #status = "warning",
                                    tableOutput(outputId = "coefficients")),
                                
                                box(width = 7,
                                    title = "Anova Table",
                                    solidHeader = FALSE,
                                    #status = "warning",
                                    tableOutput(outputId = "anova")))),
                
                # TAB 2 = raw data
                tabItem(tabName = "data",
                        
                        fluidRow(
                                box(width = 5,
                                    solidHeader = TRUE,
                                    status = "primary",
                                    title = "Raw Data",
                                    DT::dataTableOutput(outputId = "data")),
                                box(width = 7,
                                    solidHeader = TRUE,
                                    status = "primary",
                                    title = "Data distribution",
                                    plotOutput(outputId = "histogram"))
                                
                        )
                ),
                
                # TAB 3 = help
                tabItem(tabName = "help",
                        
                        fluidRow(
                                box(width = 12,
                                    solidHeader = FALSE,
                                    #status = "primary",
                                    title = "Help",
                                    shiny::includeMarkdown("README.Rmd"))
                        )
                ),
                
                # TAB 4 = credits
                tabItem(tabName = "credits",
                        
                        fluidRow(
                                box(width = 12,
                                    solidHeader = FALSE,
                                    #status = "primary",
                                    title = "Credits",
                                    h3("Motor Trend Dataset"),
                                    HTML("In 1974, Motor Trend US magazine published the data of 11 aspects of automobile design and performance for a collection of 32 automobiles (1973–74 models)."),
                                    HTML("See the documentation for 'mtcars' dataset <a href='https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html'>here</a>"),
                                    h3("'SSregression' - Exploring Sums of Squares in linear regression"),
                                    HTML("Original idea of this Shiny Application is from 'Gustavo Paterno'<br>See the link on <a href='https://github.com/paternogbc/SSregression'>github</a>"))
                        )
                )
        )
)

ui <- dashboardPage(header, sidebar, body)