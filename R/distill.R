
#' Title
#'
#' @param x data.frame with at least two columns, one with case (patient)
#' identification (column name specified by argument \code{id}) and one with a
#' date of interest (column name specified by argument \code{date})
#' @param y object of class \code{\link{codedata}}
#' @param id name of column in \code{x} containing case (patient) identification
#' @param date name of column in \code{x} date of interest
#' @param years number of years before \code{date} during which codes from
#' \code{y} are valid
#'
#' @return Object of class \code{tbl_df} with rows from \code{x} compatible
#' with \code{y} and an additional attribute "id" specifynig the name of the id
#' column (as specified by argument \code{id})
#' @export
#'
#' @examples
#' distill(ex_people, ex_icd10, id = "name", date = "surgery")
distill <- function(x, y, id = "id", date, years = 1, keep_names = FALSE) {

  stopifnot(
    is.data.frame(x),
    all(c(id, date) %in% names(x)),
    is.codedata(y),
    is.numeric(years),
    years > 0
  )

  # Need factor to be compatible for left_join
  x[id] <- as.factor(x[[id]])

  # Prefilter to increase speed (faster than left_join)
  y <- y[fastmatch::fmatch(y$id, x[[id]], 0) > 0, ]

  res <-
    suppressWarnings(
      dplyr::rename_(x, id = id, xdate = date) %>%
      dplyr::mutate_(
        xdate = ~as.Date(xdate)
      ) %>%
        dplyr::left_join(y, by = "id") %>%
      dplyr::filter(
        xdate < date + 365 * years
      )
    )

  # Get back to original column names of x
  nr <- names(res)
  nr[nr == "id"]    <- id
  nr[nr == "date"]  <- "code_date"
  nr[nr == "xdate"] <- date
  names(res) <- nr

  attr(res, "id") <- id
  res
}