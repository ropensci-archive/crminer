crmc <- function(x) Filter(Negate(is.null), x)

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

crminer_ua <- function() {
  versions <- c(
    paste0("r-curl/", utils::packageVersion("curl")),
    paste0("rOpenSci(crul/%s)", utils::packageVersion("crul")),
    sprintf("rOpenSci(rcrossref/%s)", utils::packageVersion("rcrossref"))
  )
  paste0(versions, collapse = " ")
}

crm_GET <- function(endpoint, args = list(), todf = TRUE, on_error = warning,
                    parse = TRUE, ...) {

  url <- sprintf("http://api.crossref.org/%s", endpoint)
  cli <- crul::HttpClient$new(
    url = url,
    headers = list(
      useragent = crminer_ua(),
      'X-USER-AGENT' = crminer_ua()
    ),
    opts = list(...)
  )
  res <- cli$get(query = args)
  doi <- gsub("works/|/agency|funders/", "", endpoint)
  if (!res$status_code < 300) {
    on_error(sprintf("%s: %s - (%s)", res$status_code, get_err(res), doi),
             call. = FALSE)
    list(message = NULL)
  } else {
    stopifnot(res$response_headers$`content-type` ==
                "application/json;charset=UTF-8")
    res <- res$parse("UTF-8")
    if (parse) jsonlite::fromJSON(res, todf) else res
  }
}

get_err <- function(x) {
  xx <- x$parse("UTF-8")
  if (x$response_headers$`content-type` == "text/plain") {
    tmp <- xx
  } else if (x$response_headers$`content-type` == "text/html") {
    html <- xml2::read_html(xx)
    tmp <- xml2::xml_text(xml2::xml_find_one(html, '//h3[@class="info"]'))
  } else if (
    x$response_headers$`content-type` == "application/json;charset=UTF-8"
  ) {
    tmp <- jsonlite::fromJSON(xx, FALSE)
  } else {
    tmp <- xx
  }
  if (inherits(tmp, "list")) {
    tmp$message[[1]]$message
  } else {
    if (any(class(tmp) %in% c("HTMLInternalDocument", "xml_document"))) {
      "Server error - check query - or api.crossref.org may have problems"
    } else {
      tmp
    }
  }
}

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!class(x) %in% y) {
      stop(deparse(substitute(x)), " must be of class ",
           paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}
