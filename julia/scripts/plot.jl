using CSV
using DataFrames
using Gadfly
using Cairo
using Fontconfig

include("./config.jl")


# Read the data from CSV as a dataframe
data = CSV.File(joinpath(outputdir, "data.csv")) |> DataFrame

# Transform the dataframe for the plot
data = stack(data, [:Time, :Error, :Space])
data = rename(data, :variable => :Measure, :value => :Value)

# Generate the plot
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

# Save the plot
draw(PNG(joinpath(outputdir, "plot.png"), 15cm, 9cm; dpi = 300), p)
