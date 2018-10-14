context("crm_html")

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  url1 <- crm_links("10.7717/peerj.1545", type = "html")
}

test_that("crm_html works with links input",{
  skip_on_cran()

  res <- suppressMessages(crm_html(url1))
  expect_is(res, "xml_document")
  expect_equal(xml2::xml_name(res), "html")
})

test_that("crm_html works with character URL input", {
  skip_on_cran()

  res <- suppressMessages(crm_html(url1$html))
  expect_is(res, "xml_document")
  expect_equal(xml2::xml_name(res), "html")
})


test_that("crm_html fails well",{
  skip_on_cran()
  
  expect_error(crm_html(5), "no 'crm_html' method for numeric")
  expect_error(crm_html(mtcars), "no 'crm_html' method for data.frame")
  expect_error(crm_html(matrix(1:5)), "no 'crm_html' method for matrix")

  expect_error(crm_html("adfdf"), "Not a proper url")

  expect_error(crm_html(url1, overwrite_unspecified = 5),
               "overwrite_unspecified must be of class logical")
})
