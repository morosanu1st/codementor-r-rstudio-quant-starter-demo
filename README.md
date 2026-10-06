# R / RStudio quant research starter

A beginner-friendly R starter for a **quantitative research master's**. It covers a robust package setup (so `ggplot2` works on a fresh R 4.6.x install), data-frame basics, bar charts in **ggplot2 with a base-R fallback**, and simple **returns and summary statistics** on bundled sample price data. A troubleshooting guide covers package-version problems on new R releases.

Built by **Mihai Chindriș**, software engineer and tutor (BSc Computer Science, TU Cluj 2019; MSc Business Intelligence, TU Wien, in progress).

## What's included

```
R/00_setup_packages.R   report_environment(), ensure_packages(): install with dependencies,
                        load safely, report OK/FAILED + versions; renv notes
R/quant_starter.R       full walkthrough script (run with Source in RStudio or Rscript)
quant_starter.Rmd       the same lesson as an R Markdown notebook (Knit to HTML)
data/prices.csv         60 trading days of fictional prices for ALPHA, BETA, GAMMA
docs/TROUBLESHOOTING.md symptom → fix table for package issues after an R upgrade
quant-starter.Rproj     open this in RStudio so paths "just work"
```

The walkthrough covers:

1. **Environment check**: R version, library paths, package status, `sessionInfo()`
2. **Data frames**: create, `str()`, add columns, filter, sort, `read.csv()`, `table()`
3. **Simple and log returns** per ticker (`ave()`, no extra packages)
4. **Summary stats**: mean/sd of daily returns, annualised return/volatility, Sharpe (rf = 0), total return, max drawdown, correlation matrix
5. **Bar charts**: `ggplot2::geom_col()` / `geom_bar()`, and a `barplot()` fallback if ggplot2 can't load
6. Output saved to `output/` (`summary_stats.csv`, `total_return_bar.png`, `prices_base.png`)

## How to run

**RStudio:** open `quant-starter.Rproj`, then open `R/quant_starter.R` and click **Source**. Or open `quant_starter.Rmd` and click **Knit**.

**Terminal**, from the repo root:

```bash
Rscript R/quant_starter.R                    # uses ggplot2 if available
FORCE_BASE_PLOT=1 Rscript R/quant_starter.R  # demo the base-R fallback
Rscript -e 'rmarkdown::render("quant_starter.Rmd")'
```

The first run installs `ggplot2` (and its dependencies) if it is missing. After upgrading R, call `ensure_packages("ggplot2", upgrade_old = TRUE)` once.

Sample output:

```
  ggplot2    OK       3.5.1
 ticker n_days mean_daily sd_daily ann_return ann_vol sharpe_rf0 total_return
  ALPHA     59   0.000416  0.01393      0.105   0.221      0.475       0.0191
   BETA     59   0.002459  0.01802      0.620   0.286      2.166       0.1452
  GAMMA     59  -0.001753  0.00714     -0.442   0.113     -3.898      -0.0997
Saved (ggplot2): output/total_return_bar.png
```

## ggplot2 not working on R 4.6.1?

See **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**. In short: restart R, set the cloud CRAN mirror, `update.packages(ask = FALSE, checkBuilt = TRUE)`, `install.packages("ggplot2", dependencies = TRUE)`, restart again. Make sure RStudio itself is up to date and pointing at the R version you expect.

## How I'd help: 5-week plan, 2 hours/week

| Week | Focus | You leave with |
|---|---|---|
| 1 | **Setup that works**: fix the R 4.6.1 / ggplot2 install together, RStudio tour, projects, scripts vs console, renv | A working environment and this repo running on *your* machine |
| 2 | **Data frames and data import**: types, indexing, filtering, sorting, `read.csv`, dates, missing values, tidy vs wide | Clean price/return tables from your own data files |
| 3 | **Charts**: base R vs ggplot2, bar charts, line charts, histograms of returns, labelling and saving figures for reports | Publication-ready plots for coursework |
| 4 | **Quant basics**: simple vs log returns, annualisation, volatility, Sharpe, drawdown, correlation, intro to `quantmod`/`PerformanceAnalytics` | Reproducible summary-stats code you understand line by line |
| 5 | **Reproducible research**: R Markdown/Quarto reports, functions, debugging, reading errors, asking good questions with `sessionInfo()` | A small end-to-end analysis report you can extend in your master's |

Each session is hands-on in your own RStudio: you type, I explain *why*. You also get short exercises between sessions and a written recap.

## License

MIT. See [LICENSE](LICENSE).
