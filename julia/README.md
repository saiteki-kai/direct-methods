# Julia

## Install packages

```bash
julia --project -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"
```

## Execution

Compute Measures

```bash
julia --project scripts/main.jl
```

Generate Plot

```bash
julia --project scripts/plot.jl
```
