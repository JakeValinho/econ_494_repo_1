# Independent R implementation of the Table 5 bootstrap
#
# The authors' Stata routine:
#   1. samples city clusters with replacement within strata;
#   2. re-estimates veteran probability using weighted OLS;
#   3. constructs predicted-veteran x post interactions;
#   4. runs the four Table 5 regressions;
#   5. repeats 1,000 times.
#
# This script follows that logic in R. Because R and Stata use different RNG
# implementations, setting the same seed does NOT imply identical bootstrap
# draws. The resulting standard errors should be compared approximately.

source("R/00_setup.R")

urban_path <- "data/raw/urban_lprob.dta"
boot_path  <- "data/raw/boot_results.dta"

if (!file.exists(urban_path)) {
  stop("Missing data/raw/urban_lprob.dta. See data/README.md.")
}

urban <- haven::read_dta(urban_path)

# Number of replications. Example quick test from a terminal:
#   REPS=50 Rscript R/03_full_bootstrap.R
REPS <- as.integer(Sys.getenv("REPS", unset = "1000"))
set.seed(123)

# Fixed factor levels help make model matrices consistent across bootstrap draws.
urban <- urban |>
  dplyr::mutate(
    mid_f = factor(mid),
    race_f = factor(race),
    state_f = factor(stateicp)
  )

# Verify the bootstrap cluster is nested within strata, as required by the
# Stata bsample cluster(city) strata(strata) design.
nested_check <- urban |>
  dplyr::filter(!is.na(city), !is.na(strata)) |>
  dplyr::distinct(city, strata) |>
  dplyr::count(city, name = "n_strata")

if (any(nested_check$n_strata > 1)) {
  stop("At least one city appears in multiple strata; inspect bootstrap design.")
}

cluster_frame <- urban |>
  dplyr::filter(!is.na(city), !is.na(strata)) |>
  dplyr::distinct(strata, city)

controls <- paste(
  "young + old",
  "+ mid_f:race_f",
  "+ mid_f:state_f",
  "+ mid_f:age",
  "+ mid_f:age_2",
  "+ mid_f:age_3"
)

first_stage_formula <- stats::as.formula(
  paste("ww1 ~", controls)
)

formula_1 <- stats::as.formula(
  paste("tot_expen ~ June_36e + prob_june_36b +", controls)
)
formula_2 <- formula_1
formula_3 <- stats::as.formula(
  paste("insure_settled ~ June_36a + prob_june_36ba +", controls)
)
formula_4 <- stats::as.formula(
  paste("bonus_spent ~ June_36i + prob_june_36bi +", controls)
)

sample_city_clusters <- function(data, clusters) {
  sampled_clusters <- clusters |>
    dplyr::group_by(strata) |>
    dplyr::group_modify(function(.x, .y) {
      .x[sample.int(nrow(.x), size = nrow(.x), replace = TRUE), , drop = FALSE]
    }) |>
    dplyr::ungroup() |>
    dplyr::mutate(draw_id = dplyr::row_number())

  # Repeated city draws intentionally duplicate all observations in that city.
  sampled_clusters |>
    dplyr::inner_join(data, by = c("strata", "city"), relationship = "many-to-many")
}

safe_coef <- function(model, name) {
  out <- stats::coef(model)[[name]]
  if (is.null(out) || length(out) == 0) NA_real_ else unname(out)
}

one_bootstrap <- function() {
  b <- sample_city_clusters(urban, cluster_frame)

  # Stata's first stage uses pweights. For coefficient estimation, weighted lm
  # reproduces the same WLS coefficient calculation used by the first stage.
  first_stage <- stats::lm(
    first_stage_formula,
    data = b,
    weights = perwt,
    na.action = stats::na.exclude
  )

  b$prob_vetb <- stats::predict(first_stage, newdata = b)
  b$prob_june_36b  <- b$prob_vetb * b$June_36e
  b$prob_june_36ba <- b$prob_vetb * b$June_36a
  b$prob_june_36bi <- b$prob_vetb * b$June_36i

  m1 <- stats::lm(formula_1, data = b)
  m2 <- stats::lm(
    formula_2,
    data = b,
    subset = !is.na(tot_expen) & tot_expen < 5000
  )
  m3 <- stats::lm(
    formula_3,
    data = b,
    subset = !is.na(tot_expen) & tot_expen < 5000
  )
  m4 <- stats::lm(
    formula_4,
    data = b,
    subset = !is.na(tot_expen) & tot_expen < 5000
  )

  c(
    b1_June_36e = safe_coef(m1, "June_36e"),
    b1_inter     = safe_coef(m1, "prob_june_36b"),
    b2_June_36e = safe_coef(m2, "June_36e"),
    b2_inter     = safe_coef(m2, "prob_june_36b"),
    b3_June_36a = safe_coef(m3, "June_36a"),
    b3_inter     = safe_coef(m3, "prob_june_36ba"),
    b4_June_36i = safe_coef(m4, "June_36i"),
    b4_inter     = safe_coef(m4, "prob_june_36bi")
  )
}

results <- matrix(
  NA_real_,
  nrow = REPS,
  ncol = 8,
  dimnames = list(
    NULL,
    c(
      "b1_June_36e", "b1_inter",
      "b2_June_36e", "b2_inter",
      "b3_June_36a", "b3_inter",
      "b4_June_36i", "b4_inter"
    )
  )
)

for (i in seq_len(REPS)) {
  results[i, ] <- one_bootstrap()
  if (i %% 50 == 0 || i == REPS) {
    message("Completed bootstrap replication ", i, " / ", REPS)
  }
}

results <- tibble::as_tibble(results)
readr::write_csv(results, "output/table5_bootstrap_R.csv")

r_ses <- results |>
  dplyr::summarise(dplyr::across(dplyr::everything(), ~ stats::sd(.x, na.rm = TRUE))) |>
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "coefficient",
    values_to = "R_bootstrap_se"
  )

if (file.exists(boot_path)) {
  author_boot <- haven::read_dta(boot_path)

  author_ses <- author_boot |>
    dplyr::select(dplyr::all_of(names(results))) |>
    dplyr::summarise(dplyr::across(dplyr::everything(), ~ stats::sd(.x, na.rm = TRUE))) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "coefficient",
      values_to = "author_bootstrap_se"
    )

  se_comparison <- r_ses |>
    dplyr::left_join(author_ses, by = "coefficient") |>
    dplyr::mutate(
      difference = R_bootstrap_se - author_bootstrap_se,
      pct_difference = 100 * difference / author_bootstrap_se
    )

  print(se_comparison)
  readr::write_csv(se_comparison, "output/table5_bootstrap_se_comparison.csv")
} else {
  print(r_ses)
  readr::write_csv(r_ses, "output/table5_bootstrap_R_ses.csv")
}
