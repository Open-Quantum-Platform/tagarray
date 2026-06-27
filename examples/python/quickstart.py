"""tagarray Python quickstart (requires `pip install .` from the repo root)."""
import numpy as np
import tagarray

c = tagarray.Container("python-quickstart")
c["vec"] = np.asfortranarray([1.0, 2.0, 3.0])   # store
print("PY  : vec =", np.asarray(c["vec"].data))  # read back (zero-copy view)
