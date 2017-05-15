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
#' link <- crm_links("10.1016/j.physletb.2010.10.049", "plain")
#' crm_plain(link)
#'
#' # another eg, which requires Crossref TDM authentication, see ?auth
#' link <- crm_links("10.1016/j.funeco.2010.11.003", "plain")
#' # crm_plain(link)
#' }
crm_plain <- function(url, overwrite_unspecified=FALSE, ...) {
  UseMethod("crm_plain")
}

#' @export
crm_plain.default <- function(url, overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_plain' method for ", class(url), call. = FALSE)
}

#' @export
crm_plain.tdmurl <- function(url, overwrite_unspecified = FALSE, ...) {
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "plain")
  if (is.null(url$plain[[1]])) {
    stop("no plain text link found", call. = FALSE)
  }
  getTEXT(url$plain[[1]], "plain", cr_auth(url, 'plain'), ...)
}

#' @export
crm_plain.list <- function(url, overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_plain' must be a list of tdmurl objects",
         call. = FALSE)
  }
  crm_plain(url$plain, overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_plain.character <- function(url, overwrite_unspecified = FALSE, ...) {
  crm_plain(as_tdmurl(url, "plain"),
            overwrite_unspecified = overwrite_unspecified, ...)
}
