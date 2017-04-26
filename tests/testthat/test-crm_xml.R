context("crm_xml")

library("xml2")

data(dois_pensoft)
doi1 <- sample(dois_pensoft, size = 1)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  url1 <- crm_links(doi1, type = "xml")
}


test_that("crm_xml works with links input",{
  skip_on_cran()

  links <- crm_links("10.3897/compcytogen.v10i4.9536", type = "all")
  res <- suppressMessages(crm_xml(links))
  expect_is(res, "xml_document")
  expect_equal(xml2::xml_name(res), "article")
})

test_that("crm_xml works with character URL input", {
  skip_on_cran()

  res <- suppressMessages(crm_xml(url1$xml))
  expect_is(res, "xml_document")
  expect_equal(xml2::xml_name(res), "article")
})


test_that("crm_xml fails well",{
  expect_error(crm_xml(5), "no 'crm_xml' method for numeric")
  expect_error(crm_xml(mtcars), "no 'crm_xml' method for data.frame")
  expect_error(crm_xml(matrix(1:5)), "no 'crm_xml' method for matrix")

  expect_error(crm_xml("adfdf"), "Not a proper url")

  skip_on_cran()
  expect_error(crm_xml(url1, overwrite_unspecified = 5),
               "overwrite_unspecified must be of class logical")
})
