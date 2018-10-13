#' @title Caching
#'
#' @description Manage cached `crminer` files with \pkg{hoardr}
#'
#' @export
#' @name crm_cache
#'
#' @details The dafault cache directory is
#' `paste0(rappdirs::user_cache_dir(), "/R/crminer")`, but you can set
#' your own path using `cache_path_set()`
#'
#' `cache_delete` only accepts 1 file name, while
#' `cache_delete_all` doesn't accept any names, but deletes all files.
#' For deleting many specific files, use `cache_delete` in a [lapply()]
#' type call
#'
#' @section Useful user functions:
#'
#' - `crm_cache$cache_path_get()` get cache path
#' - `crm_cache$cache_path_set()` set cache path. You can set the 
#'    entire path directly via the `full_path` arg like 
#'   `crm_cache$cache_path_set(full_path = "your/path")`
#' - `crm_cache$list()` returns a character vector of full
#'    path file names
#' - `crm_cache$files()` returns file objects with metadata
#' - `crm_cache$details()` returns files with details
#' - `crm_cache$delete()` delete specific files
#' - `crm_cache$delete_all()` delete all files, returns nothing
#'
#' @examples \dontrun{
#' crm_cache
#'
#' # list files in cache
#' crm_cache$list()
#'
#' # delete certain database files
#' # crm_cache$delete("file path")
#' # crm_cache$list()
#'
#' # delete all files in cache
#' # crm_cache$delete_all()
#' # crm_cache$list()
#' }
NULL
