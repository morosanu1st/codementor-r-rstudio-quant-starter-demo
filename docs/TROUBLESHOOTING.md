# Troubleshooting: packages after a new R release (e.g. R 4.6.x)

"ggplot2 doesn't work" right after installing or upgrading R almost always comes down to one of the causes below. Go through them **in order**, and **restart R between steps** (RStudio: *Session → Restart R*, or `Ctrl/Cmd + Shift + F10`).

## Step 0: collect the facts (2 minutes)

```r
R.version.string          # which R is RStudio actually using?
.libPaths()               # where are packages installed?
packageVersion("ggplot2") # is it installed at all?
library(ggplot2)          # copy the FULL error message
sessionInfo()
```

In RStudio, *Tools → Global Options → General → R version* shows which R installation RStudio uses. If you have several installed, RStudio may be pointing at the old one.

## Symptom → fix

| Error / symptom | Likely cause | Fix |
|---|---|---|
| `there is no package called 'ggplot2'` | New minor R version (4.5 → 4.6) = **new, empty personal library** | `install.packages("ggplot2", dependencies = TRUE)` |
| `package 'X' was built under R version 4.y.z` | Only a **warning**. A binary built for a slightly different R | Usually harmless. Update when a newer binary is out |
| `namespace 'rlang' 1.1.x is already loaded, but >= 1.1.y is required` | An old dependency is already loaded in this session | **Restart R first**, then `install.packages(c("rlang","vctrs","cli","lifecycle","scales","ggplot2"))` |
| `package 'ggplot2' is not available for this version of R` | Mirror issue, a typo, or the CRAN **binary for a brand-new R isn't built yet** (Windows/macOS) | `options(repos = c(CRAN = "https://cloud.r-project.org"))`, try again; or `install.packages("ggplot2", type = "source")` (Windows needs Rtools matching your R version) |
| `Warning: 'lib = ...' is not writable` / asks to create a personal library | No write access to the system library | Answer **yes** to the personal library, or run `dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)` |
| `ERROR: failed to lock directory ... 00LOCK-ggplot2` | A previous install crashed | Delete the `00LOCK-*` folder inside `.libPaths()[1]`, restart, reinstall |
| `installation of package 'X' had non-zero exit status` | Compilation failed (source install) | Read *the first* error above it. Usually a missing compiler/system library (Rtools on Windows, Xcode CLT on macOS, `libcurl/libxml2/libfontconfig` dev packages on Linux) |
| `library(ggplot2)` works but **no plot appears** | In a script, function or loop, ggplot objects are not auto-printed | `print(p)` or `ggsave("plot.png", p)` |
| `Error in plot.new(): figure margins too large` | Plots pane too small | Enlarge the pane, or `dev.off()` and plot again |
| Old tutorial code errors with newer ggplot2 (4.x) | ggplot2 4.0 (2025) changed internals (S7 classes); some old extension packages / tricks broke | Update extension packages too (`update.packages(checkBuilt = TRUE)`). Check the error with the package's NEWS |
| RStudio crashes / weird behaviour with the new R | RStudio older than the R release | Update RStudio Desktop (Help → Check for Updates) |

## The "nuclear but safe" refresh

```r
# 1. Restart R first (Session -> Restart R)
options(repos = c(CRAN = "https://cloud.r-project.org"))
update.packages(ask = FALSE, checkBuilt = TRUE)   # rebuild/upgrade everything built for old R
install.packages("ggplot2", dependencies = TRUE)
# 2. Restart R again, then:
library(ggplot2)
ggplot(data.frame(x = c("a","b"), y = c(1, 2)), aes(x, y)) + geom_col()
```

## Always have a fallback

Base R graphics need no packages, so you can keep working while you fix the install:

```r
barplot(c(ALPHA = 1.9, BETA = 14.5, GAMMA = -10.0), col = "steelblue", ylab = "Return (%)")
```

`R/quant_starter.R` does this automatically: it uses ggplot2 if it loads, otherwise `barplot()`. Run it with `FORCE_BASE_PLOT=1` to see the fallback.

## Prevent it next time: renv

```r
install.packages("renv")
renv::init()       # project-local library + renv.lock
renv::snapshot()   # record versions after changes
renv::restore()    # recreate the exact library on a new machine / new R
```

With renv, upgrading R or working on another course can't silently break this project. You re-run `renv::restore()` and you're back to known-good versions.
