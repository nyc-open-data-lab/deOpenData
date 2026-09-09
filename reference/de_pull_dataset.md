# Pull a Delaware Open Data dataset

Downloads a dataset from the Delaware Open Data Socrata API using either
a human-readable catalog \`key\` or the official Socrata dataset \`uid\`
returned by \[de_list_datasets()\].

## Usage

``` r
de_pull_dataset(
  dataset,
  limit = 10000,
  filters = list(),
  date = NULL,
  from = NULL,
  to = NULL,
  date_field = NULL,
  where = NULL,
  order = NULL,
  timeout_sec = 30,
  clean_names = TRUE,
  coerce_types = TRUE
)
```

## Arguments

- dataset:

  A single dataset \`key\` or Socrata dataset \`uid\` from
  \[de_list_datasets()\]. For example, a key may look like
  \`"recently_closed_bids"\`, while a UID may look like \`"yhim-4378"\`.

- limit:

  Number of rows to retrieve. Defaults to 10,000.

- filters:

  Optional named list of exact-match filters. Each list name should be a
  field name in the dataset, and each value should be the value or
  values to match. Vector values are translated into SQL-style \`IN\`
  conditions in the generated SoQL query. For example, \`filters =
  list(agencycode = c("AOA", "ARNG"))\` returns rows where
  \`agencycode\` is either \`"AOA"\` or \`"ARNG"\`.

- date:

  Optional single date used to match all records from that day. Requires
  \`date_field\`.

- from:

  Optional start date, inclusive. Requires \`date_field\`.

- to:

  Optional end date, exclusive. Requires \`date_field\`.

- date_field:

  Optional date or datetime column to use with \`date\`, \`from\`, or
  \`to\`. This must be supplied when any date filter is used. Users can
  identify available date columns by inspecting the dataset on the
  Delaware Open Data Portal or by pulling a small sample with \`limit\`.

- where:

  Optional raw SoQL \`WHERE\` clause for advanced filtering. SoQL is the
  Socrata Query Language used by Delaware Open Data. If \`date\`,
  \`from\`, or \`to\` are also supplied, their generated conditions are
  combined with \`where\` using \`AND\`.

- order:

  Optional raw SoQL \`ORDER BY\` clause, such as \`"DATE_FIELD DESC"\`.

- timeout_sec:

  Request timeout in seconds. Defaults to 30.

- clean_names:

  Logical. If \`TRUE\`, column names are converted to snake_case using
  \[janitor::clean_names()\]. Defaults to \`TRUE\`.

- coerce_types:

  Logical. If \`TRUE\`, the package attempts lightweight,
  heuristic-based type coercion after downloading the data. Columns are
  converted only when at least 95 percent of non-missing values can be
  parsed as the target type. This helps avoid unsafe conversions when
  source data are inconsistent.

## Value

A tibble containing rows from the requested Delaware Open Data dataset.

## Details

When a catalog \`key\` is supplied, \`de_pull_dataset()\` first
retrieves the live Delaware Open Data catalog to look up the
corresponding Socrata \`uid\`, then sends a second request to download
the dataset itself. Supplying a \`uid\` directly is more stable and
avoids ambiguity, while keys are provided for readability and
classroom-friendly workflows.

Dataset keys are generated from dataset names using
\[janitor::make_clean_names()\]. Because keys are derived from live
catalog metadata, Socrata UIDs are the most stable identifiers.

\`de_pull_dataset()\` is designed for common catalog-based workflows.
For arbitrary Socrata JSON endpoints that are not included in the
package catalog, use \[de_any_dataset()\].

The \`filters\` argument is intended for simple exact-match filtering.
For more complex conditions, use the \`where\` argument with raw SoQL
syntax.

Internally, filter field names are wrapped in \`TRIM()\` when
constructing SoQL queries to reduce mismatches caused by leading or
trailing whitespace in source data.

Type coercion is intentionally conservative. When \`coerce_types =
TRUE\`, the package attempts to infer common R column types from the API
response, but columns with inconsistent values may remain character
columns.

Datetime coercion is also conservative. Timezone offsets and sub-second
precision may not always be preserved during automatic parsing, and
columns with inconsistent datetime formats may remain character columns.

## Examples

``` r
if (interactive() && curl::has_internet()) {
  # Pull by human-readable key
  de_pull_dataset("recently_closed_bids", limit = 3)

  # Pull by Socrata UID
  de_pull_dataset("yhim-4378", limit = 3)

  # Filter to one value
  de_pull_dataset(
    "yhim-4378",
    limit = 3,
    filters = list(agencycode = "AOA")
  )

  # Filter to multiple values
  de_pull_dataset(
    "yhim-4378",
    limit = 10,
    filters = list(agencycode = c("AOA", "ARNG"))
  )

  # Date filtering
  de_pull_dataset(
    "yhim-4378",
    from = "2025-01-01",
    to = "2025-06-01",
    date_field = "opendate",
    limit = 100
  )

  # Advanced filtering with raw SoQL
  de_pull_dataset(
    "yhim-4378",
    where = "agencycode = 'HSS' AND unspsc = '8613'",
    order = "opendate DESC",
    limit = 100
  )
}
```
