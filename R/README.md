
# deOpenData

[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/grand-total/deOpenData?color=blue)](https://r-pkg.org/pkg/deOpenData)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

`deOpenData` provides a lightweight R interface to the [Delaware Open
Data Portal](https://data.delaware.gov/).

The package allows users to search, filter, and download datasets from
the Delaware Open Data Portal directly into R without manually
constructing API queries, handling JSON responses, or performing type
conversion.

Designed for students, educators, researchers, journalists, civic
technologists, and analysts, `deOpenData` reduces the technical overhead
required to begin working with municipal Open Data while preserving
access to the underlying Socrata infrastructure.

------------------------------------------------------------------------

## How `deOpenData` Works

The package provides a streamlined interface to the Delaware Open Data
Portal’s Socrata API.

Internally, `deOpenData`:

- retrieves metadata from the live Delaware Open Data catalog
- constructs parameterized HTTP requests
- downloads JSON responses from Socrata endpoints
- converts results into tidy tibble outputs
- optionally cleans column names
- optionally performs conservative type coercion

Most workflows begin with `de_list_datasets()`, which retrieves a live
catalog of datasets available through the Delaware Open Data Portal.

Datasets can then be downloaded using either:

- a human-readable catalog `key`
- the official Socrata dataset UID, such as `"yhim-4378"`

The human-readable key is designed to improve readability and usability,
while the UID is the stable identifier used by the Socrata platform.

## Core Functions

The package provides three primary functions:

- `de_list_datasets()` retrieves a live catalog of available Delaware
  Open Data datasets, including human-readable keys, Socrata UIDs,
  names, and other available metadata.

- `de_pull_dataset()` downloads cataloged datasets using either a
  human-readable key or Socrata UID, with support for filtering,
  ordering, date ranges, optional column-name cleaning, and optional
  type coercion.

- `de_any_dataset()` downloads data directly from a valid Socrata JSON
  endpoint without requiring the dataset to appear in the package
  catalog.

Datasets retrieved through `de_pull_dataset()` support arguments
including:

- `limit`
- `filters`
- `date`
- `from`
- `to`
- `date_field`
- `where`
- `order`
- `clean_names`
- `coerce_types`

All functions return tibble outputs.

Advanced users may also provide raw SoQL conditions through the `where`
argument.

SoQL, or Socrata Query Language, is the query syntax used by
Socrata-powered Open Data portals. Additional information is available
from the [Socrata developer
documentation](https://dev.socrata.com/docs/queries/).

------------------------------------------------------------------------

## Installation

### Install from CRAN

``` r
install.packages("deOpenData")
```

### Install the development version from GitHub

``` r
# install.packages("pak")
pak::pak("gomes-sh/deOpenData")
```

Alternatively:

``` r
# install.packages("remotes")
remotes::install_github("gomes-sh/deOpenData")
```

------------------------------------------------------------------------

## Example

``` text
library(deOpenData)
library(dplyr)

# Browse available datasets
catalog <- de_list_datasets()

# Search for datasets containing a keyword
catalog |>
  filter(grepl("bid", name, ignore.case = TRUE)) |>
  select(key, uid, name)

# Pull a dataset using its UID
example_data <- de_pull_dataset(
  dataset = "yhim-4378",
  limit = 100
)

# Pull the same dataset using its catalog key
example_data_by_key <- de_pull_dataset(
  dataset = "recently_closed_bids",
  limit = 100
)

# Pull filtered data
filtered_data <- de_pull_dataset(
  dataset = "yhim-4378",
  limit = 100,
  filters = list(
    agencycode = "AOA"
  )
)
```

The `filters` argument accepts a named list and automatically constructs
the corresponding SoQL filtering conditions.

Multiple values may be supplied for one field:

``` text
filtered_data <- de_pull_dataset(
  dataset = "yhim-4378",
  limit = 100,
  filters = list(
    agencycode = c("AOA", "ARNG")
  )
)
```

Multiple fields may also be combined:

``` text
filtered_data <- de_pull_dataset(
  dataset = "yhim-4378",
  limit = 100,
  filters = list(
    agencycode = "ARNG",
    unspsc = "7212"
  )
)
```

Date filtering is available for datasets containing date or datetime
fields:

``` text
date_filtered_data <- de_pull_dataset(
  dataset = "yhim-4378",
  from = "2025-01-01",
  to = "2025-06-01",
  date_field = "opendate",
  limit = 100
)
```

------------------------------------------------------------------------

## Accessing Any Socrata Endpoint

When a dataset is not available through `de_list_datasets()`, it can be
downloaded directly using `de_any_dataset()`.

``` text
endpoint_data <- de_any_dataset(
  json_link = "https://data.delaware.gov/resource/yhim-4378.json",
  limit = 100
)
```

Use `de_pull_dataset()` for catalog-based workflows and
`de_any_dataset()` when working directly with a Socrata JSON endpoint.

------------------------------------------------------------------------

## Learn by Example

A complete introductory workflow is available in the package vignette:

``` r
vignette("getting-started", package = "deOpenData")
```

The vignette demonstrates how to:

- browse the dataset catalog
- download data using a key or UID
- filter records
- work with date ranges
- access direct JSON endpoints
- perform a simple analysis

------------------------------------------------------------------------

## Package Website

Complete documentation is available on the package website:

<https://github.com/gomes-sh/deOpenData>

The website includes:

- function reference pages
- installation instructions
- introductory articles
- vignettes
- release notes

------------------------------------------------------------------------

## Development

To run the package tests locally:

``` r
devtools::test()
```

To rebuild the documentation:

``` r
devtools::document()
```

To run a complete package check:

``` r
devtools::check()
```

To rebuild the pkgdown website:

``` r
pkgdown::build_site()
```

------------------------------------------------------------------------

## Contributing

Contributions are welcome.

To report a bug, request a feature, or suggest an improvement, open an
issue on GitHub:

<https://github.com/gomes-sh/deOpenData/issues>

Pull requests are also welcome. Before submitting a pull request, please
ensure that:

- package documentation has been regenerated
- automated tests pass
- `devtools::check()` completes successfully
- new behavior is documented and tested

------------------------------------------------------------------------

## Author

**Shelby Lyn Gomes**

Email: <gomessh@mailbox.org>  
GitHub: [@gomes-sh](https://github.com/gomes-sh)

------------------------------------------------------------------------

## Maintenance

Because the package retrieves metadata dynamically from the live
Delaware Open Data catalog, newly published datasets may become
available without requiring a package update.

Package updates may still be required when the portal changes its
catalog structure, dataset metadata fields, or API behavior.

------------------------------------------------------------------------

## Disclaimer

`deOpenData` is an independent project and is not affiliated with,
endorsed by, or maintained by Delaware or the organization responsible
for the Delaware Open Data Portal.
