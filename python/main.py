import os
import time
import psutil
import platform

# import tracemalloc

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
    # tracemalloc.start()

    try:
        factor = cholesky(A)
        x = factor(b)
    except CholmodNotPositiveDefiniteError:
        print("not positive matrix")
        x = spsolve(A, b).reshape([N, 1])

    end = time.time()
    elapsed = end - start
    error = norm(x - e) / norm(e)

    memory = psutil.virtual_memory().used + psutil.swap_memory().used

    # current, peak = tracemalloc.get_traced_memory()
    # snapshot = tracemalloc.take_snapshot()
    # for stat in snapshot.statistics("lineno"):
    #    print(stat)
    # tracemalloc.stop()

    return N, error, elapsed, memory


def main():
    cwd = os.getcwd()
    curr_os = platform.system().lower()  # os.uname()[0].lower()
    data_dir = os.path.join(cwd, "..", "data", "matrix_market")

    data = []
    for f in sorted(os.listdir(data_dir)):
        filename = os.path.join(data_dir, f)

        print(f"Loading {f}...")
        A = mmread(filename).tocsc()
        print("Loaded.")

        N, error, time, space = solve(A)
        print({"N": N, "Time": time, "Error": error, "Space": space})

        data.append({"N": N, "Time": time, "Error": error, "Space": space})

    df = pd.DataFrame(data)
    output_path = os.path.join("output", "{}.csv".format(curr_os))
    df.to_csv(output_path, index = False)


def test():
    cwd = os.getcwd()
    data_dir = os.path.join(cwd, "..", "data", "matrix_market")
    f = "7_Hook_1498.mtx"
    filename = os.path.join(data_dir, f)

    print(f"Loading {f}...")
    A = mmread(filename).tocsc()
    print("Loaded.")

    N, error, time, space = solve(A)
    print({"N": N, "Time": time, "Error": error, "Space": space})


if __name__ == "__main__":
    main()
