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

cwd = os.getcwd()
curr_os = platform.system().lower()
data_dir = os.path.join(cwd, "..", "data", "matrix_market")

def solve(A):
  N = A.shape[0]
  e = np.ones([N, 1])
  b = A.dot(e)

  start = time.time()

  try:
    factor = cholesky(A)
    x = factor(b)
  except CholmodNotPositiveDefiniteError:
    print("not positive matrix")
    x = spsolve(A, b).reshape([N, 1])

  end = time.time()
  space = psutil.Process().memory_info().rss

  elapsed = end - start
  error = norm(x - e) / norm(e)

  return N, error, elapsed, space

def main():
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
  f = "2_ns3Da.mtx"
  filename = os.path.join(data_dir, f)

  print(f"Loading {f}...")
  A = mmread(filename).tocsc()
  print("Loaded.")

  N, error, time, space = solve(A)
  print({"N": N, "Time": time, "Error": error, "Space": space})


if __name__ == "__main__":
    main()
