#' Extract text from a single pdf document
#'
#' @export
#' @param path (character) Path to a file. required
#' @param ... args passed on to [pdftools::pdf_info()]
#' and [pdftools::pdf_text()] - any args are passed to
#' both of those function calls, which makes sense
#' @return An object of class `crm_pdf` with a slot for
#' `info` (pdf metadata essentially), and `text` (the extracted
#' text) - with an attribute (`path`) with the path to the pdf
#' on disk
#' @details We use \pkg{pdftools} under the hood to do pdf text
#' extraction
#' @examples
#' path <- system.file("examples", "MairChamberlain2014RJournal.pdf",
#'    package = "crminer")
#' (res <- crm_extract(path))
#' res$info
#' res$text
#' # with newlines, pretty print
#' cat(res$text)
#'
#' # another example
#' path <- system.file("examples", "ChamberlainEtal2013Ecosphere.pdf",
#'    package = "crminer")
#' (res <- crm_extract(path))
#' res$info
#' cat(res$text)
crm_extract <- function(path, ...) {
  path <- path.expand(path)
  if (!file.exists(path)) stop("path does not exist", call. = FALSE)
  structure(
    list(
      info = pdftools::pdf_info(path, ...),
      text = pdftools::pdf_text(path, ...)
    ),
    class = "crm_pdf",
    path = path
  )
}

#' @export
print.crm_pdf <- function(x, ...) {
  cat("<document>", attr(x, "path"), "\n", sep = "")
  cat("  Pages: ", x$info$pages, "\n", sep = "")
  cat("  No. characters: ", sum(nchar(x$text)), "\n", sep = "")
  cat("  Created: ", as.character(as.Date(x$info$created)), "\n",
      sep = "")
}
