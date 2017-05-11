#' Convert output from classify to data frame or data.table
#'
#' Output from \code{\link{classify}} is given as a matrix.
#' It is often convenient co convert this matrix to a data frame or data.table
#'  with
#' a separate column for id instead of row names since this fits better with
#' the philosophy of "tidyverse". The data frame format is however less optimal
#' for working with large data sets, wherefore matrix output is used as default.
#'
#' @param x output from \code{\link{classify}}
#' (technically an object of internal class "classified")
#'
#' @param ... ignored
#' @return data frame with:
#' \itemize{
#'   \item{first column named as "id" column specified as input
#'     to \code{\link{classify}} and with data from \code{row.names(x)}}
#'   \item{all columns from \code{x}}
#'   \item{no row names}
#' }
#'
#' @export
as.data.frame.classified <- function(x, ...) {
  y            <- NextMethod()
  id           <- attr(x, "id")
  y[[id]]      <- row.names(x)
  row.names(y) <- NULL
  y            <- y[, c(id, setdiff(names(y), id))]
  attr(y, "classcodes") <- attr(x, "classcodes")
  y
}

#' @export
#' @rdname as.data.frame.classified
as.data.table.classified <- function(x, ...) {
  structure(
    as.data.table(as.data.frame(x, ...)),
    classcodes = attr(x, "classcodes")
  )
}