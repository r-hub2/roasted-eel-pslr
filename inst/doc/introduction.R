## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(pslr)

## -----------------------------------------------------------------------------
public_suffix("www.example.co.uk")
registrable_domain("www.example.co.uk")

## -----------------------------------------------------------------------------
public_suffix("a.b.kobe.jp") # a wildcard match under kobe.jp
public_suffix("city.kobe.jp") # an exception match under kobe.jp

## -----------------------------------------------------------------------------
# github.io is a PRIVATE rule sitting under the ICANN suffix io.
public_suffix("user.github.io", section = "all") # default scope, both sections
public_suffix("user.github.io", section = "icann") # the ICANN rule for io
public_suffix("user.github.io", section = "private")

## -----------------------------------------------------------------------------
public_suffix("example.com", section = "private")

## -----------------------------------------------------------------------------
public_suffix("example.madeuptld") # default rule
public_suffix("example.madeuptld", unknown = "na") # explicit-only

## -----------------------------------------------------------------------------
is_public_suffix("co.uk")
is_public_suffix("madeuptld") # TRUE via the implicit default rule
is_public_suffix("madeuptld", unknown = "na") # explicit membership only

## -----------------------------------------------------------------------------
public_suffix("example.рф") # ASCII A-label by default
public_suffix("example.рф", output = "unicode") # decoded to Unicode
public_suffix("example.xn--p1ai") # the A-label spelling agrees

## -----------------------------------------------------------------------------
public_suffix("www.example.com.")
registrable_domain("www.example.com.")

## -----------------------------------------------------------------------------
suffix_extract("blog.user.github.io")
public_suffix_rule(c("www.ck", "a.b.kobe.jp", "example.madeuptld"))

## ----eval = FALSE-------------------------------------------------------------
# # Revalidate against upstream, publish any changed bytes, and activate them:
# psl_refresh(activate = TRUE)
# 
# # Switch the active list for this session:
# psl_use("cache") # the snapshot the last refresh selected
# psl_use("bundled") # back to the shipped snapshot
# psl_use("path", path = "my_list.dat") # a custom file

## ----freshness-setup, include = FALSE-----------------------------------------
# Build this vignette against an empty snapshot cache, so its output describes
# a fresh installation rather than whatever the building machine refreshed.
options(
  pslr.cache_dir = file.path(tempdir(), "pslr-vignette-cache"),
  pslr.config_dir = file.path(tempdir(), "pslr-vignette-config")
)

## -----------------------------------------------------------------------------
psl_status() # the list active in this session
psl_status("bundled")$state # the snapshot installed with the package

## ----eval = FALSE-------------------------------------------------------------
# psl_reminder(enable = TRUE) # weekly by default
# psl_reminder(enable = TRUE, every = 30) # or a month
# psl_reminder(enable = FALSE) # off; the interval is remembered
# psl_reminder() # just query, writes nothing

## ----eval = FALSE-------------------------------------------------------------
# # refresh-psl.R
# pslr::psl_refresh()

## -----------------------------------------------------------------------------
snapshots <- psl_snapshots()
snapshots[c("checksum", "bundled", "size", "integrity")]

## ----eval = FALSE-------------------------------------------------------------
# psl_cache_prune() # referenced snapshots, plus one more
# psl_cache_prune(keep = 0) # referenced snapshots only

## ----eval = FALSE-------------------------------------------------------------
# # After at least one psl_refresh(), the cache selection is a second snapshot:
# changes <- psl_diff("bundled", "cache")
# table(changes$change)
# head(changes)

## -----------------------------------------------------------------------------
write_list <- function(private) {
  path <- tempfile(fileext = ".dat")
  writeLines(
    c(
      "// ===BEGIN ICANN DOMAINS===",
      "com",
      "// ===END ICANN DOMAINS===",
      "// ===BEGIN PRIVATE DOMAINS===",
      private,
      "// ===END PRIVATE DOMAINS==="
    ),
    path
  )
  path
}

psl_diff(
  write_list(c("a.example.com", "*.b.example.com")),
  write_list(c("b.example.com", "c.example.com"))
)

## -----------------------------------------------------------------------------
d <- psl_diff("bundled", "bundled")
attr(d, "old_version")[c("source", "checksum")]

## -----------------------------------------------------------------------------
engine <- psl_engine("bundled")
public_suffix("example.co.uk", engine = engine)
suffix_extract("www.example.co.uk", engine = engine)

## ----eval = FALSE-------------------------------------------------------------
# # In the target process, rebuild from a recorded snapshot file:
# engine <- psl_engine("path", path = "my_list.dat")

## -----------------------------------------------------------------------------
psl_version()

## -----------------------------------------------------------------------------
nrow(psl_rules("icann"))
head(psl_rules("private"), 3)

