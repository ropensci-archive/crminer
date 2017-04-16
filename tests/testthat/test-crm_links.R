context("crm_links")

test_that("crm_links works", {
  l1 <- crm_links("10.7717/peerj.1268", "pdf")
  l2 <- crm_links(doi = "10.5555/515151", "pdf")

  expect_is(l1, "tdmurl")
  expect_equal(attr(l1, "type"), "pdf")
  expect_equal(attr(l1, "member"), "4443")

  expect_is(l2, "tdmurl")
  expect_equal(attr(l2, "type"), "pdf")
  expect_equal(attr(l2, "member"), "7822")
})

test_that("crm_links fails correctly", {
  expect_error(crm_links(), 'argument "doi" is missing')
  expect_warning(crm_links("3434"), "Resource not found")
  expect_null(suppressWarnings(crm_links("3434")))
  expect_null(crm_links("10.7717/peerj.1268", type = "adfasf"))
})
