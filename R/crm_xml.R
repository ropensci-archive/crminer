#' Get full text XML
#'
#' @export
#' @inheritParams crm_text
#' @details Note that this function is not vectorized. To do many requests
#' use a for/while loop or lapply family calls, or similar.
#'
#' Note that some links returned will not in fact lead you to full text
#' content as you would understandbly think and expect. That is, if you
#' use the `filter` parameter with e.g., [rcrossref::cr_works()]
#' and filter to only full text content, some links may actually give back
#' only metadata for an article. Elsevier is perhaps the worst offender,
#' for one because they have a lot of entries in Crossref TDM, but most
#' of the links that are apparently full text are not in facct full text,
#' but only metadata.
#'
#' Check out [auth] for details on authentication.
#' @examples \dontrun{
#' ## peerj
#' x <- crm_xml("https://peerj.com/articles/2356.xml")
#'
#' ## pensoft
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### xml
#' crm_xml(url=links)
#'
#' ## hindawi
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### xml
#' crm_xml(links)
#' }
crm_xml <- function(url, overwrite_unspecified = FALSE, ...) {
  UseMethod("crm_xml")
}

#' @export
crm_xml.default <- function(url, overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_xml' method for ", class(url), call. = FALSE)
}

#' @export
crm_xml.tdmurl <- function(url, overwrite_unspecified = FALSE, ...) {
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "xml")
  if (is.null(url$xml[[1]])) stop("no xml link found")
  getTEXT(url$xml[[1]], "xml", cr_auth(url, 'xml'), ...)
}

#' @export
crm_xml.list <- function(url, overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_xml' must be a list of tdmurl objects",
         call. = FALSE)
  }
  crm_xml(url$xml, overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_xml.character <- function(url, overwrite_unspecified = FALSE, ...) {
  crm_xml(as_tdmurl(url, "xml"),
          overwrite_unspecified = overwrite_unspecified, ...)
}
