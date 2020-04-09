#' Make keyvalue object from classcodes object
#'
#' @param x classcodes object
#' @inheritParams summary.classcodes
#' @param ... arguments passed to \code{\link{summary.classcodes}}
#'
#' @importFrom decoder as.keyvalue
#' @export
as.keyvalue.classcodes <- function(x, coding, ...) {
  decoder::as.keyvalue(summary(x, coding, ...)$codes_vct)
}
