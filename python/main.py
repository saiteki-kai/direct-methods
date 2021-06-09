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
    print("not positive matrix")
    x = spsolve(A, b).reshape([N, 1])

  end = time.time()
  memory = psutil.Process().memory_info().rss

  elapsed = end - start
  error = norm(x - e) / norm(e)

  return N, error, elapsed, memory


def main():
    cwd = os.getcwd()
    curr_os = platform.system().lower()
    process = psutil.Process(os.getpid())
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

def mem_test():
  N = 6
  #tracemalloc.start()
  a = np.random.rand(N*2**27)
  """
  snapshot = tracemalloc.take_snapshot()
  top_stats = snapshot.statistics('lineno')
  print('[Top 10]')
  for stat in top_stats[:10]:
    print(stat)
  _, peak = tracemalloc.get_traced_memory()
  #tracemalloc.reset_peak()
  tracemalloc.stop()
  print(peak)
  """

"""
memory_start = psutil.Process().memory_full_info().uss
a = np.random.rand(N*2**27)
memory_end = psutil.Process().memory_full_info().uss
print("memory-start: {} bytes".format(memory_start))
print("memory-end: {} bytes".format(memory_end))
print("memory: {} bytes".format(memory_end - memory_start))"""


if __name__ == "__main__":
    main()
