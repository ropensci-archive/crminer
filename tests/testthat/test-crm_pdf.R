context("crm_pdf")

test_that("crm_pdf works for 'unspecified' = TRUE",{
  skip_if_not(Sys.getenv("CROSSREF_TDM") != "",
              "Needs 'Sys.setenv(CROSSREF_TDM = \"your-key\")' to be set.")
  links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")

  res <- crm_pdf(links, overwrite_unspecified = TRUE)
  expect_equal(res$info$pages, 11)
})

test_that("crm_pdf fails for 'unspecified' = FALSE",{
  links <- crm_links("10.2903/j.efsa.2014.3550", type = "all")

  expect_error(crm_pdf(links, overwrite_unspecified = FALSE),
              "no pdf link found")
})
