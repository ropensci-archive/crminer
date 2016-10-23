crminer
=======



[![Build Status](https://travis-ci.org/ropenscilabs/crminer.svg?branch=master)](https://travis-ci.org/ropenscilabs/crminer)
[![codecov.io](https://codecov.io/github/ropenscilabs/crminer/coverage.svg?branch=master)](https://codecov.io/github/ropenscilabs/crminer?branch=master)

Publishers can optionally provide links in the metadata they provide to Crossref for full text of the work, but that data is often missing. Find out more about it at [http://tdmsupport.crossref.org/](http://tdmsupport.crossref.org/).

## Authentication

coming soon ...

## Install

Development version


```r
devtools::install_github("ropenscilabs/crminer")
```


```r
library("crminer")
library("rcrossref")
```

## Search

Get some DOIs for articles that provide full text, and that have
`CC-BY 4.0` licenses (i.e., more likely to actually be open), and from
PeerJ


```r
out <-
  cr_members(4443, works = TRUE, filter = list(
    has_full_text = TRUE,
    license_url = "http://creativecommons.org/licenses/by/4.0/")
  )
(dois <- out$data$DOI)
```

```
#>  [1] "10.7717/peerj-cs.23" "10.7717/peerj.1229"  "10.7717/peerj.1256" 
#>  [4] "10.7717/peerj.1257"  "10.7717/peerj.1259"  "10.7717/peerj.1261" 
#>  [7] "10.7717/peerj.1263"  "10.7717/peerj.1265"  "10.7717/peerj.1268" 
#> [10] "10.7717/peerj.1269"  "10.7717/peerj.1258"  "10.7717/peerj-cs.32"
#> [13] "10.7717/peerj.1287"  "10.7717/peerj.1286"  "10.7717/peerj.1285" 
#> [16] "10.7717/peerj.1282"  "10.7717/peerj.1279"  "10.7717/peerj.1278" 
#> [19] "10.7717/peerj.1275"  "10.7717/peerj.1241"
```

## Get full text links

Then get URLs to full text content


```r
links <- lapply(dois, crm_links, type = "xml")
(links <- Filter(Negate(is.null), links))[1:5]
```

```
#> [[1]]
#> <url> https://peerj.com/articles/cs-23.xml
#> 
#> [[2]]
#> <url> https://peerj.com/articles/1229.xml
#> 
#> [[3]]
#> <url> https://peerj.com/articles/1256.xml
#> 
#> [[4]]
#> <url> https://peerj.com/articles/1257.xml
#> 
#> [[5]]
#> <url> https://peerj.com/articles/1259.xml
```

## Get full text

### XML

Then use those URLs to get full text


```r
crm_text(url = links[[1]])
#> {xml_document}
#> <article article-type="research-article" dtd-version="1.0" xmlns:xlink="http://www.w3.org/1999/xlink" ...
#> [1] <front>\n  <journal-meta>\n    <journal-id journal-id-type="publisher-id">peerj-cs</journal-id>\n ...
#> [2] <body>\n  <sec sec-type="intro">\n    <title>Introduction</title>\n    <p>The question of natural ...
#> [3] <back>\n  <sec sec-type="additional-information">\n    <title>Additional Information and Declarat ...
```

### PDF

Sometimes you can only get a pdf, in that case we will extract text from 
the pdf for you on use of `crm_text()`


```r
links <- lapply(dois, crm_links, type = "pdf")
(links <- Filter(Negate(is.null), links))[1:5]
```

```
#> [[1]]
#> <url> https://peerj.com/articles/cs-23.pdf
#> 
#> [[2]]
#> <url> https://peerj.com/articles/1229.pdf
#> 
#> [[3]]
#> <url> https://peerj.com/articles/1256.pdf
#> 
#> [[4]]
#> <url> https://peerj.com/articles/1257.pdf
#> 
#> [[5]]
#> <url> https://peerj.com/articles/1259.pdf
```

The get pdf and text is extracted


```r
(res <- crm_text(url = links[[1]], type = "pdf"))
```


```r
cat(substring(res$text[[1]], 1, 300))
```

```
#> N EWS AND N OTES                                                                                                     178
#>           Web Technologies Task View
#>           by Patrick Mair and Scott Chamberlain
#>           Abstract This article presents the CRAN Task View on Web Technologies. We describe t
```

## Extract text from pdf

If you already have a path to the pdf, use `crm_extract()`


```r
path <- system.file("examples", "MairChamberlain2014RJournal.pdf", package = "crminer")
(res <- crm_extract(path))
```

```
#> <document>/Library/Frameworks/R.framework/Versions/3.3/Resources/library/crminer/examples/MairChamberlain2014RJournal.pdf
#>   Pages: 4
#>   No. characters: 17358
#>   Created: 2014-07-29
```

```r
res$info
```

```
#> $version
#> [1] "1.5"
#> 
#> $pages
#> [1] 4
#> 
#> $encrypted
#> [1] FALSE
#> 
#> $linearized
#> [1] FALSE
#> 
#> $keys
#> $keys$Creator
#> [1] "pdftk 2.02 - www.pdftk.com"
#> 
#> $keys$Producer
#> [1] "itext-paulo-155 (itextpdf.sf.net-lowagie.com)"
#> 
#> 
#> $created
#> [1] "2014-07-29 00:14:10 PDT"
#> 
#> $modified
#> [1] "2014-07-29 00:14:10 PDT"
#> 
#> $metadata
#> [1] ""
#> 
#> $locked
#> [1] FALSE
#> 
#> $attachments
#> [1] FALSE
#> 
#> $layout
#> [1] "no_layout"
```

```r
cat(substring(res$text[[1]], 1, 300))
```

```
#> N EWS AND N OTES                                                                                                     178
#>           Web Technologies Task View
#>           by Patrick Mair and Scott Chamberlain
#>           Abstract This article presents the CRAN Task View on Web Technologies. We describe t
```


## Meta

* Please [report any issues or bugs](https://github.com/ropenscilabs/crminer/issues).
* License: MIT
* Get citation information for `crminer` in R doing `citation(package = 'crminer')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
