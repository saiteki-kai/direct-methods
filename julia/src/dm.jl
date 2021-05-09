using LinearAlgebra
using SparseArrays


BLAS.set_num_threads(1)

function solvematrix(A::SparseMatrixCSC)
    N = size(A, 1)
    e = ones(N, 1)
    b = A * e

    x, time, space = @timed A \ b
    error = norm(x - e) / norm(e)

    return (N, time, error, space)
end
