using CSV
using DataFrames
using Gadfly
using Cairo
using Fontconfig


function plot(data::DataFrame, variable)
    p = Gadfly.plot(
        data,
        Geom.point,
        Geom.line,
        Scale.x_log10,
        Scale.y_log10,
        Theme(; background_color="white");
        x=:N,
        y=variable,
        color=:OS
    )

    draw(PNG(joinpath(pwd(), "output", "comparison", "$variable.png"), 15cm, 9cm; dpi=300), p)
end

# TODO: change paths

data1 = CSV.File(joinpath(pwd(), "output", "linux.csv")) |> DataFrame
data2 = CSV.File(joinpath(pwd(), "output", "windows.csv")) |> DataFrame

data = vcat(data1, data2, source=:OS => ["linux", "windows"])

plot(data, :Time)
plot(data, :Space)
plot(data, :Error)
