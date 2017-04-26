context("as_tdmurl")

test_that("as_tdmurl - ", {
  aa <- as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.xml",
   "xml")
  bb <- as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.pdf",
     "pdf")
  cc <-
   as_tdmurl("http://downloads.hindawi.com/journals/bmri/2014/201717.pdf",
     "pdf", "10.1155/2014/201717")

  expect_is(aa, "tdmurl")
  expect_is(bb, "tdmurl")
  expect_is(cc, "tdmurl")

  expect_equal(attr(aa, "type"), "xml")
  expect_equal(attr(bb, "type"), "pdf")
  expect_equal(attr(cc, "type"), "pdf")

  expect_equal(
    unclass(aa)[1]$xml,
    "http://downloads.hindawi.com/journals/bmri/2014/201717.xml")
  expect_equal(
    unclass(bb)[1]$pdf,
    "http://downloads.hindawi.com/journals/bmri/2014/201717.pdf")
  expect_equal(
    unclass(cc)[1]$pdf,
    "http://downloads.hindawi.com/journals/bmri/2014/201717.pdf")
})

