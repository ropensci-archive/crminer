context("utils")

test_that("alter_url", {
  # wiley
  ## pdf -> pdfdirect
  x = "https://onlinelibrary.wiley.com/doi/pdf/10.1111/1477-9552.12353"
  expect_match(alter_url(x), "pdfdirect")

  ## http scheme should be https not http
  z = "http://api.wiley.com/onlinelibrary/tdm/v1/articles/10.1111%2Fj.2164-0947.1942.tb00833.x"
  expect_match(alter_url(z), "https")
})

test_that("make_file_path", {
  # pensoft
  doi1 <- '10.3897/zookeys.762.20335'
  url1 <- "https://zookeys.pensoft.net/lib/ajax_srv/article_elements_srv.php?action=download_pdf&item_id=20335"

  # with doi
  path1 <- make_file_path(url1, doi1, 'pdf')
  expect_is(path1, "character")
  expect_match(path1, "10.3897.zookeys.762.20335")

  # if leave doi NULL
  path2 <- make_file_path(url1, NULL, 'pdf')
  expect_is(path2, "character")
  expect_match(path2, "20335")


  # other
  doi3 <- '10.1006/jeth.1993.1066'
  url3 <- "https://api.elsevier.com/content/article/PII:S0022053183710665?httpAccept=application/pdf"

  # with doi
  path3 <- make_file_path(url3, doi3, 'pdf')
  expect_is(path3, "character")
  expect_match(path3, "PII:S0022053183710665")
  # removes query parameters
  expect_false(grepl("httpAccept", path3))

  # if leave doi NULL - doesn't change anything
  path4 <- make_file_path(url3, NULL, 'pdf')
  expect_identical(path3, path4)
})

test_that("maybe_overwrite_unspecified", {
  url = list(unspecified = "foobar")
  a <- maybe_overwrite_unspecified(FALSE, url, "pdf")
  expect_is(a, "list")
  expect_named(a, "unspecified")

  b <- maybe_overwrite_unspecified(TRUE, url, "pdf")
  expect_is(b, "list")
  expect_named(b, "pdf")

  d <- maybe_overwrite_unspecified(TRUE, url, "xml")
  expect_is(d, "list")
  expect_named(d, "xml")
})
