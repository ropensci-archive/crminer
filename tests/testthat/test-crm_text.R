context("crm_text")

# out <- cr_works(
#   filter = list(has_full_text = TRUE, license_url = "http://creativecommons.org/licenses/by/4.0/"),
#   limit = 100
# )

# links <- crm_links("10.7717/peerj.1282")
# xml1 <- cr_ft_text(links, 'xml')

test_that("crm_text works: pdf", {
  links <- crm_links("10.7717/peerj.1268", "pdf")
  pdf_read <- crm_text(links, "pdf", read = FALSE, verbose = FALSE)
  pdf <- crm_text(links, "pdf", verbose = FALSE)

  #expect_is(xml1, "xml_document")
  expect_is(pdf_read, "character")
  expect_is(pdf, "crm_pdf")

  #expect_equal(length(xml1), 2)
  expect_equal(length(pdf_read), 1)
  expect_equal(length(pdf), 2)
  expect_is(pdf$info, "list")
  expect_equal(length(pdf$text), pdf$info$pages)
})

# test_that("cr_ft_text gives back right values", {
#   library("xml2")
#   expect_match(xml2::xml_find_all(xml1, "//ref")[[1]], "Ake AssiL")
#   expect_match(pdf_read, "~/.crossref")
# })

test_that("crm_text fails correctly", {
  expect_error(crm_text(), 'argument "url" is missing')
  expect_error(crm_text("3434"), "a character vector argument expected")

  links <- crm_links("10.1155/mbd.1994.183", "all")
  expect_error(crm_text(links, type = "adfasf"), "'arg' should be one of")
})

test_that("crm_text with pdf works for 'unspecified' = TRUE",{
  skip_if_not(Sys.getenv("CROSSREF_TDM") != "",
              "Needs 'Sys.setenv(CROSSREF_TDM = \"your-key\")' to be set.")
  links <- crm_links("10.2903/j.efsa.2014.3550",type = "all")

  res <- crm_text(links, type = "pdf", overwrite_unspecified = TRUE)
  expect_equal(res$info$pages, 11)
})

test_that("crm_text with pdf fails for 'unspecified' = FALSE",{
  links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")

  expect_error(crm_text(links, type = "pdf", overwrite_unspecified = FALSE),
              "Chosen type not available in links")
})

