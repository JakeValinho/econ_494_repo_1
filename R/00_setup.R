# ECON 494 — Hausman (2016) replication
# Package setup

packages <- c(
  "haven",       # Read Stata .dta files
  "dplyr",       # Data manipulation
  "tidyr",       # Data reshaping
  "purrr",       # Functional tools
  "stringr",     # String tools
  "readr",       # CSV/text files
  "broom",       # Tidy model output
  "fixest",      # Regressions / fixed effects / clustered SEs
  "modelsummary" # Regression tables
)

missing_packages <- packages[
  !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

invisible(lapply(packages, library, character.only = TRUE))

set.seed(1936)

dir.create("output", showWarnings = FALSE, recursive = TRUE)
