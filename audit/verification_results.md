# Verified reproduction results — Hausman (2016), Table 5

Using the separately distributed `urban_lprob.dta` from OpenICPSR project 100128 and the authors' supplied `boot_results.dta`, the Table 5 specification was independently translated and checked against the Stata output.

## Point estimates and fit

The four OLS specifications reproduce the authors' Table 5 values to displayed rounding:

| Column | Post coefficient | Interaction coefficient | N | R² |
|---|---:|---:|---:|---:|
| (1) | 264.1169 | 647.2271 | 2745 | 0.152023 |
| (2) | 198.2407 | 403.1177 | 2681 | 0.185684 |
| (3) | -5.5898 | 95.9504 | 2681 | 0.033618 |
| (4) | 0.0742 | 152.4382 | 2339 | 0.047925 |

These correspond to the published rounded values 264.1 / 647.2, 198.2 / 403.1, -5.590 / 95.95, and 0.0742 / 152.4.

## Bootstrap standard errors

The sample standard deviations of the authors' 1,000 saved bootstrap coefficient draws reproduce the published standard errors:

| Column | Post SE | Interaction SE |
|---|---:|---:|
| (1) | 70.5207 | 379.4406 |
| (2) | 43.1735 | 169.6765 |
| (3) | 4.2920 | 22.8827 |
| (4) | 6.8552 | 46.4510 |

## $5,000 cutoff check

The table wording says observations with spending greater than $5,000 are omitted, while the code uses `tot_expen < 5000`. The cleaned dataset contains:

- 0 observations with `tot_expen == 5000`;
- 64 observations with `tot_expen > 5000`.

Therefore the wording/code distinction has **no numerical effect** on Table 5.

## Confirmed coding / reproducibility findings

### 1. Column (4) is mislabeled

The data-construction code defines `bonus_spent = V202` and comments that V202 is the **amount of soldiers' bonus spent for current living**. The next line incorrectly assigns the display label `Cash gifts received`, which is inherited by Table 5.

**Effect:** no effect on estimates or standard errors, but a material interpretation error in the table heading.

### 2. Main Table 5 bootstrap block is commented out

In `run_bootstrap.do`, the block that runs `hhsurvey_bootstrap` for 1,000 repetitions and saves `boot_results.dta` is enclosed in a block comment.

**Effect:** no effect when using the supplied `boot_results.dta`; however, running `run_bootstrap.do` as shipped does not regenerate the main Table 5 bootstrap draws.

### 3. Hard-coded local paths

The Stata scripts contain an author-specific Dropbox path.

**Effect:** portability/reproducibility issue only; no effect after paths are corrected.

## Important translation pitfall: default OLS standard errors are wrong for the published table

A direct regression translation that reports default `lm()` / OLS standard errors does **not** reproduce the inference in the paper because the paper reports bootstrap standard errors for the displayed post and interaction coefficients.

For example, in column (1):

- interaction coefficient = 647.23;
- ordinary OLS SE ≈ 280.08, giving p ≈ 0.021;
- published bootstrap SE ≈ 379.44, giving a normal-approximation p ≈ 0.088.

So a naive translation would change the interaction from approximately 10% significance in the published table to 5% significance. This is not an error in the author's code; it is an important implementation detail the reproduction must preserve.

## Bottom line

The main Table 5 numerical results are reproducible from the supplied data and bootstrap draws. The audit identified a clear outcome-label error and reproducibility/portability issues, but no coding error that changes the Table 5 point estimates.
