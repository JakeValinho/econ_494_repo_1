# ECON 494 — Assignment completion checklist

## Class 3 requirement

> Reproduce an AER (2016–2021) paper's main table in another programming language and check for coding errors and their effects.

## Completion status

- [x] **Eligible AER paper selected.** Joshua K. Hausman (2016), *Fiscal Policy and Economic Recovery: The Case of the 1936 Veterans' Bonus*, American Economic Review 106(4).
- [x] **Main empirical table selected.** Table 5, “Total expenditure and saving regressions,” contains the paper's central household spending/saving evidence.
- [x] **Original language identified.** The authors' replication is written in Stata.
- [x] **Different language used.** Table 5 is translated into R in `R/02_reproduce_table5.R`.
- [x] **Original data located.** `urban_lprob.dta` was obtained from OpenICPSR project 100128; `boot_results.dta` is from the AER replication package (project 231365).
- [x] **Point estimates reproduced.** All four reported post-bonus and interaction coefficients match the authors' generated Table 5 to displayed rounding.
- [x] **Sample sizes reproduced.** N matches in all four columns: 2,745; 2,681; 2,681; and 2,339.
- [x] **R-squared reproduced.** All four values match to displayed rounding.
- [x] **Published standard errors verified.** The SDs of the authors' 1,000 saved bootstrap draws reproduce all eight reported Table 5 standard errors.
- [x] **Original code audited.** Relevant Stata files were traced and reviewed line-by-line.
- [x] **Coding/documentation errors identified and effects checked.** See `audit/verification_results.md` and `audit/audit_log.md`.
- [x] **$5,000 sample-rule discrepancy tested.** There are zero observations exactly equal to $5,000, so `< 5000` versus “omit if > $5,000” has no numerical effect.
- [x] **Column (4) labeling error identified.** The underlying outcome is bonus spending, despite the table label “Cash gifts received.” Numerical estimates are unchanged; interpretation is affected.
- [x] **Reproducibility issue identified.** The main Table 5 bootstrap block is commented out in `run_bootstrap.do`; the supplied saved draws still reproduce the paper.
- [x] **Inference translation risk checked.** Using default R OLS standard errors rather than the intended bootstrap SEs can materially change significance; this is documented in `audit/verification_results.md`.
- [x] **Independent bootstrap code translated.** `R/03_full_bootstrap.R` implements the authors' city-within-strata bootstrap in R. A fresh 1,000-draw run is an optional stronger verification, not required to reproduce the published table because the authors provide the bootstrap draws used in publication.
- [x] **AI use documented.** See `AI_USE.md`.
- [x] **Research ideas prepared for class discussion.** See `research_ideas.md`.

## Bottom line

The required coding/AI exercise is complete: the main table has been reproduced in a different programming language, the original code has been audited, and the effects of identified coding/documentation/reproducibility issues have been checked and documented.

The only optional extension is to execute a new 1,000-replication bootstrap from `R/03_full_bootstrap.R` and compare its sampling variability with the authors' saved bootstrap results. Because R and Stata use different random-number generators, those draws should not be expected to match observation-for-observation.
