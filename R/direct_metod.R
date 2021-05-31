if (!require("pacman")) install.packages("pacman")
pacman::p_load(Matrix, microbenchmark, profmem)

library(Matrix)
library(microbenchmark)
library(profmem)

path <- file.path("..","data","matrix_market")
file <- c("0_GT01R.mtx","1_TSC_OPF_1047.mtx","2_ns3Da.mtx","3_nd24k.mtx",
          "4_ifiss_mat.mtx", "5_bundle_adj.mtx","6_G3_circuit.mtx")

r_time <- c()
r_error <- c()
r_ram <- c()

for(var in file)
{
  ram<-profmem({
  a <- readMM(file.path(path,var))
  xe <- rep(1,nrow(a))
  xe<-t(t(xe))
  b <- a%*%xe
  time <- microbenchmark(x <- solve(a,b),times = 1)
  time<-(as.numeric(time))[2]/1000000 # per andare a milli secondi
  error <- norm(x-xe)/norm(xe)
  })
  ram <- sum(ram[[2]])
  
  r_time <- c(r_time, c(time))
  r_error <- c(r_error, c(error))
  r_ram <- c(r_ram, c(ram))
}

df <- data.frame(file, r_time, r_error, r_ram)
if(.Platform$OS.typ == "windows")
{
  write.csv(df, file.path("output","windows.csv"))
} else {
  write.csv(df, file.path("output","linux.csv"))
}