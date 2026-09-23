# Data required for the Hausman (2016) Table 5 replication

The repository does not commit the raw `.dta` files. Put the required files under:

```text
data/raw/
```

## 1. `urban_lprob.dta`

This is the cleaned 1936 household consumption survey + 1930 Census dataset used by the Table 5 regressions.

It is distributed separately through OpenICPSR project **100128**:

https://www.openicpsr.org/openicpsr/project/100128/version/V1/view

The file page reports 67,833 cases and 134 variables. Download `urban_lprob.dta` and save it as:

```text
data/raw/urban_lprob.dta
```

## 2. `boot_results.dta`

This file contains the authors' 1,000 saved bootstrap draws used for the Table 5 standard errors.

It is included in the official AER replication package, OpenICPSR project **231365**, at:

```text
Revised-Data-and-programs-for-AER/Stata/Data/boot_results.dta
```

Copy it to:

```text
data/raw/boot_results.dta
```

## Why the data are not committed here

The project uses repository-relative paths and keeps raw data out of version control so the GitHub repo remains lightweight and the source datasets remain tied to their official distribution pages and citations.

The AER replication deposit states that its code is distributed under a Modified BSD License and its databases/tables/text under CC BY 4.0. The separate `urban_lprob.dta` deposit should still be cited directly when used.
