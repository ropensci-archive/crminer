#' @details Note that this function is not vectorized. To do many requests
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
#' Check out [auth()] for details on authentication.
