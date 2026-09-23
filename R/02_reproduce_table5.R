# Reproduce Hausman (2016), Table 5 in R
#
# Paper: Fiscal Policy and Economic Recovery: The Case of the 1936 Veterans' Bonus
# Target: Table 5, "Total expenditure and saving regressions"
#
# Required local files:
#   data/raw/urban_lprob.dta
#   data/raw/boot_results.dta
#
# urban_lprob.dta is distributed separately by OpenICPSR (project 100128).
# boot_results.dta is in the AER replication package (project 231365).

source("R/00_setup.R")

urban_path <- "data/raw/urban_lprob.dta"
boot_path  <- "data/raw/boot_results.dta"

if (!file.exists(urban_path)) {
  stop(
    "Missing data/raw/urban_lprob.dta. Download urban_lprob.dta from ",
    "OpenICPSR project 100128 and place it in data/raw/."
  )
}

if (!file.exists(boot_path)) {
  stop(
    "Missing data/raw/boot_results.dta. Copy it from the official AER ",
    "replication package (Stata/Data/boot_results.dta) into data/raw/."
  )
}

urban <- haven::read_dta(urban_path)
boot  <- haven::read_dta(boot_path)

# -----------------------------------------------------------------------------
# Controls
# -----------------------------------------------------------------------------
# This is a direct translation of the Stata control set:
#
# young old
# i.mid#i.race
# i.mid#i.stateicp
# i.mid#c.age
# i.mid#c.age_2
# i.mid#c.age_3
#
# Stata's # operator includes interactions without separately adding the two
# component main effects. The R formula below follows the same structure.

controls <- paste(
  "young + old",
  "+ factor(mid):factor(race)",
  "+ factor(mid):factor(stateicp)",
  "+ factor(mid):age",
  "+ factor(mid):age_2",
  "+ factor(mid):age_3"
)

f1 <- stats::as.formula(
  paste("tot_expen ~ June_36e + prob_june_36e +", controls)
)

f2 <- f1

f3 <- stats::as.formula(
  paste("insure_settled ~ June_36a + prob_june_36a +", controls)
)

f4 <- stats::as.formula(
  paste("bonus_spent ~ June_36i + prob_june_36i +", controls)
)

# -----------------------------------------------------------------------------
# OLS coefficients: Table 5 columns 1-4
# -----------------------------------------------------------------------------

m1 <- stats::lm(f1, data = urban)

m2 <- stats::lm(
  f2,
  data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)

m3 <- stats::lm(
  f3,
  data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)

m4 <- stats::lm(
  f4,
  data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)

# -----------------------------------------------------------------------------
# Bootstrap standard errors
# -----------------------------------------------------------------------------
# The published Stata table does not use the conventional lm() standard errors
# for the two displayed coefficients. The authors append 1,000 saved bootstrap
# draws and replace the relevant diagonal elements of e(V) with the variance of
# those draws. We reproduce those standard errors directly from boot_results.dta.

boot_se <- tibble::tribble(
  ~column, ~post_se, ~interaction_se,
  "(1)", stats::sd(boot$b1_June_36e, na.rm = TRUE), stats::sd(boot$b1_inter, na.rm = TRUE),
  "(2)", stats::sd(boot$b2_June_36e, na.rm = TRUE), stats::sd(boot$b2_inter, na.rm = TRUE),
  "(3)", stats::sd(boot$b3_June_36a, na.rm = TRUE), stats::sd(boot$b3_inter, na.rm = TRUE),
  "(4)", stats::sd(boot$b4_June_36i, na.rm = TRUE), stats::sd(boot$b4_inter, na.rm = TRUE)
)

extract_column <- function(model, column, post_name, interaction_name) {
  b <- stats::coef(model)

  tibble::tibble(
    column = column,
    post_coef = unname(b[[post_name]]),
    interaction_coef = unname(b[[interaction_name]]),
    n = stats::nobs(model),
    r2 = summary(model)$r.squared
  )
}

reproduced <- dplyr::bind_rows(
  extract_column(m1, "(1)", "June_36e", "prob_june_36e"),
  extract_column(m2, "(2)", "June_36e", "prob_june_36e"),
  extract_column(m3, "(3)", "June_36a", "prob_june_36a"),
  extract_column(m4, "(4)", "June_36i", "prob_june_36i")
) |>
  dplyr::left_join(boot_se, by = "column")

# Published Table 5 targets, transcribed from the authors' supplied tot_expen.tex.
published <- tibble::tribble(
  ~column, ~post_coef_pub, ~post_se_pub, ~interaction_coef_pub, ~interaction_se_pub, ~n_pub, ~r2_pub,
  "(1)", 264.1,   70.52, 647.2, 379.4, 2745, 0.152,
  "(2)", 198.2,   43.17, 403.1, 169.7, 2681, 0.186,
  "(3)",  -5.590,  4.292, 95.95, 22.88, 2681, 0.034,
  "(4)",   0.0742, 6.855, 152.4, 46.45, 2339, 0.048
)

comparison <- reproduced |>
  dplyr::left_join(published, by = "column") |>
  dplyr::mutate(
    post_coef_diff = post_coef - post_coef_pub,
    post_se_diff = post_se - post_se_pub,
    interaction_coef_diff = interaction_coef - interaction_coef_pub,
    interaction_se_diff = interaction_se - interaction_se_pub,
    n_diff = n - n_pub,
    r2_diff = r2 - r2_pub
  )

print(comparison)

readr::write_csv(reproduced, "output/table5_reproduced.csv")
readr::write_csv(comparison, "output/table5_published_vs_reproduced.csv")

# A lightweight automatic check. Published coefficients are rounded, so use
# tolerances rather than exact equality.
coef_tol <- 0.15
se_tol   <- 0.02
r2_tol   <- 0.0015

checks <- comparison |>
  dplyr::transmute(
    column,
    post_coef_match = abs(post_coef_diff) <= coef_tol,
    post_se_match = abs(post_se_diff) <= se_tol,
    interaction_coef_match = abs(interaction_coef_diff) <= coef_tol,
    interaction_se_match = abs(interaction_se_diff) <= se_tol,
    n_match = n_diff == 0,
    r2_match = abs(r2_diff) <= r2_tol
  )

print(checks)
readr::write_csv(checks, "output/table5_replication_checks.csv")

if (!all(unlist(checks[-1]))) {
  warning(
    "At least one published value did not match within tolerance. ",
    "Check factor-variable translation, sample restrictions, and data version."
  )
}
