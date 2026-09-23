# Reproduce Hausman (2016), Table 5 in R
#
# IMPORTANT:
# Do not fill in variable names or specifications by guessing.
# First identify the exact Stata do-file(s) and datasets that generate
# Table 5 using R/01_inventory_replication_files.R.

source("R/00_setup.R")

# -------------------------------------------------------------------
# 1. LOAD ORIGINAL DATA
# -------------------------------------------------------------------

# Example only:
# census <- haven::read_dta("data/raw/...dta")
# consumption <- haven::read_dta("data/raw/...dta")


# -------------------------------------------------------------------
# 2. REPRODUCE ORIGINAL SAMPLE RESTRICTIONS
# -------------------------------------------------------------------

# Translate every original keep/drop/if condition explicitly.
# Do not rely on implicit R missing-value behavior.


# -------------------------------------------------------------------
# 3. FIRST STAGE: PREDICT VETERAN STATUS / PROBABILITY
# -------------------------------------------------------------------

# Match:
# - estimation sample
# - dependent variable
# - age controls
# - race controls
# - geographic controls
# - functional form
# - weights, if any


# -------------------------------------------------------------------
# 4. CONSTRUCT TABLE 5 VARIABLES
# -------------------------------------------------------------------

# Match the original definitions for:
# - post-bonus dummy
# - predicted veteran probability
# - veteran probability × post-bonus interaction
# - expenditure / saving outcomes
# - all controls


# -------------------------------------------------------------------
# 5. SECOND-STAGE REGRESSIONS
# -------------------------------------------------------------------

# Reproduce each published Table 5 column separately.
# Do not assume the same controls or sample apply to every column.


# -------------------------------------------------------------------
# 6. BOOTSTRAP / CLUSTERING
# -------------------------------------------------------------------

# Translate the authors' exact bootstrap algorithm rather than substituting
# an ordinary heteroskedasticity-robust or cluster-robust vcov.


# -------------------------------------------------------------------
# 7. BUILD COMPARISON TABLE
# -------------------------------------------------------------------

published <- tibble::tribble(
  ~statistic, ~col1, ~col2, ~col3, ~col4,
  "Post bonus coefficient", NA, NA, NA, NA,
  "Post bonus SE",           NA, NA, NA, NA,
  "Interaction coefficient", NA, NA, NA, NA,
  "Interaction SE",           NA, NA, NA, NA,
  "N",                        NA, NA, NA, NA,
  "R2",                       NA, NA, NA, NA
)

# Fill published values only after checking them against the paper.
# Then join the R estimates and calculate differences.

readr::write_csv(
  published,
  "output/table5_published_vs_reproduced.csv"
)
