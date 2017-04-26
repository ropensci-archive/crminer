context("crm_plain")

url <- "https://api.elsevier.com/content/article/PII:S0370269310012608?httpAccept=text/plain"
title <- "On the unitarity of linearized General Relativity coupled to matter"

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  link1 <- crm_links("10.1016/j.physletb.2010.10.049", "plain")
}

test_that("crm_plain works with links input",{
  skip_on_cran()

  res <- suppressMessages(crm_plain(link1))
  expect_is(res, "character")
  expect_gt(nchar(res), 100000L)
  expect_match(res, title)
})

test_that("crm_plain works with character URL input", {
  skip_on_cran()

  res <- suppressMessages(crm_plain(url))
  expect_is(res, "character")
  expect_gt(nchar(res), 100000L)
  expect_match(res, title)
})

test_that("crm_plain fails well",{
  expect_error(crm_plain(5), "no 'crm_plain' method for numeric")
  expect_error(crm_plain(mtcars), "no 'crm_plain' method for data.frame")
  expect_error(crm_plain(matrix(1:5)), "no 'crm_plain' method for matrix")

  expect_error(crm_plain("adfdf"), "Not a proper url")

  skip_on_cran()
  expect_error(crm_plain(link1, overwrite_unspecified = 5),
               "overwrite_unspecified must be of class logical")
})
