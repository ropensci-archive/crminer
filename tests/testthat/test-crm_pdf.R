context("crm_pdf")

test_that("crm_pdf works for 'unspecified'",{
  links <- crm_links("10.2903/j.efsa.2014.3550",type = "all")

  res <- crm_pdf(links,overwriteUnspecified = T)
  expect_equal(res$info$pages,11)
})

test_that("crm_pdf works for 'unspecified'",{
  links <- crm_links("10.2903/j.efsa.2014.3550",type = "all")

  expect_error(crm_pdf(links,overwriteUnspecified = F),
              "no pdf link found")

})