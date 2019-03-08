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
    sprintf("rOpenSci(rcrossref/%s)", utils::packageVersion("rcrossref")),
    email_get()
  )
  paste0(versions, collapse = " ")
}

#' Share email with Crossref in `.Renviron`
#' @noRd
email_get <- function() {
  email <- Sys.getenv("crossref_email")
  if (identical(email, "")) email <- Sys.getenv("CROSSREF_EMAIL")
  if (identical(email, "")) {
    NULL
  } else {
    paste0("(mailto:", val_email(email), ")")
  }
}
#' Email checker
#' @param email email address (character string)
#' @noRd
val_email <- function(email) {
  if (!grepl(email_regex(), email))
    stop(sprintf("Email address (%s) not properly formed - Check your .Renviron!",
         email), call. = FALSE)
  return(email)
}
#' Email regex
#' From \url{http://stackoverflow.com/a/25077140}
#' @noRd
email_regex <-
  function()
    "^[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$"

crm_GET <- function(endpoint, args = list(), todf = TRUE, on_error = warning,
                    parse = TRUE, ...) {

  url <- sprintf("https://api.crossref.org/%s", endpoint)
  cli <- crul::HttpClient$new(
    url = url,
    headers = list(
      `User-Agent` = crminer_ua(),
      `X-USER-AGENT` = crminer_ua()
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
    tmp <- xml2::xml_text(xml2::xml_find_first(html, '//h3[@class="info"]'))
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
