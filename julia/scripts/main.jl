using MatrixMarket
using DataFrames
using CSV

include("./config.jl")
include("../src/DirectMethod.jl")


const data = DataFrame(; N=Int64[], Time=Float64[], Error=Float64[], Space=Int64[])

foreach(readdir(DATA_DIR)) do filename
    print("Loading $filename... \n")
    A, t, m = @timed MatrixMarket.mmread(joinpath(DATA_DIR, filename))
    print("Loaded $filename [$t seconds, $m bytes] \n")

    T = solvematrix(A)
    push!(data, T)

    print("$T \n\n")
end

CSV.write(joinpath(OUTPUT_DIR, "data.csv"), data)
