#' Convert output matrix from classify to data frame or data.table
#'
#' @param x output from \code{\link{classify}}
#' @param ... ignored
#' @return data frame with:
#' \itemize{
#'   \item{first column named as "id" column specified as input
#'     to \code{\link{classify}} and with data from \code{row.names(x)}}
#'   \item{all columns from \code{classified}}
#'   \item{no row names}
#' }
#'
#' @export
#' @family classcodes
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