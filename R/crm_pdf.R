#' Get full text PDFs
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
#'
#' @section Caching:
#' By default we use
#' `paste0(rappdirs::user_cache_dir(), "/crminer")`, but you can
#' set this directory to something different. Ignored unless getting
#' pdf. See [crm_cache] for caching details.
#' @examples \dontrun{
#' # set a temp dir. cache path
#' crm_cache$cache_path_set(path = "crminer", type = "tempdir")
#' ## you can set the entire path directly via the `full_path` arg
#' ## like crm_cache$cache_path_set(full_path = "your/path")
#'
#' ## peerj
#' x <- crm_pdf("https://peerj.com/articles/2356.pdf")
#'
#' ## pensoft
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### pdf
#' crm_text(url=links, type="pdf", read = FALSE)
#' crm_text(links, "pdf")
#'
#' ## hindawi
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### pdf
#' crm_text(links, "pdf", read=FALSE)
#' crm_text(links, "pdf")
#'
#' ### Caching, for PDFs
#' # out <- cr_members(2258, filter=c(has_full_text = TRUE), works = TRUE)
#' # (links <- crm_links(out$data$DOI[10], "all"))
#' # crm_text(links, type = "pdf", cache=FALSE)
#' # system.time( cacheyes <- crm_text(links, type = "pdf", cache=TRUE) )
#' ### second time should be faster
#' # system.time( cacheyes <- crm_text(links, type = "pdf", cache=TRUE) )
#' # system.time( cacheno <- crm_text(links, type = "pdf", cache=FALSE) )
#' # identical(cacheyes, cacheno)
#' }
crm_pdf <- function(url, overwrite = TRUE, read = TRUE,
                    cache = FALSE, overwrite_unspecified = FALSE, ...) {
  UseMethod("crm_pdf")
}

#' @export
crm_pdf.default <- function(url, overwrite = TRUE, read = TRUE, cache = FALSE,
                            overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_pdf' method for ", class(url), call. = FALSE)
}

#' @export
crm_pdf.tdmurl <- function(url, overwrite = TRUE, read = TRUE, cache = FALSE,
                           overwrite_unspecified = FALSE, ...) {

  assert(overwrite, "logical")
  assert(read, "logical")
  assert(cache, "logical")
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  if (is.null(url$pdf[[1]])) {
    stop("no pdf link found", call. = FALSE)
  }
  # getPDF(url, cr_auth(url, 'pdf'), overwrite, "pdf",
  getPDF(url$pdf[[1]], cr_auth(url, 'pdf'), overwrite, "pdf",
         read, attr(url, "doi"), cache, ...)
}

#' @export
crm_pdf.list <- function(url, overwrite = TRUE, read = TRUE, cache = FALSE,
                         overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_pdf' must be a list of tdmurl objects",
         call. = FALSE)
  }
  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  crm_pdf(url$pdf, overwrite = overwrite, read = read,
          cache = cache, overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_pdf.character <- function(url, overwrite = TRUE, read = TRUE, cache = FALSE,
                              overwrite_unspecified = FALSE, ...) {
  crm_pdf(as_tdmurl(url, "pdf"), overwrite = overwrite, read = read,
          cache = cache, overwrite_unspecified = overwrite_unspecified, ...)
}
