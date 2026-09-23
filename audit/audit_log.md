# Code audit log — Hausman (2016), Table 5

## Scope

Target table: **Table 5 — Total expenditure and saving regressions**.

Original Stata files traced in the official replication package:

- `Stata/Code/hh-survey-results.do` — creates the published table.
- `Stata/Code/hhsurvey_bootstrap.do` — defines one bootstrap replication.
- `Stata/Code/run_bootstrap.do` — runs/saves bootstrap draws.
- `Stata/Data/boot_results.dta` — 1,000 saved bootstrap draws.
- `Stata/Output/tot_expen.tex` — authors' generated Table 5.
- `urban_lprob.dta` — cleaned analysis dataset from OpenICPSR project 100128.

## Reproduction result

The Table 5 regressions reproduce the published point estimates, sample sizes, and R² values to displayed rounding:

| Column | Post coefficient | Interaction coefficient | N | R² |
|---|---:|---:|---:|---:|
| (1) | 264.1169 | 647.2271 | 2745 | 0.152023 |
| (2) | 198.2407 | 403.1177 | 2681 | 0.185684 |
| (3) | -5.5898 | 95.9504 | 2681 | 0.033618 |
| (4) | 0.0742 | 152.4382 | 2339 | 0.047925 |

The sample SDs of the authors' 1,000 bootstrap draws also reproduce the published standard errors:

| Column | Post SE | Interaction SE |
|---|---:|---:|
| (1) | 70.5207 | 379.4406 |
| (2) | 43.1735 | 169.6765 |
| (3) | 4.2920 | 22.8827 |
| (4) | 6.8552 | 46.4510 |

---

## Finding 1 — Column (4) is mislabeled

**Status:** Confirmed coding/documentation error.  
**Numerical effect:** None.  
**Interpretation effect:** Material.

The data-construction code states that survey variable `V202` is the **amount of soldiers' bonus spent for current living** and constructs:

```text
gen bonus_spent = V202
```

The next line incorrectly assigns:

```text
label var bonus_spent "Cash gifts received"
```

Table 5 inherits the wrong display label. The regression itself still uses `bonus_spent`, so the estimates are numerically correct but the column heading describes the wrong economic variable.

---

## Finding 2 — Main Table 5 bootstrap block is commented out

**Status:** Confirmed reproducibility issue.  
**Numerical effect using supplied bootstrap data:** None.

In `run_bootstrap.do`, the block that calls `hhsurvey_bootstrap`, performs 1,000 replications, and saves `boot_results.dta` is enclosed in a block comment.

Therefore, running `run_bootstrap.do` as distributed does **not** regenerate the main Table 5 bootstrap draws. The supplied `boot_results.dta` nevertheless contains the draws used in the final table and reproduces the published SEs.

---

## Finding 3 — $5,000 cutoff wording has no effect

**Status:** Wording/code discrepancy confirmed; numerical effect = zero.

The table says households are omitted if expenditure is **greater than $5,000**, while the Stata code uses:

```text
if tot_expen < 5000
```

The cleaned dataset contains:

- **0** observations with `tot_expen == 5000`;
- **64** observations with `tot_expen > 5000`.

Because nobody is exactly at $5,000, `< 5000` and `<= 5000` produce the same Table 5 sample. This discrepancy does not change any result.

---

## Finding 4 — Hard-coded author-specific paths

**Status:** Confirmed portability issue.  
**Numerical effect:** None once corrected.

The Stata do-files contain an author-specific Dropbox path. A new user must manually change the path before the original scripts will run. The R reproduction uses repository-relative paths instead.

---

## Important translation pitfall — default OLS SEs do not reproduce the paper

This is **not an error in the authors' code**, but it is an important potential replication error.

The point estimates come from OLS, but the paper reports bootstrap standard errors for the displayed post and interaction coefficients. A naive R translation using the default `lm()` standard errors changes inference.

For Table 5 column (1), the interaction is approximately:

- coefficient: **647.23**;
- default OLS SE: **280.08**, p ≈ **0.021**;
- published bootstrap SE: **379.44**, p ≈ **0.088** using a normal approximation.

So using default OLS standard errors would make the interaction appear significant at 5%, whereas the published bootstrap inference only supports approximately 10% significance.

---

## Checklist

- [x] Exact Table 5 source do-file identified
- [x] `urban_lprob.dta` obtained
- [x] Four OLS specifications independently translated
- [x] Published point estimates matched
- [x] Published N matched in all four columns
- [x] Published R² matched in all four columns
- [x] Saved bootstrap SEs independently reproduced
- [x] $5,000 cutoff discrepancy tested
- [x] Column (4) labeling error identified
- [x] Commented-out bootstrap block identified
- [x] Hard-coded path issue identified
- [ ] Optional: run a fresh 1,000-replication R bootstrap and compare its SEs with the authors' saved Stata draws

See `audit/verification_results.md` and `output/table5_verified_reference.csv` for the numerical verification output.
