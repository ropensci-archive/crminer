context("crm_pdf")

data(dois_pensoft)
doi1 <- sample(dois_pensoft, size = 1)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  url1 <- crm_links(doi1, type = "pdf")
}


test_that("crm_pdf works with links input",{
  skip_on_cran()

  links <- crm_links("10.3897/compcytogen.v10i4.9536", type = "all")
  res <- suppressMessages(crm_pdf(links))
  expect_named(res, c("info", "text"))
  expect_equal(res$info$pages, 12)
})

test_that("crm_pdf works with character URL input", {
  skip_on_cran()

  res <- suppressMessages(crm_pdf(url1$pdf))
  expect_named(res, c("info", "text"))
  expect_type(res$info$pages, "integer")
})

test_that("crm_pdf works for 'unspecified' = TRUE",{
  skip_on_cran()

  skip_if_not(Sys.getenv("CROSSREF_TDM") != "",
              "Needs 'Sys.setenv(CROSSREF_TDM = \"your-key\")' to be set.")
  links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")
  res <- crm_pdf(links, overwrite_unspecified = TRUE)
  expect_equal(res$info$pages, 11)
})

test_that("crm_pdf fails for 'unspecified' = FALSE",{
  skip_on_cran()

  links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")

  expect_error(crm_pdf(links, overwrite_unspecified = FALSE),
              "no 'crm_pdf' method for NULL")
})


test_that("crm_pdf fails well",{
  expect_error(crm_pdf(5), "no 'crm_pdf' method for numeric")
  expect_error(crm_pdf(mtcars), "no 'crm_pdf' method for data.frame")
  expect_error(crm_pdf(matrix(1:5)), "no 'crm_pdf' method for matrix")

  expect_error(crm_pdf("adfdf"), "Not a proper url")

  skip_on_cran()
  expect_error(crm_pdf(url1, path = 5), "path must be of class character")
  expect_error(crm_pdf(url1, overwrite = "adfdf"),
               "overwrite must be of class logical")
  expect_error(crm_pdf(url1, read = 5), "read must be of class logical")
  expect_error(crm_pdf(url1, cache = 5), "cache must be of class logical")
  expect_error(crm_pdf(url1, overwrite_unspecified = 5),
               "overwrite_unspecified must be of class logical")
})
