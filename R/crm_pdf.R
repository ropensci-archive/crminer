#' Get full text PDFs
#'
#' @export
#' @inheritParams crm_text
#' @template deets
#' @examples \dontrun{
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
crm_pdf <- function(url, path = cr_cache_path(), overwrite = TRUE, read = TRUE,
                    cache = FALSE, overwrite_unspecified = FALSE, ...) {
  UseMethod("crm_pdf")
}

#' @export
crm_pdf.default <- function(url, path = cr_cache_path(), overwrite = TRUE,
                            read = TRUE, cache = FALSE,
                            overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_pdf' method for ", class(url), call. = FALSE)
}

#' @export
crm_pdf.tdmurl <- function(url, path = cr_cache_path(), overwrite = TRUE,
                           read = TRUE, cache = FALSE,
                           overwrite_unspecified = FALSE, ...) {

  assert(path, "character")
  assert(overwrite, "logical")
  assert(read, "logical")
  assert(cache, "logical")
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  if (is.null(url$pdf[[1]])) {
    stop("no pdf link found", call. = FALSE)
  }
  getPDF(url$pdf[[1]], path, cr_auth(url, 'pdf'), overwrite, "pdf",
         read, cache, ...)
}

#' @export
crm_pdf.list <- function(url, path = cr_cache_path(), overwrite = TRUE,
                         read = TRUE, cache = FALSE,
                         overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_pdf' must be a list of tdmurl objects",
         call. = FALSE)
  }
  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  crm_pdf(url$pdf, path = path, overwrite = overwrite, read = read,
          cache = cache, overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_pdf.character <- function(url, path = cr_cache_path(), overwrite = TRUE,
                              read = TRUE, cache = FALSE,
                              overwrite_unspecified = FALSE, ...) {
  crm_pdf(as_tdmurl(url, "pdf"), path = path, overwrite = overwrite,
          read = read, cache = cache,
          overwrite_unspecified = overwrite_unspecified, ...)
}
