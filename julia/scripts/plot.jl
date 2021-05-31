using CSV
using DataFrames
using Gadfly
using Cairo
using Fontconfig

include("./utils.jl")


# Read the data from CSV as a dataframe
data = CSV.File(joinpath(OUTPUT_DIR, "$(getos()).csv")) |> DataFrame

# Transform the dataframe for the plot
data = stack(data, [:Time, :Error, :Space])
data = rename(data, :variable => :Measure, :value => :Value)

# Generate the plot
const p = Gadfly.plot(
    data,
    Geom.point,
    Geom.line,
    Scale.x_log10,
    Scale.y_log10,
    Theme(; background_color="white");
    x=:N,
    y=:Value,
    color=:Measure
)

# Save the plot
draw(PNG(joinpath(OUTPUT_DIR, "$(getos()).png"), 15cm, 9cm; dpi=300), p)
