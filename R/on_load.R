crm_cache <- NULL

.onLoad <- function(libname, pkgname){
  x <- hoardr::hoard()
  x$cache_path_set("crminer")
  crm_cache <<- x
}
