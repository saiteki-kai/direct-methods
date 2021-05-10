# Julia

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Install packages

```bash
julia --project -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"
```

## Execution

Compute the measures and save them in a csv file

```bash
julia --project scripts/main.jl
```

Generate a plot from the csv and save it as a png file

```bash
julia --project scripts/plot.jl
```
