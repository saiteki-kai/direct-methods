library(ggplot2)

save_plot <- function(data, variable, path) {
  p <- ggplot(data, aes_string(x = "N", y = variable, color = "OS")) +
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
    annotation_logticks(sides = "trbl")

  filename <- file.path(path, paste0(variable, ".png"))

  ggsave(filename,
    plot = p,
    device = "png",
    height = 6.67,
    width = 13.34
  )
}

save_plot_all <- function(data, path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)

  for (v in c("Time", "Error", "Space")) {
    if (v %in% names(data)) {
      save_plot(data, v, path)
    }
  }
}

for (lang in c("julia", "matlab", "python", "R")) {
  path <- file.path("..", lang, "output")

  pathL <- file.path(path, "linux.csv")
  pathW <- file.path(path, "windows.csv")

  if (file.exists(pathL) && file.exists(pathW)) {
    dataL <- read.csv(pathL)
    dataW <- read.csv(pathW)

    dataL$OS <- "linux"
    dataW$OS <- "windows"

    data <- rbind(dataL, dataW)

    save_plot_all(data, lang)
  } else {
    print("missing plots")
  }
}
