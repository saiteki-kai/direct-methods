using CSV
using DataFrames
using Gadfly
using Cairo
using Fontconfig

include("config.jl")


const filename = joinpath(outputdir, "data.csv")
print(filename)
data = DataFrame(CSV.File(filename))

# Transform the dataframe for the plot
data = stack(data, [:Time, :Error, :Space])
data = rename(data, :variable => :Measure, :value => :Value)

const p = Gadfly.plot(
    data,
    x = :N,
    y = :Value,
    color = :Measure,
    Geom.point,
    Geom.line,
    Scale.x_log10,
    Scale.y_log10,
    Theme(background_color = "white"),
)

draw(PNG(joinpath(outputdir, "plot.png"), 15cm, 9cm; dpi = 300), p)
