# ECON 494 Replication — Hausman (2016)

## Paper

Joshua K. Hausman (2016), **“Fiscal Policy and Economic Recovery: The Case of the 1936 Veterans' Bonus.”**  
*American Economic Review*, 106(4), 1100–1143.  
DOI: 10.1257/aer.20130957

Official article: https://www.aeaweb.org/articles?id=10.1257/aer.20130957

Official replication package: https://www.openicpsr.org/openicpsr/project/231365/version/V1/view

## Assignment goal

Reproduce a main table from the paper in a programming language different from the authors' original implementation, then audit the original code for coding choices or errors and evaluate whether they affect the results.

The original replication materials use **Stata**. This repository will reproduce the analysis in **R**.

## Target result

### Table 5 — Total Expenditure and Saving Regressions

Table 5 contains the paper's main household-level spending result. The replication will identify the exact Stata files and data used for the table, translate the full workflow into R, and compare the reproduced estimates against the published results.

The main objective is to match the published coefficients, standard errors, sample sizes, and specification choices as closely as possible in R.

## Repository structure

```text
econ_494_repo_1/
├── README.md
├── .gitignore
├── R/
│   ├── 00_setup.R
│   ├── 01_inventory_replication_files.R
│   └── 02_reproduce_table5.R
├── data/
│   └── README.md
├── original/
│   └── README.md
├── output/
│   └── .gitkeep
└── audit/
    └── audit_log.md
```

## Workflow

### 1. Download the official replication package

Download the replication materials from the official AEA/openICPSR page.

Do **not** commit the raw replication data to GitHub unless its license explicitly permits redistribution.

Place the downloaded files locally under:

```text
data/raw/
original/stata/
```

These folders are ignored by Git.

### 2. Inventory the original files

Run:

```r
source("R/00_setup.R")
source("R/01_inventory_replication_files.R")
```

This creates a file inventory in `output/` so the exact Stata scripts and datasets used to generate Table 5 can be identified.

### 3. Translate Table 5 into R

`R/02_reproduce_table5.R` is the workspace for the independent R translation.

The R implementation should match:

- sample restrictions;
- variable construction;
- first-stage estimation;
- generated veteran probabilities;
- second-stage controls;
- interaction terms;
- outlier cutoffs;
- bootstrap procedure;
- clustering level;
- coefficient definitions;
- reported standard errors.

### 4. Audit the original implementation

Document every issue investigated in:

```text
audit/audit_log.md
```

For each potential issue record:

1. Original Stata code.
2. What the code is intended to do.
3. R translation.
4. Whether results match.
5. Any suspected error or ambiguous choice.
6. Corrected implementation, if applicable.
7. Effect on coefficients, standard errors, significance, or sample size.

## Audit checklist

Potential sources of differences include:

- Missing-value handling.
- Exact sample restrictions.
- Outlier thresholds.
- First-stage versus second-stage samples.
- Construction of the post-bonus indicator.
- Construction of interaction terms.
- Geographic controls and fixed effects.
- Bootstrap resampling unit.
- City-level clustering.
- Number of bootstrap replications.
- Weighting.
- Duplicate observations.
- Merge behavior.
- Stata-specific defaults that differ from R defaults.

## Reproducibility standard

A successful reproduction should report, for each Table 5 column:

| Statistic | Published | R reproduction | Difference |
|---|---:|---:|---:|
| Post-bonus coefficient | | | |
| Post-bonus SE | | | |
| Interaction coefficient | | | |
| Interaction SE | | | |
| N | | | |
| R² | | | |

Small numerical differences caused only by random bootstrap seeds should be documented rather than automatically treated as coding errors.

## Citation

Hausman, Joshua K. 2016. “Fiscal Policy and Economic Recovery: The Case of the 1936 Veterans' Bonus.” *American Economic Review* 106(4): 1100–1143. https://doi.org/10.1257/aer.20130957
