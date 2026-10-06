# quant_starter.R
# R / RStudio starter for quantitative research:
# environment check -> data frames -> bar charts -> simple returns & summary stats
#
# Run in RStudio: open the .Rproj or this file, then Ctrl/Cmd + Shift + Enter (Source).
# Or in a terminal, from the repo root:   Rscript R/quant_starter.R

# Make paths work whether run from the repo root or from R/
if (!file.exists("data/prices.csv") && file.exists("../data/prices.csv")) setwd("..")
source("R/00_setup_packages.R")
dir.create("output", showWarnings = FALSE)

# ----------------------------------------------------------------------------
# 0. Environment & packages
# ----------------------------------------------------------------------------
report_environment()
pkg_ok <- ensure_packages(c("ggplot2"))     # set upgrade_old = TRUE after an R upgrade
has_ggplot <- isTRUE(pkg_ok[["ggplot2"]])
# Set FORCE_BASE_PLOT=1 to try the base-R fallback even when ggplot2 works.
if (Sys.getenv("FORCE_BASE_PLOT") == "1") has_ggplot <- FALSE

# ----------------------------------------------------------------------------
# 1. Data frame basics
# ----------------------------------------------------------------------------
# Build one by hand ...
portfolio <- data.frame(
  ticker = c("ALPHA", "BETA", "GAMMA"),
  sector = c("Tech", "Energy", "Utilities"),
  weight = c(0.5, 0.3, 0.2),
  stringsAsFactors = FALSE
)
str(portfolio)                                   # column types
portfolio$weight_pct <- portfolio$weight * 100   # add a column
print(portfolio[portfolio$weight > 0.25, ])      # filter rows
print(portfolio[order(-portfolio$weight), c("ticker", "weight")])   # sort + select

# ... or read one from CSV (bundled sample data, fictional tickers)
prices <- read.csv("data/prices.csv", stringsAsFactors = FALSE)
prices$date <- as.Date(prices$date)
cat("\nRows:", nrow(prices), " Columns:", ncol(prices), "\n")
print(head(prices))
print(table(prices$ticker))

# ----------------------------------------------------------------------------
# 2. Simple returns, per ticker
#    r_t = P_t / P_{t-1} - 1      (log returns: log(P_t / P_{t-1}))
# ----------------------------------------------------------------------------
prices <- prices[order(prices$ticker, prices$date), ]
prices$ret <- ave(prices$close, prices$ticker,
                  FUN = function(p) c(NA, p[-1] / p[-length(p)] - 1))
prices$log_ret <- ave(prices$close, prices$ticker,
                      FUN = function(p) c(NA, diff(log(p))))

# ----------------------------------------------------------------------------
# 3. Summary statistics table
# ----------------------------------------------------------------------------
summarise_ticker <- function(d) {
  r <- na.omit(d$ret)
  data.frame(
    ticker        = d$ticker[1],
    n_days        = length(r),
    mean_daily    = mean(r),
    sd_daily      = sd(r),
    ann_return    = mean(r) * 252,          # simple annualisation
    ann_vol       = sd(r) * sqrt(252),
    sharpe_rf0    = (mean(r) / sd(r)) * sqrt(252),
    total_return  = d$close[nrow(d)] / d$close[1] - 1,
    max_drawdown  = min(d$close / cummax(d$close) - 1)
  )
}
stats <- do.call(rbind, lapply(split(prices, prices$ticker), summarise_ticker))
rownames(stats) <- NULL
cat("\nSummary statistics (daily simple returns):\n")
print(format(stats, digits = 3), row.names = FALSE)
write.csv(stats, "output/summary_stats.csv", row.names = FALSE)

# Correlation matrix of returns (wide format first)
wide <- reshape(prices[, c("date", "ticker", "ret")],
                idvar = "date", timevar = "ticker", direction = "wide")
cat("\nCorrelation of daily returns:\n")
print(round(cor(wide[, -1], use = "complete.obs"), 2))

# ----------------------------------------------------------------------------
# 4. Bar chart: total return per ticker
#    ggplot2 if available, otherwise base R barplot() -- same information.
# ----------------------------------------------------------------------------
plot_total_returns <- function(stats, file = "output/total_return_bar.png") {
  if (has_ggplot) {
    p <- ggplot2::ggplot(stats, ggplot2::aes(x = ticker, y = total_return * 100,
                                             fill = total_return > 0)) +
      ggplot2::geom_col(width = 0.6, show.legend = FALSE) +
      ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f%%", total_return * 100)),
                         vjust = ifelse(stats$total_return > 0, -0.4, 1.3)) +
      ggplot2::scale_fill_manual(values = c(`TRUE` = "#2E7D32", `FALSE` = "#C62828")) +
      ggplot2::labs(title = "Total return over the sample", x = NULL, y = "Return (%)") +
      ggplot2::theme_minimal(base_size = 13)
    ggplot2::ggsave(file, p, width = 6, height = 4, dpi = 120)
    if (interactive()) print(p)    # shows in the RStudio Plots pane
    cat("Saved (ggplot2):", file, "\n")
  } else {
    png(file, width = 720, height = 480)
    cols <- ifelse(stats$total_return > 0, "#2E7D32", "#C62828")
    bp <- barplot(stats$total_return * 100, names.arg = stats$ticker, col = cols,
                  main = "Total return over the sample", ylab = "Return (%)",
                  ylim = range(0, stats$total_return * 100) * 1.25)
    text(bp, stats$total_return * 100, sprintf("%.1f%%", stats$total_return * 100),
         pos = ifelse(stats$total_return > 0, 3, 1))
    abline(h = 0)
    invisible(dev.off())
    cat("Saved (base R fallback):", file, "\n")
  }
}
plot_total_returns(stats)

# Bonus: price lines (base R works everywhere, no packages needed)
png("output/prices_base.png", width = 720, height = 480)
tick <- unique(prices$ticker)
idx  <- lapply(split(prices, prices$ticker), function(d) 100 * d$close / d$close[1])
matplot(sort(unique(prices$date)), do.call(cbind, idx), type = "l", lty = 1, lwd = 2,
        col = 1:3, xlab = "", ylab = "Index (start = 100)", main = "Rebased prices")
legend("topleft", legend = tick, col = 1:3, lwd = 2, bty = "n")
invisible(dev.off())

# ----------------------------------------------------------------------------
# 5. Session info -- paste this when asking for help
# ----------------------------------------------------------------------------
cat("\n")
print(sessionInfo())
