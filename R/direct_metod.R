if (!require("pacman")) install.packages("pacman")
pacman::p_load(Matrix, profmem)

library(Matrix)
library(profmem)

path <- file.path("..", "data", "matrix_market")
#"3_nd24k.mtx"
names <- c( 
  "0_GT01R.mtx", "1_TSC_OPF_1047.mtx", "2_ns3Da.mtx",
  "4_ifiss_mat.mtx", "5_bundle_adj.mtx", "6_G3_circuit.mtx"
)

r_n <- c()
r_time <- c()
r_error <- c()
r_ram <- c()

for (filename in names) {
  a <- readMM(file.path(path, filename))

  N <- nrow(a)
  xe <- rep(1, N)
  xe <- t(t(xe))
  b <- a %*% xe

  start_time <- Sys.time()
  ram <- profmem({
    x <- solve(a, b)
  })
  time <- Sys.time() - start_time

  ram <- sum(ram$bytes, na.rm = TRUE)
  error <- norm(x - xe) / norm(xe)

  r_n <- c(r_n, c(N))
  r_time <- c(r_time, c(time))
  r_error <- c(r_error, c(error))
  r_ram <- c(r_ram, c(ram))

  print(paste("N:", N, "Time:", time, "Error:", error, "Space:", ram))
}

df <- data.frame(N = r_n, Time = r_time, Error = r_error, Space = r_ram)

if (.Platform$OS.typ == "windows") {
  write.csv(df, file.path("output", "windows.csv"), row.names = FALSE)
} else {
  write.csv(df, file.path("output", "linux.csv"), row.names = FALSE)
}
