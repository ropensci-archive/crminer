context("crm_pdf")
  
# FIXME: when vcr fixed to use relative paths to files on disk,
# only skip on cran
skip_on_cran()
# skip_on_travis()

crm_cache$cache_path_set(path = "crminer", type = "tempdir")

# don't use a random DOI when caching
# data(dois_pensoft)
# doi1 <- sample(dois_pensoft, size = 1)
# doi1 <- "10.3897/phytokeys.74.10380"
doi1 <- "10.3897/phytokeys.136.47386"

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  vcr::use_cassette("crm_pdf_prep", {
    url1 <- crm_links(doi1, type = "pdf")
  })
}

test_that("crm_pdf works with links input",{
  vcr::use_cassette("crm_pdf_links_in", {
    links <- crm_links("10.3897/compcytogen.v10i4.9536", type = "all")
    res <- suppressMessages(crm_pdf(links))
  })
  expect_named(res, c("info", "text"))
  expect_equal(res$info$pages, 12)
})

test_that("crm_pdf works with character URL input", {
  vcr::use_cassette("crm_pdf_character_in", {
    res <- suppressMessages(crm_pdf(url1))
  })
  expect_named(res, c("info", "text"))
  expect_type(res$info$pages, "integer")
})

test_that("crm_pdf works for 'unspecified' = TRUE",{
  skip_if_not(Sys.getenv("CROSSREF_TDM") != "",
              "Needs 'Sys.setenv(CROSSREF_TDM = \"your-key\")' to be set.")
  vcr::use_cassette("crm_pdf_unspecified_true", {
    links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")
    res <- crm_pdf(links, overwrite_unspecified = TRUE)
  })
  expect_equal(res$info$pages, 11)
})

test_that("crm_pdf fails for 'unspecified' = FALSE",{
  vcr::use_cassette("crm_pdf_unspecified_false", {
    links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")
  })

  expect_error(crm_pdf(links, overwrite_unspecified = FALSE),
              "no 'crm_pdf' method for NULL")
})

test_that("crm_pdf fails well",{
  expect_error(crm_pdf(5), "no 'crm_pdf' method for numeric")
  expect_error(crm_pdf(mtcars), "no 'crm_pdf' method for data.frame")
  expect_error(crm_pdf(matrix(1:5)), "no 'crm_pdf' method for matrix")
  expect_error(crm_pdf("adfdf"), "Not a proper url")

  skip_on_cran()
  expect_error(crm_pdf(url1, overwrite = "adfdf"),
               "overwrite must be of class logical")
  expect_error(crm_pdf(url1, read = 5), "read must be of class logical")
  expect_error(crm_pdf(url1, cache = 5), "cache must be of class logical")
  expect_error(crm_pdf(url1, overwrite_unspecified = 5),
               "overwrite_unspecified must be of class logical")
})
