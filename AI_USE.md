# AI use and verification

This project used AI as a coding and auditing assistant, consistent with the class exercise.

## How AI was used

AI assisted with:

- locating and tracing the relevant replication files;
- identifying which Stata code generates Table 5;
- translating the Stata regression specifications into R;
- interpreting Stata factor-variable syntax such as `i.mid#i.race` and `i.mid#c.age`;
- identifying the bootstrap design and translating it into R;
- comparing the R output with the authors' generated Stata table;
- searching the original code for coding, labeling, portability, and sample-definition issues;
- proposing tests to determine whether those issues changed the numerical results.

## What was independently checked

AI-generated code and interpretations were not accepted without verification. The project checks them against the original replication files and data:

- all Table 5 point estimates were recalculated from `urban_lprob.dta`;
- N and R² were compared with the authors' generated `tot_expen.tex`;
- all eight reported bootstrap standard errors were recalculated from the supplied 1,000 bootstrap draws in `boot_results.dta`;
- the suspected `$5,000` cutoff discrepancy was tested directly in the data;
- the column (4) labeling issue was verified against the original data-construction Stata code;
- the commented-out bootstrap block was verified directly in `run_bootstrap.do`.

## Limitations

The independent R bootstrap implementation in `R/03_full_bootstrap.R` has been translated from the authors' Stata procedure, but the core reproduction does not depend on a new random bootstrap run because the exact 1,000 draws used to produce the published table are supplied by the authors. A fresh run would be an additional robustness exercise and would not be expected to reproduce the exact same draws because R and Stata use different random-number generators.

## Principle

AI was used to accelerate code translation and debugging. Claims about the paper and its code were verified against the original source files, data, and reproduced numerical results rather than relying on AI output alone.
