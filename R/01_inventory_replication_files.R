# Inventory the official Hausman (2016) replication package after downloading it.
#
# Put the authors' files somewhere under:
#   data/raw/
# or
#   original/stata/
#
# This script does not modify the authors' files.

source("R/00_setup.R")

roots <- c("data/raw", "original/stata")
roots <- roots[dir.exists(roots)]

if (length(roots) == 0) {
  stop(
    "No replication files found. Download the official package and place ",
    "the files under data/raw/ or original/stata/."
  )
}

files <- unlist(
  lapply(
    roots,
    list.files,
    recursive = TRUE,
    full.names = TRUE,
    all.files = FALSE
  )
)

inventory <- tibble::tibble(
  path = files,
  file = basename(files),
  extension = tolower(tools::file_ext(files)),
  size_kb = round(file.info(files)$size / 1024, 1)
) |>
  dplyr::arrange(extension, path)

readr::write_csv(inventory, "output/file_inventory.csv")

stata_files <- inventory |>
  dplyr::filter(extension %in% c("do", "ado", "dta"))

readr::write_csv(stata_files, "output/stata_file_inventory.csv")

print(stata_files, n = Inf)
