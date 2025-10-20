# Word Frequency Counter

A Shiny web application for counting and visualizing the frequency of specific words across multiple text files. This tool allows users to upload a set of documents and a separate list of words to track, then generates an interactive plot and downloadable reports of the word counts.

## Project Overview

The Word Frequency Counter is designed for researchers, analysts, or anyone needing to track the occurrence of specific terms across a collection of documents. By providing a simple interface to upload files and specify target words, the application automates the process of text analysis, providing quick, visual, and exportable insights.

### Key Features

-   **Multi-File Analysis**: Upload and process multiple text files simultaneously.
-   **Custom Word Lists**: Specify which words to count by uploading a simple text file.
-   **Interactive Visualization**: Generates a line plot to compare word frequencies across different files.
-   **Dynamic Filtering**: Interactively select which words to display on the chart.
-   **Data Export**:
    -   Export the frequency data to an Excel (`.xlsx`) file.
    -   Download the generated chart as a high-quality PNG image.
    -   Save the raw results in a simple HTML report.

---

## Installation & Setup

To run this application on your local machine, you will need R and RStudio installed.

### Prerequisites

-   R (version 4.0.0 or newer recommended)
-   RStudio Desktop (recommended for ease of use)

### Dependencies Installation

1.  Open R or RStudio.
2.  Run the following command in the console to install the required packages from CRAN:

    ```r
    install.packages(c(
      "shiny", "tidyverse", "readtext", "pdftools", "writexl",
      "ggplot2", "shinythemes", "tidyr", "reshape2"
    ))
    ```

### Running the Application

1.  Clone or download this repository to your local machine.
2.  Navigate to the project directory.
3.  Open the `word_Frequency_counter.R` file in RStudio.
4.  Click the "Run App" button in the top-right corner of the script editor, or run the following command in the R console:

    ```r
    shiny::runApp("word_Frequency_counter.R")
    ```

---

## Usage Guide

Follow these steps to analyze your files:

1.  **Upload Source Files**: Click the "Upload Files" button and select one or more text files (`.txt`, `.csv`, etc.) that you want to analyze. The names of the uploaded files will appear below the button.

2.  **Upload Filter File**: Click the "Upload Filter File (Words to Count)" button and select a `.txt` file. This file should contain the specific words you want to count, with **one word per line**.

    *Example `filter-words.txt`:*
    ```
    analysis
    data
    shiny
    ```

3.  **Analyze**: Click the "Analyze Words" button to start the counting process.

4.  **Visualize**: Once the analysis is complete, a list of the counted words will appear as checkboxes. Select the words you wish to see in the plot. The plot will update automatically.

5.  **Export Results**:
    -   **Export Chart as PNG**: Downloads the current plot as a `.png` file.
    -   **Export Data as Excel**: Downloads a table of all word counts across all files as an `.xlsx` file.
    -   **Save Results as HTML**: Downloads a simple HTML file containing the word count table.

---

## Project Structure

The project is self-contained within a single R script and a few metadata files.

```
Word-counter-with-Rshiny-app/
├── word_Frequency_counter.R    # The main R Shiny application script
├── License                     # Apache 2.0 License file
└── README.md                   # This documentation file
```

### Architecture Overview

The application is built using the R Shiny framework and follows a standard `ui`/`server` structure:

-   **`ui` (User Interface)**: Defines the layout and appearance of the web application using `fluidPage`. It includes file inputs, action buttons, download buttons, and placeholders for the plot and other outputs. The `shinytheme("cyborg")` is used for styling.
-   **`server` (Server Logic)**: Contains the reactive logic that powers the application.
    -   It uses `observeEvent` to react to file uploads and button clicks.
    -   `reactiveVal` is used to store the list of filter words and the resulting word frequency data frame.
    -   The core analysis logic reads text from files, cleans it (removes punctuation and numbers), and counts the occurrences of the specified words.
    -   `renderPlot` generates the `ggplot2` line chart based on user selections.
    -   `downloadHandler` functions manage the creation and serving of downloadable files (PNG, Excel, HTML).

---

## Development

### Contribution Guidelines

Contributions are welcome! If you have suggestions for improvements or find a bug, please feel free to open an issue or submit a pull request.

When contributing, please ensure your code is well-commented and follows the existing style.

### Testing

To test the application:

1.  Create a few sample `.txt` files with varying content.
2.  Create a `filter-words.txt` file with a list of words to search for, including some that are present in the sample files and some that are not.
3.  Run the application and perform the following actions:
    -   Upload the source and filter files.
    -   Click "Analyze Words" and verify the word selection checkboxes appear.
    -   Select different combinations of words and check if the plot renders correctly.
    -   Use all three "Export" / "Download" buttons and verify the output files are created correctly and contain the expected data.

---

## Troubleshooting

-   **Error reading filter file**: Ensure your filter file is a plain text (`.txt`) file with one word per line.
-   **Error reading file: [filename]**: The application is designed for plain text files. If you upload a binary file like a PDF or DOCX, it may fail.
-   **No data to export**: Make sure you have successfully run an analysis and selected words for the chart before trying to export the chart.

---

## License

This project is licensed under the Apache License, Version 2.0. See the LICENSE file for full details.

---

## Support

For questions or support, please open an issue in the GitHub repository.