library(ggplot2)
library(dplyr)

save_plot <- function(data, variable, group, path) {
  ylabel <- variable
  if (variable == "Time") {
    ylabel <- "Time (s)"
  } else if (variable == "Space") {
    ylabel <- "Space (bytes)"
  }

  p <- ggplot(data, aes_string(x = "N", y = variable, color = group, fill = group)) +
    geom_line() +
    geom_point(shape = (data$P) + 15) +
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

info <- data.frame(
  n = c(7980, 8140, 20414, 72000, 96307, 513351, 1585478),
  nnz = c(430909, 2012833, 1679599, 28715634, 3599932, 20207907, 7660826),
  isposdef = c(FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, TRUE)
)

# Languages Comparison
for (lang in c("julia", "matlab", "python", "R")) {
  print(paste("lang:", lang))

  path <- file.path("..", lang, "output")

  pathL <- file.path(path, "linux.csv")
  pathW <- file.path(path, "windows.csv")

  if (file.exists(pathL) && file.exists(pathW)) {
    dataL <- read.csv(pathL)
    dataW <- read.csv(pathW)

    dataL$OS <- "linux"
    dataW$OS <- "windows"

    idxL <- info$n %in% dataL$N
    idxW <- info$n %in% dataW$N

    # switch N to nnz
    dataL$N <- info$nnz[idxL]
    dataW$N <- info$nnz[idxW]

    # mark if positive definite 
    dataL$P <- info$isposdef[idxL]
    dataW$P <- info$isposdef[idxW]

    data <- rbind(dataL, dataW)

    save_plot_all(data, "OS", file.path("results", "lang", lang))
  } else {
    print("missing plots")
  }
}

# OS Comparison
for (os in c("linux", "windows")) {
  print(paste("OS:", os))

  data <- NULL
  for (lang in c("julia", "matlab", "python", "R")) {
    path <- file.path("..", lang, "output", paste0(os, ".csv"))

    if (file.exists(path)) {
      csv <- read.csv(path)
      csv$lang <- lang

      idx <- info$n %in% csv$N
      csv$N <- info$nnz[idx] # switch N to nnz
      csv$P <- info$isposdef[idx] # mark if positive definite 

      data <- dplyr::bind_rows(data, csv)
    }
  }
  save_plot_all(data, "lang", file.path("results", "os", os))
}
