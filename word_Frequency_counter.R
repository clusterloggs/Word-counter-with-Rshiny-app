library(shiny)
library(tidyverse)
library(readtext)
library(pdftools)
library(writexl)
library(ggplot2)
library(shinythemes)
library(tidyr)
library(reshape2)

ui <- fluidPage(
  theme = shinytheme("cyborg"),
  titlePanel("Word Frequency Counter (Multiple Files)"),
  sidebarLayout(
    sidebarPanel(
      fileInput("files", "Upload Files", multiple = TRUE),
      br(),
      fileInput("filter_file", "Upload Filter File (Words to Count)"),
      br(),
      actionButton("analyze_button", "Analyze Words"),
      br(),
      uiOutput("filtered_words_ui"),
      br(),
      downloadButton("export_chart", "Export Chart as PNG"),
      downloadButton("download_word_freq", "Export Data as Excel"),
      downloadButton("save_html", "Save Results as HTML") # New button for HTML download
    ),
    mainPanel(
      plotOutput("word_freq_plot"),
      verbatimTextOutput("file_info"),
      verbatimTextOutput("filtered_words")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values to store results
  filter_words <- reactiveVal(NULL)
  filtered_word_freq <- reactiveVal(data.frame())
  
  # Display uploaded file information
  output$file_info <- renderPrint({
    req(input$files)
    cat("Uploaded Files:\n")
    for (i in seq_along(input$files$name)) {
      cat(input$files$name[i], "\n")
    }
  })
  
  # Load filter words
  observeEvent(input$filter_file, {
    req(input$filter_file)
    words <- tryCatch({
      readLines(input$filter_file$datapath, warn = FALSE)
    }, error = function(e) {
      showNotification("Error reading filter file. Please check the format.")
      return(NULL)
    })
    if (!is.null(words)) {
      filter_words(tolower(words))
    }
  })
  
  # Analyze words in multiple files
  observeEvent(input$analyze_button, {
    req(input$files, filter_words())
    
    word_counts <- lapply(seq_along(input$files$datapath), function(i) {
      file_path <- input$files$datapath[i]
      file_name <- input$files$name[i]
      
      # Read and preprocess text
      text <- tryCatch({
        tolower(readLines(file_path, warn = FALSE))
      }, error = function(e) {
        showNotification(paste("Error reading file:", file_name))
        return(NULL)
      })
      
      if (!is.null(text)) {
        text <- gsub("[[:punct:][:digit:]]", "", text) # Remove punctuation and numbers
        text <- unlist(strsplit(text, "\\s+"))         # Split into words
        
        # Count word occurrences
        counts <- sapply(filter_words(), function(word) sum(text == word))
        data.frame(file = file_name, word = filter_words(), count = counts)
      }
    })
    
    # Combine all results into a single data frame
    combined_results <- do.call(rbind, word_counts)
    filtered_word_freq(combined_results)
  })
  
  # Display filtered words as a checkbox group
  output$filtered_words_ui <- renderUI({
    req(filtered_word_freq())
    checkboxGroupInput("word_checkboxes", "Select Words for Chart", 
                       choices = unique(filtered_word_freq()$word))
  })
  
  # Render filtered word frequencies
  output$word_freq_plot <- renderPlot({
    req(filtered_word_freq(), input$word_checkboxes)
    if (length(input$word_checkboxes) == 0) {
      showNotification("Please select words to display in the chart.")
      return(NULL)
    }
    
    selected_words <- filtered_word_freq()[filtered_word_freq()$word 
                                           %in% input$word_checkboxes, ]
    
    if (nrow(selected_words) == 0) {
      showNotification("No data matches the selected words.")
      return(NULL)
    }
    
    # Reshape data for plotting
    plot_data <- selected_words %>%
      pivot_wider(names_from = file, values_from = count, 
                  values_fill = list(count = 0))
    plot_data_melted <- pivot_longer(plot_data, -word, names_to = "file", 
                                     values_to = "count")
    
    ggplot(plot_data_melted, aes(x = file, y = count, color = word, 
                                 group = word)) +
      geom_line(size = 1) +
      labs(title = "Word Frequencies Across Files", x = "Files", y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
  })
  
  # Export chart as PNG
  output$export_chart <- downloadHandler(
    filename = function() { "word_frequencies_chart.png" },
    content = function(file) {
      req(filtered_word_freq(), input$word_checkboxes)
      selected_words <- filtered_word_freq()[filtered_word_freq()$word 
                                             %in% input$word_checkboxes, ]
      
      if (nrow(selected_words) == 0) {
        showNotification("No data to export. Please select words.")
        return()
      }
      
      plot_data <- selected_words %>%
        pivot_wider(names_from = file, values_from = count, 
                    values_fill = list(count = 0))
      plot_data_melted <- pivot_longer(plot_data, -word, names_to = "file", 
                                       values_to = "count")
      
      p <- ggplot(plot_data_melted, aes(x = file, y = count, color = word, 
                                        group = word)) +
        geom_line(size = 1) +
        labs(title = "Word Frequencies Across Files", x = "Files", 
             y = "Count") + theme_minimal() +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
      
      tryCatch({
        ggsave(file, plot = p, device = "png", width = 15, height = 10, 
               units = "in", dpi = 300)
      }, error = function(e) {
        showNotification("Error saving chart as PNG.")
      })
    }
  )
  
  # Export word frequencies as Excel
  output$download_word_freq <- downloadHandler(
    filename = function() { "word_frequencies.xlsx" },
    content = function(file) {
      req(filtered_word_freq())
      tryCatch({
        writexl::write_xlsx(filtered_word_freq(), file)
      }, error = function(e) {
        showNotification("Error exporting data as Excel.")
      })
    }
  )
  
  # Save results as HTML
  output$save_html <- downloadHandler(
    filename = function() { "word_frequencies.html" },
    content = function(file) {
      req(filtered_word_freq())
      html_content <- paste("<html><head><title>Word Frequencies</title></head>",
                            "<body><h1>Word Frequency Analysis Results</h1>",
                            "<table border='1'><tr><th>File</th><th>Word</th><th>Count</th></tr>",
                            paste0(
                              apply(filtered_word_freq(), 1, function(row) {
                                paste("<tr><td>", row["file"], "</td><td>",
                                      row["word"], "</td><td>",
                                      row["count"], "</td></tr>")
                              }),
                              collapse = ""
                            ),
                            "</table></body></html>")
      writeLines(html_content, file)
    }
  )
}

shinyApp(ui = ui, server = server)
