#' Get full text from a DOI
#'
#' @export
#' @param url (character) A URL.
#' @param type (character) One of 'xml' (default), 'html', 'plain', 'pdf',
#' 'unspecified', or 'all'
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
#' @param ... Named parameters passed on to [crul::HttpClient()]
#'
#' @details Note that [crm_text()], [crm_pdf()], [crm_xml()], [crm_plain()]
#' are not vectorized.
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
#' Check out [auth()] for details on authentication.
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
#' #crm_pdf(links)
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
#'
#' ## elsevier
#' ## requires extra authentication
#' data(dois_elsevier)
#'
#' ## set key first
#' # Sys.setenv(CROSSREF_TDM_ELSEVIER = "your-key")
#' ## XML
#' link <- crm_links("10.1016/j.funeco.2010.11.003", "xml")
#' # res <- crm_text(url = link, type = "xml")
#' ## plain text
#' link <- crm_links("10.1016/j.funeco.2010.11.003", "plain")
#' # res <- crm_text(url = link, "plain")
#'
#' ## Wiley
#' Sys.setenv(CROSSREF_TDM = "your-key")
#'
#' ### all wiley
#' data(dois_wiley)
#'
#' # res <- list()
#' # dois <- dois_wiley$set1[1:10]
#' # for (i in seq_along(dois)) {
#' #    tmp <- crm_links(dois[i], "all")
#' # res[[i]] <- crm_text(url = tmp, type = "pdf", cache=FALSE,
#' #        overwrite_unspecified = TRUE)
#' # }
#' # res
#'
#' #### older dates
#' # res <- list()
#' # for (i in seq_along(dois_wiley$set2)) {
#' #   tmp <- crm_links(dois_wiley$set2[i], "all")
#' #   res[[i]] <- crm_text(tmp, type = "pdf", cache=FALSE,
#' #         overwrite_unspecified=TRUE)
#' # }
#' # res
#'
#' ### wiley subset with CC By 4.0 license
#' # res <- list()
#' # for (i in seq_along(dois_wiley$set3)) {
#' #   tmp <- crm_links(dois_wiley$set3[i], "all")
#' #   res[[i]] <- crm_text(tmp, type = "pdf", cache=F,
#' #         overwrite_unspecified=TRUE)
#' # }
#' }

crm_text <- function(url, type = 'xml', path = cr_cache_path(),
                     overwrite = TRUE, read = TRUE, cache = TRUE,
                     overwrite_unspecified = FALSE, ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, type)
  auth <- cr_auth(url, type)
  switch(
    pick_type(type, url),
    xml = getTEXT(get_url(url, 'xml'), type, auth, ...),
    plain = getTEXT(get_url(url, 'xml'), type, auth, ...),
    pdf = getPDF(url = get_url(url, 'pdf'), path, auth, overwrite, type,
                 read, cache, ...)
  )
}

cr_cache_path <- function() paste0(rappdirs::user_cache_dir(), "/crminer")

get_url <- function(a, b){
  url <- if (inherits(a, "tdmurl")) a[[1]] else a[[b]]
  if (grepl("pensoft", url)) {
    url
  } else {
    sub("\\?.+", "", url)
  }
}

#' @export
#' @rdname crm_text
crm_plain <- function(url, path = cr_cache_path(), overwrite = TRUE, read=TRUE,
                        overwrite_unspecified=FALSE, ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "plain")
  if (is.null(url$plain[[1]])) {
    stop("no plain text link found", call. = FALSE)
  }
  getTEXT(url$plain[[1]], "plain", cr_auth(url, 'plain'), ...)
}

#' @export
#' @rdname crm_text
crm_xml <- function(url, path = cr_cache_path(), overwrite = TRUE, read=TRUE,
                      overwrite_unspecified = FALSE, ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "xml")
  if (is.null(url$xml[[1]])) {
    stop("no xml link found", call. = FALSE)
  }
  getTEXT(url$xml[[1]], "xml", cr_auth(url, 'xml'), ...)
}

