context("cache")

test_that("crm_cache structure is as expected", {
  expect_is(crm_cache, "HoardClient")
  expect_is(crm_cache, "R6")
  expect_is(crm_cache$cache_path_get, "function")
  expect_is(crm_cache$cache_path_set, "function")
  expect_is(crm_cache$compress, "function")
  expect_is(crm_cache$uncompress, "function")
  expect_is(crm_cache$delete, "function")
  expect_is(crm_cache$delete_all, "function")
  expect_is(crm_cache$details, "function")
  expect_is(crm_cache$files, "function")
  expect_is(crm_cache$key, "function")
  expect_is(crm_cache$keys, "function")
  expect_is(crm_cache$list, "function")
  expect_is(crm_cache$mkdir, "function")
  expect_is(crm_cache$print, "function")

  expect_is(crm_cache$path, "character")
  expect_null(crm_cache$type)
})


test_that("crm_cache works as expected", {
  skip_on_cran()

  # clear cache in case any in there
  crm_cache$delete_all()

  # cache should be empty
  expect_equal(length(crm_cache$list()), 0)

  # message on delete all
  expect_message(crm_cache$delete_all(), "no files found")

  # message on delete all
  expect_error(crm_cache$delete(), "argument \"files\" is missing")
  expect_error(crm_cache$delete("adfdf"), "These files don't exist")

  # details, with no files
  expect_is(crm_cache$details(), "cache_info")

  # files is NULL
  expect_null(crm_cache$files())

  # keys is NULL
  expect_null(crm_cache$keys())

  # key is NULL and errors well when file not found
  expect_error(crm_cache$key(), "argument \"x\" is missing")
  expect_error(crm_cache$key("ADfdf"), "file does not exist")

  # path is default
  expect_equal(crm_cache$path, "crminer")
})
