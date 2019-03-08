context("crm_links")

test_that("crm_links works", {
  l1 <- crm_links("10.7717/peerj.1268", "pdf")
  l2 <- crm_links(doi = "10.5555/515151", "pdf")
  l3 <- crm_links(doi = "10.1016/j.ad.2015.06.020", "xml")
  l4 <- crm_links(doi = "10.7717/peerj.2363", "html")
  l5 <- crm_links(doi = "10.7717/peerj.1268", type = "all")
  l6 <- crm_links(doi = "10.7717/peerj.1268")

  expect_is(l1, "tdmurl")
  expect_equal(attr(l1, "type"), "pdf")
  expect_equal(attr(l1, "member"), "4443")
  expect_named(l1, "pdf")

  expect_is(l2, "tdmurl")
  expect_equal(attr(l2, "type"), "pdf")
  expect_equal(attr(l2, "member"), "7822")
  expect_named(l2, "pdf")

  expect_is(l3, "tdmurl")
  expect_equal(attr(l3, "type"), "xml")
  expect_equal(attr(l3, "member"), "78")
  expect_named(l3, "xml")

  expect_is(l4, "tdmurl")
  expect_equal(attr(l4, "type"), "html")
  expect_equal(attr(l4, "member"), "4443")
  expect_named(l4, "html")

  expect_is(l5, "list")
  expect_gt(length(l5), 2)
  expect_equal(attr(l5$pdf, "type"), "pdf")
  expect_equal(attr(l5$xml, "type"), "xml")
  expect_equal(attr(l5$html, "type"), "html")
  expect_equal(attr(l5$pdf, "member"), "4443")
  expect_equal(attr(l5$xml, "member"), "4443")
  expect_equal(attr(l5$html, "member"), "4443")
  expect_true('pdf' %in% names(l5))

  expect_identical(l5, l6)
})

test_that("crm_links fails correctly", {
  expect_error(crm_links(), 'argument "doi" is missing')
  #expect_null(crm_links("10.7717/peerj.1268", type = "adfasf"))

  skip_on_cran()
  expect_warning(crm_links("3434"), "Resource not found")
})

orig_email <- Sys.getenv("crossref_email")

test_that("crm_links - email works", {
  Sys.setenv("crossref_email" = "name@example.com")
  a <- crm_links("10.7717/peerj.2363")
  expect_is(a, "list")
})

test_that("crm_links - email utility functions work", {
  Sys.setenv("crossref_email" = "name@example.com")
  mt <- email_get()
  expect_is(mt, "character")
  expect_match(mt, "\\(mailto:name@example.com\\)")

  Sys.setenv("crossref_email" = "name@example")
  expect_error(email_get(), "Email address \\(")

  expect_is(email_regex, "function")
  expect_match(email_regex(), "0-9")
  # good
  expect_true(grepl(email_regex(), "name@gmail.com"))
  # bad
  expect_false(grepl(email_regex(), "name@gmail"))
  expect_false(grepl(email_regex(), "namegmail.com"))
  expect_false(grepl(email_regex(), "@gmail.com"))

  expect_is(val_email, "function")
  expect_equal(val_email("name@gmail.com"), "name@gmail.com")
  expect_error(val_email("name@gmail"), "not")
  expect_error(val_email("@gmail.com"), "not")
  expect_error(val_email("name@"), "not")
})

# reset to original env
Sys.setenv("crossref_email" = orig_email)
