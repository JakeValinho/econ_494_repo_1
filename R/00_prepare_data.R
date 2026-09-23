# Prepare the two data files needed for the Hausman (2016) Table 5 replication.
#
# Put these two official ZIP files in the repository root (or in data/):
#   1. ICPSR_100128-V1.1.zip  -> contains urban_lprob.dta
#   2. 231365-V1.zip           -> contains boot_results.dta
#
# Then run:
#   source("R/00_prepare_data.R")
#
# The script extracts only the two files needed for Table 5 into data/raw/.
# Raw files remain ignored by Git via .gitignore.

raw_dir <- file.path("data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

find_zip <- function(filename) {
  candidates <- c(
    filename,
    file.path("data", filename),
    file.path("downloads", filename)
  )

  hit <- candidates[file.exists(candidates)]

  if (length(hit) == 0) {
    stop(
      "Could not find ", filename, ". Put it in the repository root or data/ folder."
    )
  }

  hit[[1]]
}

urban_zip <- find_zip("ICPSR_100128-V1.1.zip")
aer_zip   <- find_zip("231365-V1.zip")

urban_target <- file.path(raw_dir, "urban_lprob.dta")
boot_target  <- file.path(raw_dir, "boot_results.dta")

# -----------------------------
# urban_lprob.dta
# -----------------------------
urban_listing <- utils::unzip(urban_zip, list = TRUE)
urban_match <- urban_listing$Name[grepl("(^|/)urban_lprob\\.dta$", urban_listing$Name)]

if (length(urban_match) != 1) {
  stop("Could not uniquely identify urban_lprob.dta inside ", urban_zip)
}

urban_tmp <- tempfile("urban_extract_")
dir.create(urban_tmp)
utils::unzip(urban_zip, files = urban_match, exdir = urban_tmp)
file.copy(file.path(urban_tmp, urban_match), urban_target, overwrite = TRUE)
unlink(urban_tmp, recursive = TRUE)

# -----------------------------
# boot_results.dta
# -----------------------------
aer_listing <- utils::unzip(aer_zip, list = TRUE)
boot_match <- aer_listing$Name[grepl("(^|/)boot_results\\.dta$", aer_listing$Name)]

if (length(boot_match) != 1) {
  stop("Could not uniquely identify boot_results.dta inside ", aer_zip)
}

boot_tmp <- tempfile("boot_extract_")
dir.create(boot_tmp)
utils::unzip(aer_zip, files = boot_match, exdir = boot_tmp)
file.copy(file.path(boot_tmp, boot_match), boot_target, overwrite = TRUE)
unlink(boot_tmp, recursive = TRUE)

cat("Data setup complete.\n")
cat("Created:\n")
cat("  ", urban_target, "\n", sep = "")
cat("  ", boot_target, "\n", sep = "")
cat("\nNow run:\n")
cat('  source("R/02_reproduce_table5.R")\n')
