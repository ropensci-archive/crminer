crminer
=======



[![cran checks](https://cranchecks.info/badges/worst/crminer)](https://cranchecks.info/pkgs/crminer)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/ropensci/crminer.svg?branch=master)](https://travis-ci.org/ropensci/crminer)
[![codecov.io](https://codecov.io/github/ropensci/crminer/coverage.svg?branch=master)](https://codecov.io/github/ropensci/crminer?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/crminer)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/crminer)](https://cran.r-project.org/package=crminer)

[Crossref](https://www.crossref.org/) is a not-for-profit membership organization for
scholarly publishing. For our purposes here, they provide a nice
[search API](https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md)
for metadata for scholarly works.

Publishers can optionally provide links in metadata they provide to Crossref for
full text of the work, but that data is often missing, although coverage of links
does seem to increase through time. Find out more about it
at <http://tdmsupport.crossref.org/>

See <https://github.com/ropensci/rcrossref> for a full fledged R client
for working with the [Crossref search API](https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md).

`crminer` focuses only on getting the user full text via the Crossref
search API. That is, this client depends on the full text links provided
by publishers in the Crossref search API. Clearly `crminer` will
become more useful as a higher percentage of scholarly works have full text
links in the API.

For our purposes there's two types of scholarly works you want to get full
text for via this package. First, those that require no authentication.
`crminer` should work easily for these. Second, those that require
authentication. These scholarly works will require some extra work to
get to, and you have to be fortunate enough to have an institution that
gets access to the content. More discussion next:


## Authentication

Authentication is applicable only when the publisher you want to get
fulltext from requires it. OA publishers shouldn't need it as you'd
expect, and there's some papers from typically closed publishers
that are open (a good way to check this is the license on the paper [
see `rcrossref`]). There's many publishers that don't share links at all,
so they are irrelevant here.

For publishers that required authentication, the Crossref TDM
program allows for a single token to authenticate across publishers
(to make it easier for text miners). The publishers involved with the
authentication scheme are really only Elsevier and Wiley - these two
publishers make up a lot of the papers out there and a lot of the
links on the Crossref API.

There's a how to guide for Crossref TDM at
<http://tdmsupport.crossref.org/researchers/>.
Get your Crossref TDM token by registering at
<https://apps.crossref.org/clickthrough/researchers>.
Save the token in your `.Renviron` file with a new row like
`CROSSREF_TDM=your key`. We will read that key in for you - it's best
this way rather than passing in a key via a parameter - since you might
put that code up on the web somewhere and someone could use your key.

### IP addresses

If you don't know what IP addresses are, check out
<https://en.wikipedia.org/wiki/IP_address>. At least Elsevier and
I think Wiley also check your IP address in addition to requiring the
authentication token. Usually your're good if you're physically at the
institution that has access to the publishers content OR on a VPN
(i.e., pretending you're there).

If you forget about this, you'll get errors about not being authorized.
So check and make sure you're on a VPN if you're not physically
located at your institution.

### Fences

There's yet another issue to worry about. At least with Elsevier, they
have a so-called "fence" - that is, even if an institution has access
to Elsevier content, Elsevier doesn't necessarily have the fence
turned off - if its not off, you can't get through - if it's off, you can.
If you have the right token and you are sure you're on the right
IP address, this could be the problem for your lack of access. If that happens
get in touch with me at <mailto:scott@ropensci.org> and i'll try to sort it out.

### HELP!

If you're having trouble with any of this [open an issue](https://github.com/ropensci/crminer/issues)

### Help in package

The above text about auth is also at `?auth` after installing `crminer`.

## Package API

* `as_tdmurl()` - coerce a URL to a `tdmurl` object
* `crm_extract()` - extract text from a PDF
* `crm_links()` - get full text links from DOIs
* `crm_html()` - fetch full text html
* `crm_pdf()` - fetch full text pdf
* `crm_plain()` - fetch full plain text
* `crm_text()` - general purpose full text fetcher
* `crm_xml()` - fetch full text xml

## Install

CRAN version


```r
install.packages("crminer")
```

Development version


```r
devtools::install_github("ropensci/crminer")
```


```r
library("crminer")
```

## Get full text links

Load some dois from `crminer`


```r
data(dois_pensoft)
```

Get full text links with `crm_links()`


```r
links <- lapply(dois_pensoft[1:3], crm_links, type = "xml")
```

## Get full text

### XML

Then use one of those URLs to get full text


```r
crm_text(url = links[[1]])
#> {xml_document}
#> <article article-type="research-article" dtd-version="1.0" xmlns:xlink="http://www.w3.org/1999/xlink" ...
#> [1] <front>\n  <journal-meta>\n    <journal-id journal-id-type="publisher-id">peerj-cs</journal-id>\n ...
#> [2] <body>\n  <sec sec-type="intro">\n    <title>Introduction</title>\n    <p>The question of natural ...
#> [3] <back>\n  <sec sec-type="additional-information">\n    <title>Additional Information and Declarat ...
```

You can also use `crm_xml()` to get XML.

### PDF

Get PDF full text links with `crm_links()`


```r
links <- lapply(dois_pensoft[1:3], crm_links, type = "pdf")
```

Then get pdf and text is extracted


```r
(res <- crm_text(url = links[[1]], type = "pdf"))
```

```
#> <document>/Users/sckott/Library/Caches/R/crminer/10445.pdf
#>   Pages: 28
#>   No. characters: 73844
#>   Created: 2106-02-07
```


```r
cat(substring(res$text[[1]], 1, 300))
```

```
#>                                       Research Ideas and Outcomes 2: e10445
#>                                       doi: 10.3897/rio.2.e10445
#>                                                           Project Report
#> EMODnet Workshop on mechanisms and guidelines
#> to mobilise historical data into biogeogr
```

You can also use `crm_pdf()` to get PDF.

## Extract text from pdf

If you already have a path to the pdf, use `crm_extract()`


```r
path <- system.file("examples", "MairChamberlain2014RJournal.pdf", package = "crminer")
(res <- crm_extract(path))
```

```
#> <document>/Library/Frameworks/R.framework/Versions/3.5/Resources/library/crminer/examples/MairChamberlain2014RJournal.pdf
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

* Please [report any issues or bugs](https://github.com/ropensci/crminer/issues).
* License: MIT
* Get citation information for `crminer` in R doing `citation(package = 'crminer')`
* Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[![rofooter](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
