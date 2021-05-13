# Julia

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

| Package       | Version |
|:--------------|:-------:|
| MatrixMarket  |  0.3.1  |
| DataFrames    |  1.1.1  |
| CSV           |  0.8.4  |
| Gadfly        |  1.3.3  |
| Fontconfig    |  0.4.0  |
| Cairo         |  1.0.5  |

## Install Packages

```bash
julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"
```

## Execution

Compute the measures and save them in a csv file

```bash
julia --project=. scripts/main.jl
```

Generate a plot from the csv and save it as a png file

```bash
julia --project=. scripts/plot.jl
```

## Notes (from [docs.julialang.org](https://docs.julialang.org/))

### Julia Types

Julia's type system is dynamic, but gains some of the advantages of static type systems by making it possible to indicate that certain values are of specific types. This can be of great assistance in generating efficient code, but even more significantly, it allows method dispatch on the types of function arguments to be deeply integrated with the language.

Multiple dispatch together with the flexible parametric type system give Julia its ability to abstractly express high-level algorithms decoupled from implementation details, yet generate efficient, specialized code to handle each case at run time.

### Sparse Arrays

In Julia, sparse matrices are stored in the **Compressed Sparse Column (CSC)** format. Julia sparse matrices have the type SparseMatrixCSC{Tv,Ti}, where Tv is the type of the stored values, and Ti is the integer type for storing column pointers and row indices. The internal representation of SparseMatrixCSC is as follows:

```julia
struct SparseMatrixCSC{Tv,Ti<:Integer} <: AbstractSparseMatrixCSC{Tv,Ti}
    m::Int                  # Number of rows
    n::Int                  # Number of columns
    colptr::Vector{Ti}      # Column j is in colptr[j]:(colptr[j+1]-1)
    rowval::Vector{Ti}      # Row indices of stored values
    nzval::Vector{Tv}       # Stored values, typically nonzeros
end
```

The compressed sparse column storage makes it easy and quick to access the elements in the column of a sparse matrix, whereas accessing the sparse matrix by rows is considerably slower. Operations such as insertion of previously unstored entries one at a time in the CSC structure tend to be slow. This is because all elements of the sparse matrix that are beyond the point of insertion have to be moved one place over.

### Linear Algebra

Linear algebra functions in Julia are largely implemented by calling functions from LAPACK. Sparse matrix factorizations call functions from SuiteSparse. Other sparse solvers are available as Julia packages.

Julia features a rich collection of special matrix types, which allow for fast computation with specialized routines that are specially developed for particular matrix types.
The special matrices hooks to various optimized methods for them in LAPACK.

Julia provides many factorizations which can be used to speed up problems such as linear solve or matrix exponentiation by pre-factorizing a matrix into a form more amenable (for performance or memory reasons) to the problem.

### Dense Matrices

Matrix division using a polyalgorithm. For input matrices A and B, the result X is such that A*X == B when A is square. The solver that is used depends upon the structure of A.

If A is upper or lower triangular (or diagonal), no factorization of A is required and the system is solved with either forward or backward substitution.

For non-triangular square matrices, an LU factorization is used.

For rectangular A the result is the minimum-norm least squares solution computed by a pivoted QR factorization of A and a rank estimate of A based on the R factor.

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

When A is sparse, a similar polyalgorithm is used. For indefinite matrices, the LDLt factorization does not use pivoting during the numerical factorization and therefore the procedure can fail even for invertible matrices.

Sparse matrix solvers call functions from SuiteSparse (CHOLMOD, UMFPACK, SPQR).

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

If factorize is called on a Hermitian positive-definite matrix, for instance, then factorize will return a Cholesky factorization.

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
