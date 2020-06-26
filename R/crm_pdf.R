#' Get full text PDFs
#'
#' @export
#' @inheritParams crm_text
#' @inheritSection crm_text Notes
#' @inheritSection crm_text User-agent
#' @inheritSection crm_text Elsevier-partial
#' @inheritSection crm_text Caching
#' @examples \dontrun{
#' # set a temp dir. cache path
#' crm_cache$cache_path_set(path = "crminer", type = "tempdir")
#' ## you can set the entire path directly via the `full_path` arg
#' ## like crm_cache$cache_path_set(full_path = "your/path")
#'
#' ## peerj
#' x <- crm_pdf("https://peerj.com/articles/6840.pdf")
#'
#' ## pensoft
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[10], "all"))
#' crm_pdf(links)
#'
#' ## hindawi
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[12], "all"))
#' ### pdf
#' crm_pdf(links, read=FALSE)
#' crm_pdf(links)
#' }
crm_pdf <- function(url, overwrite = TRUE, read = TRUE,
                    overwrite_unspecified = FALSE, ...) {
  UseMethod("crm_pdf")
}

#' @export
crm_pdf.default <- function(url, overwrite = TRUE, read = TRUE,
                            overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_pdf' method for ", class(url), call. = FALSE)
}

#' @export
crm_pdf.tdmurl <- function(url, overwrite = TRUE, read = TRUE,
                           overwrite_unspecified = FALSE, ...) {

  assert(overwrite, "logical")
  assert(read, "logical")
  assert(overwrite_unspecified, "logical")

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  if (is.null(url$pdf[[1]])) {
    stop("no pdf link found", call. = FALSE)
  }
  getPDF(url$pdf[[1]], cr_auth(url, 'pdf'), overwrite, "pdf",
         read, attr(url, "doi"), ...)
}

#' @export
crm_pdf.list <- function(url, overwrite = TRUE, read = TRUE,
                         overwrite_unspecified = FALSE, ...) {

  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_pdf' must be a list of tdmurl objects",
         call. = FALSE)
  }
  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  crm_pdf(url$pdf, overwrite = overwrite, read = read,
          overwrite_unspecified = overwrite_unspecified, ...)
}

#' @export
crm_pdf.character <- function(url, overwrite = TRUE, read = TRUE,
                              overwrite_unspecified = FALSE, ...) {

  crm_pdf(as_tdmurl(url, "pdf"), overwrite = overwrite, read = read,
          overwrite_unspecified = overwrite_unspecified, ...)
}
