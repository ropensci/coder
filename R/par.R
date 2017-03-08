#' Data from the Swedish Patient Register (PAR).
#'
#' Functions to check that a data set contains patient data from
#' the Swedish Patient Register (PAR).
#'
#' @param x,y objects with data from NPR
#' (possibly one object for in- and one for outpatient data)
#'
#' @return Object as described by \code{\link{as.codedata}}
#' @export
#' @name pardata
as.pardata <- function(x, y = NULL) {

  # Data can contain either diagnose data (ICD) or KVA
  nms      <- c("lpnr", "indatum")
  nms_dia  <- c("hdia", paste0("bdia", 1:15))
  nms_op   <- paste0("op", 1:30)
  names(x) <- tolower(names(x))
  if (!is.null(y)) names(y) <- tolower(names(y))

  nms_codes <-
    if (all(c(nms_dia, nms_op) %in% names(x))) {
      stop("Data sets contain both ICD and KVA codes!")
    } else if (all(c(nms, nms_dia) %in% names(x))) {
      message("NPR data with diagnose (ICD) codes.")
      nms_dia
    } else if (all(c(nms, nms_op) %in% names(x))) {
      message("NPR data with operation (KVA) codes.")
      nms_op
    } else {
      stop("Mandatory NPR column missing!")
    }

  x <- as.data.table(x[, c(nms, nms_codes)])
  if (!is.null(y))
    x <- rbind(x, as.data.table(y[, c(nms, nms_codes)]))

  # Make as codedata
  variable <- hdia <- code <-  NULL # silly workaround to avoid CHECK note
  x <-
    melt(
      x,
      measure.vars  = nms_codes,
      value.name    = "code"
    )[variable == "op1" | variable == "hdia" | code != "",
      hdia := as.character(variable) == "hdia"]
  setnames(x, c("lpnr", "indatum"), c("id", "date"))

  as.codedata(x)
}
