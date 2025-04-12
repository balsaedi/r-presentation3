#!/usr/bin/env Rscript

# Script to prepare R Slidy presentation for GitHub Pages
cat("Preparing R Slidy presentation for GitHub Pages deployment...\n")

# Install required packages if not already installed
required_packages <- c("rmarkdown", "knitr")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Installing package: %s\n", pkg))
    install.packages(pkg, repos = "https://cran.rstudio.com/")
  }
}

# Load libraries
library(rmarkdown)
library(knitr)

# Define file paths
rmd_file <- "index.Rmd"
css_file <- "Custom.css"

# Check if files exist
if (!file.exists(rmd_file)) {
  stop("Error: statistical-programming-presentation.Rmd file not found in the current directory!")
}
if (!file.exists(css_file)) {
  stop("Error: fixed-custom.css file not found in the current directory!")
}

# Create docs directory if it doesn't exist
if (!dir.exists("docs")) {
  dir.create("docs")
  cat("Created 'docs' directory\n")
}

# Copy CSS file to docs directory
file.copy(css_file, file.path("docs", css_file), overwrite = TRUE)
cat("Copied CSS file to docs directory\n")

# Render the presentation to Slidy format
cat("Rendering the R Markdown presentation to Slidy...\n")
render(rmd_file, 
       output_format = "slidy_presentation", 
       output_file = "index.html",
       output_dir = getwd())
cat("Presentation rendered successfully\n")

# Get the rendered HTML file
html_file <- "index.html"

# Check if HTML file was created
if (file.exists(html_file)) {
  file.copy(html_file, file.path("docs", "index.html"), overwrite = TRUE)
  cat("Copied rendered HTML to docs/index.html\n")
} else {
  stop("Error: Rendered HTML file not found!")
}

# Copy any generated directories that Slidy needs
dirs_to_check <- c("libs", "index_files")
for (dir_name in dirs_to_check) {
  if (dir.exists(dir_name)) {
    if (dir.exists(file.path("docs", dir_name))) {
      unlink(file.path("docs", dir_name), recursive = TRUE)
    }
    dir.create(file.path("docs", dir_name), recursive = TRUE, showWarnings = FALSE)
    
    # Copy all files from the directory to docs
    dir_files <- list.files(dir_name, recursive = TRUE, full.names = TRUE)
    for (file in dir_files) {
      rel_path <- substring(file, nchar(dir_name) + 2) # Remove "dir_name/" from the beginning
      target_dir <- dirname(file.path("docs", dir_name, rel_path))
      if (!dir.exists(target_dir)) {
        dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
      }
      file.copy(file, file.path("docs", dir_name, rel_path), overwrite = TRUE)
    }
    cat(sprintf("Copied %s directory to docs\n", dir_name))
  }
}

# Create .nojekyll file to prevent GitHub Pages from running Jekyll
file.create("docs/.nojekyll")
cat("Created .nojekyll file\n")

# Create a simple README.md file if it doesn't exist
if (!file.exists("README.md")) {
  readme_content <- "# Statistical Programming - Slidy Presentation\n\nThis repository contains an R Slidy presentation on Statistical Programming, Simulation and Modeling deployed with GitHub Pages.\n\nView the presentation at: https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/\n"
  writeLines(readme_content, "README.md")
  cat("Created README.md file\n")
}

# Done!
cat("\nDeployment preparation complete!\n")
cat("Now commit and push these changes to your GitHub repository\n")
cat("Then enable GitHub Pages in your repository settings to serve from the 'docs' folder\n")
