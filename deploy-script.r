#!/usr/bin/env Rscript

# Script to prepare R presentation for GitHub Pages
cat("Preparing R presentation for GitHub Pages deployment...\n")

# Install required packages if not already installed
required_packages <- c("rmarkdown", "revealjs", "knitr")
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
  stop("Error: index.Rmd file not found in the current directory!")
}
if (!file.exists(css_file)) {
  stop("Error: modern-reveal-css.css file not found in the current directory!")
}

# Create docs directory if it doesn't exist
if (!dir.exists("docs")) {
  dir.create("docs")
  cat("Created 'docs' directory\n")
}

# Copy CSS file to docs directory
file.copy(css_file, file.path("docs", css_file), overwrite = TRUE)
cat("Copied CSS file to docs directory\n")

# FIXED APPROACH: Render in the current directory first
cat("Rendering the R Markdown presentation...\n")
render(rmd_file, output_format = "revealjs::revealjs_presentation")
cat("Presentation rendered successfully\n")

# Get the base name of the Rmd file without extension
base_name <- tools::file_path_sans_ext(basename(rmd_file))
html_file <- paste0(base_name, ".html")

# Copy the rendered HTML file to docs
if (file.exists(html_file)) {
  file.copy(html_file, file.path("docs", "index.html"), overwrite = TRUE)
  cat("Copied rendered HTML to docs/index.html\n")
} else {
  stop("Error: Rendered HTML file not found!")
}

# Copy libs directory if it exists
if (dir.exists("libs")) {
  if (dir.exists("docs/libs")) {
    unlink("docs/libs", recursive = TRUE)
  }
  dir.create("docs/libs", recursive = TRUE, showWarnings = FALSE)
  
  # Copy all files from libs to docs/libs
  libs_files <- list.files("libs", recursive = TRUE, full.names = TRUE)
  for (file in libs_files) {
    rel_path <- substring(file, 6) # Remove "libs/" from the beginning
    target_dir <- dirname(file.path("docs/libs", rel_path))
    if (!dir.exists(target_dir)) {
      dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
    }
    file.copy(file, file.path("docs/libs", rel_path), overwrite = TRUE)
  }
  cat("Copied libs directory to docs\n")
}

# Create .nojekyll file to prevent GitHub Pages from running Jekyll
file.create("docs/.nojekyll")
cat("Created .nojekyll file\n")

# Create a simple README.md file if it doesn't exist
if (!file.exists("README.md")) {
  readme_content <- "# R Presentation - GitHub Pages\n\nThis repository contains an R presentation deployed with GitHub Pages.\n\nView the presentation at: https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/\n"
  writeLines(readme_content, "README.md")
  cat("Created README.md file\n")
}

# Done!
cat("\nDeployment preparation complete!\n")
cat("Now commit and push these changes to your GitHub repository\n")
cat("Then enable GitHub Pages in your repository settings to serve from the 'docs' folder\n")
