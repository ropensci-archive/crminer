library("vcr")
vcr::vcr_configure(
  dir = "../fixtures",
  write_disk_path = "../files",
  filter_sensitive_data =
    list("<<crossref-tdm-token>>" = Sys.getenv("CROSSREF_TDM"))
)
vcr::check_cassette_names()
