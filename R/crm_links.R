#' Get full text links from a DOI
#'
#' @export
#' @param doi A DOI
#' @param type One of xml, plain, pdf, or all
#' @param ... Named parameters passed on to \code{\link[httr]{GET}}
#' @details Note that \code{\link{crm_links}} is not vectorized.
#'
#' Note that some links returned will not in fact lead you to full text
#' content as you would understandbly think and expect. That is, if you
#' use the \code{filter} parameter with e.g., \code{\link[rcrossref]{cr_works}}
#' and filter to only full text content, some links may actually give back
#' only metadata for an article. Elsevier is perhaps the worst offender,
#' for one because they have a lot of entries in Crossref TDM, but most
#' of the links that are apparently full text are not in fact full text,
#' but only metadata. You can get full text if you are part of a subscribing
#' institution to that specific Elsever content, but otherwise, you're SOL.
#'
#' Note that there are still some bugs in the data returned form CrossRef.
#' For example, for the publisher eLife, they return a single URL with
#' content-type application/pdf, but the URL is not for a PDF, but for both
#' XML and PDF, and content-type can be set with that URL as either XML or
#' PDF to get that type. Anyway, expect changes...
#'
#' @return \code{NULL} if no full text links given; a list of tdmurl objects if
#' links found.
#'
#' @examples \dontrun{
#' # pdf link
#' crm_links(doi = "10.5555/515151", "pdf")
#' crm_links(doi = "10.5555/515151", "pdf")
#'
#' # all links
#' crm_links(doi = "10.3897/phytokeys.52.5250", type = "all")
#'
#' # Get doi first from other fxn, then pass here
#' out <- cr_works(filter=c(has_full_text = TRUE), limit = 50)
#' dois <- out$data$DOI
#' crm_links(dois[2], "xml")
#' crm_links(dois[1], "plain")
#' crm_links(dois[1], "all")
#'
#' # (most likely) No links
#' crm_links(cr_r(1))
#' crm_links(doi="10.3389/fnagi.2014.00130")
#' }

crm_links <- function(doi, type='xml', ...) {
  res <- crm_works_links(dois = doi, ...)[[1]]
  if (is.null(unlist(res$links))) {
    NULL
  } else {
    elife <- if (grepl("elife", res$links[[1]]$URL)) TRUE else FALSE
    withtype <- if (type == 'all') {
      res$links
    } else {
      Filter(function(x) grepl(type, x$`content-type`), res$links)
    }
    if (is.null(withtype) || length(withtype) == 0) {
      NULL
    } else {
      withtype <- stats::setNames(withtype, sapply(withtype, function(x){
        if (x$`content-type` == "unspecified") {
          "unspecified"
        } else {
          strsplit(x$`content-type`, "/")[[1]][[2]]
        }
      }))
      if (elife) {
        withtype <-
          c(
            withtype,
            stats::setNames(
              list(
                utils::modifyList(
                  withtype[[1]],
                  list(`content-type` = "application/xml"))
              ),
            "xml")
          )
      }

      if (type == "all") {
        out <- lapply(
          withtype, function(b) makeurl(b$URL, st(b$`content-type`), doi)
        )
      } else {
        y <- match.arg(type, c('xml','plain','pdf','unspecified'))
        out <- makeurl(withtype[[y]]$URL, y, doi)
      }

      structure(out, member = res$member)
    }
  }
}

crm_works_links <- function(dois = NULL, ...) {
  get_links <- function(x) {
    tmp <- crm_GET(sprintf("works/%s", x), NULL, FALSE)
    trylinks <- tryCatch(tmp$message$link, error = function(e) e)
    if (inherits(trylinks, "error")) {
      NULL
    } else {
      list(links = trylinks, member = tmp$message$member)
    }
  }
  stats::setNames(lapply(dois, get_links, ...), dois)
}

st <- function(x){
  if (grepl("/", x)) {
    strsplit(x, "/")[[1]][[2]]
  } else {
    x
  }
}
