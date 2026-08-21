#' Pull any Delaware Open Data dataset from a Socrata JSON endpoint
#'
#' Downloads data from any Delaware Open Data Socrata JSON endpoint and returns
#' the result as a tibble. This function is useful for datasets that are not
#' included in the curated catalog returned by [de_list_datasets()].
#'
#' Delaware Open Data datasets have Socrata JSON endpoints that usually follow
#' this pattern:
#'
#' `https://data.delaware.gov/resource/<dataset_uid>.json`
#'
#' For example, a dataset with the Socrata UID `"yhim-4378"` would have the JSON
#' endpoint:
#'
#' `https://data.delaware.gov/resource/yhim-4378.json`
#'
#' Users can find a dataset's UID from the Delaware Open Data Portal URL, the API
#' documentation page for the dataset, or the output of [de_list_datasets()].
#'
#' @param json_link A single Socrata dataset JSON endpoint URL, such as
#'   `"https://data.delaware.gov/resource/yhim-4378.json"`.
#' @param limit Number of rows to retrieve. Defaults to 10,000.
#' @param timeout_sec Request timeout in seconds. Defaults to 30.
#' @param clean_names Logical. If `TRUE`, column names are converted to
#'   snake_case using [janitor::clean_names()]. Defaults to `TRUE`.
#' @param coerce_types Logical. If `TRUE`, the package attempts lightweight,
#'   heuristic-based type coercion after downloading the data. Columns are
#'   converted only when at least 95 percent of non-missing values can be parsed
#'   as the target type. This helps avoid unsafe conversions when source data are
#'   inconsistent.
#'
#' @return A tibble containing rows from the requested Delaware Open Data
#'   endpoint.
#'
#' @details
#' `de_any_dataset()` bypasses the package catalog and sends a request directly
#' to the supplied JSON endpoint. Unlike [de_pull_dataset()], it does not look
#' up defaults such as catalog keys, date fields, or default ordering.
#'
#' This function is intended for direct endpoint access. For catalog-based
#' workflows using readable keys or Socrata UIDs, use [de_pull_dataset()].
#'
#' @examples
#' # Examples that hit the live Delaware Open Data API are guarded so CRAN
#' # checks do not fail when the network is unavailable or slow.
#' if (interactive() && curl::has_internet()) {
#'   # Build a JSON endpoint from a Socrata UID
#'   uid <- "yhim-4378"
#'   endpoint <- paste0("https://data.delaware.gov/resource/", uid, ".json")
#'
#'   out <- try(de_any_dataset(endpoint, limit = 3), silent = TRUE)
#'   if (!inherits(out, "try-error")) {
#'     head(out)
#'   }
#' }
#'
#' @export
de_any_dataset <- function(json_link,
                             limit = 10000,
                             timeout_sec = 30,
                             clean_names = TRUE,
                             coerce_types = TRUE) {

  if (!is.character(json_link) || length(json_link) != 1 || is.na(json_link)) {
    stop("`json_link` must be a single, non-missing character URL.", call. = FALSE)
  }

  if (!grepl("\\.json($|\\?)", json_link)) {
    stop(
      "`json_link` must be a Socrata JSON endpoint ending in .json.",
      call. = FALSE
    )
  }

  limit <- .de_validate_limit(limit)
  timeout_sec <- .de_validate_timeout(timeout_sec)

  query_list <- list("$limit" = limit)

  data <- .de_get_json(
    json_link,
    query_list,
    timeout_sec = timeout_sec
  )

  out <- tibble::as_tibble(data, .name_repair = "minimal")

  # Optional post-processing pipeline
  out <- .de_postprocess(
    out,
    clean_names = clean_names,
    coerce_types = coerce_types
  )

  out
}
