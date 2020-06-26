get_url <- function(a, b){
  url <- if (inherits(a, "tdmurl")) a[[1]] else a[[b]]
  if (grepl("pensoft|elsevier", url)) {
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
  # special handling for DOIs transferred to Elsevier
  if (grepl("elsevier", url)) mem_num <- "78"
  if (mem_num %in% c(78, 263, 311, 286)) {
    type <- switch(
      type,
      xml = "text/xml",
      plain = "text/plain",
      html = "text/html",
      pdf = "application/pdf"
    )
    switch(
      as.character(mem_num),
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

last <- function(x) x[length(x)]
lastn <- function(x, n = 1) {
  stopifnot(n >= 1)
  x[(length(x)-(n-1)):length(x)]
}

make_file_path <- function(url, doi, type) {
  # pensoft special handling
  if (grepl("pensoft", url[[1]])) {
    if (is.null(doi)) {
      tmp <- strsplit(url, "=")[[1]]
      doi <- tmp[length(tmp)]
    }
    ff <- file.path(crm_cache$cache_path_get(), type,
      paste0(sub("/", ".", doi), paste0(".", type)))
  } else if (last(strsplit(url, "/")[[1]]) == "pdf" && !grepl("elsevier", url)) {
    # special handling for urls that just end in pdf
    parts <- strsplit(url, "/")[[1]]
    parts <- parts[-length(parts)]
    ff <- file.path(crm_cache$cache_path_get(), type, paste0(
      gsub("=|-|\\s", "_", paste0(lastn(parts, 3), collapse="")),
      paste0(".", type)
    ))
  } else {
    burl <- sub("\\?.+", "", url)
    ff <- if (!grepl(type, basename(burl))) {
      paste0(basename(burl), ".", type)
    } else {
      basename(burl)
    }
    ff <- file.path(crm_cache$cache_path_get(), type, ff)
  }
  return(path.expand(ff))
}

alter_url <- function(url) {
  # wiley special handling
  ## /pdfdirect/ seems to work more often than /pdf/
  if (grepl("wiley", url)) {
    url <- sub("pdf", "pdfdirect", url)
  }
  ## some wiley urls have the wrong http scheme
  if (grepl("wiley", url)) {
    if (grepl("http://", url))
      url <- sub("http", "https", url)
  }
  return(url)
}

is_ct <- function(type) {
  function(x) {
    if (!is.null(x$response_headers$`content-type`)) {
      grepl(type, x$response_headers$`content-type`)
    } else {
      # no content type header, just say TRUE to move on to next code path
      return(TRUE)
    }
  }
}
is_ct_pdf <- is_ct(type = "pdf")
is_ct_html <- is_ct(type = "html")
is_ct_xml <- is_ct(type = "xml")
is_ct_plain <- is_ct(type = "plain")

likely_pdf <- function(x) {
  z=tryCatch(suppressMessages(pdftools::pdf_info(x)), error = function(e) e)
  !inherits(z, "error")
}

no_elsevier_warning <- function(x, file) {
  hds <- x$response_headers
  if ("x-els-status" %in% names(hds)) {
    if ("ok" != tolower(hds$`x-els-status`)) {
      warning(paste("Elsevier", hds[["x-els-status"]]),
        sprintf("\n file (%s) deleted", file))
      unlink(file)
      return(FALSE)
    }
    return(TRUE)
  }
  return(TRUE)
}

getTEXT <- function(url, auth, type, doi, ...) {
  dir.create(file.path(crm_cache$cache_path_get(), type),
    showWarnings = FALSE, recursive = TRUE)
  filepath <- make_file_path(url, doi, type)
  if (file.exists(filepath)) {
    cache_mssg(filepath)
    return(switch_text(filepath, type))
  }
  cli <- crul::HttpClient$new(url = url, headers = auth,
    opts = list(followlocation = TRUE, ...))
  res <- cli$get(disk = filepath)
  switch_text(res$content, type)
}
switch_text <- function(x, type) {
  switch(
    type,
    xml = xml2::read_xml(x),
    txt = readLines(x, warn = FALSE, encoding = "UTF-8"),
    html = xml2::read_html(x),
    stop("only 'xml', 'txt', and 'html' supported")
  )
}
getPDF <- function(url, auth, overwrite, type, read,
  doi, try_ocr = FALSE, ...) {

  dir.create(file.path(crm_cache$cache_path_get(), "pdf"),
    showWarnings = FALSE, recursive = TRUE)
  filepath <- make_file_path(url, doi, type)
  txtpath <- sub("pdf$", "txt", filepath)
  if (file.exists(txtpath) && read) {
    cache_mssg(txtpath)
    return(give_txt(txtpath))
  }
  url <- alter_url(url)
  if (file.exists(filepath)) {
    cache_mssg(filepath)
  } else {
    message("Downloading pdf...")
    cli <- crul::HttpClient$new(
      url = url,
      opts = list(followlocation = TRUE, ...),
      headers = c(auth, list(Accept = "application/pdf"))
    )
    res <- cli$get(disk = filepath)
    if (!res$success()) on.exit(unlink(filepath), add = TRUE)
    res$raise_for_status()
    if (
      res$status_code < 202 &&
      is_ct_pdf(res) && 
      no_elsevier_warning(res, filepath) &&
      likely_pdf(filepath)
    ) {
      filepath <- res$content
    } else {
      on.exit(unlink(filepath), add = TRUE)
      try_extract_pdf_errors(filepath)
      read <- FALSE
    }
  }

  if (read) {
    txtpath <- sub("pdf$", "txt", filepath)
    if (!file.exists(txtpath)) {
      message("Extracting text from pdf...")
      out <- crm_extract(path = filepath)
      if (!all(nzchar(out$text)) && try_ocr) {
        message("no text extracted, pdf likely scanned,",
          " trying pdftools::pdf_ocr_text ...")
        out <- crm_extract(path = filepath, try_ocr = TRUE)
      }
      cache_pdf_text(out, txtpath)
    } else {
      out <- structure(
        list(
          info = pdftools::pdf_info(filepath),
          text = readLines(txtpath)
        ),
        class = "crm_pdf",
        path = filepath
      )
    }
    return(out)
  } else {
    filepath
  }
}

give_txt <- function(x) {
  structure(list(text = readLines(x)), class = "crm_pdf_text", path = x)
}

maybe_overwrite_unspecified <- function(overwrite_unspecified, url, type) {
  if (overwrite_unspecified) {
    url <- stats::setNames(url, type)
    attr(url, "type") <- type
  }
  return(url)
}

cache_pdf_text <- function(x, txtpath) {
  if (!file.exists(txtpath) && !is.null(x$text)) {
    cat(x$text, file = txtpath, sep = "\n")
  }
}

stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))
cache_mssg <- function(file) {
  fi <- file.info(file)
  size <- round(fi$size/1000000, 3)
  chaftdec <- nchar(stract(as.character(size), '^[0-9]+'))
  if (chaftdec > 1) size <- round(size, 1)
  message("using cached file: ", file)
  message(
    sprintf("date created (size, mb): %s (%s)", fi$ctime, size))
}
