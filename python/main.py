import os
import time
import platform
import psutil


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
    try:
        factor = cholesky(A)
        x = factor(b)
    except CholmodNotPositiveDefiniteError:
        print('not positive matrix')
        x = spsolve(A, b).reshape([N, 1])
    end = time.time()

    elapsed = end - start
    error = norm(x - e) / norm(e)
    process = psutil.Process(os.getpid())
    memory = process.memory_full_info().uss

    return N, error, elapsed, memory

def main():
    cwd = os.getcwd()
    curr_os = platform.system().lower()
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
    df.to_csv(output_path)

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

def mem_test():
    N = 3
    a = np.random.rand(N*2**27)
    process = psutil.Process(os.getpid())
    memory = process.memory_full_info().uss
    print("memory: {} bytes".format(memory))


if __name__ == "__main__":
    main()
