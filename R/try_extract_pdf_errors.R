# x: a file path to a pdf
# returns: an error if any matches; if no matches, returns NULL
try_extract_pdf_errors <- function(x) {
  if (!file.exists(x)) return()
  if (likely_pdf(x)) return()
  if (!any(nzchar(readLines(x, n = 10)))) return()
  html <- xml2::read_html(x)

  # publisher: ?; eg.: xx
  ex <- xml2::xml_find_all(html, "//*[contains(@class, 'error')]")
  if (!length(ex) == 0 && any(nzchar(xml2::xml_text(ex)))) {
    stop("error in pdf retrieval; attempted to extract error messages:\n",
      xml2::xml_text(ex), call. = FALSE)
  }

  # publisher: ?; eg.: xx
  fx <- xml2::xml_find_all(html, "//text()[. = 'Not logged in']")
  if (!length(fx) == 0) {
    stop("error in pdf retrieval; attempted to extract error messages:\n",
      xml2::xml_text(fx), call. = FALSE)
  }

  # publisher: wiley; eg.: 10.1002/ijfe.286
  sx <- xml2::xml_find_all(html, "//*[contains(@id, 'iucr-failure')]")
  if (!length(sx) == 0) {
    stop("error in pdf retrieval; attempted to extract error messages:\n",
      xml2::xml_text(sx), call. = FALSE)
  }

  # publisher: ?; eg.: xx
  html_txt <- xml2::xml_text(html)
  fx <- grepl('Bad Request|Error', html_txt)
  if (fx) {
    stop("error in pdf retrieval; could not extract any error messages\n",
      call. = FALSE)
  }
}
