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

# test_that("try_ocr parameter", {
#   skip_on_cran()
#   skip_on_travis()
#   skip_on_appveyor()
#
#   # doi <- '10.1006/jeth.1993.1066'
#   path <- system.file("examples", "S0022053183710665.pdf",
#     package = "crminer")
#   ocr_false <- crm_extract(path, try_ocr = FALSE)
#   expect_is(ocr_false, "crm_pdf")
#   expect_true(!all(nzchar(ocr_false$text)))
#
#   ocr_true <- crm_extract(path, try_ocr = TRUE)
#   expect_is(ocr_true, "crm_pdf")
#   expect_true(all(nzchar(ocr_true$text)))
# })
