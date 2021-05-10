const datadir = joinpath(pwd(), "..", "data", "matrix_market")

const os = lowercase(string(Sys.KERNEL))
const outputdir = joinpath(pwd(), "output", os)
