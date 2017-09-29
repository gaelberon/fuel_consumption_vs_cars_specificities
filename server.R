library(shiny)
library(ggplot2)
library(shinydashboard)
library(car)
library(DT)
library(ggExtra)

get_scale_dimensions <- function(x_var) {
        
        breaks <- NULL
        labels <- NULL
        limits <- NULL
        trans <- NULL
        
        if (x_var == 'nb_cylinders') {
                breaks <- c(4, 6, 8)
                labels <- c(4, 6, 8)
                limits <- c(3.8, 8.2)
        } else if (x_var == 'displacement') {
                breaks <- c(100, 200, 300, 400, 500)
                labels <- c(100, 200, 300, 400, 500)
                limits <- c(50, 500)
        } else if (x_var == 'horsepower') {
                breaks <- c(50, 100, 150, 200, 250, 300, 350)
                labels <- c(50, 100, 150, 200, 250, 300, 350)
                limits <- c(50, 350)
        } else if (x_var == 'rear_axle_ratio') {
                breaks <- c(2.5, 3, 3.5, 4, 4.5, 5)
                labels <- c(2.5, 3, 3.5, 4, 4.5, 5)
                limits <- c(2.5, 5)
        } else if (x_var == 'weight') {
                breaks <- c(2, 3, 4, 5)
                labels <- c(2, 3, 4, 5)
                limits <- c(1.3, 5.7)
        } else if (x_var == 'quarter_mile_sec') {
                breaks <- c(14, 16, 18, 20, 22, 24)
                labels <- c(14, 16, 18, 20, 22, 24)
                limits <- c(13, 24)
        } else if (x_var == 'vs_engine_type') {
                breaks <- c(0, 1)
                labels <- c("V-engine", "Straight engine")
                limits <- c(-.2, 1.2)
        } else if (x_var == 'transmission') {
                breaks <- c(0, 1)
                labels <- c("Automatic", "Manual")
                limits <- c(-.2, 1.2)
        } else if (x_var == 'nb_gears') {
                breaks <- c(3, 4, 5)
                labels <- c(3, 4, 5)
                limits <- c(2.8, 5.2)
        } else if (x_var == 'nb_carburators') {
                breaks <- c(2, 4, 6, 8)
                labels <- c(2, 4, 6, 8)
                limits <- c(1.5, 8.5)
        }
        scale_dimensions <- list(name = x_var,
                                 breaks = breaks,
                                 labels = labels,
                                 limits = limits,
                                 trans = trans)
        
        return(scale_dimensions)
}

