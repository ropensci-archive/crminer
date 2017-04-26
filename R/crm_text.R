#' Get full text
#'
#' @export
#' @param url A URL (character) or an object of class `tdmurl` from a call
#' to [crm_links()]. If you'll be getting text from the publishers are use
#' Crossref TDM (which requires authentication), we strongly recommend
#' using [crm_links()] first and passing output of that here, as [crm_links()]
#' grabs the publisher Crossref member ID, which we use to do authentication
#' and other publisher specific fixes to URLs
#' @param type (character) One of 'xml' (default), 'html', 'plain', 'pdf',
#' 'unspecified'
#' @param path (character) Path to store pdfs in. By default we use
#' `paste0(rappdirs::user_cache_dir(), "/crminer")`, but you can
#' set this directory to something different. Ignored unless getting
#' pdf
#' @param overwrite (logical) Overwrite file if it exists already?
#' Default: `TRUE`
#' @param read (logical) If reading a pdf, this toggles whether we extract
#' text from the pdf or simply download. If `TRUE`, you get the text from
#' the pdf back. If `FALSE`, you only get back the metadata.
#' Default: `TRUE`
#' @param cache (logical) Use cached files or not. All files are written to
#' your machine locally, so this doesn't affect that. This only states whether
#' you want to use cached version so that you don't have to download the file
#' again. The steps of extracting and reading into R still have to be performed
#' when `cache=TRUE`. Default: `TRUE`
#' @param overwrite_unspecified (logical) Sometimes the crossref API returns
#' mime type 'unspecified' for the full text links (for some Wiley dois
#' for example). This parameter overrides the mime type to be `type`.
#' @param ... Named curl parameters passed on to [crul::HttpClient()], see
#' `?curl::curl_options` for available curl options
#' @template deets
#'
#' @examples \dontrun{
#' ## pensoft
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### xml
#' crm_text(url=links, type='xml')
#' ### pdf
#' crm_text(url=links, type="pdf", read = FALSE)
#' crm_text(links, "pdf")
#'
#' ## hindawi
#' data(dois_pensoft)
#' (links <- crm_links(dois_pensoft[1], "all"))
#' ### xml
#' crm_text(links, 'xml')
#' ### pdf
#' crm_text(links, "pdf", read=FALSE)
#' crm_text(links, "pdf")
#'
#' ## DOIs w/ full text, and with CC-BY 3.0 license
#' data(dois_crminer_ccby3)
#' (links <- crm_links(dois_crminer_ccby3[40], "all"))
#' # crm_text(links, 'pdf')
#'
#' ## You can use crm_xml, crm_plain, and crm_pdf to go directly to
#' ## that format
#' (links <- crm_links(dois_crminer_ccby3[5], "all"))
#' crm_xml(links)
#'
#' ### Caching, for PDFs
#' if (requireNamespace("rcrossref")) {
#'   library("rcrossref")
#'   out <- cr_members(2258, filter=c(has_full_text = TRUE), works = TRUE)
#'   # (links <- crm_links(out$data$DOI[10], "all"))
#'   # crm_text(links, type = "pdf", cache=FALSE)
#'   # system.time( cacheyes <- crm_text(links, type = "pdf", cache=TRUE) )
#'   ### second time should be faster
#'   # system.time( cacheyes <- crm_text(links, type = "pdf", cache=TRUE) )
#'   # system.time( cacheno <- crm_text(links, type = "pdf", cache=FALSE) )
#'   # identical(cacheyes, cacheno)
#' }
#'
#' ## elsevier
#' ## requires authentication
#' ### load some Elsevier DOIs
#' data(dois_elsevier)
#'
#' ## set key first - OR set globally - See ?auth
#' # Sys.setenv(CROSSREF_TDM_ELSEVIER = "your-key")
#' ## XML
#' link <- crm_links("10.1016/j.funeco.2010.11.003", "xml")
#' # res <- crm_text(url = link, type = "xml")
#' ## plain text
#' link <- crm_links("10.1016/j.funeco.2010.11.003", "plain")
#' # res <- crm_text(url = link, "plain")
#'
#' ## Wiley
#' ## requires authentication
#' ### load some Wiley DOIs
#' data(dois_wiley)
#'
#' ## set key first - OR set globally - See ?auth
#' # Sys.setenv(CROSSREF_TDM = "your-key")
#'
#' ### all wiley
#' tmp <- crm_links("10.1111/apt.13556", "all")
#' # crm_text(url = tmp, type = "pdf", cache=FALSE,
#' #   overwrite_unspecified = TRUE)
#'
#' #### older dates for Wiley
#' # tmp <- crm_links(dois_wiley$set2[1], "all")
#' # crm_text(tmp, type = "pdf", cache=FALSE,
#' #    overwrite_unspecified=TRUE)
#'
#' ### Wiley paper with CC By 4.0 license
#' # tmp <- crm_links("10.1113/jp272944", "all")
#' # crm_text(tmp, type = "pdf", cache=FALSE)
#' }
crm_text <- function(url, type = 'xml', path = cr_cache_path(),
                     overwrite = TRUE, read = TRUE, cache = FALSE,
                     overwrite_unspecified = FALSE, ...) {
  UseMethod("crm_text")
}

#' @export
crm_text.default <- function(url, type = 'xml', path = cr_cache_path(),
                             overwrite = TRUE, read = TRUE, cache = FALSE,
                             overwrite_unspecified = FALSE, ...) {
  stop("no 'crm_text' method for ", class(url), call. = FALSE)
}

#' @export
crm_text.tdmurl <- function(url, type = 'xml', path = cr_cache_path(),
                            overwrite = TRUE, read = TRUE, cache = FALSE,
                            overwrite_unspecified = FALSE, ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, type)
  auth <- cr_auth(url, type)
  switch(
    pick_type(type, url),
    xml = getTEXT(get_url(url, 'xml'), type, auth),
    plain = getTEXT(get_url(url, 'xml'), type, auth, ...),
    html = getTEXT(get_url(url, 'html'), type, auth, ...),
    pdf = getPDF(url = get_url(url, 'pdf'), path, auth, overwrite, type,
                 read, cache, ...)
  )
}

#' @export
crm_text.list <- function(url, type = 'xml', path = cr_cache_path(),
                         overwrite = TRUE, read = TRUE, cache = FALSE,
                         overwrite_unspecified = FALSE, ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_text' must be a list of tdmurl objects",
         call. = FALSE)
  }
  if (!type %in% c("xml", "plain", "html", "pdf")) {
    stop("'type' must be one of xml, plain, html, or pdf")
  }
  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, type)
  if (is.null(url[[type]])) stop('no links for type ', type)
  crm_text(url[[type]], type = type, path = path, overwrite = overwrite,
           read = read, cache = cache,
           overwrite_unspecified = overwrite_unspecified, ...)
}