#' @export
#' @rdname crm_text
crm_pdf <- function(url, path = cr_cache_path(), overwrite = TRUE, read = TRUE,
                    cache = FALSE, overwrite_unspecified = FALSE, ...) {

  url <- maybe_overwrite_unspecified(overwrite_unspecified, url, "pdf")
  if (is.null(url$pdf[[1]])) {
    stop("no pdf link found", call. = FALSE)
  }
  getPDF(url$pdf[[1]], path, cr_auth(url, 'pdf'), overwrite, "pdf",
         read, cache, ...)
}

pick_type <- function(x, z) {
  x <- match.arg(x, c("xml","plain","pdf"))
  if (length(z) == 1) {
    avail <- attr(z, which = "type")
  } else {
    avail <- vapply(z, function(x) attr(x, which = "type"), character(1),
                    USE.NAMES = FALSE)
  }
  if (!x %in% avail) stop("Chosen type not available in links", call. = FALSE)
  x
}

cr_auth <- function(url, type) {
  mem <- attr(url, "member")
  mem_num <- basename(mem)
  if (mem_num %in% c(78, 263, 311)) {
    type <- switch(type,
                   xml = "text/xml",
                   plain = "text/plain",
                   pdf = "application/pdf"
    )
    switch(
      mem_num,
      `78` = {
        key <- Sys.getenv("CROSSREF_TDM")
        #add_headers(`X-ELS-APIKey` = key, Accept = type)
        list(`CR-Clickthrough-Client-Token` = key, Accept = type)
      },
      `263` = {
        key <- Sys.getenv("CROSSREF_TDM")
        list(`CR-TDM-Client_Token` = key, Accept = type)
        # add_headers(`CR-Clickthrough-Client-Token` = key, Accept = type)
      },
      `311` = {
        list(
          `CR-Clickthrough-Client-Token` = Sys.getenv("CROSSREF_TDM"),
          Accept = type
        )
      }
    )
  } else {
    NULL
  }
}

getTEXT <- function(x, type, auth, ...){
  cli <- crul::HttpClient$new(url = x, headers = auth, opts = list(...))
  res <- cli$get()
  switch(
    type,
    xml = xml2::read_xml(res$parse("UTF-8")),
    plain = res$parse("UTF-8"),
    stop("only 'xml' and 'plain' supported")
  )
}

getPDF <- function(url, path, auth, overwrite, type, read,
                   cache=FALSE, ...) {
  if (!file.exists(path)) {
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
  }

  # pensoft special handling
  if (grepl("pensoft", url[[1]])) {
    doi <- attr(url, "doi")
    if (is.null(doi)) {
      tmp <- strsplit(url, "=")[[1]]
      doi <- tmp[length(tmp)]
    }
    filepath <- file.path(path, paste0(sub("/", ".", doi), ".pdf"))
  } else {
    ff <- if (!grepl(type, basename(url))) {
      paste0(basename(url), ".", type)
    } else {
      basename(url)
    }
    filepath <- file.path(path, ff)
  }

  filepath <- path.expand(filepath)
  if (cache && file.exists(filepath)) {
    if ( !file.exists(filepath) ) {
      stop( sprintf("%s not found", filepath), call. = FALSE)
    }
  } else {
    message("Downloading pdf...")
    cli <- crul::HttpClient$new(
      url = url,
      opts = list(followlocation = TRUE, ...),
      headers = c(auth, list(Accept = "application/pdf"))
    )
    res <- cli$get(disk = filepath)
    res$raise_for_status()
    if (res$status_code < 202) {
      filepath <- res$content
    } else {
      unlink(filepath)
      filepath <- res$status_code
      read <- FALSE
    }
  }

  if (read) {
    message("Extracting text from pdf...")
    crm_extract(path = filepath)
  } else {
    filepath
  }
}

maybe_overwrite_unspecified <- function(overwrite_unspecified, url, type) {
  if (overwrite_unspecified) {
    url <- stats::setNames(url, type)
    attr(url, "type") <- type
  }
  return(url)
}
