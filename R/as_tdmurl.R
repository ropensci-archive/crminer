#' Coerce a url to a tdmurl with a specific type
#'
#' A tmd url is just a URL with some attributes to make it easier
#' to handle within other functions in this package.
#'
#' @export
#' @param url (character) A URL.
#' @param type (character) One of 'xml' (default), 'html', 'plain', 'pdf',
#' 'unspecified', or 'all'
#' @param doi (character) A DOI, optional, default: \code{NULL}
#' @examples
#' as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.xml",
#'    "xml")
#' as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.pdf",
#'    "pdf")
#' out <-
#'  as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.pdf",
#'    "pdf", "10.1155/2014/201717")
#' attributes(out)
#' identical(attr(out, "type"), "pdf")
as_tdmurl <- function(url, type, doi) UseMethod("as_tdmurl")

#' @export
#' @rdname as_tdmurl
as_tdmurl.tdmurl <- function(url, type, doi) url

#' @export
#' @rdname as_tdmurl
as_tdmurl.character <- function(url, type, doi=NULL) {
  makeurl(check_url(url), type, doi, NULL)
}

#' @export
print.tdmurl <- function(x, ...) {
  cat("<url> ", x[[1]], "\n", sep = "")
}

makeurl <- function(x, y, z, member) {
  # x <- structure(x, class = "tdmurl", type = match_type(y), doi = z)
  # stats::setNames(list(x), match_type(y))
  structure(stats::setNames(list(x), match_type(y)),
            class = "tdmurl", type = match_type(y), doi = z,
            member = member)
}

check_url <- function(x) {
  if (!grepl("https?://", x)) stop("Not a proper url") else x
}

match_type <- function(x) {
  match.arg(x, c("xml","html","plain","pdf","unspecified","all"))
}
