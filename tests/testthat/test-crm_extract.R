context("crm_extract")

test_that("crm_extract works, eg1", {
  path <- system.file("examples", "MairChamberlain2014RJournal.pdf",
      package = "crminer")
  aa <- crm_extract(path)

  expect_is(aa, "crm_pdf")
  expect_named(aa, c("info", "text"))
  expect_is(aa$info, "list")
  expect_is(aa$text, "character")
  expect_true(grepl("Technologies", aa$text[1]))
})

test_that("crm_extract works, eg2", {
  path <- system.file("examples", "ChamberlainEtal2013Ecosphere.pdf",
                      package = "crminer")
  aa <- crm_extract(path)

  expect_is(aa, "crm_pdf")
  expect_named(aa, c("info", "text"))
  expect_is(aa$info, "list")
  expect_is(aa$text, "character")
  expect_true(grepl("agriculture", aa$text[1]))
})

test_that("crm_extract works with raw input", {
  path <- system.file("examples", "raw-example.rds", package = "crminer")
  rds <- readRDS(path)
  aa <- crm_extract(raw = rds)

  expect_is(aa, "crm_pdf")
  expect_named(aa, c("info", "text"))
  expect_is(aa$info, "list")
  expect_is(aa$text, "character")
  expect_equal(attr(aa, "path"), "raw")
  expect_true(grepl("inhibition", aa$text[1]))
})


test_that("crm_extract fails well", {
  expect_error(crm_extract(4, 5), 'is not TRUE')
  expect_error(crm_extract("3434"), "path does not exist")
  expect_error(crm_extract(raw = 5), 'raw must be of class raw')
})
