#' Get full plain text
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
#' link <- crm_links("10.7717/peerj.1545", "html")
#' crm_html(link)
#'
#' link <- crm_links("10.7717/peerj.1545")
#' crm_html(link)
#'
#' crm_html("https://peerj.com/articles/1545.html")
#' }
crm_html <- function(url, overwrite_unspecified=FALSE, ...) {
  UseMethod("crm_html")
}

#' @export
crm_html.default <- function(url, overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_html' method for ", class(url), call. = FALSE)
}

#' @export
crm_html.tdmurl <- function(url, overwrite_unspecified = FALSE, ...) {
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "html")
  if (is.null(url$html[[1]])) {
    stop("no html text link found", call. = FALSE)
  }
  getTEXT(url$html[[1]], "html", cr_auth(url, 'html'), ...)
}

#' @export
crm_html.list <- function(url, overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_html' must be a list of tdmurl objects",
         call. = FALSE)
  }
  crm_html(url$html, overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_html.character <- function(url, overwrite_unspecified = FALSE, ...) {
  crm_html(as_tdmurl(url, "html"),
           overwrite_unspecified = overwrite_unspecified, ...)
}