server <- function(input, output) {
        # Load dataset 'mtcars'
        data(mtcars)
        # Rename the columns names to more relevant identifiers
        names(mtcars) <- c('mpg', 'nb_cylinders', 'displacement', 'horsepower',
                           'rear_axle_ratio', 'weight', 'quarter_mile_sec',
                           'vs_engine_type', 'transmission', 'nb_gears',
                           'nb_carburators')
        
        # Refreshing data
        # Return the selected x variable
        X_var <- reactive({
                # get the x_var selected in the radiobuttons
                X_var <- input$x_var
        })
        
        # Refreshing data
        Rawdata <- reactive({
                # get the x_var selected in the radiobuttons
                x_var <- input$x_var
                
                # calculate the linear regression model
                mod <- lm(mpg ~ mtcars[, x_var], data = mtcars)
                mpg_predict <- predict(mod)
                Rawdata <- data.frame(mpg = mtcars$mpg,
                                      x = mtcars[, x_var],
                                      predict = mpg_predict)
        })
        
        # Refreshing data
        SSdata <- reactive({
                dat <- Rawdata()
                mod <- lm(mpg ~ x, dat)
                mpg_predict <- predict(mod)
                dat$predict <- mpg_predict
                SST <- sum((dat$mpg - mean(dat$mpg))^2)
                SSE <- round(sum((dat$mpg - mpg_predict)^2), digits = 5)
                SSA <- SST - SSE
                
                SSQ <- data.frame(SS = c("Total","Regression","Error"),
                                  value = as.numeric(c(SST, SSA, SSE)/SST)*100)
                SSQ$SS <- factor(SSQ$SS, as.character(SSQ$SS))
                SSdata <- data.frame(SS = factor(SSQ$SS, as.character(SSQ$SS)),
                                     value = as.numeric(c(SST, SSA, SSE)/SST)*100)
        })
        
        # Output slope
        output$slopeOut <- renderText({
                dat <- Rawdata()
                mod <- lm(mpg ~ x, dat)
                if(is.null(mod)) {
                        "No model found"
                } else {
                        round(mod[[1]][2],2)
                }
        })
        
        # Output intercept
        output$intOut <- renderText({
                dat <- Rawdata()
                mod <- lm(mpg ~ x, dat)
                if(is.null(mod)) {
                        "No model found"
                } else {
                        round(mod[[1]][1],2)
                }
                
        })
        
        ### Output graph "total"
        output$total <- renderPlot({
                x_var <- X_var()
                scale_dimensions <- get_scale_dimensions(x_var)
                cols <- c("#619CFF", "#00BA38", "#F8766D")
                ggplot(Rawdata(), aes(x = x, y = mpg)) +
                        geom_point(size = 3) +
                        geom_segment(xend = Rawdata()[,2],
                                     yend = mean(Rawdata()[,1]),
                                     colour = "#619CFF") +
                        geom_hline(yintercept = mean(Rawdata()[,1])) +
                        theme(axis.title = element_text(size = 20),
                              axis.text  = element_text(size = 18),
                              panel.background=element_rect(fill = "white",
                                                            colour = "black")) +
                        ggtitle("SS total") +
                        scale_x_continuous(name = scale_dimensions$name,
                                           breaks = scale_dimensions$breaks,
                                           labels = scale_dimensions$labels,
                                           limits = scale_dimensions$limits)
        })
        
        ### Output graph "regression"
        output$regression <- renderPlot({
                x_var <- X_var()
                scale_dimensions <- get_scale_dimensions(x_var)
                cols <- c("#619CFF", "#00BA38", "#F8766D")
                ggplot(Rawdata(), aes(x = x, y = mpg)) +
                        geom_point(alpha = 0) +
                        geom_smooth(method = "lm", se = F, colour = "black") +
                        geom_hline(yintercept = mean(Rawdata()[,1])) +
                        geom_segment(aes(x  = x,
                                         y  = predict),
                                     xend   = Rawdata()[,2],
                                     yend   = mean(Rawdata()[,1]),
                                     colour = "#00BA38") +
                        theme(axis.title = element_text(size = 20),
                              axis.text  = element_text(size = 18),
                              panel.background = element_rect(fill = "white",
                                                              colour = "black")) +
                        ggtitle("SS regression") +
                        scale_x_continuous(name = scale_dimensions$name,
                                           breaks = scale_dimensions$breaks,
                                           labels = scale_dimensions$labels,
                                           limits = scale_dimensions$limits)
        })
        
        ### Output graph "error"
        output$error <- renderPlot({
                x_var <- X_var()
                scale_dimensions <- get_scale_dimensions(x_var)
                cols <- c("#619CFF", "#00BA38", "#F8766D")
                ggplot(Rawdata(), aes(x = x, y = mpg)) +
                        geom_point(size=3) + geom_smooth(method = "lm", se = F,
                                                         colour = "black") +
                        geom_segment(xend = Rawdata()[,2], yend = Rawdata()[,3],
                                     colour = "#F8766D") +
                        theme(axis.title = element_text(size = 20),
                              axis.text  = element_text(size = 18),
                              panel.background = element_rect(fill = "white",
                                                              colour = "black")) +
                        ggtitle("SS error") +
                        scale_x_continuous(name = scale_dimensions$name,
                                           breaks = scale_dimensions$breaks,
                                           labels = scale_dimensions$labels,
                                           limits = scale_dimensions$limits)
        })
        
        ### Output graph "variance"
        output$variance <- renderPlot({
                cols <- c("#619CFF", "#00BA38", "#F8766D")
                ggplot(SSdata(), aes(y = value, x = SS, fill = SS)) +
                        geom_bar(stat = "identity") +
                        scale_fill_manual(values = cols) +
                        theme(axis.title  = element_text(size = 20),
                              axis.text.x = element_text(size = 0),
                              axis.text.y = element_text(size = 16),
                              panel.background = element_rect(fill = "white",
                                                              colour = "black")) +
                        ylab("% of variance") +
                        xlab("Sums of Squares")
        })
        
        output$reg <- renderPlot({
                x_var <- X_var()
                scale_dimensions <- get_scale_dimensions(x_var)
                ggplot(mtcars, aes(y = mpg, x = mtcars[, x_var])) +
                        geom_point(size = 3, colour = "blue", alpha = .5) +
                        geom_smooth(method = "lm") +
                        theme(axis.title = element_text(size = 20),
                              axis.text  = element_text(size = 16),
                              panel.background = element_rect(fill = "white",
                                                              colour = "black")) +
                        ylab("MPG (Miles Per -US- Gallon)") +
                        xlab(x_var) +
                        scale_x_continuous(name = scale_dimensions$name,
                                           breaks = scale_dimensions$breaks,
                                           labels = scale_dimensions$labels,
                                           limits = scale_dimensions$limits)
        })
        
        ### Second output "anova"
        output$anova <- renderTable({
                anova_df <- as.data.frame(anova(lm(mpg ~ x, Rawdata())))
                anova_df <- data.frame(x = rownames(anova_df),
                                       anova_df[, 1:length(names(anova_df))])
                return(anova_df)
        })
        
        ### Second output "SS"
        output$coefficients <- renderTable({
                coef <- as.data.frame(summary(lm(mpg ~ x, Rawdata()))$coefficients)
                coef <- round(coef, 3)
                coef <- data.frame(x = rownames(coef), coef[, 1:length(names(coef))])
                return(coef)
        })
        
        output$data <- DT::renderDataTable({
                DT::datatable(Rawdata()[c(1,2)],
                              options = list(searchable = FALSE,
                                             searching = FALSE,
                                             lengthMenu = c(5, 15, 32),
                                             pageLength = 32))
        })
        
        output$histogram <- renderPlot({
                x_var <- X_var()
                scale_dimensions <- get_scale_dimensions(x_var)
                d1 <- ggplot(Rawdata(), aes(y = mpg, x = x)) +
                        geom_point(size = 3, colour = "blue", alpha = .5) +
                        theme(axis.title = element_text(size = 20),
                              axis.text  = element_text(size = 16),
                              panel.background = element_rect(fill = "white",
                                                              colour = "black")) +
                        ylab("MPG (Miles Per -US- Gallon)") +
                        xlab(x_var) +
                        scale_x_continuous(name = scale_dimensions$name,
                                           breaks = scale_dimensions$breaks,
                                           labels = scale_dimensions$labels,
                                           limits = scale_dimensions$limits)
                ggMarginal(
                        d1,
                        type = 'histogram')
        })
}