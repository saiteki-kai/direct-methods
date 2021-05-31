if (!require("pacman")) install.packages("pacman")
pacman::p_load(Matrix, microbenchmark)

library(Matrix)
library(microbenchmark)

path=""
file <- c("G3_circuit/G3_circuit.mtx","GT01R/GT01R.mtx",
        "Hook_1498/Hook_1498.mtx", "ifiss_mat/ifiss_mat.mtx",
        "nd24k/nd24k.mtx", "ns3Da/ns3Da.mtx", "TSC_OPF_1047/TSC_OPF_1047.mtx")

r_time <- c()
r_error <- c()

for(var in file)
{
  a <- readMM(paste(path,"ns3Da/ns3Da.mtx", sep = ""))
  xe <- rep(1,nrow(a))
  xe<-t(t(xe))
  b <- a%*%xe
  a<-chol(a)
  time <- microbenchmark(x <- solve(a,b,sparse=FALSE),times = 1)
  time<-(as.numeric(time))[2]/1000000 # per andare a milli secondi
  error <- norm(x-xe)/norm(xe)
  
  r_time <- c(r_time, c(time))
  r_error <- c(r_error, c(error))
}

df <- data.frame(file, r_time, r_error)
write.csv(df, "output/output.csv")