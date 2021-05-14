import os
import time
import tracemalloc

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import scipy
from scipy.io.mmio import mmread
from scipy.linalg import norm
from scipy.sparse.linalg import spsolve, eigs, eigsh
from sksparse.cholmod import cholesky, CholmodNotPositiveDefiniteError


def solve(A):
    N = A.shape[0]
    e = np.ones([N, 1])
    b = A.dot(e)

    start = time.time()
    tracemalloc.start()

    try:
        factor = cholesky(A)
        x = factor(b)
    except CholmodNotPositiveDefiniteError:
        print('not positive matrix')
        x = spsolve(A, b).reshape([N, 1])

    end = time.time()
    elapsed = end - start
    error = norm(x - e) / norm(e)

    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    return N, error, elapsed, peak


def main():
    cwd = os.getcwd()
    data_dir = os.path.join(cwd, "..", "data", "matrix_market")

    data = []
    for f in sorted(os.listdir(data_dir)):
        filename = os.path.join(data_dir, f)

        print(f"Loading {f}...")
        A = mmread(filename).tocsr()
        print("Loaded.")

        N, error, elapsed, memory = solve(A)
        print({"N": N, "time": elapsed, "error": error, "memory": memory})

        data.append({"N": N, "time": elapsed, "error": error, "memory": memory})

    df = pd.DataFrame(data)
    df = df.melt(["N"], ["error", "time", "memory"])
    df.to_csv('./python_results.csv')

    sns.set_style("darkgrid")
    grid = sns.lineplot(x="N", y="value", data=df, hue="variable")
    grid.set(xscale="log", yscale="log")
    plt.savefig("plt.svg")
    plt.show()



if __name__ == "__main__":
    main()
