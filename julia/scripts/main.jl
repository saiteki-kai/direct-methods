using Printf
using MatrixMarket
using DataFrames
using CSV

include("./config.jl")
include("../src/DirectMethod.jl")


const data = DataFrame(;
    N=Int64[],
    Time=Float64[],
    Error=Float64[],
    Space=Int64[],
)

foreach(readdir(datadir)) do filename
    @printf("Loading %s...\n", filename)
    A, t = @timed MatrixMarket.mmread(joinpath(datadir, filename))
    @printf("Loaded %s [%f seconds]\n", filename, t)

    T = solvematrix(A)
    push!(data, T)

    @printf("%s\n\n", T)
end

CSV.write(joinpath(outputdir, "data.csv"), data)
