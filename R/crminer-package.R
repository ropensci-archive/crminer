#' crminer - Crossref text miner
#'
#' @name crminer-package
#' @aliases crminer
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
NULL

#' A character vector of 500 DOIs from Crossref
#'
#' Obtained via
#' \code{rcrossref::cr_works(filter = c(has_full_text = TRUE), limit = 500)}
#'
#' @docType data
#' @keywords datasets
#' @format A character vector of length 500
#' @name dois_crminer
NULL

#' A character vector of 100 DOIs from Crossref with license CC-BY 3.0
#'
#' Obtained via
#' \code{rcrossref::cr_works(filter = list(has_full_text = TRUE,
#' license_url="http://creativecommons.org/licenses/by/3.0/"), limit = 100)}
#'
#' @docType data
#' @keywords datasets
#' @format A character vector of length 100
#' @name dois_crminer_ccby3
NULL

#' A character vector of 100 Pensoft DOIs from Crossref
#'
#' Obtained via \code{rcrossref::cr_members(2258,
#' filter = c(has_full_text = TRUE), works = TRUE, limit = 100)}
#'
#' @docType data
#' @keywords datasets
#' @format A character vector of length 100
#' @name dois_pensoft
NULL

#' A character vector of 50 Hindawi DOIs from Crossref
#'
#' Obtained via \code{rcrossref::cr_members(98,
#' filter = c(has_full_text = TRUE), works = TRUE, limit = 50)}
#'
#' @docType data
#' @keywords datasets
#' @format A character vector of length 50
#' @name dois_hindawi
NULL

#' A character vector of 100 Elsevier DOIs from Crossref
#'
#' Obtained via \code{rcrossref::cr_members(78,
#' filter = c(has_full_text = TRUE), works = TRUE, limit = 100)}
#'
#' @docType data
#' @keywords datasets
#' @format A character vector of length 100
#' @name dois_elsevier
NULL

#' A list of 3 character vectors totaling 250 Wiley DOIs from Crossref
#'
#' \itemize{
#'  \item set1: Obtained via \code{rcrossref::cr_members(311,
#'  filter = c(has_full_text = TRUE), works = TRUE, limit = 100)}
#'  \item set2 (a set with older dates): Obtained via
#'  \code{rcrossref::cr_members(311, filter=c(has_full_text = TRUE,
#'  type = 'journal-article', until_created_date = "2013-12-31"),
#'  works = TRUE, limit = 100)}
#'  \item set3 (with CC By 4.0 license): Obtained via
#'  \code{rcrossref::cr_members(311, filter=c(has_full_text = TRUE,
#'  license.url = "http://creativecommons.org/licenses/by/4.0/"),
#'  works = TRUE, limit = 100)}
#' }
#'
#' @docType data
#' @keywords datasets
#' @format A list of length 3, \code{set1} with a character vector of
#' length 100, \code{set2} with a character vector of length 100, and
#' \code{set3} with a character vector of length 50.
#' @name dois_wiley
NULL
