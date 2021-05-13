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

## Notes

Multiple dispatch together with the flexible parametric type system give Julia its ability to abstractly express high-level algorithms decoupled from implementation details, yet generate efficient, specialized code to handle each case at run time.

If A is upper or lower triangular (or diagonal), no factorization of A is required and the system is solved with either forward or backward substitution.

For non-triangular square matrices, an LU factorization is used.

### Dense Matrices

[source](https://github.com/JuliaLang/julia/blob/6aaedecc447e3d8226d5027fb13d0c3cbfbfea2a/stdlib/LinearAlgebra/src/generic.jl#L1122-L1139)

```julia
function (\)(A::AbstractMatrix, B::AbstractVecOrMat)
    require_one_based_indexing(A, B)
    m, n = size(A)
    if m == n
        if istril(A)
            if istriu(A)
                return Diagonal(A) \ B
            else
                return LowerTriangular(A) \ B
            end
        end
        if istriu(A)
            return UpperTriangular(A) \ B
        end
        return lu(A) \ B
    end
    return qr(A,Val(true)) \ B
end
```

### Sparse Matrices

[source](https://github.com/JuliaLang/julia/blob/248c02f531948a1b66bdd887906d3746fd1ccc2b/stdlib/SparseArrays/src/linalg.jl#L1538-L1558)

```julia
function \(A::AbstractSparseMatrixCSC, B::AbstractVecOrMat)
    require_one_based_indexing(A, B)
    m, n = size(A)
    if m == n
        if istril(A)
            if istriu(A)
                return \(Diagonal(Vector(diag(A))), B)
            else
                return \(LowerTriangular(A), B)
            end
        elseif istriu(A)
            return \(UpperTriangular(A), B)
        end
        if ishermitian(A)
            return \(Hermitian(A), B)
        end
        return \(lu(A), B)
    else
        return \(qr(A), B)
    end
end
```

### Hermitian Matrices

[source](https://github.com/JuliaLang/julia/blob/bb5b98e72a151c41471d8cc14cacb495d647fb7f/stdlib/LinearAlgebra/src/symmetric.jl#L655)

```julia
\(A::HermOrSym{<:Any,<:StridedMatrix}, B::AbstractVector) = \(factorize(A), B)
```

[source](https://github.com/JuliaLang/julia/blob/248c02f531948a1b66bdd887906d3746fd1ccc2b/stdlib/SparseArrays/src/linalg.jl#L1616-L1624)

```julia
function factorize(A::LinearAlgebra.RealHermSymComplexHerm{Float64,<:AbstractSparseMatrixCSC})
    F = cholesky(A; check = false)
    if LinearAlgebra.issuccess(F)
        return F
    else
        ldlt!(F, A)
        return F
    end
end
```
