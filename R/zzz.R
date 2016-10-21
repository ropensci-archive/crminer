crmc <- function(x) Filter(Negate(is.null), x)

ct_utf8 <- function(x) httr::content(x, as = "text", encoding = "UTF-8")

asl <- function(z) {
  if (is.logical(z) || tolower(z) == "true" || tolower(z) == "false") {
    if (z) {
      return('true')
    } else {
      return('false')
    }
  } else {
    return(z)
  }
}

make_crminer_ua <- function() {
  c(
    httr::user_agent(crminer_ua()),
    httr::add_headers(`X-USER-AGENT` = crminer_ua())
  )
}

crminer_ua <- function() {
  versions <- c(paste0("r-curl/", utils::packageVersion("curl")),
                paste0("httr/", utils::packageVersion("httr")),
                sprintf("rOpenSci(rcrossref/%s)", utils::packageVersion("rcrossref")))
  paste0(versions, collapse = " ")
}

crm_GET <- function(endpoint, args, todf = TRUE, on_error = warning, parse = TRUE, ...) {
  url <- sprintf("http://api.crossref.org/%s", endpoint)
  if (length(args) == 0) {
    res <- httr::GET(url, make_crminer_ua(), ...)
  } else {
    res <- httr::GET(url, query = args, make_crminer_ua(), ...)
  }
  doi <- gsub("works/|/agency|funders/", "", endpoint)
  if (!res$status_code < 300) {
    on_error(sprintf("%s: %s - (%s)", res$status_code, get_err(res), doi), call. = FALSE)
    list(message = NULL)
  } else {
    stopifnot(res$headers$`content-type` == "application/json;charset=UTF-8")
    res <- ct_utf8(res)
    if (parse) jsonlite::fromJSON(res, todf) else res
  }
}

get_err <- function(x) {
  xx <- ct_utf8(x)
  if (x$headers$`content-type` == "text/plain") {
    tmp <- xx
  } else if (x$headers$`content-type` == "text/html") {
    html <- xml2::read_html(xx)
    tmp <- xml2::xml_text(xml2::xml_find_one(html, '//h3[@class="info"]'))
  } else if (x$headers$`content-type` == "application/json;charset=UTF-8") {
    tmp <- jsonlite::fromJSON(xx, FALSE)
  } else {
    tmp <- xx
  }
  if (inherits(tmp, "list")) {
    tmp$message[[1]]$message
  } else {
    if (any(class(tmp) %in% c("HTMLInternalDocument", "xml_document"))) {
      return("Server error - check your query - or api.crossref.org may be experiencing problems")
    } else {
      return(tmp)
    }
  }
}

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x
