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
#' @param overwrite (logical) Overwrite file if it exists already?
#' Default: `TRUE`
#' @param read (logical) If reading a pdf, this toggles whether we extract
#' text from the pdf or simply download. If `TRUE`, you get the text from
#' the pdf back. If `FALSE`, you only get back the metadata.
#' Default: `TRUE`
#' @param overwrite_unspecified (logical) Sometimes the crossref API returns
#' mime type 'unspecified' for the full text links (for some Wiley dois
#' for example). This parameter overrides the mime type to be `type`.
#' @param try_ocr (logical) whether to try extracting OCRed
#' pages with `pdftools::pdf_ocr_text()`. default: `FALSE`.
#' if `FALSE`, we use `pdftools::pdf_text()`
#' @param ... Named curl options passed on to [crul::verb-GET], see
#' `curl::curl_options()` for available curl options. See especially the
#' User-agent section below
#'
#' @section Notes:
#' Note that this function is not vectorized. To do many requests
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
#' set this directory to something different. Paths are setup under "/crminer"
#' for each of the file types: "/crminer/pdf", "/crminer/xml", "/crminer/txt",
#' and "/crminer/html". See [crm_cache] for caching details.
#'
#' We cache all file types, as well as the extracted text from the pdf. The
#' text is saved in a text file with the same file name as the pdf, but with
#' the file extension ".txt". On subsequent requests of the same DOI, we first
#' look for a cached .txt file matching the DOI, and return it if it exists.
#' If it does not exist, but the the PDF does exist, we skip the PDF
#' download step and move on to reading the PDF to text; we cache that text
#' in to .txt file. If there's no .txt or .pdf file, we download the PDF and
#' read the pdf to text, and both are cached.
#'
#' @section User-agent:
#' You can optionally set a user agent string with the curl option `useragent`,
#' like `crm_text("some doi", "pdf", useragent = "foo bar")`.
#' user agent strings are sometimes used by servers to decide whether to
#' provide a response (in this case, the full text article). sometimes, a
#' browser like user agent string will make the server happy. by default all
#' requests in this package have a user agent string like
#' `libcurl/7.64.1 r-curl/4.3 crul/0.9.0`, which is a string with the names
#' and versions of the http clients used under the hood. If you supply
#' a user agent string using the `useragent` curl option, we'll use it instead.
#' For more information on user agent's, and exmaples of user agent strings you
#' can use here, see
#' https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
#'
#' @section Elsevier-partial:
#' For at least some PDFs from Elsevier, most likely when you do not have
#' full access to the full text, they will return a successful response,
#' but only return the first page of the PDF. They do however include
#' a warning message in the response headers, which we look for and pass
#' on to the user AND delete the pdf because we assume if you are using this
#' package you don't want just the first page but the whole article. This
#' behavior as far as we know does not occur with other article types
#' (xml, plain), but let us know if you see it.
#' @examples \dontrun{
#' # set a temp dir. cache path
#' crm_cache$cache_path_set(path = "crminer", type = "tempdir")
#' ## you can set the entire path directly via the `full_path` arg
#' ## like crm_cache$cache_path_set(full_path = "your/path")
#'
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
#'   # crm_text(links, type = "pdf")
#'   # system.time( first <- crm_text(links, type = "pdf") )
#'   ### second time should be faster
#'   # system.time( second <- crm_text(links, type = "pdf") )
#'   # identical(first, second)
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
#' # try_ocr
#' x <- crm_links('10.1006/jeth.1993.1066')
#' # (out <- crm_text(x, "pdf", try_ocr = TRUE))
#' x <- crm_links('10.1006/jeth.1997.2332')
#' # (out <- crm_text(x, "pdf", try_ocr = TRUE))
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
#' # crm_text(url = tmp, type = "pdf",
#' #   overwrite_unspecified = TRUE)
#'
#' #### older dates for Wiley
#' # tmp <- crm_links(dois_wiley$set2[1], "all")
#' # crm_text(tmp, type = "pdf",
#' #    overwrite_unspecified=TRUE)
#'
#' ### Wiley paper with CC By 4.0 license
#' # tmp <- crm_links("10.1113/jp272944", "all")
#' # crm_text(tmp, type = "pdf")
#' }
crm_text <- function(url, type = 'xml', overwrite = TRUE, read = TRUE,
                     overwrite_unspecified = FALSE, try_ocr = FALSE, ...) {
  UseMethod("crm_text")
}

#' @export
crm_text.default <- function(url, type = 'xml',
                             overwrite = TRUE, read = TRUE,
                             overwrite_unspecified = FALSE,
                             try_ocr = FALSE, ...) {
  stop("no 'crm_text' method for ", class(url), call. = FALSE)
}

#' @export
crm_text.tdmurl <- function(url, type = 'xml',
                            overwrite = TRUE, read = TRUE,
                            overwrite_unspecified = FALSE, try_ocr = FALSE,
                            ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, type)
  auth <- cr_auth(url, type)
  doi <- attr(url, "doi")
  switch(
    pick_type(type, url),
    xml = getTEXT(get_url(url, 'xml'), auth, type, doi, ...),
    plain = getTEXT(get_url(url, 'xml'), auth, 'txt', doi, ...),
    html = getTEXT(get_url(url, 'html'), auth, type, doi, ...),
    pdf = getPDF(get_url(url, 'pdf'), auth, overwrite, type,
                 read, doi, try_ocr, ...)
  )
}

#' @export
crm_text.list <- function(url, type = 'xml',
                         overwrite = TRUE, read = TRUE,
                         overwrite_unspecified = FALSE, try_ocr = FALSE,
                         ...) {
  if (!all(vapply(url, class, "", USE.NAMES = FALSE) == "tdmurl")) {
    stop("list input to 'crm_text' must be a list of tdmurl objects",
         call. = FALSE)
  }
  if (!type %in% c("xml", "plain", "html", "pdf")) {
    stop("'type' must be one of xml, plain, html, or pdf")
  }
  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, type)
  if (is.null(url[[type]])) stop('no links for type ', type)
  crm_text(url[[type]], type = type, overwrite = overwrite,
           read = read, overwrite_unspecified = overwrite_unspecified,
           try_ocr = try_ocr, ...)
}
