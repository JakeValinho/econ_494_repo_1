# Code audit log — Hausman (2016), Table 5

## Scope

Target table: **Table 5 — Total expenditure and saving regressions**.

Original Stata files traced in the official replication package:

- `Stata/Code/hh-survey-results.do` — creates the published table.
- `Stata/Code/hhsurvey_bootstrap.do` — defines one bootstrap replication.
- `Stata/Code/run_bootstrap.do` — runs/saves bootstrap draws.
- `Stata/Data/boot_results.dta` — 1,000 saved bootstrap draws used for Table 5 standard errors.
- `Stata/Output/tot_expen.tex` — authors' generated Table 5 output.

The cleaned analysis dataset, `urban_lprob.dta`, is distributed separately through OpenICPSR project 100128.

---

## Reconstructed Table 5 workflow

The published table is generated in four steps:

1. Load `urban_lprob.dta`.
2. Append `boot_results.dta`.
3. Run four OLS regressions for total spending, restricted total spending, bonus saved, and bonus spending.
4. Replace the reported standard errors for the post-bonus and interaction coefficients with the standard deviations of the 1,000 saved bootstrap coefficient draws.

The original bootstrap resamples **city clusters within strata**, re-estimates veteran probability using weighted OLS, reconstructs predicted-veteran × post interactions, and then re-runs the Table 5 regressions.

### Published targets

| Column | Outcome shown in table | Post coefficient | Post SE | Interaction coefficient | Interaction SE | N | R² |
|---|---|---:|---:|---:|---:|---:|---:|
| (1) | Total spending | 264.1 | 70.52 | 647.2 | 379.4 | 2745 | 0.152 |
| (2) | Total spending | 198.2 | 43.17 | 403.1 | 169.7 | 2681 | 0.186 |
| (3) | Bonus saved | -5.590 | 4.292 | 95.95 | 22.88 | 2681 | 0.034 |
| (4) | Cash gifts received* | 0.0742 | 6.855 | 152.4 | 46.45 | 2339 | 0.048 |

`boot_results.dta` independently reproduces all eight published bootstrap standard errors when the SD of each saved coefficient series is calculated in another language.

---

## Finding 1 — Column 4 is mislabeled

**Status:** Confirmed labeling/documentation error.  
**Numerical effect:** None on coefficients or standard errors.  
**Interpretation effect:** Material; it changes what a reader thinks the dependent variable measures.

The data-construction code creates `bonus_spent` from survey variable `V202` and comments that it is the **amount of the soldiers' bonus spent for current living**. Immediately afterward, the variable is assigned the label **“Cash gifts received.”** Table 5 inherits that label for column (4).

The regression itself uses `bonus_spent`, so the numerical result is a regression of reported bonus spending, not cash gifts received. The error is therefore in the displayed label rather than the estimated model.

### Replication test

The R script keeps the variable name `bonus_spent` rather than relying on the incorrect Stata display label.

---

## Finding 2 — Main Table 5 bootstrap block is commented out in `run_bootstrap.do`

**Status:** Confirmed reproducibility issue.  
**Numerical effect when using supplied `boot_results.dta`:** None.  
**Effect when attempting to regenerate everything from scratch:** The main Table 5 bootstrap results are not regenerated unless the user manually re-enables that block.

The section of `run_bootstrap.do` that calls `hhsurvey_bootstrap` and saves `boot_results.dta` is enclosed in a block comment. Later bootstrap routines are active.

This does not invalidate the published Table 5 because the replication package already supplies `boot_results.dta`. It does mean that simply running `run_bootstrap.do` as shipped will not regenerate the main table's bootstrap draws.

### Replication response

`R/02_reproduce_table5.R` reproduces the published standard errors from the supplied 1,000 draws. `R/03_full_bootstrap.R` independently implements the cluster-within-strata bootstrap in R.

---

## Finding 3 — $5,000 cutoff wording versus code

**Status:** Potential sample-definition discrepancy to test.  
**Numerical effect:** Depends on whether any observations have `tot_expen == 5000`.

The published row describes columns (2)–(4) as omitting observations when expenditure is **greater than** $5,000. The Stata code actually uses:

```text
if tot_expen < 5000
```

That excludes observations equal to exactly $5,000 as well as observations above it.

### Test in R

Once `urban_lprob.dta` is present:

```r
sum(urban$tot_expen == 5000, na.rm = TRUE)
```

If the result is zero, the wording difference has no numerical effect. If it is positive, rerun the affected columns with `tot_expen <= 5000` and report the resulting changes.

---

## Finding 4 — Hard-coded author-specific paths

**Status:** Confirmed portability issue, not an econometric error.  
**Numerical effect:** None after paths are corrected.

The original do-files use a hard-coded Dropbox location. A new user must edit the path before the Stata programs can run.

The R reproduction instead uses repository-relative paths such as `data/raw/urban_lprob.dta`.

---

## Bootstrap verification from supplied draws

Calculating sample SDs from the 1,000 observations in `boot_results.dta` gives:

| Column | Coefficient | SD from saved draws | Published SE |
|---|---|---:|---:|
| (1) | Post bonus | 70.5207 | 70.52 |
| (1) | Interaction | 379.4406 | 379.4 |
| (2) | Post bonus | 43.1735 | 43.17 |
| (2) | Interaction | 169.6765 | 169.7 |
| (3) | Post bonus | 4.2920 | 4.292 |
| (3) | Interaction | 22.8827 | 22.88 |
| (4) | Post bonus | 6.8552 | 6.855 |
| (4) | Interaction | 46.4510 | 46.45 |

This confirms that the saved bootstrap draws are exactly the source of the standard errors reported in the supplied `tot_expen.tex` table, up to displayed rounding.

---

## Remaining checks after obtaining `urban_lprob.dta`

- [x] Exact Table 5 source do-file identified
- [x] Bootstrap source do-file identified
- [x] Saved bootstrap results identified
- [x] Published standard errors reproduced from saved draws
- [x] Published coefficients / N / R² transcribed from authors' generated table
- [x] Column 4 labeling error identified
- [x] Commented-out main bootstrap block identified
- [ ] `urban_lprob.dta` downloaded from OpenICPSR project 100128
- [ ] Four OLS point estimates reproduced in R
- [ ] Published N matched in all four columns
- [ ] Published R² matched in all four columns
- [ ] Test whether any observation has `tot_expen == 5000`
- [ ] Run independent R bootstrap and compare its SEs with authors' saved draws
