# Reproduce Hausman (2016), Table 5 in R
#
# Paper: Fiscal Policy and Economic Recovery: The Case of the 1936 Veterans' Bonus
# Target: Table 5, "Total expenditure and saving regressions"
#
# Required local files:
#   data/raw/urban_lprob.dta
#   data/raw/boot_results.dta

source("R/00_setup.R")

urban_path <- "data/raw/urban_lprob.dta"
boot_path  <- "data/raw/boot_results.dta"

if (!file.exists(urban_path)) {
  stop("Missing data/raw/urban_lprob.dta. See data/README.md.")
}
if (!file.exists(boot_path)) {
  stop("Missing data/raw/boot_results.dta. See data/README.md.")
}

urban <- haven::read_dta(urban_path)
boot  <- haven::read_dta(boot_path)

# Direct translation of the Stata controls:
# young old i.mid#i.race i.mid#i.stateicp
# i.mid#c.age i.mid#c.age_2 i.mid#c.age_3
controls <- paste(
  "young + old",
  "+ factor(mid):factor(race)",
  "+ factor(mid):factor(stateicp)",
  "+ factor(mid):age",
  "+ factor(mid):age_2",
  "+ factor(mid):age_3"
)

f1 <- stats::as.formula(paste(
  "tot_expen ~ June_36e + prob_june_36e +", controls
))
f2 <- f1
f3 <- stats::as.formula(paste(
  "insure_settled ~ June_36a + prob_june_36a +", controls
))
f4 <- stats::as.formula(paste(
  "bonus_spent ~ June_36i + prob_june_36i +", controls
))

# Table 5 OLS point estimates
m1 <- stats::lm(f1, data = urban)
m2 <- stats::lm(
  f2, data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)
m3 <- stats::lm(
  f3, data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)
m4 <- stats::lm(
  f4, data = urban,
  subset = !is.na(tot_expen) & tot_expen < 5000
)

# Published Table 5 uses bootstrap SEs for the displayed post and interaction
# coefficients. These are the sample SDs of the authors' 1,000 saved draws.
boot_se <- tibble::tribble(
  ~column, ~post_se, ~interaction_se,
  "(1)", stats::sd(boot$b1_June_36e, na.rm = TRUE), stats::sd(boot$b1_inter, na.rm = TRUE),
  "(2)", stats::sd(boot$b2_June_36e, na.rm = TRUE), stats::sd(boot$b2_inter, na.rm = TRUE),
  "(3)", stats::sd(boot$b3_June_36a, na.rm = TRUE), stats::sd(boot$b3_inter, na.rm = TRUE),
  "(4)", stats::sd(boot$b4_June_36i, na.rm = TRUE), stats::sd(boot$b4_inter, na.rm = TRUE)
)

extract_column <- function(model, column, post_name, interaction_name) {
  b <- stats::coef(model)
  s <- summary(model)$coefficients

  tibble::tibble(
    column = column,
    post_coef = unname(b[[post_name]]),
    interaction_coef = unname(b[[interaction_name]]),
    ols_post_se = unname(s[post_name, "Std. Error"]),
    ols_interaction_se = unname(s[interaction_name, "Std. Error"]),
    ols_post_p = unname(s[post_name, "Pr(>|t|)"]),
    ols_interaction_p = unname(s[interaction_name, "Pr(>|t|)"]),
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
  dplyr::left_join(boot_se, by = "column") |>
  dplyr::mutate(
    # Normal approximation used here only to illustrate why the bootstrap SE
    # matters for inference. The paper's star cutoffs use the posted SEs.
    bootstrap_post_p = 2 * stats::pnorm(-abs(post_coef / post_se)),
    bootstrap_interaction_p = 2 * stats::pnorm(-abs(interaction_coef / interaction_se))
  )

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

# Check the apparent >5000 versus <5000 wording discrepancy.
cutoff_check <- tibble::tibble(
  exactly_5000 = sum(urban$tot_expen == 5000, na.rm = TRUE),
  above_5000 = sum(urban$tot_expen > 5000, na.rm = TRUE)
)

print(comparison)
print(cutoff_check)

readr::write_csv(reproduced, "output/table5_reproduced.csv")
readr::write_csv(comparison, "output/table5_published_vs_reproduced.csv")
readr::write_csv(cutoff_check, "output/table5_cutoff_check.csv")

# Published values are rounded, including one SE shown to only one decimal.
coef_tol <- 0.15
se_tol   <- 0.06
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
  warning("At least one published value did not match within rounding tolerance.")
}
