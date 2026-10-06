# 00_setup_packages.R
# Robust package setup for a fresh (or freshly upgraded) R installation.
#
# Why this exists: right after a new R release (e.g. 4.6.x), your old
# library may contain packages built for the previous R version, and
# CRAN binaries for Windows/macOS can lag a few days behind. The usual
# symptoms are `library(ggplot2)` failing with messages like
#   "package 'ggplot2' was built under R version ..."
#   "namespace 'rlang' 1.1.x is already loaded, but >= 1.1.y is required"
#   "there is no package called 'vctrs'"
# The functions below check, install or repair, and report what happened,
# without stopping the whole script.

# Use a fixed, reliable CRAN mirror (Posit's CDN), so we never get the
# "please select a CRAN mirror" pop-up.
options(repos = c(CRAN = "https://cloud.r-project.org"))

# 1. Print basic environment info --------------------------------------------
report_environment <- function() {
  cat("R version   :", R.version.string, "\n")
  cat("Platform    :", R.version$platform, "\n")
  cat("Library path(s):\n")
  for (p in .libPaths()) cat("   -", p, "\n")
  invisible(NULL)
}

# 2. Install missing packages (with their dependencies) and load them --------
#    Returns a named logical vector: TRUE = loaded OK.
ensure_packages <- function(pkgs, upgrade_old = FALSE) {
  if (upgrade_old) {
    # Rebuild or upgrade anything that was built for an older R version.
    # checkBuilt = TRUE is the important bit after an R upgrade.
    message("Updating old packages (checkBuilt = TRUE) ...")
    try(update.packages(ask = FALSE, checkBuilt = TRUE), silent = TRUE)
  }

  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    message("Installing: ", paste(missing, collapse = ", "))
    # dependencies = TRUE pulls in Imports/Depends/LinkingTo (+ Suggests).
    # Use c("Depends", "Imports", "LinkingTo") if you want a lighter install.
    tryCatch(
      install.packages(missing, dependencies = c("Depends", "Imports", "LinkingTo")),
      error = function(e) message("install.packages() failed: ", conditionMessage(e))
    )
  }

  ok <- vapply(pkgs, function(p) {
    loaded <- tryCatch({
      suppressPackageStartupMessages(library(p, character.only = TRUE))
      TRUE
    }, error = function(e) {
      message(sprintf("Could not load '%s': %s", p, conditionMessage(e)))
      FALSE
    })
    loaded
  }, logical(1))

  for (p in names(ok)) {
    ver <- if (ok[[p]]) as.character(utils::packageVersion(p)) else "-"
    cat(sprintf("  %-10s %-8s %s\n", p, if (ok[[p]]) "OK" else "FAILED", ver))
  }
  invisible(ok)
}

# 3. Optional: project-local library with renv -------------------------------
# renv gives every project its own package library and a lockfile, so an R
# upgrade (or another course) can't break this project's packages.
#   install.packages("renv")
#   renv::init()       # once, creates renv.lock + project library
#   renv::snapshot()   # after installing/updating packages
#   renv::restore()    # on another machine / after reinstalling R
