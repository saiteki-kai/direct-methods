library(ggplot2)
library(dplyr)

save_plot <- function(data, variable, group, path) {
  ylabel = variable
  if (variable == "Time") {
    ylabel = "Time (s)"
  } else if (variable == "Space") {
    ylabel = "Space (bytes)"
  }

  p <- ggplot(data, aes_string(x = "N", y = variable, color = group)) +
    geom_point() +
    geom_line() +
    scale_x_log10(
      breaks = scales::trans_breaks("log10", function(x) 10 ^ x),
      labels = scales::trans_format("log10", scales::math_format(10 ^ .x))
    ) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10 ^ x),
      labels = scales::trans_format("log10", scales::math_format(10 ^ .x))
    ) +
    annotation_logticks(sides = "trbl") +
    xlab("NNZ") +
    ylab(ylabel)

  filename <- file.path(path, paste0(variable, ".png"))

  ggsave(filename,
    plot = p,
    device = "png",
    height = 4,
    width = 8,
    units = "in"
  )
}

save_plot_all <- function(data, group, path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)

  for (v in c("Time", "Error", "Space")) {
    if (v %in% names(data)) {
      save_plot(data, v, group, path)
    }
  }
}

nnz <- c(430909, 2012833, 1679599, 28715634, 3599932, 20207907, 7660826)

# Languages Comparison
for (lang in c("julia", "matlab", "python", "R")) {
  path <- file.path("..", lang, "output")

  pathL <- file.path(path, "linux.csv")
  pathW <- file.path(path, "windows.csv")

  if (file.exists(pathL) && file.exists(pathW)) {
    dataL <- read.csv(pathL)
    dataW <- read.csv(pathW)

    dataL$OS <- "linux"
    dataW$OS <- "windows"

    # switch N to nnz
    dataL$N <- nnz
    dataW$N <- nnz

    data <- rbind(dataL, dataW)

    save_plot_all(data, "OS", file.path("results", "lang", lang))
  } else {
    print("missing plots")
  }
}

# OS Comparison
for (os in c("linux", "windows")) {
  data <- NULL
  for (lang in c("julia", "matlab", "python", "R")) {
    path <- file.path("..", lang, "output", paste0(os, ".csv"))

    if (file.exists(path)) {
      csv <- read.csv(path)
      csv$lang = lang
      
      # switch N to nnz
      csv$N <- nnz

      data <- dplyr::bind_rows(data, csv)
    }
  }
  save_plot_all(data, "lang", file.path("results", "os", os))
}
