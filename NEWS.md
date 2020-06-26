crminer 0.4.0
=============

### NEW FEATURES

* `crm_pdf()` and `crm_text()` lose the `cache` parameter, which toggled whether or not to use caching. those functions always cache requests now (#37)
* `crm_extract()` gains parameter `try_ocr` (logical, default: `FALSE`) to optionally try Optical Character Recognition (OCR) with extract pdf pages if the pdf is scanned images. extraction can take a while, but the result is cached, so will be very fast on subsequent requests for the same article (#37)

### MINOR IMPROVEMENTS

* `crm_plain()`, `crm_xml()`, `crm_html()`, and `crm_text()` now cache articles as `crm_pdf()` has for a while. Along with this change caching is now split into separate folders for pdf, txt (for plain), xml, and html (#17)
* internally force Pensoft publisher urls to https from http (#48)
* added docs section `User-agent` to `crm_html()`, `crm_pdf()`, `crm_plain()`, `crm_xml()`, and `crm_text()` detailing how users can set a user agent string with the `useragent` curl option (#41) (#42)
* fix a link in the README (#47) thanks @salim-b

### BUG FIXES

* for wiley articles, replace part of url `pdf` with `pdfdirect` for better access (#40)
* initially for wiley specific errors, extracted out internal function `try_extract_pdf_errors()` to attempt to extract various errors that occur when trying to download and extract text from pdfs (#40)
* eLife specific url fix in `crm_links()`, older url was leading to article landing pages (#6)
* fix for cases in which Elsevier returns just the first page of a pdf instead of the whole article. we show the user a warning when this occurs and delete the 1 page pdf file (#43)
* fix for weird article urls that end in not a file extenstion of pdf, but just the string 'pdf' following some other part of the url (#44)
* added special handling for malformed pdfs in `crm_pdf()`/`crm_text()` (with `type="pdf"`) - arose from a Cambridge publisher article, hopefully will handle all malformed pdfs (#45)
* change `crm_links()` to always include a pdf link even if no returned by Crossref - as almost always probably there is a pdf for every article, but the link just may not have been included in metadata sent to Crossref (#37)
* various fixes for Elsevier: A) fix for url parsing, was removing text after `?` (as they were all likely query params that we didn't need), but Elsevier gives the content type as a query param. B) some dois that are listed as having a non-Elsevier owner are actually owned by Elsevier now; special handling for those dois. C)  (#37)


crminer 0.3.2
=============

### MINOR IMPROVEMENTS

* now using `vcr` for tests that write to disk (#34)

### BUG FIXES

* fix for a case where a DOI's current owner differs from a previous owner  (#36)

crminer 0.3.0
=============

### MINOR IMPROVEMENTS

* replace all `xml2::xml_find_one` with `xml2::xml_find_first` (#32)

### BUG FIXES

* fix for `crm_links()`: fix full text links from Elsevier that have `httpss` instead of `https`  (#30) thanks @njahn82
* fix for `crm_links()`: the fuction wasn't using email header for Crossref polite pool - now it does if you provide your email address, see docs (#31)


crminer 0.2.0
=============

### NEW FEATURES

* `crm_cache$cache_path_set()` gains ability to set the full cache path directly via its `full_path` parameter via an update to package `hoardr`   (#27)

### MINOR IMPROVEMENTS

* add `raw` as another parameter in `crm_extract()` to allow raw byte extraction from a pdf (#24)
* add intended application (from crossref) to output of `crm_links()` to allow filtering on the intended application (#28)


crminer 0.1.4
=============

### BUG FIXES

* Fixed failing tests due to Crossref changing what they give
back for links - made tests robust to those changes (#21)


crminer 0.1.2
=============

### NEW FEATURES

* New object `crm_cache` for managing cached files, see `?crm_cache`
after installation (#19)

### MINOR IMPROVEMENTS

* Now using `hoardr` for managing cached files (#19)
* `crm_pdf()` and `crm_text()` lose the parameter `path` - instead cache
directory managed through `crm_cache`


crminer 0.1.0
=============

### NEW FEATURES

* Released to CRAN
