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
