get_url <- function(a, b){
  url <- if (inherits(a, "tdmurl")) a[[1]] else a[[b]]
  if (grepl("pensoft", url)) {
    url
  } else if (attr(a, "member") == "78") {
    url
  } else {
    sub("\\?.+", "", url)
  }
}

pick_type <- function(x, z) {
  x <- match.arg(x, c("xml", "plain", "html", "pdf"))
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
  wiley_cambridge <- function(type) {
    list(
      `CR-Clickthrough-Client-Token` = Sys.getenv("CROSSREF_TDM"),
      Accept = type
    )
  }
  mem <- attr(url, "member")
  if (is.null(mem)) return(list())
  mem_num <- basename(mem)
  if (mem_num %in% c(78, 263, 311, 286)) {
    type <- switch(
      type,
      xml = "text/xml",
      plain = "text/plain",
      html = "text/html",
      pdf = "application/pdf"
    )
    switch(
      mem_num,
      `78` = { # elsevier
        key <- Sys.getenv("CROSSREF_TDM")
        list(`CR-Clickthrough-Client-Token` = key, Accept = type)
      },
      `263` = { # IEEE
        key <- Sys.getenv("CROSSREF_TDM")
        list(`CR-TDM-Client_Token` = key, Accept = type)
      },
      `311` = wiley_cambridge(type), # wiley
      `286` = wiley_cambridge(type) # cambridge
    )
  } else {
    return(list())
  }
}

getTEXT <- function(x, type, auth, ...){
  cli <- crul::HttpClient$new(url = x, headers = auth, opts = list(...))
  res <- cli$get()
  switch(
    type,
    xml = xml2::read_xml(res$parse("UTF-8")),
    plain = res$parse("UTF-8"),
    html = xml2::read_html(res$parse("UTF-8")),
    stop("only 'xml', 'plain', and 'html' supported")
  )
}

getPDF <- function(url, auth, overwrite, type, read, doi, cache = FALSE, ...) {
  crm_cache$mkdir()
  # if (!file.exists(path)) {
  #   dir.create(path, showWarnings = FALSE, recursive = TRUE)
  # }

  # pensoft special handling
  if (grepl("pensoft", url[[1]])) {
    if (is.null(doi)) {
      tmp <- strsplit(url, "=")[[1]]
      doi <- tmp[length(tmp)]
    }
    filepath <- file.path(crm_cache$cache_path_get(),
                          paste0(sub("/", ".", doi), ".pdf"))
  } else {
    burl <- sub("\\?.+", "", url)
    ff <- if (!grepl(type, basename(burl))) {
      paste0(basename(burl), ".", type)
    } else {
      basename(burl)
    }
    filepath <- file.path(crm_cache$cache_path_get(), ff)
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
